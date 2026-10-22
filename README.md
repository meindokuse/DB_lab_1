# Лабораторная работа №1 — Служба доставки (Вариант 6)

## Предметная область
Система автоматизации работы курьерской службы доставки: управление клиентами, отправлениями, складами, курьерами, доставками и платёжными транзакциями.

Структура БД включает **10 таблиц** (спроектирована в 3НФ), содержит ограничения `UNIQUE`, `CHECK`, составные ограничения, внешние ключи с правилами `ON DELETE RESTRICT` и `ON DELETE CASCADE`.

---

## Быстрый запуск и демонстрация

### Вариант 1: Через Docker (рекомендуемый)

Для запуска нужен только установленный Docker:

```bash
# 1. Запустить БД в контейнере
make up
# (или: docker compose up -d)

# 2. Запустить интерактивную демонстрацию для преподавателя
make demo
# (или: ./demo.sh)

# 3. Остановить контейнер
make down
```

### Вариант 2: Локально (без Docker)

Если в системе установлен PostgreSQL:

```bash
# 1. Создать базу данных (если еще не создана)
createdb -h localhost -U postgres delivery_db

# 2. Запустить демонстрацию
make demo-local
# (или: ./demo.sh --local)
```

Или выполнить скрипты по отдельности:
```bash
psql -h localhost -U postgres -d delivery_db -f schema.sql
psql -h localhost -U postgres -d delivery_db -f data.sql
psql -h localhost -U postgres -d delivery_db -f constraints_test.sql
psql -h localhost -U postgres -d delivery_db -f migration.sql
```

---

## Просмотр базы данных в VS Code

1. Установите расширение **Database Client** (ID: `cweijan.vscode-database-client2`) либо **SQLTools** (`mtxr.sqltools`).
2. В боковой панели выберите подключение к PostgreSQL:
   - **Host**: `localhost`
   - **Port**: `5432`
   - **Database**: `delivery_db`
   - **User / Password**: `postgres` / `postgres`
3. Дважды кликните по любой таблице для просмотра данных или выберите схему `public` $\to$ **Design / ER Diagram** для отображения графической схемы связей.

---

## Состав файлов проекта

| Файл | Описание |
|---|---|
| `schema.sql` | Создание таблиц, связей PK/FK, индексов и ограничений целостности |
| `data.sql` | Первичное наполнение тестовыми данными |
| `constraints_test.sql` | 16 тестов нарушения ограничений (каждый запрос отклоняется СУБД) |
| `migration.sql` | Изменение структуры схемы (`ALTER TABLE` без потери данных) |
| `demo.sh` | Интерактивный bash-скрипт демонстрации (Docker и Local) |
| `Makefile` | Набор быстрых команд управления и запуска |
| `docker-compose.yml` | Конфигурация контейнера PostgreSQL 16 |
| `DEMO_GUIDE.md` | Подробная шпаргалка к сдаче и ответы на частые вопросы преподавателя |
| `.vscode/` | Рекомендации расширений и готовые настройки подключения к БД |
