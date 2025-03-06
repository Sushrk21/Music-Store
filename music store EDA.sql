use chinook
/*1)What is the Total Revenue, Total Customers and total number of order and Average Order Value?*/
Select distinct Count(Customerid) as Total_Customers from Customer;

SELECT 
    SUM(Total) AS Total_Revenue,
    COUNT(InvoiceId) AS Total_Orders,
    ROUND(SUM(Total) * 1.0 / COUNT(InvoiceId), 2) AS Average_Order_Value
FROM Invoice;

/*2)which are the genres that generate more revenue?*/
Select Top 3 g.Name as Genre_Name,Sum(il.UnitPrice) as Revenue from Genre g
join Track t on g.GenreId=t.GenreId
join InvoiceLine il on t.TrackId=il.TrackId
group by g.Name order by Revenue desc


/*3)Who are the artists with highest total sales?*/
Select Top 3  ar.Name as Artist_Name,Count(il.TrackId) as Tracks_Sold, Sum(il.UnitPrice) as Total_Sales from Artist ar
join Album al on ar.ArtistId=al.ArtistId
join Track t on t.AlbumId=al.AlbumId
join InvoiceLine il on t.TrackId=il.TrackId
Group by ar.Name order by Total_Sales desc

/*4)Which albums contribute the most to revenue?*/
Select Top 3 t.AlbumId,a.Title, Sum(il.UnitPrice) as Revenue from Album a
join Track t on t.AlbumId=a.AlbumId
join InvoiceLine il on t.TrackId=il.TrackId
Group by t.AlbumId,a.Title order by Revenue desc 

/*5)How has the company's revenue changed over time, and what is the count of transactions and Year-over-Year (YoY) growth rate?*/
With cte1 as
(Select Year(InvoiceDate) as Year, Count(InvoiceId)as Count_of_Transactions, Sum(Total) as Total_Revenue from Invoice
Group by Year(InvoiceDate))

Select Year, 
Count_of_Transactions,
Total_Revenue as Current_Year_Revenue,
Lag(Total_Revenue) Over(Order by Year) as Previous_Year_Revenue,
Case
    When Lag(Total_Revenue) Over(Order by Year) is NULL Then NULL
	Else ((Total_Revenue - LAG(Total_Revenue) Over (Order by Year)) / LAG(Total_Revenue) Over (Order by Year)) * 100
	END AS YOY_Growth_Percentage
	from cte1
	Order by Year;

/*6)What is the distribution of Customers Assigned to each Sales employee?*/
Select Concat(e.FirstName,' ',e.LastName)as Name,Count(CustomerId) as Customers_Assigned from  Employee e
join Customer c on e.EmployeeId=c.SupportRepId
Where e.Title='Sales Support Agent'
Group by Concat(e.FirstName,' ',e.LastName)

/*7)Who does each employee report to?*/
Select e1.EmployeeId, e1.FirstName+' '+e1.LastName as EmployeeName,
e2.EmployeeId as ID,e2.Title,
e2.FirstName+' '+e2.LastName as Reports_to
from Employee e1
join Employee e2
on e1.ReportsTo=e2.EmployeeId

/*8)Who are the top 5 highest-spending customers?*/
Select Top 5 c.CustomerId, Concat(c.FirstName,' ',c.LastName)as Customer_Name, Sum(i.Total) as Total_amount
from Customer c join Invoice i on c.CustomerId=i.CustomerId
group by c.CustomerId,Concat(c.FirstName,' ',c.LastName) Order by Total_amount desc

/*9)What are the Top three music genres purchased by highest sepending customer*/
Select Top 3 g.Name  as Genre_Name,Count(g.Name) as Count from Genre g
join Track t on g.GenreId=t.GenreId
join InvoiceLine il on t.TrackId=il.TrackId
join Invoice i on il.InvoiceId=i.InvoiceId
Where i.CustomerId = (Select top 1 c.CustomerId from Customer c join Invoice i on c.CustomerId=i.CustomerId 
group by c.Customerid Order by Sum(i.Total) desc) 
group by g.Name Order by Count desc

/*10)Which countries have generated the highest total sales revenue, and how many customers from that country contributed to these sales?*/
Select Top 5 BillingCountry, Count_Of_Customers,Revenue from
(Select Billingcountry,Count(CustomerId)as Count_Of_Customers,Sum(Total) as Revenue from Invoice
Group by BillingCountry)as Country_revenue Order by Count_Of_Customers desc

/*11)Which countries have the lowest total sales revenue?*/
Select Top 10 BillingCountry, Count_Of_Customers,Revenue from
(Select BillingCountry,Count(CustomerId)as Count_Of_Customers,Sum(Total) as Revenue from Invoice
Group by BillingCountry)as Country_revenue Order by Revenue asc

/*12)which are the top 5 best selling and least selling months?*/
/*top 5 best selling months*/
Select Top 5 DATENAME(MONTH, InvoiceDate) as Month,Sum(Total) as Total_Sales From Invoice
Group by DATENAME(MONTH, InvoiceDate) Order by Total_Sales DESC;

/*top 5 least selling months*/
Select Top 5 DATENAME(MONTH, InvoiceDate) as Month,Sum(Total) as Total_Sales From Invoice
Group by DATENAME(MONTH, InvoiceDate) Order by Total_Sales Asc;

/*13)Which tracks have the highest sales based on invoice data? Additionally, 
what is the total number of tracks  compared to the total number of tracks sold?*/

Select Top 10 t.Name as Track_Name, ar.Name AS Artist_Name, Count(il.TrackId) AS Total_Sales
From InvoiceLine il Join Track t on il.TrackId = t.TrackId
join Album al on t.AlbumId = al.AlbumId
Join Artist ar on al.ArtistId = ar.ArtistId
Group by t.Name, ar.Name
Order by Total_Sales desc;

Select
    (Select Count(*) From Track) as Total_Tracks,
    (Select Count(Distinct TrackId) From InvoiceLine) as Total_Tracks_Sold;


/*14)How do track lengths correlate with sales?*/
Select t.Name as Track_Name,ar.Name as Artist_Name,t.Milliseconds / 1000.0 as track_length_seconds, Count(il.TrackId) as Total_Sales
From InvoiceLine il
Join Track t on il.TrackId = t.TrackId
Join Album al on t.AlbumId = al.AlbumId
join Artist ar on al.ArtistId = ar.ArtistId
Group by t.Name, ar.Name, t.Milliseconds
Order by Total_Sales Desc

