-- Очистка таблиц перед созданием
DROP TABLE IF EXISTS payment_transactions CASCADE;
DROP TABLE IF EXISTS deliveries CASCADE;
DROP TABLE IF EXISTS shipments CASCADE;
DROP TABLE IF EXISTS warehouses CASCADE;
DROP TABLE IF EXISTS couriers CASCADE;
DROP TABLE IF EXISTS clients CASCADE;
DROP TABLE IF EXISTS payment_methods CASCADE;
DROP TABLE IF EXISTS vehicle_types CASCADE;
DROP TABLE IF EXISTS status_payment CASCADE;
DROP TABLE IF EXISTS status_shipments CASCADE;

-- Справочник типов транспорта
CREATE TABLE vehicle_types (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_vehicle_types_name UNIQUE (name)
);

-- Статусы отправления
CREATE TABLE status_shipments (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_status_shipments_name UNIQUE (name)
);

-- Статусы платежей
CREATE TABLE status_payment (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_status_payment_name UNIQUE (name)
);

-- Способы оплаты
CREATE TABLE payment_methods (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    CONSTRAINT uq_payment_methods_name UNIQUE (name)
);

-- Клиенты
CREATE TABLE clients (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    email VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT uq_clients_email UNIQUE (email)
);

-- Курьеры
CREATE TABLE couriers (
    id BIGSERIAL PRIMARY KEY,
    full_name VARCHAR(150) NOT NULL,
    phone VARCHAR(20) NOT NULL,
    vehicle_type_id INTEGER NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    hired_at DATE NOT NULL DEFAULT CURRENT_DATE,
    CONSTRAINT fk_couriers_vehicle_type
        FOREIGN KEY (vehicle_type_id) REFERENCES vehicle_types (id) ON DELETE RESTRICT
);

-- Склады
CREATE TABLE warehouses (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    address TEXT NOT NULL,
    city VARCHAR(100) NOT NULL,
    phone VARCHAR(20) NOT NULL
);

-- Посылки / отправления
CREATE TABLE shipments (
    id BIGSERIAL PRIMARY KEY,
    tracking_number VARCHAR(20) NOT NULL,
    client_id BIGINT NOT NULL,
    sender_address TEXT NOT NULL,
    receiver_address TEXT NOT NULL,
    weight_kg NUMERIC(8, 3) NOT NULL,
    declared_value NUMERIC(12, 2) NOT NULL DEFAULT 0,
    status_id INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    CONSTRAINT uq_shipments_tracking_number UNIQUE (tracking_number),
    CONSTRAINT chk_shipments_weight_positive CHECK (weight_kg > 0),
    CONSTRAINT chk_shipments_declared_value_non_negative CHECK (declared_value >= 0),
    CONSTRAINT fk_shipments_status FOREIGN KEY (status_id) REFERENCES status_shipments (id) ON DELETE RESTRICT,
    CONSTRAINT fk_shipments_client FOREIGN KEY (client_id) REFERENCES clients (id) ON DELETE RESTRICT
);

-- Назначение доставок курьерам
CREATE TABLE deliveries (
    id BIGSERIAL PRIMARY KEY,
    shipment_id BIGINT NOT NULL,
    courier_id BIGINT NOT NULL,
    warehouse_id BIGINT NOT NULL,
    assigned_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    delivered_at TIMESTAMPTZ,
    notes TEXT,

    -- Составной unique: одну посылку нельзя дважды привязать к тому же курьеру
    CONSTRAINT uq_deliveries_shipment_courier UNIQUE (shipment_id, courier_id),
    CONSTRAINT chk_deliveries_dates CHECK (delivered_at IS NULL OR delivered_at >= assigned_at),
    CONSTRAINT fk_deliveries_shipment FOREIGN KEY (shipment_id) REFERENCES shipments (id) ON DELETE CASCADE,
    CONSTRAINT fk_deliveries_courier FOREIGN KEY (courier_id) REFERENCES couriers (id) ON DELETE RESTRICT,
    CONSTRAINT fk_deliveries_warehouse FOREIGN KEY (warehouse_id) REFERENCES warehouses (id) ON DELETE RESTRICT
);

-- Оплата
CREATE TABLE payment_transactions (
    id BIGSERIAL PRIMARY KEY,
    shipment_id BIGINT NOT NULL,
    amount NUMERIC(12, 2) NOT NULL,
    payment_method_id INTEGER NOT NULL,
    paid_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status_id INTEGER NOT NULL,

    CONSTRAINT chk_payment_amount_positive CHECK (amount > 0),
    CONSTRAINT fk_payment_status FOREIGN KEY (status_id) REFERENCES status_payment (id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_method FOREIGN KEY (payment_method_id) REFERENCES payment_methods (id) ON DELETE RESTRICT,
    CONSTRAINT fk_payment_shipment FOREIGN KEY (shipment_id) REFERENCES shipments (id) ON DELETE CASCADE
);
