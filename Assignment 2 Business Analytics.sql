/*
Assignment 2: Business Analytics ASHTON SARLO :)

1. Create a new SQLite3 database named "USCensus.db".
2. Create three tables in the "USCensus.db" database:

- "Stats" with columns "Abb" (state abbreviation), "Area" (land area), and "Pop" (population).
- "Names" with columns "Abb" (state abbreviation) and "State" (full state name).
- "Capitals" with columns "State" (full state name), "Capital" (capital city), and "CapitalPop" (capital city population).

For each table, select the most appropriate data type for each column ("TEXT", "INTEGER", "REAL"), and choose the most appropriate
column as the primary key.
*/

CREATE TABLE Stats (
    Abb TEXT PRIMARY KEY,
    Area INTEGER,
    Pop INTEGER
);

CREATE TABLE Names (
    Abb TEXT PRIMARY KEY,
    State TEXT
);

CREATE TABLE Capitals (
    State TEXT PRIMARY KEY,
    Capital TEXT,
    CapitalPop INTEGER
);

/*
Verify the structure of each table, once using a dot command, and once using a SQL command.

Display the names of all tables in the database, once using a dot command and once using a SQL command.
*/

.schema Stats
.schema Names
.schema Capitals
.tables

PRAGMA table_info(Stats);
PRAGMA table_info(Names);
PRAGMA table_info(Capitals);
SELECT name FROM sqlite_master WHERE type='table';

/*
Import data from the provided files into their respective tables.

Retrieve the first two rows of each table to confirm that the data was imported correctly.
*/

.mode csv
.import --skip 1 Stats.csv Stats
.import --skip 1 Names.csv Names
.import --skip 1 Capitals.csv Capitals

SELECT * FROM Stats LIMIT 2;
SELECT * FROM Names LIMIT 2;
SELECT * FROM Capitals LIMIT 2;

/*
Retrieve the abbreviations and populations of the top five states with the highest populations.
*/

SELECT Abb, Pop
FROM Stats
ORDER BY Pop DESC
LIMIT 5;

/*
Retrieve the abbreviations of the states with the smallest land areas, sorted alphabetically.
*/

SELECT Abb
FROM Stats
ORDER BY Area ASC
LIMIT 1;

/*
Count the number of states where population density (population divided by land area) below 50 people per square kilometer.
*/

SELECT COUNT(*) AS LowDensity
FROM Stats
WHERE (Pop * 1.0 / Area) < 50;

/*
Retrieve the abbreviations of states with populations between 1 million and 2 million (inclusive).
*/

SELECT Abb
FROM Stats
WHERE Pop BETWEEN 1000000 AND 2000000;

/*
Calculate the population density for each state, rounded to two decimal places, and
display "Abb" (state abbreviation) and "Density" (alias for calculated population density).
*/

SELECT Abb,
       ROUND(Pop * 1.0 / Area, 2) AS Density
FROM Stats;

/*
Retrieve each state’s abbreviation, full name, and capital city.
*/

SELECT S.Abb,
       N.State,
       C.Capital
FROM Stats S
JOIN Names N ON S.Abb = N.Abb
JOIN Capitals C ON N.State = C.State;

/*
Retrieve the full name, capital city, and population of each state.
*/

SELECT N.State,
       C.Capital,
       S.Pop
FROM Stats S
JOIN Names N ON S.Abb = N.Abb
JOIN Capitals C ON N.State = C.State;

/*
Retrieve the full names of states where the population density exceeds 100 people per
square kilometer and the capital city population exceeds 200,000.
*/

SELECT N.State
FROM Stats S
JOIN Names N ON S.Abb = N.Abb
JOIN Capitals C ON N.State = C.State
WHERE (S.Pop * 1.0 / S.Area) > 100
  AND C.CapitalPop > 200000;

/*
Retrieve the full name and capital city of states where the capital city population is greater
than three times the average capital population.
*/

