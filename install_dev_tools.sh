#!/bin/bash

set -e

SCRIPT_LOG="install_dev_tools.log"
touch $SCRIPT_LOG

MESSAGE() {
    local timeAndDate
    timeAndDate=$(date '+%Y-%m-%dT%H:%M:%S')
    local message="$timeAndDate [$1] $2"
    echo "$message" | tee -a "$SCRIPT_LOG"
}

# Перевірка чи запущено на macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    MESSAGE ERROR "Цей скрипт призначений для macOS. Поточна ОС: $OSTYPE"
    exit 1
fi

# Встановлення Homebrew якщо відсутній
if ! command -v brew &> /dev/null; then
    MESSAGE INFO "Встановлення Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    # Додавання brew до PATH для поточної сесії
    eval "$(/opt/homebrew/bin/brew shellenv)" 2>/dev/null || eval "$(/usr/local/bin/brew shellenv)" 2>/dev/null
    MESSAGE INFO "Homebrew успішно встановлено"
else
    MESSAGE INFO "Homebrew вже встановлено"
    # Спроба оновлення, але без помилки якщо не вдається
    MESSAGE INFO "Спроба оновлення Homebrew..."
    brew update 2>/dev/null || MESSAGE WARNING "Оновлення Homebrew не вдалося, продовжуємо..."
fi

# Встановлення Docker:

if ! command -v docker &> /dev/null; then
    MESSAGE INFO "Встановлення Docker..."
    brew install --cask docker
    MESSAGE INFO "Docker встановлено. Запустіть Docker Desktop з папки Програми"
    MESSAGE INFO "Примітка: Docker Desktop потрібно запустити вручну на macOS"
else
    dockerVersion=$(docker --version 2>/dev/null || echo "Docker встановлено але не запущено")
    MESSAGE INFO "Docker вже встановлено: $dockerVersion"
fi

# Встановлення Docker Compose:

if ! command -v docker-compose &> /dev/null; then
    MESSAGE INFO "Встановлення Docker Compose..."
    brew install docker-compose
    dockerComposeVersion=$(docker-compose --version)
    MESSAGE INFO "Docker Compose встановлено: $dockerComposeVersion"
else
    dockerComposeVersion=$(docker-compose --version)
    MESSAGE INFO "$dockerComposeVersion вже встановлено"
fi

# Встановлення Python:

# Отримання фактичного виконувача Python 3, який ми будемо використовувати
PYTHON_CMD=$(command -v python3)

if command -v python3 &> /dev/null; then
    pythonVersion=$(python3 -V 2>&1 | awk '{print $2}')
    if [[ "$(printf '%s\n' "3.9" "$pythonVersion" | sort -V | head -n1)" == "3.9" ]]; then
        MESSAGE INFO "Python $pythonVersion вже встановлено"
    else
        MESSAGE WARNING "Встановлена версія Python ($pythonVersion) старша за 3.9, оновлення..."
        brew install python
        # Оновлення команди Python до нової інсталяції
        PYTHON_CMD=$(command -v python3)
        pythonVersion=$(python3 -V 2>&1 | awk '{print $2}')
        MESSAGE INFO "Python оновлено до версії $pythonVersion"
    fi
else
    MESSAGE INFO "Python не встановлено, встановлення..."
    brew install python
    PYTHON_CMD=$(command -v python3)
    pythonVersion=$(python3 -V 2>&1 | awk '{print $2}')
    MESSAGE INFO "Python $pythonVersion встановлено"
fi

# Перевірка встановлення PIP (входить до складу Python на macOS/Homebrew):
# Використання тієї ж версії Python для pip
PIP_CMD="${PYTHON_CMD} -m pip"

if $PYTHON_CMD -m pip --version &> /dev/null; then
    pipVersion=$($PIP_CMD --version)
    MESSAGE INFO "PIP доступний: $pipVersion"
else
    MESSAGE INFO "PIP недоступний, спроба встановлення..."
    $PYTHON_CMD -m ensurepip --upgrade 2>/dev/null || MESSAGE WARNING "Не вдалося встановити pip через ensurepip"
