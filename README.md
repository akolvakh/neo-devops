# Скрипти для встановлення інструментів розробки

Цей репозиторій містить bash скрипти для автоматизованого встановлення основних інструментів розробки на різних операційних системах.

## Доступні скрипти

### 1. Версія для macOS (`install_dev_tools.sh`)
- **Цільова система**: macOS (Intel та Apple Silicon)
- **Пакетний менеджер**: Homebrew
- **Інструменти**: Homebrew, Docker Desktop, Docker Compose, Python 3, Django

### 2. Версія для Linux (`install_dev_tools_linux.sh`)
- **Цільова система**: Ubuntu/Debian системи
- **Пакетний менеджер**: apt
- **Інструменти**: Docker CE, Docker Compose, Python 3.9+, Django, утиліти розробки

## Швидкий старт

### Для користувачів macOS:
```bash
chmod +x install_dev_tools.sh
./install_dev_tools.sh
```

### Для користувачів Ubuntu/Debian:
```bash
chmod +x install_dev_tools_linux.sh
./install_dev_tools_linux.sh
```

## Документація

- **Посібник для macOS**: Продовжуйте читати цей README
- **Посібник для Linux**: Дивіться [README_linux.md](README_linux.md) для специфічної документації Ubuntu/Debian

---

# Посібник встановлення для macOS

## Огляд

Скрипт `install_dev_tools.sh` автоматизує встановлення та налаштування основних інструментів розробки, включаючи Homebrew, Docker Desktop, Docker Compose, Python 3, PIP та Django. Він розроблений як ідемпотентний, тобто може бути запущений кілька разів безпечно без виникнення проблем.

## Особливості

- **Автоматизоване встановлення**: Встановлює Homebrew, Docker Desktop, Docker Compose, Python 3, PIP та Django
- **Перевірка версій**: Виявляє існуючі встановлення та пропускає, якщо вже встановлено
- **Журналювання**: Всі операції записуються у `install_dev_tools.log` з часовими мітками
- **Обробка помилок**: Використовує `set -e` для виходу при будь-якій помилці
- **Оптимізація для macOS**: Використовує пакетний менеджер Homebrew для чистих встановлень

## Передумови

- macOS (будь-яка недавня версія)
- Права адміністратора для деяких встановлень
- Інтернет-з'єднання для завантаження пакетів

## Використання

### Базове використання

1. Зробіть скрипт виконуваним:
```bash
chmod +x install_dev_tools.sh
```

2. Запустіть скрипт:
```bash
./install_dev_tools.sh
```

### Що встановлює скрипт

1. **Homebrew**: Відсутній пакетний менеджер для macOS
   - Встановлює, якщо відсутній
   - Оновлює існуюче встановлення

2. **Docker Desktop**: Контейнерна платформа з GUI для macOS
   - Встановлює Docker Desktop через Homebrew cask
   - Включає Docker CLI та Docker Daemon
   - **Примітка**: Потребує ручного запуску з папки Програми

3. **Docker Compose**: Інструмент для визначення багатоконтейнерних додатків
   - Встановлює через Homebrew
   - Працює з Docker Desktop

4. **Python 3**: Мова програмування (версія 3.9 або вища)
   - Використовує встановлення Python через Homebrew
   - Включає пакетний менеджер pip

5. **Django**: Python веб-фреймворк
   - Встановлює через pipx або pip3
   - Остання стабільна версія з PyPI

## Поведінка скрипту

### Система журналювання

Скрипт створює лог файл `install_dev_tools.log`, який містить:
- Часова мітка для кожної операції
- Статус встановлення (INFO, WARNING, ERROR)
- Інформація про версії встановлених інструментів
- Повідомлення про помилки, якщо такі є

### Виявлення версій

Скрипт перевіряє існуючі встановлення:
- **Homebrew**: Використовує `command -v brew`
- **Docker**: Використовує `command -v docker` 
- **Docker Compose**: Використовує `docker-compose --version`
- **Python**: Забезпечує версію 3.9 або вищу використовуючи порівняння версій
- **Django**: Використовує Python import для перевірки доступності Django