SELECT N.State,
       C.Capital
FROM Names N
JOIN Capitals C ON N.State = C.State
WHERE C.CapitalPop > 3 * (SELECT AVG(CapitalPop) FROM Capitals);

/*
Retrieve the total land area of all states.
*/

SELECT SUM(Area) AS TotalArea
FROM Stats;

/*
Modify the "Stats" table by adding a new column "Density", then populate it with the
calculated population density. Ensure that the column uses the most appropriate data
type
*/

ALTER TABLE Stats ADD COLUMN Density REAL;
UPDATE Stats
SET Density = ROUND(Pop * 1.0 / Area, 2);

/*
Retrieve the full names of states where the population density is below 2 people per
square kilometer and the capital city population exceeds 500,000.
*/

SELECT N.State
FROM Stats S
JOIN Names N ON S.Abb = N.Abb
JOIN Capitals C ON N.State = C.State
WHERE (S.Pop * 1.0 / S.Area) < 2
  AND C.CapitalPop > 500000;

/*
Retrieve pairs of state abbreviations where population densities differ by at most 0.3
persons per square kilometer. Ensure that each pair appears only once.
*/

SELECT A.Abb AS Abb1,
       B.Abb AS Abb2
FROM Stats A
JOIN Stats B ON A.Abb < B.Abb
WHERE ABS((A.Pop * 1.0 / A.Area) - (B.Pop * 1.0 / B.Area)) <= 0.3;

/*
Retrieve the full names of states where the population exceeds 20 million in one query,
then append the results with the full names of states where the land area is greater than
300,000 square kilometers in a separate query, ensuring that no duplicate state names
appear in the output.
*/

SELECT N.State
FROM Stats S
JOIN Names N ON S.Abb = N.Abb
WHERE S.Pop > 20000000
UNION
SELECT N.State
FROM Stats S
JOIN Names N ON S.Abb = N.Abb
WHERE S.Area > 300000;

/*
Categorize states based on population density: "Low" for states with a population density
below 50, "Medium" for states with a density between 50 and 100 (inclusive), and "High"
for states with a density of 100 or more. For each category, calculate the total population
and assign it the alias "TotPop", and compute the average land area, rounding it to two
decimal places and assigning it the alias "AvgArea". Assign the alias "DensityRange" to the
category column.
*/

SELECT 
  CASE
    WHEN (Pop * 1.0 / Area) < 50 THEN 'Low'
    WHEN (Pop * 1.0 / Area) BETWEEN 50 AND 100 THEN 'Medium'
    ELSE 'High'
  END AS DensityRange,
  SUM(Pop) AS TotPop,
  ROUND(AVG(Area), 2) AS AvgArea
FROM Stats
GROUP BY DensityRange;

/*
Modify the previous query so that it produces a similar output for the previously identified
categories but only includes those where the total population exceeds 100 million.
*/

SELECT 
  CASE
    WHEN (Pop * 1.0 / Area) < 50 THEN 'Low'
    WHEN (Pop * 1.0 / Area) BETWEEN 50 AND 100 THEN 'Medium'
    ELSE 'High'
  END AS DensityRange,
  SUM(Pop) AS TotPop,
  ROUND(AVG(Area), 2) AS AvgArea
FROM Stats
GROUP BY DensityRange
HAVING SUM(Pop) > 100000000;

/*
.
.
.
.
.
.
.
.
.
.
.
.
*/

/*
Part 2
Create a new SQLite3 database named "Superstore.db".
Open each provided file in a spreadsheet application or text editor to examine their contents. Identify the column names and data types.
Create three tables in the "Superstore.db" database named "Orders", "People", and "Returns", ensuring that each column is assigned the most appropriate data type based on the data observed.
Import each data file into its respective table.

Each row in the "Orders" table represents an individual sale, but an order (identified by
"Order ID") may contain multiple sales, meaning multiple rows can share the same "Order
ID". 
*/

