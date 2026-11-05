#!/bin/sh
# Start JDownloader 2 headless, controlled via MyJDownloader.
#
# JDownloader is not part of the image: JDownloader.jar is downloaded into
# /opt/JDownloader on the first start and updates itself there. JDownloader
# restarts itself after an update; the loop below restarts it inside the
# container, so Kubernetes does not recreate the container and lose the
# update (endless update loop, see jaymoulin/docker-jdownloader#82).
# Mount /opt/JDownloader as a volume to keep JDownloader and its updates
# across container recreations (e.g. `docker run --rm`, pod rescheduling).
set -eu

JD_DIR="/opt/JDownloader"
SHARE_DIR="/usr/local/share/jdownloader"
SETTINGS="${JD_DIR}/cfg/org.jdownloader.api.myjdownloader.MyJDownloaderSettings.json"

mkdir -p "${JD_DIR}/cfg" "${JD_DIR}/logs" "${JD_DIR}/libs" "${JD_DIR}/Downloads"

# Archive extraction library (sevenzipjbinding), also into an empty volume
for lib in "${SHARE_DIR}"/libs/*.jar; do
  [ -f "${JD_DIR}/libs/$(basename "$lib")" ] || cp "$lib" "${JD_DIR}/libs/"
done

[ -f "$SETTINGS" ] || cp "${SHARE_DIR}/myjdownloader-settings.json.dist" "$SETTINGS"

# Set one key of the MyJDownloader settings (jq cannot edit in place)
set_setting() {
  tmp="${SETTINGS}.tmp"
  jq --arg v "$2" ".$1 = \$v" "$SETTINGS" >"$tmp" && mv "$tmp" "$SETTINGS"
}

# Login from the environment (otherwise configure it in the settings file)
if [ -n "${MYJD_USER:-}" ] && [ -n "${MYJD_PASSWORD:-}" ]; then
  set_setting email "$MYJD_USER"
  set_setting password "$MYJD_PASSWORD"
fi
# Device name shown in MyJDownloader
if [ -n "${MYJD_DEVICE_NAME:-}" ]; then
  set_setting devicename "$MYJD_DEVICE_NAME"
fi

# Debugging helper: with this file in the download folder the container
# keeps running without JDownloader, so you can exec into it
if [ -f "${JD_DIR}/Downloads/jdownloader-block.txt" ]; then
  echo "jdownloader-block.txt found, not starting JDownloader"
  exec sleep infinity
fi

# Remove a broken JDownloader.jar (e.g. an interrupted download)
if [ -f "${JD_DIR}/JDownloader.jar" ] && ! unzip -l "${JD_DIR}/JDownloader.jar" >/dev/null 2>&1; then
  echo "JDownloader.jar is broken, removing it"
  rm -f "${JD_DIR}/JDownloader.jar"
fi

# Finish an interrupted self-update
if [ ! -f "${JD_DIR}/JDownloader.jar" ] && [ -f "${JD_DIR}/tmp/update/self/JDU/JDownloader.jar" ]; then
  cp "${JD_DIR}/tmp/update/self/JDU/JDownloader.jar" "${JD_DIR}/"
fi

# First start: download JDownloader
if [ ! -f "${JD_DIR}/JDownloader.jar" ]; then
  echo "Downloading JDownloader.jar"
  curl -fsSL --retry 30 --retry-delay 10 --retry-connrefused --connect-timeout 15 \
    -o "${JD_DIR}/JDownloader.jar.tmp" "https://installer.jdownloader.org/JDownloader.jar"
  mv "${JD_DIR}/JDownloader.jar.tmp" "${JD_DIR}/JDownloader.jar"
fi

# umask, octal (e.g. 0002)
if [ -n "${UMASK:-}" ]; then
  if echo "$UMASK" | grep -Eq '^0[0-7]{3}$'; then
    echo "Setting umask to ${UMASK}"
    umask "$UMASK"
  else
    echo "Ignoring invalid UMASK '${UMASK}' (expected e.g. 0002)"
  fi
fi

# Forward stop signals to JDownloader and stop the restart loop
running=1
pid=""
stop() {
  running=0
  [ -n "$pid" ] && kill -TERM "$pid" 2>/dev/null || true
}
trap stop TERM INT

cd "$JD_DIR"
while [ "$running" -eq 1 ]; do
  # VMARGS: additional JVM arguments, e.g. "-Xmx1g"
  # shellcheck disable=SC2086 # VMARGS is a list of arguments
  java -Djava.awt.headless=true -Dsun.jnu.encoding=UTF-8 -Dfile.encoding=UTF-8 \
    ${VMARGS:-} -jar "${JD_DIR}/JDownloader.jar" &
  pid=$!
  # wait returns early when a signal arrives; wait again for the exit
  wait "$pid" || true
  wait "$pid" 2>/dev/null || true
  pid=""
  if [ "$running" -eq 1 ]; then
    echo "JDownloader exited, restarting in 5 seconds"
    sleep 5
  fi
done
echo "JDownloader stopped"
