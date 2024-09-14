select * from goldusers_signup;
select * from users;
select * from sales_zomato;
select * from product_zomato;

-- 1. what is the total amount each customer spent on zomato ?
select s.userid,sum(p.price) as total_amount_spent from sales_zomato s join product_zomato p on s.product_id=p.product_id group by userid;

-- 2. How many days has each customer visited zomato ?
select userid,count(distinct created_date) as total_visited_days from sales_zomato group by userid;

-- 3. What was the first product purchased by each customer ?
select * from (select *,rank() over(partition by userid order by created_date) rank_no from sales_zomato) a where rank_no = 1;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customer ?
-- part-1
select product_id, count(product_id) from sales_zomato group by product_id order by 2 desc limit 1; 

-- part-2
select userid,count(product_id) as total_product_count from sales_zomato where product_id =
(select product_id from sales_zomato limit 1 ) group by userid order by 1;

-- 5. Which item is most popular for each customer ?
select * from
(select *,rank() over (partition by userid order by cnt desc) as total_rank from
(select userid,product_id,count(product_id) as cnt from sales_zomato group by userid,product_id)a)b where total_rank = 1;

-- 6. Which item was purchased first by the customer after they became a member ?
select * from 
(select c.*,rank() over (partition by userid order by created_date) as rnk from
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales_zomato s join goldusers_signup g on s.userid=g.userid 
and created_date>=gold_signup_date)c)d where rnk = 1;

-- 7. Which item was purchased just before the customer became member ?
select * from 
(select c.*,rank() over (partition by userid order by created_date desc) as rnk from
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales_zomato s join goldusers_signup g on s.userid=g.userid 
and created_date<=gold_signup_date)c)d where rnk = 1;

-- 8. What is the total orders and amount spent for each member before became a member ?
select userid,count(created_date) order_puchased,sum(price) total_amt_spent from
(select c.*,p.price from
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales_zomato s join goldusers_signup g on s.userid=g.userid 
and created_date<=gold_signup_date)c join product_zomato p on c.product_id=p.product_id)e group by userid order by 1;

-- 9. If buying each products generates points for e.g. 5rs=2 zomato points and each products has different purchasing points for
-- e.g. for p1 5rs=1 zomato point, for p2 10rs=5 zomato points and p3 5rs=1 zomato point.
-- Calculate points collected by each customers and for which product most points have been given till now ?
-- part-1
select userid,sum(total_points_collected)*2.5 as total_cashback_earned from
(select e.*, total_amt/zomato_points as total_points_collected from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as zomato_points from
(select c.userid,c.product_id,sum(price) as total_amt from
(select s.*,p.price from sales_zomato s join product_zomato p on s.product_id=p.product_id)c 
group by userid,product_id order by 1)d)e)f group by userid;

-- part-2
select * from
(select *,rank() over (order by total_points_earned desc) rnk from
(select product_id,sum(total_points_collected) as total_points_earned from
(select e.*, total_amt/zomato_points as total_points_collected from
(select d.*,case when product_id=1 then 5 when product_id=2 then 2 when product_id=3 then 5 else 0 end as zomato_points from
(select c.userid,c.product_id,sum(price) as total_amt from
(select s.*,p.price from sales_zomato s join product_zomato p on s.product_id=p.product_id)c 
group by userid,product_id order by 1)d)e)f group by product_id)f)t where rnk = 1;

-- 10. In the first one year after a customer joins the gold program (including there join date) irrespective of what the customer has 
-- purchased they earn 5 zomato points for every 10 rs spent who earned more 1 and 3 and what was their point earnings in their 1st year ?
-- 1 zomato_point = 2 rs
-- 0.5 zomato_point = 1 rs
select c.*,p.price * 0.5 as total_points_earned from
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales_zomato s join goldusers_signup g on s.userid = g.userid
where created_date >=gold_signup_date and created_date <= timestampadd(year,1,gold_signup_date))c 
join product_zomato p on c.product_id =p.product_id order by userid;

-- 11. Rank all the transaction of the customers ?
select *,rank() over (partition by userid order by created_date) as rnk from sales_zomato;

-- 12. Rank all the transactions for each member whenever they are a gold memeber for every non gold member transaction mark as na ?
select c.*,case when gold_signup_date is null then 'na' else rank() over (partition by userid order by created_date desc) end as rnk from
(select s.userid,s.created_date,s.product_id,g.gold_signup_date from sales_zomato s left join goldusers_signup g
on s.userid=g.userid and created_date >= gold_signup_date)c;















