# ansible

Ansible automation container with Kerberos and Windows (WinRM) support.

## Features

- **Ansible 13.1.0** (latest stable)
- **Kerberos Support** for authentication
- **WinRM Support** for Windows automation
- **Multi-Architecture** support (amd64, arm64)
- **Non-root user** (ansible)
- Based on Ubuntu 24.04 LTS

## Usage

### Run Ansible Playbook

```bash
# Mount your playbooks and inventory
docker run -it --rm \
  -v $(pwd)/playbooks:/playbooks \
  -v $(pwd)/inventory:/inventory \
  ghcr.io/tuxpeople/ansible:latest \
  ansible-playbook -i /inventory/hosts /playbooks/site.yml
```

### Interactive Shell

```bash
docker run -it --rm \
  -v $(pwd):/workspace \
  ghcr.io/tuxpeople/ansible:latest \
  /bin/bash
```

### Run ad-hoc Command

```bash
docker run -it --rm \
  -v $(pwd)/inventory:/inventory \
  ghcr.io/tuxpeople/ansible:latest \
  ansible all -i /inventory/hosts -m ping
```

## Installed Packages

- `ansible` - Automation framework
- `virtualenv` - Python virtual environments
- `pywinrm` - Windows Remote Management
- `krb5-user` - Kerberos authentication tools

## Configuration

### Kerberos Configuration

Mount your Kerberos config:

```bash
docker run -it --rm \
  -v /etc/krb5.conf:/etc/krb5.conf:ro \
  ghcr.io/tuxpeople/ansible:latest
```

### SSH Keys

Mount your SSH keys for host authentication:

```bash
docker run -it --rm \
  -v ~/.ssh:/home/ansible/.ssh:ro \
  ghcr.io/tuxpeople/ansible:latest
```

## Examples

### Basic Playbook Execution

```bash
docker run -it --rm \
  -v $(pwd):/ansible \
  -w /ansible \
  ghcr.io/tuxpeople/ansible:latest \
  ansible-playbook playbook.yml
```

### With Vault Password

```bash
docker run -it --rm \
  -v $(pwd):/ansible \
  -w /ansible \
  -e ANSIBLE_VAULT_PASSWORD_FILE=/ansible/.vault_pass \
  ghcr.io/tuxpeople/ansible:latest \
  ansible-playbook playbook.yml
```

## Image Tags

- `latest` - Latest stable release
- `X.Y.Z` - Specific version
- `X.Y` - Minor version (floating)
- `X` - Major version (floating)
- `main` - Latest build from main branch
- `nightly` - Nightly build

## Security

- Runs as non-root user `ansible` (UID 1000)
- No secrets baked into image
- Regular security scans with Trivy
- Signed with Cosign

## Links

- [Ansible Documentation](https://docs.ansible.com/)
- [GitHub Repository](https://github.com/tuxpeople/oci-containers)
- [Image Registry (GHCR)](https://ghcr.io/tuxpeople/ansible)
- [Image Registry (Docker Hub)](https://hub.docker.com/r/tdeutsch/ansible)
