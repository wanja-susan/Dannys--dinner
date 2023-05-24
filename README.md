# Dannys--dinner
This project is derived from Danny Ma's #8WeekSQLChallenge.

# Introduction
Danny Ma, a lover of Japanese food, took a daring step in early 2021 by opening a charming restaurant called Danny's Diner.
The menu primarily features his top three favorite dishes: 
1) Sushi 
2) Surry
3) Ramen 

# Problem Statement
The restaurant is facing challenges and requires assistance in utilizing their collected data to improve their operations. Danny wants to understand customer behavior, expenditure, and preferences to enhance their experience. 
By analyzing this data, he aims to make informed decisions on expanding the customer loyalty program. Additionally, he needs simplified datasets for easy data inspection. Privacy concerns have led to the provision of a sample of customer data for the case study, which should be sufficient to develop functional SQL queries. 
Three key datasets are provided: 
1) Sales
2) Menu
3) Members

# Entity Relationship Diagram
Please find below an entity relationship diagram (ERD) that illustrates the relationships between various entities.

![ERD](https://github.com/wanja-susan/Dannys--dinner/assets/130906675/6eb0ab19-2235-4b1a-bb76-65edf3595539)


# Case study Questions
1. What is the total amount each customer spent at the restaurant?
2. How many days has each customer visited the restaurant?
3. What was the first item from the menu purchased by each customer?
4. What is the most purchased item on the menu and how many times was it purchased by all customers?
5. Which item was the most popular for each customer?
6. Which item was purchased first by the customer after they became a member?
7. Which item was purchased just before the customer became a member?
8. What is the total items and amount spent for each member before they became a member?
9. If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?

# Solutions
Software used is MYSQL.

# 1. What is the total amount each customer spent at the restaurant?
- Sales and menu table are needed for this query hence the JOIN clause.
- Use SUM aggregate function to get total amount spent
- Use GROUP BY to specify the rows based on customer id
- ` with total_sales as
        (select s.customer_id, s.order_date, m.product_id,m.product_name,m.product_price
         from sales s
         inner join menu m
         on s.product_id=m.product_id)
           select customer_id, sum(product_price) as total_amount
           from total_sales
           group by customer_id;`
           
![Q 1](https://github.com/wanja-susan/Dannys--dinner/assets/130906675/6b7edd98-f459-4b04-a9d9-01db55397a79)

# 2. How many days has each customer visited the restaurant?
- Use COUNT DISTINCT to get unique days
- Use GROUP BY to specify the rows based on customer id
- `select customer_id, count(distinct order_date)  as no_of_days
from sales
group by customer_id
; `

![Q 2](https://github.com/wanja-susan/Dannys--dinner/assets/130906675/30062db1-27da-4b08-bf3c-a6f3de84bb28)

# 3. What was the first item from the menu purchased by each customer?
- Use DENSE_RANK and OVER(PARTITION BY ORDER BY) to create a new column which ranks the item based on order_date.
- Add a WHERE clause to see rank = 1
- Use GROUP BY to specify the rows based on customer id and product id
- `WITH ranked_item as (
   Select s.customer_id, s.order_date ,m.product_name,
    DENSE_RANK() OVER (PARTITION BY s.customer_id ORDER BY  s.order_date) AS ranked
     From sales s
     Join menu m
        ON s.product_id = m.product_id
		)
Select customer_id, product_name
From ranked_item
Where ranked = '1'
Group by customer_id, product_name`

![Q 3](https://github.com/wanja-susan/Dannys--dinner/assets/130906675/0d86a77b-cec3-4975-8cfd-ee843e192663)

# 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
- Use COUNT to get number of items purchased.
- Use join clause to product name from menu and product id from sales
- Use GROUP BY to specify the rows based on product name and product id
- Order in DESC
- Limit 1 to get the most purchased item

- `select count(s.product_id) as most_purchased,m.product_name
from sales s
inner join menu m
on s.product_id=m.product_id
group by s.product_id,product_name
order by most_purchased desc
limit 1;`

![Q 4](https://github.com/wanja-susan/Dannys--dinner/assets/130906675/09aa68c7-ae13-4291-985f-d57107c31145)

# 5. Which item was the most popular for each customer?

- `select s.customer_id, m.product_name, count(*) AS order_count
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
);`
