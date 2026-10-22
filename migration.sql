-- Миграция: приоритет доставки и рейтинг курьеров без потери существующих данных

-- 1. Добавляем приоритет доставки в посылки
ALTER TABLE shipments
    ADD COLUMN priority VARCHAR(10) NOT NULL DEFAULT 'standard';

ALTER TABLE shipments
    ADD CONSTRAINT chk_shipments_priority
        CHECK (priority IN ('standard', 'express', 'overnight'));

-- 2. Добавляем рейтинг курьера (от 0 до 5)
ALTER TABLE couriers
    ADD COLUMN rating NUMERIC(3, 2);

ALTER TABLE couriers
    ADD CONSTRAINT chk_couriers_rating
        CHECK (rating IS NULL OR (rating >= 0 AND rating <= 5));

-- Индекс по приоритету
CREATE INDEX IF NOT EXISTS idx_shipments_priority ON shipments (priority);

-- Заполнение новых полей для существующих записей
UPDATE shipments SET priority = 'express' WHERE id IN (2, 4);
UPDATE shipments SET priority = 'overnight' WHERE id IN (7);

UPDATE couriers SET rating = 4.85 WHERE id = 1;
UPDATE couriers SET rating = 4.20 WHERE id = 2;
UPDATE couriers SET rating = 3.95 WHERE id = 3;
UPDATE couriers SET rating = 4.60 WHERE id = 4;

-- Проверка
SELECT id, tracking_number, status_id, priority FROM shipments ORDER BY id;
SELECT id, full_name, vehicle_type_id, is_active, rating FROM couriers ORDER BY id;
