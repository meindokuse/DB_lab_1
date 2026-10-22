-- Проверка ограничений целостности (каждый запрос должен возвращать ошибку)

-- 1. Дубликат email клиента (uq_clients_email)
INSERT INTO clients (full_name, phone, email, address)
VALUES ('Дубликат Клиент', '+7 (000) 000-00-00', 'ivanov.a@mail.ru', 'г. Москва');

-- 2. Дубликат трек-номера посылки (uq_shipments_tracking_number)
INSERT INTO shipments (tracking_number, client_id, sender_address, receiver_address, weight_kg, declared_value, status_id)
VALUES ('DEL-00000001', 1, 'г. Москва, ул. А', 'г. Москва, ул. Б', 2.0, 100.00, 1);

-- 3. Отрицательный вес посылки (chk_shipments_weight_positive)
INSERT INTO shipments (tracking_number, client_id, sender_address, receiver_address, weight_kg, declared_value, status_id)
VALUES ('DEL-99999901', 1, 'г. Москва, ул. А', 'г. Москва, ул. Б', -1.5, 100.00, 1);

-- 4. Несуществующий статус посылки (fk_shipments_status)
INSERT INTO shipments (tracking_number, client_id, sender_address, receiver_address, weight_kg, declared_value, status_id)
VALUES ('DEL-99999902', 1, 'г. Москва, ул. А', 'г. Москва, ул. Б', 1.0, 100.00, 9999);

-- 5. Назначение несуществующего курьера (fk_deliveries_courier)
INSERT INTO deliveries (shipment_id, courier_id, warehouse_id)
VALUES (3, 9999, 1);

-- 6. Пустое ФИО клиента (NOT NULL)
INSERT INTO clients (full_name, phone, email, address)
VALUES (NULL, '+7 (000) 000-00-01', 'noname@test.ru', 'г. Тест');

-- 7. Несуществующий тип транспорта курьера (fk_couriers_vehicle_type)
INSERT INTO couriers (full_name, phone, vehicle_type_id, is_active, hired_at)
VALUES ('Тест Курьер', '+7 (000) 111-22-33', 9999, TRUE, '2026-01-01');

-- 8. Нулевая сумма платежа (chk_payment_amount_positive)
INSERT INTO payment_transactions (shipment_id, amount, payment_method_id, paid_at, status_id)
VALUES (1, 0.00, 1, NOW(), 1);

-- 9. Повторное назначение того же курьера на ту же посылку (составной uq_deliveries_shipment_courier)
INSERT INTO deliveries (shipment_id, courier_id, warehouse_id)
VALUES (1, 1, 2);

-- 10. Дата доставки раньше даты назначения (chk_deliveries_dates)
INSERT INTO deliveries (shipment_id, courier_id, warehouse_id, assigned_at, delivered_at)
VALUES (8, 3, 3, '2026-10-20 12:00:00+03', '2026-10-19 10:00:00+03');

-- 11. Несуществующий метод оплаты (fk_payment_method)
INSERT INTO payment_transactions (shipment_id, amount, payment_method_id, paid_at, status_id)
VALUES (1, 500.00, 9999, NOW(), 1);

-- 12. Несуществующий статус оплаты (fk_payment_status)
INSERT INTO payment_transactions (shipment_id, amount, payment_method_id, paid_at, status_id)
VALUES (1, 500.00, 2, NOW(), 9999);

-- 13. Дубликат названия типа транспорта (uq_vehicle_types_name)
INSERT INTO vehicle_types (name) VALUES ('car');

-- 14. Дубликат статуса посылки (uq_status_shipments_name)
INSERT INTO status_shipments (name) VALUES ('pending');

-- 15. Удаление типа транспорта, на который ссылается курьер (ON DELETE RESTRICT)
DELETE FROM vehicle_types WHERE name = 'car';

-- 16. Удаление статуса, на который ссылаются посылки (ON DELETE RESTRICT)
DELETE FROM status_shipments WHERE name = 'pending';