CREATE TABLE Orders (
    RowID INTEGER PRIMARY KEY,
    OrderID TEXT,
    OrderDate TEXT,
    ShipDate TEXT,
    ShipMode TEXT,
    CustomerID TEXT,
    CustomerName TEXT,
    Segment TEXT,
    City TEXT,
    State TEXT,
    Country TEXT,
    PostalCode TEXT,
    Market TEXT,
    Region TEXT,
    ProductID TEXT,
    Category TEXT,
    SubCategory TEXT,
    ProductName TEXT,
    Sales REAL,
    Quantity INTEGER,
    Discount REAL,
    Profit REAL,
    ShippingCost REAL,
    OrderPriority TEXT
);

CREATE TABLE People (
    Person TEXT PRIMARY KEY,
    Region TEXT
);

CREATE TABLE Returns (
    Returned TEXT,
    OrderID TEXT PRIMARY KEY
);

.mode csv
.import --skip 1 Orders.csv Orders
.import --skip 1 People.csv People
.import --skip 1 Returns.csv Returns

/*
Retrieve all unique countries contained in the database and determine the number of
sales originating from each country over all years. Assign the alias "Number of Sales" to the
country counts and sort the results in descending order by the number of sales.
*/

SELECT Country, COUNT(*) AS "Number of Sales"
FROM Orders
GROUP BY Country
ORDER BY "Number of Sales" DESC;

/*
Modify the previous query so that it produces a similar output but only includes countries
whose names contain "X", "Y", or "Z" (or "x", "y", or "z")
*/

SELECT Country, COUNT(*) AS "Number of Sales"
FROM Orders
WHERE Country LIKE '%x%' OR Country LIKE '%y%' OR Country LIKE '%z%'
GROUP BY Country

/*
For each of the countries identified in the previous query, determine the total profit and
profit per sale. Assign the aliases "Total Profit" and "Profit per Sale", respectively, and
order the results in descending order by "Profit per Sale".
*/

SELECT Country, SUM(Profit) * 1.0 AS "Total Profit", SUM(Profit) * 1.0 / COUNT(*) AS "Profit per Sale"
FROM Orders
ORDER BY "Profit per Sale" DESC;

/*
Modify the previous query so that it produces a similar output but only includes countries
whose names contain "X", "Y", or "Z" (or "x", "y", or "z").
*/

SELECT Country, SUM(Profit) * 1.0 AS "Total Profit", Sum(Profit) * 1.0 / Count(*) AS "Profit per Sale"
FROM Orders
WHERE Country LIKE '%x%' OR Country LIKE '%y%' OR COUNTRY LIKE '%z%'
GROUP BY "Profit per Sale" DESC;

/*
Modify the previous query so that it produces a similar output for the previously identified
countries but only includes those where either total profit or profit per sale is negative.
*/

SELECT Country, SUM(Profit) * 1.0 AS "Total Profit", SUM(Profit) * 1.0 / Count(*) AS "Profit per Sale"
FROM Orders
WHERE SUM(Total Profit) < 0 OR "Profit per Sale" < 0
GROUP BY "Profit Per Sale" DESC;

/*
From the full set of countries, choose three countries and determine the total number of
units sold (using the "Quantity" column), total sales, sales per unit, total profit, and profit
per unit for each country. Assign meaningful aliases.
*/

SELECT Country, SUM(Quantity) AS "Total Quantity", SUM(Sales) AS "Total Sales", SUM(Sales) * 1.0 / Sum(Quantity) AS "Sales per Unit",
        SUM(Profit) * 1.0 / Sum(Quantity) AS "Profit per Unit"
FROM Orders

/*
Modify the previous query to report the total number of units sold, total sales, sales per
unit, total profit, and profit per unit on an annual basis for the chosen countries, extracting
the year from either "Order ID" or "Order Date". Order the results in ascending order by
country and year and assign meaningful aliases.
*/