### Обробка помилок

- Скрипт негайно завершується при будь-якій помилці (`set -e`)
- Перевіряє сумісність з macOS перед продовженням
- Надає чіткі повідомлення про помилки в лог файлі

## Output Example

```
2024-01-15T10:30:15 [INFO] Installing Homebrew...
2024-01-15T10:32:45 [INFO] Homebrew installed successfully
2024-01-15T10:32:46 [INFO] Installing Docker...
2024-01-15T10:35:12 [INFO] Docker installed. Please start Docker Desktop from Applications folder
2024-01-15T10:35:13 [INFO] Python 3.11.6 is already installed.
2024-01-15T10:35:14 [INFO] PIP is available: pip 23.3.1
2024-01-15T10:35:15 [INFO] Django 4.2.7 installed.
```

## Після встановлення

Після успішного встановлення:

1. **Запустіть Docker Desktop вручну**:
   - Відкрийте папку Програми
   - Двічі клацніть на Docker Desktop
   - Зачекайте, поки Docker запуститься (іконка кита в рядку меню)

2. **Перевірте встановлення**:
   ```bash
   brew --version
   docker --version
   docker-compose --version
   python3 --version
   pip3 --version
   python3 -c "import django; print(django.get_version())"
   ```

3. **Опціонально**: Додайте Homebrew до вашого профілю shell:
   ```bash
   echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
   # або для Intel Mac:
   echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
   ```

## Усунення проблем

### Поширені проблеми

1. **Команди Docker не працюють**:
   - Переконайтеся, що Docker Desktop запущено (іконка кита в рядку меню)
   - Docker Desktop потребує кілька хвилин для початкового запуску

2. **Встановлення Homebrew не вдається**:
   - Переконайтеся, що у вас є Xcode Command Line Tools: `xcode-select --install`
   - Перевірте інтернет-з'єднання

3. **Проблеми з Python/pip**:
   - Homebrew Python включає pip за замовчуванням
   - Використовуйте команди `python3` та `pip3` явно

4. **Проблеми з дозволами**:
   - Деякі операції Homebrew можуть потребувати пароль адміністратора
   - Встановлення Django використовує pip (sudo не потрібен)

### Аналіз логів

Перевірте лог файл для детальної інформації:
```bash
cat install_dev_tools.log
```

## Особливості macOS

- **Apple Silicon (M1/M2)**: Homebrew встановлюється в `/opt/homebrew`
- **Intel Mac**: Homebrew встановлюється в `/usr/local`
- **Docker Desktop**: GUI додаток, а не лише CLI інструменти
- **Sudo не потрібен**: Homebrew правильно керує дозволами
- **Версії Python**: macOS поставляється з системним Python, Homebrew надає новіші версії

## Міркування безпеки

- Скрипт перевіряє сумісність з macOS перед запуском
- Використовує офіційний скрипт встановлення Homebrew
- Docker Desktop завантажується з офіційних Homebrew cask
- Python пакети встановлюються через pip (на рівні користувача, не системи)

## Внесок у розвиток

Для покращення цих скриптів:
1. Протестуйте на різних версіях macOS (для macOS скрипту)
2. Протестуйте на різних версіях Ubuntu/Debian (для Linux скрипту)
3. Додайте підтримку додаткових інструментів
4. Покращте обробку помилок та відновлення
5. Додайте більше детальних опцій журналювання
6. Додайте підтримку інших операційних систем (Windows, CentOS, тощо)

## Структура репозиторію

```
l-3/
├── README.md                    # Цей файл (посібник для macOS)
├── README_linux.md             # Посібник для Linux/Ubuntu/Debian
├── install_dev_tools.sh        # Скрипт встановлення для macOS
└── install_dev_tools_linux.sh  # Скрипт встановлення для Linux
```
