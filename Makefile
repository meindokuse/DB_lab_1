.PHONY: help up down restart schema data test migrate reset psql demo demo-auto local-init local-test local-migrate demo-local

# По умолчанию выводим справку
help:
	@echo "Доступные команды:"
	@echo "  --- Работа в Docker ---"
	@echo "  make up            - Запустить PostgreSQL в контейнере"
	@echo "  make down          - Остановить контейнер"
	@echo "  make schema        - Применить schema.sql (создать таблицы)"
	@echo "  make data          - Загрузить data.sql (тестовые данные)"
	@echo "  make test          - Запустить constraints_test.sql (проверка 16 ограничений)"
	@echo "  make migrate       - Применить migration.sql (миграция DDL)"
	@echo "  make reset         - Пересоздать базу и загрузить данные (схема + данные + миграция)"
	@echo "  make psql          - Открыть интерактивную консоль psql в контейнере"
	@echo "  make demo          - Запустить пошаговую интерактивную демонстрацию"
	@echo "  make demo-auto     - Запустить демонстрацию без пауз"
	@echo ""
	@echo "  --- Работа локально (без Docker) ---"
	@echo "  make local-init    - Создать базу delivery_db и накатить schema.sql + data.sql"
	@echo "  make local-test    - Запустить проверку ограничений через локальный psql"
	@echo "  make local-migrate - Применить миграцию через локальный psql"
	@echo "  make demo-local    - Запустить демонстрацию через локальный psql"

# --- Docker команды ---
up:
	docker compose up -d

down:
	docker compose down

restart: down up

schema:
	docker exec -i delivery_db psql -U postgres -d delivery_db < schema.sql

data:
	docker exec -i delivery_db psql -U postgres -d delivery_db < data.sql

test:
	-docker exec -i delivery_db psql -U postgres -d delivery_db < constraints_test.sql

migrate:
	docker exec -i delivery_db psql -U postgres -d delivery_db < migration.sql

reset: schema data migrate
	@echo "База данных успешно пересоздана и наполнена данными."

psql:
	docker exec -it delivery_db psql -U postgres -d delivery_db

demo:
	./demo.sh --docker

demo-auto:
	./demo.sh --docker --auto

# --- Локальные команды (без Docker) ---
local-init:
	-createdb -h localhost -U postgres delivery_db
	psql -h localhost -U postgres -d delivery_db -f schema.sql
	psql -h localhost -U postgres -d delivery_db -f data.sql
	@echo "Локальная база успешно инициализирована."

local-test:
	-psql -h localhost -U postgres -d delivery_db -f constraints_test.sql

local-migrate:
	psql -h localhost -U postgres -d delivery_db -f migration.sql

demo-local:
	./demo.sh --local
