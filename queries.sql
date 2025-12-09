-- Шаг 4. Обычный SELECT + подсчет количества через COUNT
-- Результат назван с помощью алиаса
select COUNT(customer_id) as customers_count from customers;

-- Шаг 5.

-- Таблица 1
-- Конкатенация имени и фамилии из таблицы employees
-- COUNT по sales_person_id, чтобы узнать, сколько человек провел сделок
-- Сумма по количеству умноженному на цену, чтобы рассчитать выручку для каждого продавца
-- Группировка по первому столбцу (seller)
-- Сортировка, ключевое слово DESC, чтобы сортировалось по убыванию
-- Использовались JOIN относительно главной таблицы SALES, для получения недостающей информации
-- LIMIT для ограничения на количество выводимых строк
select first_name || ' ' || last_name as seller, COUNT(s.sales_person_id) as operations, FLOOR(SUM(s.quantity * p.price)) as income
from sales s
left join employees e on s.sales_person_id = e.employee_id
left join products p on p.product_id = s.product_id
group by 1
order by FLOOR(SUM(s.quantity * p.price)) desc
limit 10;

-- Таблица 2
-- Большая часть операций описана ранее.
-- Т.к. при компиляции в SQL операции GROUP BY, HAVING, WHERE идут до SELECT
-- пришлось добавлять подзапросы.
select seller, average_income
from
    (select first_name || ' ' || last_name as seller,
    FLOOR(AVG(s.quantity * p.price)) as average_income
    from sales s
    left join employees e on s.sales_person_id = e.employee_id
    left join products p on p.product_id = s.product_id
    group by 1) sub_query
where average_income < (
    select AVG(s.quantity * p.price)
    from sales s
    left join products p on p.product_id = s.product_id)
order by average_income;

-- Таблица 3
-- Практически как таблица 1, описание TRIM, TO_CHAR, EXTRACT есть
-- на самом шаге задания. DOW нужен для получения номера дня недели,
-- т.к. DOW у sunday = 0, а у monday = 1 - делаем сдвиг (К номеру
-- прибавляем 6 и берем остаток от 7). Теперь monday = 0, sunday = 6).
select first_name || ' ' || last_name as seller,
	   TRIM(TO_CHAR(s.sale_date, 'Day')) as day_of_week,
	   FLOOR(SUM(s.quantity * p.price)) as income
from sales s
left join employees e on s.sales_person_id = e.employee_id
left join products p on p.product_id = s.product_id
group by 1, 2, extract(dow from s.sale_date)
order by (extract(dow from s.sale_date) + 6) % 7, seller;