fi

# Встановлення Django:
# Використання тієї ж версії Python, що була перевірена вище
if $PYTHON_CMD -c "import django; print('Django', django.get_version())" &> /dev/null; then
    djangoVersion=$($PYTHON_CMD -c "import django; print(django.get_version())")
    MESSAGE INFO "Django $djangoVersion вже встановлено для Python $pythonVersion"
else
    MESSAGE INFO "Django не встановлено для Python $pythonVersion, встановлення..."
    
    # Спроба встановлення Django - обробка externally-managed-environment
    if $PIP_CMD install django &> /dev/null; then
        MESSAGE INFO "Django успішно встановлено через pip"
    else
        MESSAGE WARNING "Неможливо встановити Django через pip (externally-managed environment)"
        MESSAGE INFO "Спроба альтернативних методів встановлення..."
        
        # Перевірка доступності pipx або спроба встановлення
        if ! command -v pipx &> /dev/null; then
            MESSAGE INFO "Встановлення pipx для управління віртуальними середовищами..."
            if brew install pipx 2>/dev/null; then
                MESSAGE INFO "pipx успішно встановлено"
            else
                MESSAGE WARNING "Не вдалося встановити pipx через Homebrew"
            fi
        fi
        
        # Спроба встановлення Django через pipx якщо доступний
        if command -v pipx &> /dev/null; then
            if pipx install django 2>/dev/null; then
                MESSAGE INFO "Django встановлено через pipx (доступний як команда django-admin)"
            else
                MESSAGE WARNING "Встановлення Django через pipx не вдалося"
            fi
        fi
    fi
    
    # Перевірка встановлення різними методами
    if $PYTHON_CMD -c "import django; print('Django', django.get_version())" &> /dev/null; then
        djangoVersion=$($PYTHON_CMD -c "import django; print(django.get_version())")
        MESSAGE INFO "Django $djangoVersion успішно встановлено для Python $pythonVersion"
    elif command -v django-admin &> /dev/null; then
        djangoVersion=$(django-admin --version 2>/dev/null || echo "встановлено через pipx")
        MESSAGE INFO "Django $djangoVersion доступний через команду django-admin"
    else
        MESSAGE WARNING "Встановлення Django потребує ручного налаштування"
        MESSAGE INFO "Рекомендований підхід для розробки:"
        MESSAGE INFO "  1. Створити віртуальне середовище: $PYTHON_CMD -m venv myproject"
        MESSAGE INFO "  2. Активувати: source myproject/bin/activate"
        MESSAGE INFO "  3. Встановити Django: pip install django"
    fi
fi

MESSAGE INFO "Встановлення завершено! Зверніть увагу:"
MESSAGE INFO "1. Запустіть Docker Desktop з папки Програми"
MESSAGE INFO "2. Виконувач Python: $PYTHON_CMD"
MESSAGE INFO "3. Перевірте встановлення командами:"
MESSAGE INFO "   - docker --version"
MESSAGE INFO "   - docker-compose --version" 
MESSAGE INFO "   - $PYTHON_CMD --version"
MESSAGE INFO "   - $PYTHON_CMD -m pip --version"
MESSAGE INFO ""
MESSAGE INFO "Для розробки Django:"
if $PYTHON_CMD -c "import django" &> /dev/null; then
    MESSAGE INFO "   - $PYTHON_CMD -c 'import django; print(\"Django\", django.get_version())'"
elif command -v django-admin &> /dev/null; then
    MESSAGE INFO "   - django-admin --version"
else
    MESSAGE INFO "   - Створити віртуальне середовище: $PYTHON_CMD -m venv myproject"
    MESSAGE INFO "   - Активувати: source myproject/bin/activate"
    MESSAGE INFO "   - Встановити Django: pip install django"
fi
MESSAGE INFO ""
MESSAGE INFO "Якщо у вас декілька версій Python, завжди використовуйте: $PYTHON_CMD"
