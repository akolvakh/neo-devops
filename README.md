# Django додаток з Docker Compose

Цей проєкт демонструє розгортання Django веб-додатку за допомогою Docker Compose з PostgreSQL базою даних та Nginx як реверс-прокс серверу.

## Структура проєкту

```
l-4/
├── README.md                # Ця документація
├── docker-compose.yml      # Конфігурація Docker Compose
├── .env                     # Змінні оточення
├── .gitignore              # Git ignore файл
├── settings.py             # Додаткові налаштування Django
├── django/                 # Django додаток
│   ├── Dockerfile          # Docker образ для Django
│   ├── requirements.txt    # Python залежності
│   ├── manage.py           # Django management скрипт
│   └── app/                # Основний Django проєкт
│       ├── settings.py     # Налаштування Django
│       ├── urls.py         # URL маршрути
│       └── wsgi.py         # WSGI конфігурація
└── nginx/                  # Nginx конфігурація
    └── nginx.conf          # Конфігурація реверс-прокс
```

## Архітектура

Проєкт складається з трьох основних сервісів:

### 1. **Django** (Веб-додаток)
- Базується на Python 3.10-slim
- Запускається на порту 8000
- Підключається до PostgreSQL бази даних
- Монтує код для розробки

### 2. **PostgreSQL** (База даних)
- Використовує офіційний образ PostgreSQL 14
- Зберігає дані в Docker volume
- Доступна на порту 5432

### 3. **Nginx** (Реверс-прокс)
- Проксує запити до Django додатку
- Слухає на порту 80
- Налаштований для обробки статичних файлів

## Передумови

Переконайтеся, що у вас встановлено:
- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

## Швидкий старт

### 1. Клонування та налаштування

```bash
# Перейдіть до папки проєкту
cd /path/to/goit/devops/akolvakh/l-4

# Перевірте наявність .env файлу
cat .env
```

### 2. Запуск додатку

```bash
# Збірка та запуск всіх сервісів
docker-compose up --build

# Або запуск в фоновому режимі
docker-compose up -d --build
```

### 3. Перевірка роботи

- **Django додаток**: http://localhost:8000
- **Через Nginx**: http://localhost:80
- **PostgreSQL**: localhost:5432

## Налаштування оточення

Файл `.env` містить змінні оточення:

```env
POSTGRES_PORT=5432
POSTGRES_HOST=db
POSTGRES_USER=postgres
POSTGRES_DB=postgres
POSTGRES_PASSWORD=postgres
```

### Налаштування для продакшну

Для продакшну змініть:
1. **Паролі бази даних** - використовуйте сильні паролі
2. **SECRET_KEY** - згенеруйте новий секретний ключ
3. **DEBUG** - встановіть в `False`
4. **ALLOWED_HOSTS** - додайте ваші домени

## Корисні команди

### Docker Compose команди

```bash
# Запуск сервісів
docker-compose up -d

# Зупинка сервісів
docker-compose down

# Перегляд логів
docker-compose logs -f

# Перегляд статусу сервісів
docker-compose ps

# Перебудова образів
docker-compose build --no-cache
```

### Django команди

```bash
# Виконання команд Django
docker-compose exec django python manage.py migrate
docker-compose exec django python manage.py createsuperuser
docker-compose exec django python manage.py collectstatic

# Доступ до Django shell
docker-compose exec django python manage.py shell

# Доступ до контейнера
docker-compose exec django bash
```

### База даних

```bash
# Підключення до PostgreSQL
docker-compose exec db psql -U postgres -d postgres

# Бекап бази даних
docker-compose exec db pg_dump -U postgres postgres > backup.sql

# Відновлення бази даних
docker-compose exec -T db psql -U postgres postgres < backup.sql
```

## Розробка

### Локальна розробка

Код Django додатку монтується як volume, тому зміни відразу відображаються:

```bash
# Після зміни коду перезапустіть Django сервіс
docker-compose restart django

# Або перезапустіть з логами
docker-compose up django
```

### Додавання нових пакетів

1. Додайте пакет до `django/requirements.txt`
2. Перебудуйте образ:
   ```bash
   docker-compose build django
   docker-compose up -d
   ```

### Міграції

```bash
# Створення міграцій
docker-compose exec django python manage.py makemigrations

# Застосування міграцій
docker-compose exec django python manage.py migrate
```

## Nginx конфігурація

Поточна конфігурація Nginx (`nginx/nginx.conf`):

```nginx
server {
    listen 80;
    location / {
        proxy_pass http://django:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

### Для продакшну додайте:
- SSL сертифікати
- Обробку статичних файлів
- Стискання
- Кешування

## Усунення проблем

### Поширені проблеми

1. **Порти зайняті**:
   ```bash
   # Перевірте зайняті порти
   netstat -tulpn | grep :80
   netstat -tulpn | grep :5432
   
   # Змініть порти в docker-compose.yml
   ```

2. **База даних недоступна**:
   ```bash
   # Перевірте логи PostgreSQL
   docker-compose logs db
   
   # Перезапустіть базу даних
   docker-compose restart db
   ```

3. **Django помилки**:
   ```bash
   # Перегляньте логи Django
   docker-compose logs django
   
   # Перевірте підключення до БД
   docker-compose exec django python manage.py dbshell
   ```

### Очищення

```bash
# Зупинка та видалення контейнерів
docker-compose down

# Видалення volumes (УВАГА: видалить дані БД!)
docker-compose down -v

# Очищення невикористаних образів
docker system prune
```

## Безпека

### Рекомендації для продакшну:

1. **Змінні оточення**:
   - Не зберігайте секрети в коді
   - Використовуйте Docker secrets або зовнішні сховища

2. **Django налаштування**:
   - `DEBUG = False`
   - Сильний `SECRET_KEY`
   - Правильні `ALLOWED_HOSTS`

3. **База даних**:
   - Сильні паролі
   - Обмеження доступу по мережі
   - Регулярні бекапи

4. **Nginx**:
   - SSL/TLS сертифікати
   - Приховування версій серверу
   - Rate limiting

## Моніторинг

### Логи

```bash
# Всі сервіси
docker-compose logs -f

# Конкретний сервіс
docker-compose logs -f django
docker-compose logs -f db
docker-compose logs -f nginx
```

### Метрики

```bash
# Використання ресурсів
docker-compose top

# Статистика контейнерів
docker stats
```

## Внесок у розвиток

1. Створіть feature branch
2. Внесіть зміни
3. Протестуйте локально
4. Створіть Pull Request

## Ліцензія

Цей проєкт використовується для навчальних цілей.