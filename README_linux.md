# Скрипт встановлення інструментів розробки (Linux - Ubuntu/Debian)

Цей скрипт забезпечує автоматизоване встановлення основних інструментів розробки на системах Ubuntu та Debian-based Linux.

## Огляд

Скрипт `install_dev_tools_linux.sh` автоматизує встановлення Docker, Docker Compose, Python 3, PIP, Django та додаткових інструментів розробки. Він розроблений як ідемпотентний і може бути запущений кілька разів безпечно.

## Особливості

- **Оптимізація для Linux**: Спеціально розроблений для систем Ubuntu/Debian з використанням пакетного менеджера apt
- **Комплексне встановлення**: Встановлює Docker, Docker Compose, Python 3.9+, PIP, Django та інструменти розробки
- **Перевірка версій**: Виявляє існуючі встановлення та пропускає, якщо відповідні версії присутні
- **Керування сервісами**: Правильно запускає та вмикає службу Docker
- **Права користувача**: Додає користувача до групи docker для використання Docker без root
- **Детальне журналювання**: Всі операції записуються у `install_dev_tools_linux.log`
- **Обробка помилок**: Надійна обробка помилок з негайним виходом при невдачі

## Prerequisites

- Ubuntu 18.04+ or Debian 10+
- Sudo privileges
- Internet connection
- `apt` package manager

## Usage

### Basic Usage

1. Make the script executable:
```bash
chmod +x install_dev_tools_linux.sh
```

2. Run the script:
```bash
./install_dev_tools_linux.sh
```

### What the Script Installs

1. **Docker CE (Community Edition)**:
   - Adds official Docker GPG key
   - Configures Docker repository
   - Installs Docker CE, CLI, containerd, buildx, and compose plugins
   - Starts and enables Docker service
   - Adds current user to docker group

2. **Docker Compose (Standalone)**:
   - Downloads latest version from GitHub releases
   - Installs to `/usr/local/bin/docker-compose`
   - Sets executable permissions
   - Creates symbolic link for compatibility

3. **Python 3.9+**:
   - Installs Python 3 interpreter
   - Includes pip, venv, and development headers
   - Upgrades if older version detected

4. **PIP (Python Package Installer)**:
   - Python 3 package manager
   - User-level package installations

5. **Django**:
   - Latest stable version via pip
   - User-level installation (recommended)
   - Adds local bin directory to PATH

6. **Additional Development Tools**:
   - git, curl, wget
   - vim, nano (text editors)
   - htop, tree (system utilities)
   - unzip (archive utility)

## Script Behavior

### System Compatibility Check
- Verifies Linux operating system
- Confirms apt package manager availability
- Displays system information at start

### Installation Process
1. Updates package lists
2. Installs each tool with dependency resolution
3. Configures services and permissions
4. Provides post-installation instructions

### Logging System
Creates `install_dev_tools_linux.log` with:
- Timestamped entries
- Installation status (INFO, WARNING, ERROR)
- Version information
- Error details

## Output Example

```
2024-01-15T10:30:15 [INFO] Starting installation on Ubuntu 22.04.3 LTS
2024-01-15T10:30:16 [INFO] Updating package lists...
2024-01-15T10:30:45 [INFO] Installing Docker...
2024-01-15T10:33:22 [INFO] Docker installed: Docker version 24.0.7, build afdd53b
2024-01-15T10:33:23 [INFO] Installing Docker Compose (standalone)...
2024-01-15T10:33:45 [INFO] Docker Compose version 2.21.0 installed
2024-01-15T10:33:46 [INFO] Python 3.10.6 is already installed
2024-01-15T10:33:47 [INFO] PIP is available: pip 22.0.2 from /usr/lib/python3/dist-packages/pip
2024-01-15T10:33:55 [INFO] Django 4.2.7 installed via pip
2024-01-15T10:34:12 [INFO] Installation completed successfully!
```

## Post-Installation Steps

### 1. Docker Permissions
**Log out and log back in** to activate docker group membership, or run:
```bash
newgrp docker
```

### 2. Verify Installations
```bash
# Check versions
docker --version
docker-compose --version
python3 --version
pip3 --version
python3 -c "import django; print(django.get_version())"

# Test Docker
docker run hello-world
```

### 3. Optional PATH Configuration
The script automatically adds `~/.local/bin` to your PATH for Django management commands. Restart your terminal or run:
```bash
source ~/.bashrc
```

## Troubleshooting

### Common Issues

1. **Docker Permission Denied**:
   ```bash
   # Solution 1: Re-login
   logout
   # Then log back in
   
   # Solution 2: Activate group in current session
   newgrp docker
   ```

2. **Package Installation Failures**:
   ```bash
   # Update system first
   sudo apt update && sudo apt upgrade -y
   
   # Fix broken packages
   sudo apt --fix-broken install
   ```

3. **Python Version Issues**:
   - Script automatically handles Python version upgrades
   - Ensures Python 3.9+ compatibility
   - Check with: `python3 --version`

4. **Django Import Errors**:
   ```bash
   # Verify Django installation
   python3 -c "import sys; print('\n'.join(sys.path))"
   
   # Reinstall if needed
   pip3 install --user --force-reinstall django
   ```

5. **Docker Service Issues**:
   ```bash
   # Check Docker service status
   sudo systemctl status docker
   
   # Start Docker service manually
   sudo systemctl start docker
   ```

### Log Analysis
```bash
# View full log
cat install_dev_tools_linux.log

# Check for errors
grep ERROR install_dev_tools_linux.log

# View recent entries
tail -20 install_dev_tools_linux.log
```

## Security Considerations

- **GPG Key Verification**: Docker GPG key verified before installation
- **Official Repositories**: Uses official Docker and GitHub repositories
- **User-Level Packages**: Django installed at user level (not system-wide)
- **Service Security**: Docker service properly configured and secured
- **No Root Usage**: After setup, Docker commands don't require sudo

## Advanced Usage

### Custom Python Virtual Environment
```bash
# Create virtual environment for Django projects
python3 -m venv myproject_env
source myproject_env/bin/activate
pip install django
```

### Docker Compose Usage
```bash
# Create a simple docker-compose.yml
cat > docker-compose.yml << EOF
version: '3.8'
services:
  web:
    image: nginx:alpine
    ports:
      - "8080:80"
EOF

# Run with Docker Compose
docker-compose up -d
```