SELECT Country, SUBSTR(OrderID, 1, 4) AS Year, SUM(Quantity) AS "Total Quantity", SUM(Sales) AS "Total Sales", SUM(Sales) * 1.0 / SUM(Quantity) AS "Sales per Unit",
        SUM(Profit) * 1.0 / SUM(Quantity) AS "Profit per Unit"
FROM Orders
GROUP BY Country, Year

/*
Modify the previous query to report the total number of units sold, total sales, sales per
unit, total profit, and profit per unit on a monthly basis within each year for the chosen
countries. Order the results in ascending order by country, year, and month.
*/

SELECT 
    Country,
    SUBSTR(OrderID, 1, 4) AS Year,
    SUBSTR(OrderDate, 6, 2) AS Month,
    SUM(Quantity) AS "Total Quantity", SUM(Sales) AS "Total Sales", SUM(Sales) * 1.0 / SUM(Quantity) AS "Sales per Unit", SUM(Profit) * 1.0 / SUM(Quantity) AS "Profit per Unit"
FROM Orders;

/*
Retrieve all unique regions contained in the database (using the column "Region") and
determine the total number of units sold, total sales, sales per unit, total profit, and profit
per unit for each region over all years. Assign meaningful aliases.
*/

SELECT Region, SUM(Quantity) AS "Total Quantity Per Region", SUM(Sales) AS "Total Sales Per Region", SUM(Sales) * 1.0 / SUM(Quantity) AS "Sales per Unit Per Region",
        SUM(Profit) * 1.0 / SUM(Quantity) AS "Profit per Unit Per Region"
FROM Orders;

/*
Modify the previous query to report the total number of units sold, total sales, sales per
unit, total profit, and profit per unit on an annual basis for each region. Order the results
in ascending order by region and year.
*/

SELECT Region, SUBSTR(OrderID, 1, 4) AS Year, SUM(Quantity) AS "Total Quantity Per Region", SUM(Sales) AS "Total Sales Per Region", SUM(Sales) * 1.0 / SUM(Quantity) AS "Sales per Unit Per Region",
        SUM(Profit) * 1.0 / SUM(Quantity) AS "Profit per Unit Per Region"
FROM Orders
GROUP BY Region, Year
ORDER BY Region, Year ASC;

/*
Retrieve the total number of units sold, total sales, sales per unit, total profit, and profit
per unit for each region and regional manager (using the column "Person") on an annual
basis. Assign meaningful aliases. Order the results in ascending order by region, regional
manager, and year.
*/

SELECT 
    O.Region, 
    P.Person, 
    SUBSTR(OrderID, 1, 4) AS Year,
    SUM(O.Quantity) AS "Total Units Sold", SUM(O.Sales) AS "Total Sales", SUM(O.Sales) * 1.0 / SUM(O.Quantity) AS "Sales per Unit",
    SUM(O.Profit) * 1.0 / SUM(O.Quantity) AS "Profit per Unit"
FROM Orders O
JOIN People P ON O.Region = P.Region
GROUP BY O.Region, P.Person, Year
ORDER BY O.Region, P.Person, Year ASC;

/*
Retrieve the lost total profit from returned items for each region and regional manager
over all years. Assign the alias "Lost Total Profit" to the lost profit column. Sort the results
in descending order by lost total profit. Export the results to a CSV file named
"LostProfitByRegion.csv". After executing the query, reset the output mode to column and
redirect the output back to the terminal.
*/

.output LostProfitByRegion.csv

SELECT 
    O.Region,
    P.Person,
    SUM(O.Profit) * -1 AS "Lost Total"
FROM Orders O
JOIN Returns R ON O.OrderID = R.OrderID
JOIN People P ON O.Region = P.Region
GROUP BY O.Region, P.Person
ORDER BY "Lost Total Profit" DESC;

.output stdout
.mode column
