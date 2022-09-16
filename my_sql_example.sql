/* Инструкция: 
    SQL запросы к базе данных "Корпорация" по заданию ниже.
*/

-- 1. Для каждого продавца (job_id=670) вывести разность между его зарплатой и средней зарплатой продавцов в отделе c кодом 23. 
select employee_id, first_name, last_name, salary - meanzp23 as 'Разность'
      from employee,
	(select avg(salary) as meanzp23
         from employee
         where department_id=23) tmp
       where job_id=670;

-- 2. Выбрать среднюю сумму продаж, которая приходится на одного сотрудника в городе NEW YORK.
select avg(total) as 'Средняя сумма продаж' 
    from employee e 
    join DEPARTMENT d on d.department_id = e.department_id 
	join LOCATION l on l.location_id = d.location_id 
	join CUSTOMER c on c.salesperson_id = e.employee_id 
	join SALES_ORDER so on so.customer_id = c.customer_id
    where l.regional_group = 'NEW YORK';

-- 3. Определить, какой продукт был наиболее популярен весной 2019г (по количеству проданных экземпляров quantity).
select p.product_id, p.description as 'Популярный продукт весной 2019', max(i.quantity) as 'Количество' 
    from PRODUCT p 
	join ITEM i on i.product_id = p.product_id 
	join SALES_ORDER so on so.order_id = i.order_id 
	where year(so.order_date) = 2019 
	and month(so.order_date) between 3 and 5
group by p.product_id
order by max(i.quantity) desc
limit 1;

-- 4. Выбрать товары, наиболее популярные в каждом городе (по количеству проданных экземпляров quantity).
select regional_group, max(quantity), product_id, description
from 
(select location.regional_group, item.quantity, product.product_id, product.description 
	 from product, item , sales_order, customer, employee, department, location
     where location.location_id = department.location_id 
  	 and department.department_id = employee.department_id
	 and employee.employee_id = customer.salesperson_id
	 and customer.customer_id = sales_order.customer_id
	 and sales_order.order_id = item.order_id
	 and item.product_id = product.product_id
	 group by item.quantity) tmp
group by regional_group;
       
         
      
--  5. Выбрать данные для построения графика зависимости суммы продажи 
-- от процента представленной покупателю скидки.
select i.total, (p.list_price-i.actual_price)/(p.list_price/100) as discont
    from item i
	join price p on p.product_id = i.product_id
    join sales_order so on i.order_id = so.order_id
where so.order_date between p.start_date and p.end_date;




-- ------------ Необязательно, не оценивается * -------------------- 
-- (*). Определить, не хранятся ли в базе данных сведения о покупателях, которые не совершили ни одной покупки.

select customer.customer_id, customer.name, sales_order.order_id, employee.employee_id
from item, sales_order, customer, employee
where employee.employee_id = customer.salesperson_id 
      and customer.customer_id = sales_order.customer_id 
      and employee.employee_id = customer.salesperson_id 
      and ((sales_order.order_id not in (select item.order_id from item)) or (customer.customer_id not in (select sales_order.customer_id from sales_order))) 
group by customer.customer_id;

-- (*) Определить, не зафиксированы ли случаи, когда продавались продукты, не выставленные на данный момент в продажу. 
--  Вывести название продукта, дату продажи, покупателя.

select description, start_date, name
from
(select price.product_id, price.start_date, sales_order.ship_date, sales_order.order_date, sales_order.customer_id, customer.name, product.description  
	from price, sales_order, customer, item, product 
	where  customer.customer_id = sales_order.customer_id
	and sales_order.order_id = item.order_id
	and item.product_id = product.product_id
	and product.product_id = price.product_id
group by price.product_id) tmp
where (start_date > order_date) or (start_date > ship_date)
order by description; 



-- (*) Определить, в каких регионах любят покупать дорогие товары, а в каких - дешевые.

-- Район, в котором любят покупать дешевые товары
select regional_group 
from
	(select max(quantity), regional_group, product_id, description, list_price
	from
		(select product.product_id, product.description, price.list_price, item.quantity, item.total, location.regional_group  
			 from price, product, item , sales_order, customer, employee, department, location 
			 where location.location_id = department.location_id 
			 and department.department_id = employee.department_id
			 and employee.employee_id = customer.salesperson_id
			 and customer.customer_id = sales_order.customer_id
			 and sales_order.order_id = item.order_id
			 and item.product_id = product.product_id
			 and product.product_id = price.product_id
		group by price.list_price) tmp
		group by regional_group
		order by list_price asc
		limit 1) x;
        
-- Район, в котором любят покупать дорогие товары
select regional_group 
from
	(select max(quantity), regional_group, product_id, description, list_price
	from
		(select product.product_id, product.description, price.list_price, item.quantity, item.total, location.regional_group  
			 from price, product, item , sales_order, customer, employee, department, location 
			 where location.location_id = department.location_id 
			 and department.department_id = employee.department_id
			 and employee.employee_id = customer.salesperson_id
			 and customer.customer_id = sales_order.customer_id
			 and sales_order.order_id = item.order_id
			 and item.product_id = product.product_id
			 and product.product_id = price.product_id
		group by price.list_price) tmp
		group by regional_group
		order by list_price desc
		limit 1) x;