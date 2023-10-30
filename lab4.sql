--INSERT
--Без указания списка полей INSERT INTO table_name VALUES (value1, value2, value3, ...);
INSERT INTO book
VALUES(1, 'Над пропастью во ржи', 'Джером Сэлинджер', 'роман', 350, 1),
(2, 'Война и мир', 'Лев Толстой', 'роман', 500, 2),
(3, '1984', 'Джордж Оруэлл', 'роман-антиутопия', 400, 3),
(4, '451 градус по Фаренгейту', 'Рэй Брэдбери', 'роман-антиутопия', 380, 4),
(5, 'Мастер и Маргарита', 'Михаил Булгаков', 'роман', 450, 5);
--С указанием списка полей INSERT INTO table_name (column1, column2, column3, ...)VALUES (value1, value2, value3, ...);
INSERT INTO review(review_text, review_rating, review_book_id, review_customer_id) 
VALUES( 'Задавали прочитать книгу на лето, она оказалась крутой!',5,14,6),
 ('Книга хороша, но мола быть и получше!',4,20,8),
  ('Ставлю книге тройку, трудно было ее читать',3,19,8);
--С чтением значения из другой таблицы INSERT INTO table2 (column_name(s)) SELECT column_name(s) FROM table1
insert into publisher
select * from customer where customer_id =11;
--DELETE
--Всех записей
delete from orders;
INSERT INTO orders (order_date, order_quantity, order_book_id, order_store_id)
VALUES
('2023-01-01', 5, 14, 1),
('2022-01-02', 3, 15, 1),
('2022-01-03', 2, 14, 2),
('2022-01-04', 4, 13, 2),
('2023-01-05', 1, 14, 3),
('2022-01-06', 6, 12, 3),
('2022-01-07', 3, 13, 1),
('2022-01-08', 2, 14, 2),
('2023-01-09', 7, 16, 3),
('2022-01-10', 5, 19, 2);
--по условию
delete from book where book_id >18;
--update
--всех записей
UPDATE orders
set order_date= '2023-04-12';
-- по условию обновляя один атрибут
UPDATE book
set book_price = book_price + '100,00'
where book_author= 'Федор Достоевский';
--по условию обновляя несколько атрибутов
update customer
set customer_name ='Михайлов Михаил',
customer_address = 'ул.Чаадаева,3'
where customer_phone ='89104567890';
--select
--с набором извлекаемых атрибутов
select customer_name, customer_phone from customer;
-- с набором всех атрибутов
select * from customer;
-- с условием по атрибуту
select * from book
where book_price > '750,00';
--select order by + top(limit)
--сортировка по возрастанию + ограничение вывода
select  customer_name, customer_address
from customer
order by 1 asc
limit 6;
--сортировка по убыванию;
select  customer_name, customer_address
from customer
order by 1 desc;
--с сортировкой по двум атрибутам + ограничение вывода
select  customer_name, customer_address
from customer
order by 1 desc, 2 asc
limit 6;
-- с сортировкой по первому атрибуту по списку извлекаемых
select *from customer
order by 1 asc;
-- работа с датами
-- where по дате
select *from orders
where order_date ='2022-01-05';
--where дата в диапазоне
select *from orders
where order_date between '2022-01-02' and '2022-01-06';
--извлечь только год
select extract( 'year'from order_date) from orders;
--функции агрегации
--посчитать количество записей в таблице
select count(*)from book;
--посчитать количество уникальных записей в таблице
select count(distinct book_author)from book;
--вывести уникальные значения столбца
select distinct book_author from book;
--найти максимальное значение столбца
select MAX(book_price)  from book;
--найти минимально значение столбца
select MIN(book_price)  from book;
--count + group by
select book_author, sum(book_price) as all_prices
from book
group by book_author;
--select group by +having
--например человек хочет купить всю коллекцию автора имея 1000 рублей
select book_author, sum(book_price) as all_prices
from book
group by book_author having sum(book_price) <= '1000,00' ;
--например в грузовой машине осталось место, нужно найти количество книг у продавца, которые могут вместиться с одного магазина
select order_store_id, sum(order_quantity) as all_quantity
from orders
group by order_store_id having sum(order_quantity) <= 25 ;
-- например нужно посчитать количество отзывов с определенными оценками по книгам, где  их больше 0
select review_rating, count(*) as all_review
from review
group by review_rating having count(*) > 0 ;
--SELECT JOIN
--left join и where по одному из атрибутов
SELECT* FROM publisher
left join book on publisher.publisher_id =book.book_publisher_id
where  book_id=13;
--right join
SELECT* FROM publisher
right join book on book.book_publisher_id =publisher.publisher_id
where  book_id=13;
--left join 3 таблиц обьединение id заказа, магазина и книги
select book_id , store_id, order_id
from  orders
left join store on orders.order_store_id = store.store_id
left join book on book.book_id = orders.order_book_id ;

--inner join
SELECT* FROM publisher
inner join book on publisher.publisher_id =book.book_publisher_id;
--подзапросы
-- написать запрос с условием where in
SELECT publisher_name, publisher_email
FROM publisher
where publisher_id in (
    select publisher_id from publisher
    where publisher_id < 6);
--написать запрос select atr1, atr2  from вывод отзыва покупателей
select customer_id, customer_name,
       (select review_text from review where review.review_customer_id=customer.customer_id)
from customer
order by customer_name;
--написать запрос вида select*from(подзапрос) вывод минимальной цены книги
select *from (select min(book_price) as small_price from book) as t;
--Написать запрос вида SELECT * FROM table JOIN ( подзапрос)ON .. ищем покупателей в высокими оценками чтобы отправить им на почту скидку
--Написать запрос вида SELECT * FROM table JOIN ( подзапрос)ON .. ищем покупателей в высокими оценками чтобы отправить им на почту скидкуа
select customer_name ,customer_email, review_text, review_rating from customer
inner join(select* from review)o on o.review_customer_id= customer.customer_id;