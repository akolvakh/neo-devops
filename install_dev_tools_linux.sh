#!/bin/bash

set -e
export DEBIAN_FRONTEND=noninteractive

SCRIPT_LOG="install_dev_tools_linux.log"
touch $SCRIPT_LOG

MESSAGE() {
    local timeAndDate
    timeAndDate=$(date '+%Y-%m-%dT%H:%M:%S')
    local message="$timeAndDate [$1] $2"
    echo "$message" | tee -a "$SCRIPT_LOG"
}

# Перевірка чи запущено на Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    MESSAGE ERROR "Цей скрипт призначений для Linux (Ubuntu/Debian). Поточна ОС: $OSTYPE"
    exit 1
fi

# Перевірка чи це Ubuntu або Debian
if ! command -v apt &> /dev/null; then
    MESSAGE ERROR "Цей скрипт потребує пакетного менеджера apt (Ubuntu/Debian)"
    exit 1
fi

MESSAGE INFO "Початок встановлення на $(lsb_release -d -s 2>/dev/null || echo "системі Linux")"

# Оновлення списку пакетів
MESSAGE INFO "Оновлення списків пакетів..."
sudo apt update -y

# Встановлення Docker:

if ! command -v docker &> /dev/null; then
    MESSAGE INFO "Встановлення Docker..."
    
    # Встановлення необхідних компонентів
    sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Додавання офіційного GPG ключа Docker
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
    
    # Налаштування стабільного репозиторію
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
      https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    
    # Оновлення apt та встановлення Docker
    sudo apt update -y
    sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    
    # Додавання користувача до групи docker
    sudo usermod -aG docker $USER
    
    # Запуск та увімкнення служби Docker
    sudo systemctl start docker
    sudo systemctl enable docker
    
    dockerVersion=$(docker --version)
    MESSAGE INFO "Docker встановлено: $dockerVersion"
    MESSAGE INFO "Примітка: Можливо, потрібно вийти з системи та увійти знову для використання Docker без sudo"
else
    dockerVersion=$(docker --version)
    MESSAGE INFO "Docker вже встановлено: $dockerVersion"
fi

# Встановлення Docker Compose (окремо):

if ! command -v docker-compose &> /dev/null; then
    MESSAGE INFO "Встановлення Docker Compose (окремо)..."
    
    # Отримання останньої версії
    dockerComposeVersion=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep '"tag_name":' | sed -E 's/.*"v?([^"]+)".*/\1/')
    MESSAGE INFO "Встановлення Docker Compose версії $dockerComposeVersion"
    
    # Завантаження та встановлення
    sudo curl -L "https://github.com/docker/compose/releases/download/v${dockerComposeVersion}/docker-compose-$(uname -s)-$(uname -m)" \
      -o /usr/local/bin/docker-compose
    
    # Надання прав на виконання
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Створення символічного посилання для docker compose (стиль v2)
    sudo ln -sf /usr/local/bin/docker-compose /usr/local/bin/docker-compose
    
    MESSAGE INFO "Docker Compose версії $dockerComposeVersion встановлено"
else
    dockerComposeVersion=$(docker-compose --version)
    MESSAGE INFO "$dockerComposeVersion вже встановлено"
fi

# Встановлення Python:

if command -v python3 &> /dev/null; then
    pythonVersion=$(python3 -V 2>&1 | awk '{print $2}')
    # Перевірка чи версія Python 3.9 або вища
    if [[ "$(printf '%s\n' "3.9" "$pythonVersion" | sort -V | head -n1)" == "3.9" ]]; then
        MESSAGE INFO "Python $pythonVersion вже встановлено"
    else
        MESSAGE WARNING "Встановлена версія Python ($pythonVersion) старша за 3.9, встановлення новішої версії..."
        sudo apt install -y python3 python3-pip python3-venv python3-dev
        pythonVersion=$(python3 -V 2>&1 | awk '{print $2}')
        MESSAGE INFO "Python оновлено до версії $pythonVersion"
    fi
else
    MESSAGE INFO "Python не встановлено, встановлення..."
    sudo apt install -y python3 python3-pip python3-venv python3-dev
    pythonVersion=$(python3 -V 2>&1 | awk '{print $2}')
    MESSAGE INFO "Python $pythonVersion встановлено"
fi

# Перевірка встановлення PIP:

if command -v pip3 &> /dev/null; then
    pipVersion=$(pip3 --version)
    MESSAGE INFO "PIP доступний: $pipVersion"
else
    MESSAGE INFO "PIP недоступний, встановлення..."
    sudo apt install -y python3-pip
    pipVersion=$(pip3 --version)
    MESSAGE INFO "PIP встановлено: $pipVersion"
fi

# Встановлення Django:

if python3 -c "import django; print(django.get_version())" &> /dev/null 2>&1; then
    djangoVersion=$(python3 -c "import django; print(django.get_version())")
    MESSAGE INFO "Django $djangoVersion вже встановлено"
else
    MESSAGE INFO "Django не встановлено, встановлення..."
    
    # Встановлення Django через pip (рекомендований метод)
    pip3 install --user django
    
    # Додавання локального bin користувача до PATH якщо ще не додано
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
        export PATH="$HOME/.local/bin:$PATH"
    fi
    
    djangoVersion=$(python3 -c "import django; print(django.get_version())" 2>/dev/null || echo "встановлено")
    MESSAGE INFO "Django $djangoVersion встановлено через pip"
fi

# Додаткові корисні пакети для розробки
MESSAGE INFO "Встановлення додаткових пакетів для розробки..."
sudo apt install -y git curl wget vim nano htop tree unzip

MESSAGE INFO "Встановлення успішно завершено!"
MESSAGE INFO ""
MESSAGE INFO "=== ВАЖЛИВІ НОТАТКИ ==="
MESSAGE INFO "1. Вийдіть з системи та увійдіть знову для використання Docker без sudo"
MESSAGE INFO "2. Або виконайте 'newgrp docker' для активації групи Docker в поточній сесії"
MESSAGE INFO "3. Перевірте встановлення наступними командами:"
MESSAGE INFO "   - docker --version"
MESSAGE INFO "   - docker-compose --version"
MESSAGE INFO "   - python3 --version"
MESSAGE INFO "   - pip3 --version"
MESSAGE INFO "   - python3 -c 'import django; print(django.get_version())'"
MESSAGE INFO ""
MESSAGE INFO "=== ТЕСТУВАННЯ DOCKER ==="
MESSAGE INFO "Після повторного входу протестуйте Docker командою: docker run hello-world"
