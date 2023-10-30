-- #1 добавить внешние ключи
ALTER TABLE booking
	ADD FOREIGN KEY(id_client) REFERENCES client(id_client);
ALTER TABLE room
	ADD FOREIGN KEY(id_hotel) REFERENCES hotel(id_hotel);
ALTER TABLE room
	ADD FOREIGN KEY(id_room_category) REFERENCES room_category(id_room_category);
ALTER TABLE room_in_booking
	ADD FOREIGN KEY(id_booking) REFERENCES booking(id_booking);
ALTER TABLE room_in_booking
	ADD FOREIGN KEY(id_room) REFERENCES room(id_room);

--# 2 Выдать информацию о клиентах гостиницы "Космос", проживающих в номерах категории "Люкс" на 1 апреля 2019г.
SELECT c.name FROM client c
	LEFT JOIN booking b ON b.id_client = c.id_client
    LEFT JOIN room_in_booking rib ON rib.id_booking = b.id_booking
    LEFT JOIN room  r ON r.id_room = rib.id_room
    LEFT JOIN room_category rc ON rc.id_room_category = r.id_room_category
    LEFT JOIN hotel h ON h.id_hotel = r.id_hotel
    WHERE rib.checkin_date <= '2019-04-01' AND rib.checkout_date > '2019-04-01' AND rc.name = 'Люкс' AND h.name = 'Космос';

--# 3  Дать список свободных номеров всех гостиниц на 22 апреля.
-- в выборке должны быть номера вообще без бронирований
SELECT DISTINCT r.number, r.price, rc.name, h.name , rib.checkin_date FROM room r
	LEFT JOIN room_category rc ON rc.id_room_category = r.id_room_category
	LEFT JOIN hotel  h ON h.id_hotel = r.id_hotel
	LEFT JOIN room_in_booking rib ON rib.id_room = r.id_room
	WHERE ((rib.checkin_date < '2019-04-22' AND rib.checkout_date <= '2019-04-22') OR (rib.checkin_date > '2019-04-22')
	    OR rib.checkin_date is NULL);

--#4 Дать количество проживающих в гостинице “Космос” на 23 марта по каждой категории номеров
SELECT rc.name, COUNT(rib.id_room_in_booking) AS numbers_of_clients from room r
    LEFT JOIN room_in_booking rib on rib.id_room = r.id_room
    LEFT JOIN room_category rc on rc.id_room_category = r.id_room_category
    LEFT JOIN hotel h on h.id_hotel = r.id_hotel
    WHERE (h.name='Космос' AND rib.checkin_date <= '2019-03-23' AND rib.checkout_date > '2019-03-23')
    GROUP BY rc.name;
--#5 Дать список последних проживавших клиентов по всем комнатам гостиницы "Космос", выехавшим в апреле с указанием даты выезда.
SELECT r.number, c.name, rib.checkout_date FROM client c
	LEFT JOIN booking b ON b.id_client = c.id_client
	LEFT JOIN room_in_booking rib ON rib.id_booking = b.id_booking
	LEFT JOIN room r ON r.id_room = rib.id_room
	INNER JOIN (SELECT room.id_room, MAX(rib.checkout_date) AS last_checkout_date FROM room
					INNER JOIN room_in_booking rib ON rib.id_room = r.id_room AND
						rib.checkout_date >= '2019-04-01' AND rib.checkout_date <= '2019-04-30'
					INNER JOIN hotel h ON h.id_hotel = r.id_hotel AND h.name = 'Космос'
					GROUP BY r.id_room
				) AS rr ON rr.id_room = r.id_room AND rr.last_checkout_date = rib.checkout_date;
--#6 Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам комнат категории “Бизнес”, которые заселились 10 мая.
UPDATE room_in_booking rib
SET checkout_date = rib.checkout_date + INTERVAL '2 DAY' from room_in_booking
     LEFT JOIN room r ON r.id_room = room_in_booking.id_room
     LEFT JOIN room_category rc ON rc.id_room_category = r.id_room_category
     LEFT JOIN hotel h ON h.id_hotel = r.id_hotel
WHERE  rib.checkin_date = '2019-05-10' AND h.name = 'Космос' AND rc.name = 'Бизнес';

--# 7 Найти все "пересекающиеся" варианты проживания. поправить дублирование точнее его убрать
-- дубликаты пересечений
SELECT  rib2.id_booking, rib2.checkin_date, rib2.checkout_date, rib1.id_room,rib1.id_booking,  rib1.checkin_date, rib1.checkout_date FROM room_in_booking rib1
	 JOIN room_in_booking rib2 ON rib2.id_room_in_booking != rib1.id_room_in_booking AND rib2.id_room = rib1.id_room
	WHERE (rib2.checkin_date >= rib1.checkin_date AND rib2.checkin_date < rib1.checkout_date)
	  AND (rib2.id_booking = 471 or rib2.id_booking = 1269);

--#8 Бронирование в транзакции(доделать функцией)

BEGIN;
INSERT INTO client (name, phone) VALUES ('Павлов Павел Анатольевич', '+7999999997');
INSERT INTO booking (id_client, booking_date)
SELECT id_client, '2022-02-25'
FROM client
WHERE client.name = 'Павлов Павел Анатольевич' AND client.phone = '+7999999997';

INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
SELECT id_booking, 244, '2022-03-25', '2022-04-04'
FROM booking
WHERE booking.id_client =
(SELECT id_client
FROM client
WHERE client.name = 'Павлов Павел Анатольевич' AND client.phone = '+7999999997'
LIMIT 1);

COMMIT;
--#9 Добавить необходимые индексы для всех таблиц
CREATE INDEX index_room_in_booking_checkin_date ON room_in_booking(checkin_date);
CREATE INDEX index_room_in_booking_checkout_date ON room_in_booking(checkout_date);
CREATE INDEX index_room_category_name ON room_category(name);
CREATE INDEX index_hotel_name ON hotel(name);