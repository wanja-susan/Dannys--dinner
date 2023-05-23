drop database dannysdinner;
create database dannysdinner;
use dannysdinner;
drop table if exists sales;
Create table sales (customer_id VARCHAR (10), order_date date, product_id integer);
insert into sales value('A', '2021-01-01', 1);
insert into sales value('A', '2021-01-01', 2);
insert into sales value('A', '2021-01-07', 2);
insert into sales value('A', '2021-01-10', 3);
insert into sales value('A', '2021-01-11', 3);
insert into sales value('A', '2021-01-11', 3);
insert into sales value('B', '2021-01-01', 2);
insert into sales value('B', '2021-01-02', 2);
insert into sales value('B', '2021-01-04', 1);
insert into sales value('B', '2021-01-11', 1);
insert into sales value('B', '2021-01-16', 3);
insert into sales value('B', '2021-02-01', 3);
insert into sales value('C', '2021-01-01', 3);
insert into sales value('C', '2021-01-01', 3);
insert into sales value('C', '2021-01-07', 3); 

 create table members(customer_id varchar (10), join_date timestamp);
 insert into members value('A', '2021-01-07');
 insert into members value('B', '2021-01-09');
 
 create table menu(product_id int, product_name varchar (10), product_price int);
 insert into menu value(1, 'sushi', 10);
  insert into menu value(2, 'curry', 15);
   insert into menu value(3, 'ramen', 12);
   
   select*
   from sales;
   select*
   from members;
   select*
   from menu;
   
   -- total amount each customer has spent in the restaurant
  with total_sales as
        (select s.customer_id, s.order_date, m.product_id,m.product_name,m.product_price
         from sales s
         inner join menu m
         on s.product_id=m.product_id)
           select customer_id, sum(product_price) as total_amount
           from total_sales
           group by customer_id;
           
-- no of days each customer visited the restaurant
select customer_id, count(distinct order_date)  as no_of_days
from sales
group by customer_id
; 

-- first item from the menu purchased by each customer
select s.customer_id, m.product_name
from sales s
inner join menu m
on s.product_id=m.product_id
where s.order_date=(select min(order_date) from sales);

-- most purchased item on the menu and how many times was it purchased by all customers
select count(s.product_id) as most_purchased,m.product_name
from sales s
inner join menu m
on s.product_id=m.product_id
group by s.product_id,product_name
order by most_purchased desc
limit 1;

-- item that was the most popular for each customer?
select s.customer_id, m.product_name, count(*) AS order_count
from sales s
join menu m 
on s.product_id = m.product_id
group by s.customer_id, m.product_name
having count(*) = (
  select max(order_count)
  from (
    select s2.customer_id, s2.product_id, count(*) AS order_count
    from sales s2
    group by s2.customer_id, s2.product_id
  ) t
  where t.customer_id = s.customer_id
);

-- item that was purchased first by the customer after they became a member
select s.customer_id,min(m.join_date)as join_date,k.product_name
from sales s
join members m
on s.customer_id=m.customer_id
join menu k 
on s.product_id=k.product_id
group by s.customer_id,k.product_name
having join_date=(select min(join_date) 
from members
where customer_id=s.customer_id)
order by s.customer_id
;

-- item that was purchased just before the customer became a member
select s.customer_id, n.product_name 
from sales s 
join members m on s.customer_id = m.customer_id 
join menu n on s.product_id = n.product_id 
where s.order_date = (
   select max(order_date) 
   from sales 
   where customer_id = s.customer_id and order_date < m.join_date
) 
limit 0, 1000;

-- total items and amount spent for each member before they became a member?
select s.customer_id, count(*) AS total_items, sum(m.product_price) as total_amount
from sales s
join menu m on s.product_id = m.product_id
join members mem on s.customer_id = mem.customer_id
where s.order_date < mem.join_date
group by s.customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
select s.customer_id, 
sum(case when m.product_name = 'sushi' then m.product_price * 2 
      else m.product_price 
    end
  ) * 10 as total_points
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
select s.customer_id,sum(case when s.order_date between m.join_date and date_add(m.join_date, interval 1 week) 
then n.product_price * 20 else n.product_price * 10 end) as points
from sales s
join menu n on s.product_id = n.product_id
join members m on s.customer_id = m.customer_id
where s.order_date <= '2021-01-31'
group by s.customer_id
having s.customer_id in ('A', 'B');
