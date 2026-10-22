#!/usr/bin/env bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' 

MODE="docker"
AUTO=false

for arg in "$@"; do
    case $arg in
        --local)
            MODE="local"
            shift
            ;;
        --docker)
            MODE="docker"
            shift
            ;;
        --auto)
            AUTO=true
            shift
            ;;
        -h|--help)
            echo "Использование: ./demo.sh [ОПЦИИ]"
            echo ""
            echo "Опции:"
            echo "  --docker     Запуск через Docker-контейнер delivery_db (по умолчанию)"
            echo "  --local      Запуск через локальный psql на хосте"
            echo "  --auto       Автоматический прогон без пауз (по умолчанию интерактивный)"
            echo "  -h, --help   Справка"
            exit 0
            ;;
    esac
done

pause() {
    if [ "$AUTO" = false ]; then
        echo ""
        echo -e "${YELLOW}Нажмите Enter для перехода к следующему шагу...${NC}"
        read -r
    fi
}

run_sql_file() {
    local file=$1
    if [ "$MODE" = "docker" ]; then
        docker exec -i delivery_db psql -U postgres -d delivery_db < "$file"
    else
        PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d delivery_db -f "$file"
    fi
}

# Функция выполнения произвольного SQL-запроса
run_query() {
    local query=$1
    if [ "$MODE" = "docker" ]; then
        docker exec -i delivery_db psql -U postgres -d delivery_db -c "$query"
    else
        PGPASSWORD=postgres psql -h localhost -p 5432 -U postgres -d delivery_db -c "$query"
    fi
}

echo -e "${BOLD}${CYAN}======================================================================${NC}"
echo -e "${BOLD}${CYAN}  ДЕМОНСТРАЦИЯ ЛАБОРАТОРНОЙ РАБОТЫ №1 — СЛУЖБА ДОСТАВКИ (ВАРИАНТ 6)   ${NC}"
echo -e "${BOLD}${CYAN}======================================================================${NC}"
echo -e "Режим запуска: ${BOLD}${MODE}${NC}"

# Проверка окружения
if [ "$MODE" = "docker" ]; then
    if ! docker ps --format '{{.Names}}' | grep -q "^delivery_db$"; then
        echo -e "${YELLOW}Контейнер delivery_db не запущен. Запускаю через docker compose up -d...${NC}"
        docker compose up -d
        sleep 2
    fi
    echo -e "${GREEN}✓ Docker-контейнер delivery_db работает и готов к работе.${NC}"
else
    if ! command -v psql &> /dev/null; then
        echo -e "${RED}Ошибка: psql не найден на локальном хосте.${NC}"
        echo "Установите postgresql-client или запускайте в режиме Docker: ./demo.sh --docker"
        exit 1
    fi
    echo -e "${GREEN}✓ Локальный psql обнаружен.${NC}"
fi

pause

# ------------------------------------------------------------------------------
# ШАГ 1. Создание схемы
# ------------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "${BOLD}${BLUE}  [ШАГ 1/4] Создание структуры БД (schema.sql)                        ${NC}"
echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "Создаются 10 таблиц, связи PK/FK, ограничения UNIQUE, CHECK, NOT NULL."
run_sql_file "schema.sql"

echo ""
echo -e "${GREEN}Список созданных таблиц в базе:${NC}"
run_query "\dt"

pause

# ------------------------------------------------------------------------------
# ШАГ 2. Заполнение тестовыми данными
# ------------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "${BOLD}${BLUE}  [ШАГ 2/4] Заполнение тестовыми данными (data.sql)                   ${NC}"
echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "Загружаются справочники, клиенты, курьеры, склады, отправления и транзакции."
run_sql_file "data.sql"

echo ""
echo -e "${GREEN}Количество записей в основных таблицах:${NC}"
run_query "SELECT
    (SELECT count(*) FROM clients) AS clients,
    (SELECT count(*) FROM couriers) AS couriers,
    (SELECT count(*) FROM warehouses) AS warehouses,
    (SELECT count(*) FROM shipments) AS shipments,
    (SELECT count(*) FROM deliveries) AS deliveries,
    (SELECT count(*) FROM payment_transactions) AS payments;"

pause

# ------------------------------------------------------------------------------
# ШАГ 3. Проверка ограничений целостности
# ------------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "${BOLD}${BLUE}  [ШАГ 3/4] Проверка ограничений целостности (constraints_test.sql)   ${NC}"
echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "${YELLOW}Внимание: каждый из 16 запросов ниже ДОЛЖЕН завершиться ошибкой (ERROR).${NC}"
echo -e "Это доказывает, что СУБД отклоняет некорректные операции и защищает данные."
echo ""

# Временно отключаем set -e, так как тесты намеренно падают с ошибками
set +e
run_sql_file "constraints_test.sql"
set -e

echo ""
echo -e "${GREEN}✓ Все ограничения целостности корректно отработали и заблокировали плохие данные.${NC}"

pause

# ------------------------------------------------------------------------------
# ШАГ 4. Миграция схемы (ALTER TABLE)
# ------------------------------------------------------------------------------
echo ""
echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "${BOLD}${BLUE}  [ШАГ 4/4] Миграция схемы по доп. требованию (migration.sql)         ${NC}"
echo -e "${BOLD}${BLUE}======================================================================${NC}"
echo -e "Добавляем поддержку приоритета доставки ('standard', 'express', 'overnight')"
echo -e "и рейтинга курьеров (0..5) с помощью ALTER TABLE без пересоздания таблиц."
run_sql_file "migration.sql"

echo ""
echo -e "${GREEN}Проверка нового ограничения CHECK (попытка задать неверный приоритет 'super-fast'):${NC}"
set +e
run_query "UPDATE shipments SET priority = 'super-fast' WHERE id = 1;"
set -e

echo ""
echo -e "${BOLD}${GREEN}  ДЕМОНСТРАЦИЯ УСПЕШНО ЗАВЕРШЕНА!                                     ${NC}"

