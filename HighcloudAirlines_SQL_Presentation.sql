create database Highcloud_Airline;
use Highcloud_Airline;
select * from maindata;

-- 1.calcuate the following fields from the Year Month (#) Day  fields ( First Create a Date Field from Year , Month , Day fields)
  -- A.Year
Set sql_safe_updates=0;
ALTER TABLE maindata ADD COLUMN Date DATE ;
UPDATE maindata SET Date = CONCAT(Year, '-', `Month (#)`, '-', Day);

 -- B.Monthno
ALTER TABLE maindata ADD COLUMN MonthNo INT;
UPDATE maindata SET MonthNo = MONTH(Date);
 
 -- C.Monthfullname 
ALTER TABLE maindata ADD COLUMN MonthFullName VARCHAR(20);
UPDATE maindata SET MonthFullName = MONTHNAME(Date);
  
  -- D.Quarter(Q1,Q2,Q3,Q4)
ALTER TABLE maindata ADD COLUMN Quarter INT;
UPDATE maindata SET Quarter = QUARTER(Date);
 
 -- E. YearMonth ( YYYY-MMM)
ALTER TABLE maindata ADD COLUMN YearMonth VARCHAR(50);
UPDATE maindata SET YearMonth = DATE_FORMAT(Date,'%Y-%b');
 
 -- F. Weekdayno
ALTER TABLE maindata ADD COLUMN WeekdayNo INT;
UPDATE maindata SET WeekdayNo = WEEKDAY(Date);
  
  -- G.Weekdayname
ALTER TABLE maindata ADD COLUMN WeekdayName VARCHAR(10);
UPDATE maindata SET WeekdayName = DAYNAME(Date);
  
  -- H.FinancialMonth
-- Assuming financial year starts in April
ALTER TABLE maindata ADD COLUMN FinancialMonth INT;
UPDATE maindata SET FinancialMonth = MONTH(Date) - 3;
UPDATE maindata SET FinancialMonth = IF(FinancialMonth <= 0, FinancialMonth + 12, FinancialMonth);
 
 -- I. Financial Quarter
ALTER TABLE maindata ADD COLUMN FinancialQuarter INT;
UPDATE maindata
SET FinancialQuarter = 
    CASE 
        WHEN MONTH(Date) IN (4, 5, 6) THEN 1  -- April, May, June (Q1)
        WHEN MONTH(Date) IN (7, 8, 9) THEN 2  -- July, August, September (Q2)
        WHEN MONTH(Date) IN (10, 11, 12) THEN 3  -- October, November, December (Q3)
        ELSE 4  -- January, February, March (Q4)
    END;

select* from maindata;

create view Date_Field as 
Select 
 Date,
    MonthNo,
    MonthFullName,
    Quarter,
    YearMonth,
    WeekdayNo,
    WeekdayName,
    FinancialMonth,
    FinancialQuarter
from maindata;

Select*from Date_field;

-- 2. Find the load Factor percentage on a yearly , Quarterly , Monthly basis ( Transported passengers / Available seats)

-- Yearly Load Factor
SELECT Year, Round(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100,2) AS LoadFactor
FROM maindata
GROUP BY Year;

-- Quarterly Load Factor
SELECT Year,Quarter, Round(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100,2) AS LoadFactor
FROM maindata
GROUP BY Year, Quarter order by Year, Quarter;

-- Monthly Load Factor
SELECT Year, MonthNo, Round(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100,2) AS LoadFactor
FROM maindata
GROUP BY Year, MonthNo order by Year, MonthNo;

-- 3. Find the load Factor percentage on a Carrier Name basis ( Transported passengers / Available seats)
SELECT Year, `Carrier Name`, Round(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100,2) AS LoadFactor
FROM maindata
GROUP BY Year, `Carrier Name` order by Year, Loadfactor desc ;

-- 4. Identify Top 10 Carrier Names based passengers preference 
SELECT Year, `Carrier Name`, TotalPassengers
FROM (
    SELECT Year, `Carrier Name`, 
           SUM(`# Transported Passengers`) AS TotalPassengers,
           RANK() OVER (PARTITION BY Year ORDER BY SUM(`# Transported Passengers`) DESC) AS CarrierRank
    FROM maindata
    GROUP BY Year, `Carrier Name`
) AS RankedData
WHERE CarrierRank <= 10
ORDER BY Year, CarrierRank;


-- 5. Display top Routes ( from-to City) based on Number of Flights 
SELECT Year, `From - To City`, NumFlights
FROM (
    SELECT Year, `From - To City`, 
           COUNT(*) AS NumFlights,
           RANK() OVER (PARTITION BY Year ORDER BY COUNT(*) DESC) AS CityRank
    FROM maindata
    GROUP BY Year, `From - To City`
) AS RankedData
WHERE CityRank =1
ORDER BY Year;


-- 6. Identify the how much load factor is occupied on Weekend vs Weekdays.
SELECT Year,
       CASE WHEN WeekdayNo IN (0, 6) THEN 'Weekend' ELSE 'Weekday' END AS DayType,
       Round(SUM(`# Transported Passengers`) / SUM(`# Available Seats`) * 100,2) AS LoadFactor
FROM maindata
GROUP BY Year, DayType
order by Year, DayType;

Alter table `distance groups` change column `ï»¿%Distance Group ID` `%Distance Group ID` INT; 

-- 7. Identify number of flights based on Distance group
SELECT Year, 
`distance groups`. `%Distance Group ID`  As Distance_Group_ID,
`distance groups`. `Distance Interval` As Distance_Interval,
 COUNT(*) AS NumFlights
 from `distance groups`
   left join `maindata` on `distance groups`. `%Distance Group ID`= `maindata`.`%Distance Group ID`
Where Year is not null
Group by Year,`distance groups`. `%Distance Group ID`, `distance groups`. `Distance Interval`
order by Year, Distance_Group_ID;
 
