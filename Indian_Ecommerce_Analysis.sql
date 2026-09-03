select year(Order_Date) as 'year',
       count(distinct month(Order_Date)) as 'cnt month'
from Indian_datasets
group by year(Order_Date)
go
----------------
SELECT
    CASE
        WHEN MONTH(Order_Date) >= 6
            THEN CONCAT(YEAR(Order_Date), '-', YEAR(Order_Date) + 1)
        ELSE CONCAT(YEAR(Order_Date) - 1, '-', YEAR(Order_Date))
    END AS Fiscal_Year,

    SUM(Total_Amount) AS Total_Sales,
    COUNT(*) AS Total_Orders,
    SUM(Quantity) AS Total_Quantity,
    COUNT(DISTINCT Customer_ID) AS Total_Customers,
    AVG(Total_Amount) AS AOV

FROM Sales

WHERE Order_Date >= '2024-06-01'
  AND Order_Date < '2026-06-01'

GROUP BY
    CASE
        WHEN MONTH(Order_Date) >= 6
            THEN CONCAT(YEAR(Order_Date), '-', YEAR(Order_Date) + 1)
        ELSE CONCAT(YEAR(Order_Date) - 1, '-', YEAR(Order_Date))
    END

ORDER BY Fiscal_Year;
-------------------
UPDATE Sales
SET year = 
    CASE
        WHEN Order_Date BETWEEN '2024-06-01' AND '2025-05-31' THEN 2024
        WHEN Order_Date BETWEEN '2025-06-01' AND '2026-05-31' THEN 2025
        WHEN Order_Date >= '2026-06-01' THEN null
    END;
go

-------------------
select year,
       sum(Order_Value) as 'befor discount',
	   sum(Total_Amount) as 'after discount',
	   count(distinct Customer_ID) as 'cnt customer',
	   count(distinct Order_ID) as 'cnt order'
from sales
group by year
order by year desc
--------------------

update sales
set Discount_percent = +((Shipping_Cost*100)/Order_Value) - ((Coupon_Discount*100)/Order_Value)
go
-------------------

select year,
       avg(abs(discount_percent)) as 'AVG discount'
from sales
where discount_percent < 0
group by year
order by year desc

select year,
       avg(abs(discount_percent)) as 'AVG maliat'
from sales
where discount_percent > 0
group by year
order by year desc
go

--------------------

select year,
       sum(Total_Amount) as 'total',
	   SUM(Total_Amount) / COUNT(DISTINCT Order_ID) AS 'Avg_Order_Value',
	   count(distinct Order_ID) as 'cnt order',
       CAST(SUM(quantity) * 1.0 / COUNT(DISTINCT Order_ID) AS DECIMAL(10,2)) AS 'Avg_Items_Per_Order',
	   count(distinct Customer_ID) as 'cnt customer',
	   avg(datediff(day,Order_Date,Delivery_Date)) as 'time to send',
	   avg(Rating) as 'Rate',
	   avg(Customer_Age) as 'Age'
from sales
where year is not null
group by year
go
-------------
select count(distinct s.Order_ID),
       count(distinct c.Customer_ID)
from sales as s
left join customers as c
on s.Customer_ID = c.Customer_ID
where year(Registration_Date) = '2023'
go
---------------

update sales
set payment = case
              when Payment_Mode = 'COD' then 1
			  when Payment_Mode = 'Debit Card' then 2
			  when Payment_Mode = 'Credit Card' then 3
			  when Payment_Mode = 'UPI' then 4 else null end
go

---------------

select year,
       avg(payment)
from sales
group by year
go

---------------
select distinct month(Order_Date) from sales
select *
from ( select year,
              month(Order_Date) as 'monthh',
			  Order_ID
       from sales) as d
pivot ( count(Order_ID) for monthh in([1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]) ) as pivottable
go

-----------------------

select year,
       count(distinct Order_ID) as 'order',
	   count(distinct Customer_ID) as 'customer',
       cast(count(distinct Order_ID) * 1.0 / count(distinct Customer_ID) * 1.0 as decimal(10,2)) as 'cnt' 
from sales 
where year is not null
group by year
go

-----------------------

update sales
set month = case
            when year = '2024' then month(Order_Date)
			when year = '2025' then month(Order_Date)
			else null end
go
------------------------

select *
from ( select year, month , cast(count(distinct order_id) * 1.0 / count(distinct customer_id) as decimal(10,3)) as 'cs'
       from ( select year , month, Order_ID , Customer_ID
	          from sales) as s
	   group by year,month) as d
pivot( max(cs) for month in([1],[2] , [3] ,[4] ,[5],[6],[7],[8],[9],[10],[11],[12])) as pivottable

-----------------------

select year,
       count(distinct s.Customer_ID) as 'customer',
	   count(distinct s.Order_ID) as 'order'
from sales as s
left join customers as c
on s.Customer_ID = c.Customer_ID
where year(Registration_Date) = '2023'
group by year

select year,
       count(distinct s.Customer_ID) as 'customer',
	   count(distinct s.Order_ID) as 'order'
from sales as s
left join customers as c
on s.Customer_ID = c.Customer_ID
where year(Registration_Date) = '2024'
group by year

---------------------
select AVG((Coupon_Discount*100)/Order_Value)
from sales
where year = '2024'
go
---------------------

select AVG(datediff(day,Order_Date,Delivery_Date))*1.0
from sales
where year = '2024'
go
---------------------
--Customers

select count(distinct Order_ID) , count(c.Customer_ID)
from sales as s
left join customers as c
on s.Customer_ID = c.Customer_ID
where year = '2024' and c.Gender = 'male'
go

---------------------

select count(distinct s.Customer_ID) * 100.0 / ( select count(distinct Customer_ID)
                                                 from sales) as d
from sales as s
left join customers as c
on s.Customer_ID = c.Customer_ID
where year = '2025' and s.Customer_ID in( select distinct Customer_ID from sales where year = '2024')
go
---------------------

select count(*) 
from sales as s
full outer join customers as c
on s.Customer_ID = c.Customer_ID
where Order_ID is null
go

---------------------

select count(s.Customer_ID)
from sales as s
left join customers as c
on s.Customer_ID = c.Customer_ID
where c.Customer_Tier = 'silver'
go
----------------------

select count(distinct c.Customer_ID) 
from sales as s
left join customers as c
on s.Customer_ID = c.Customer_ID
where year = '2025' 
go
----------------------

select count(distinct c.Customer_ID)
from sales as s
left join customers as c
on s.Customer_ID = c.Customer_ID
where year(Registration_Date) = '2023'
go
----------------------

SELECT
    p.Category,
    SUM(s.Total_Amount) AS Revenue,
    SUM(s.Total_Amount) * 100.0
        / SUM(SUM(s.Total_Amount)) OVER () AS Sales_Percentage
FROM sales AS s
JOIN products AS p
    ON s.Product_ID = p.Product_ID
GROUP BY p.Category
ORDER BY Sales_Percentage DESC;
------------------------

select  sum(s.Total_Amount)
from sales as s
left join products as p
on s.Product_ID = p.Product_ID
where p.Category = 'Electronics'
group by s.year

---------------------------


