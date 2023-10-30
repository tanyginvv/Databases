--#1 Добавить внешние ключи
ALTER TABLE dealer
	ADD FOREIGN KEY(id_company) REFERENCES company(id_company);
ALTER TABLE production
	ADD FOREIGN KEY(id_company) REFERENCES company(id_company);
ALTER TABLE production
	ADD FOREIGN KEY(id_medicine) REFERENCES medicine(id_medicine);
ALTER TABLE "order"
	ADD FOREIGN KEY(id_production) REFERENCES production(id_production);
ALTER TABLE "order"
	ADD FOREIGN KEY(id_dealer) REFERENCES dealer(id_dealer);
ALTER TABLE "order"
	ADD FOREIGN KEY(id_pharmacy) REFERENCES pharmacy(id_pharmacy);

--#2 Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с указанием
-- названий аптек, дат, объема заказов

SELECT
	o.date, o.quantity, ph.name
FROM pharmacy  ph JOIN "order"  o ON ph.id_pharmacy = o.id_pharmacy
JOIN production pr ON pr.id_production = o.id_production
JOIN company c ON c.id_company = pr.id_company
JOIN medicine  m ON m.id_medicine = pr.id_medicine
WHERE m.name = 'Кордеон' AND c.name = 'Аргус';

-- 3.Дать список лекарств компании “Фарма”, на которые не были сделаны заказы до 25 января

SELECT
    m.name
FROM production  p JOIN "order" o ON o.id_production = p.id_production
JOIN company c ON c.id_company = p.id_company
JOIN medicine m ON m.id_medicine = p.id_medicine
WHERE p.id_production NOT IN (
	SELECT
		id_production
	FROM "order"
	WHERE "order".date < '2019-01-25'
) AND c.name = 'Фарма'
GROUP BY m.name;

-- 4.Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов

SELECT
	c.name, MIN(p.rating), MAX(p.rating), count(*)
FROM "order" o JOIN production  p ON p.id_production = o.id_production
JOIN company c ON c.id_company = p.id_company
GROUP BY c.id_company, c.name
HAVING COUNT(*) >= 120;

-- 5. Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
-- Если у дилера нет заказов, в названии аптеки проставить NULL.

SELECT  d.name, ph.name
FROM dealer d
LEFT JOIN "order" o ON o.id_dealer = d.id_dealer
LEFT JOIN pharmacy ph ON ph.id_pharmacy = o.id_pharmacy
LEFT JOIN company c ON c.id_company = d.id_company
WHERE c.name = 'AstraZeneca'
GROUP BY d.name, ph.name;

-- 6. Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней

SELECT
	m.name, m.cure_duration, p.price
FROM medicine m JOIN production p ON m.id_medicine = p.id_medicine
WHERE p.price > '3000' AND m.cure_duration <= 7;

UPDATE production pr
    SET price = pr.price * 0.8 from production
    JOIN medicine m ON m.id_medicine = production.id_medicine
WHERE pr.price > '3000' AND m.cure_duration <= 7;

-- 7. Добавить необходимые индексы.

CREATE INDEX IX_medicine_name
	ON medicine (name);

CREATE INDEX IX_dealer_name
	ON dealer (name);

CREATE INDEX IX_company_name
	ON company (name);

CREATE INDEX IX_order_date
	ON "order" (date);

 CREATE INDEX IX_production_price
	ON production (price);

 CREATE INDEX IX_medicine_cure_duration
	ON medicine (cure_duration);