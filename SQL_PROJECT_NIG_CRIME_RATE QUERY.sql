CREATE DATABASE nigeria_crime_rate;
show databases;
SELECT * FROM nigeria_crime_rate_dataset;




-- question 1. What is the average response time by crime type, and how does it compare across states?
SELECT Crime_Type,State,ROUND(AVG(Response_Time))
FROM nigeria_crime_rate_dataset
GROUP BY 1,2
ORDER BY 1 DESC,2 DESC,3 DESC;

      



-- question 2 Which cities have the highest rates of specific crimes (e.g., Theft), and how do they rank within each state?
 WITH A AS (SELECT State,City,Crime_Type,COUNT(Crime_Type) AS Crimerate,
RANK()OVER(PARTITION BY Crime_Type ORDER BY COUNT(Crime_Type) DESC) AS RANKS
FROM nigeria_crime_rate_dataset
GROUP BY 1,2,3
ORDER BY 3,4 DESC)
SELECT City,Crime_Type, Crimerate, RANKS FROM A;
 
 
WITH A AS (SELECT State,City,Crime_Type,COUNT(Crime_Type) AS Crimerate,
RANK()OVER(PARTITION BY Crime_Type ORDER BY COUNT(Crime_Type) DESC) AS RANKS
FROM nigeria_crime_rate_dataset
GROUP BY 1,2,3
ORDER BY 3,4 DESC)
SELECT City,Crime_Type, Crimerate, RANKS FROM A
where RANKS = 1
order by RANKS;
    
	

    -- question 3. What is the trend of crime severity over time, especially in major cities?
    
SELECT City,YEAR(Date_Reported),ROUND(AVG(Severity),2)
FROM nigeria_crime_rate_dataset
where city in ('Ibadan','Port Harcourt','Lekki','Nsuka','Wuse','Zaria','Wari','Asaba','Kaduna North')
GROUP BY 1,2
ORDER BY 2,3 DESC;

    -- question 4 Identify the top 5 states with the highest percentage of unsolved cases.
 WITH A AS (SELECT State,Count(Outcome) AS UNRESOLVED,(SELECT COUNT(Outcome) from nigeria_crime_rate_dataset WHERE Outcome IN ("In Court","Open"))
    from nigeria_crime_rate_dataset
    WHERE Outcome IN ("Open","In Court")
    group by 1
    ORDER BY 2 DESC
    LIMIT 5)
    SELECT State,UNRESOLVED, ROUNd((UNRESOLVED
    /
    (SELECT COUNT(Outcome) from nigeria_crime_rate_dataset
    WHERE Outcome IN ("In Court","Open"))) * 100) as unsolved_percentage
    FROM A;
    
  

-- question 5. What is the monthly trend in the number of arrests by crime type
select Crime_Type,Date_Reported,monthname(Date_Reported) as monthlytrend,MONTH(Date_Reported) as MONTH_NUMBER,
count(Arrest_Made) as Arrestmade
FROM
    nigeria_crime_rate_dataset
    where Arrest_Made = 'yes'
GROUP BY 1,2,3
order by 3 desc;
   
  
  
  
  -- question 6.   Which officers have handled the most severe cases, and what is the average severity rating they deal with?
  
  select Officer_ID,COUNT(Severity),ROUND(AVG(Severity)) from nigeria_crime_rate_dataset
  WHERE Severity >=3
  GROUP BY 1
  ORDER BY 2 DESC
  LIMIT 5;
  
  

 -- question 7 .Calculate the average age difference between victims and suspects by crime type and city.
-- ABS IS USED NOT TO SHOW NEGATIVE VALUE.
SELECT City,Crime_Type,ABS(ROUND(AVG(Victim_Age)-AVG(Suspect_Age))) AS AVG_DIFF_AGE FROM nigeria_crime_rate_dataset
WHERE Suspect_Age <>""
GROUP BY 1,2
ORDER BY 1 DESC, 2 DESC;




 -- question 8 .What percentage of crimes are reported by citizens versus authorities, and does this vary by region?
SELECT State,Reported_By,count(Crime_Type) as Crimes_reported_by from nigeria_crime_rate_dataset
group by 1,2;
 WITH CTE1 AS (SELECT CASE
WHEN State IN ('Enugu','Abia','Imo','Anambra','Ebonyi') THEN 'SOUTH_East' 
WHEN State IN ('Ondo','Ekiti','Lagos','Ogun','Oyo','Osun') THEN 'SOUTH_West'
WHEN State IN ('Kano','kaduna','Katsin','Kebbi','Sokoto','Jigawa','Zamfara') THEN 'North_West' 
WHEN State IN ('Kwara','Kogi','Abuja','Niger','Nasarawa','Plateau','Benue') THEN 'North_Central'  
WHEN State IN ('Borno','Adamawa','Bauchi','Gombe','Taraba','Yobe') THEN 'North_East'
WHEN State IN ('Delta','Cross_River','Rivers','Akwa_Ibom','Bayelsa','Edo') THEN 'South_South'  
END AS Report_By_Region,Reported_By,COUNT(*) AS Reported_cases,(SELECT COUNT(*) 
FROM nigeria_crime_rate_dataset) AS Total_reported_cases
from nigeria_crime_rate_dataset 
Group By 1,2
ORDER BY 1 DESC,3 DESC)
SELECT Report_By_Region,Reported_By,ROUND((Reported_cases/Total_reported_cases)* 100,2) AS Percentage_by_Crimes FROM CTE1;



 -- question 9. Find the top 3 cities with the highest response times and analyze the average severity of cases in these cities.
 SELECT City,ROUND(AVG(Response_Time)),
 ROUND(AVG(Severity))
 FROM nigeria_crime_rate_dataset
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 3 ;
 
 
 
  -- question 10. What is the average case resolution time by crime type, and how does it vary between states?
SELECT State,Crime_Type,ROUND(AVG(datediff(CURDATE(),Date_Reported)/365)) AS CASE_RESOLUTION FROM nigeria_crime_rate_dataset
GROUP BY 1,2;

 -- question 11. Identify the state and city combinations with the highest rate of violent crimes (e.g., Homicide, Assault).
 WITH CTE AS (SELECT CONCAT(City,",",State) as StateCity,COUNT(Crime_Type) as Count_crime_type,( SELECT COUNT(*) FROM nigeria_crime_rate_dataset) Total_crime
FROM nigeria_crime_rate_dataset
 WHERE Crime_Type NOT IN ('Fraud','Theft')
 GROUP BY 1
 ORDER BY 2 DESC)
 SELECT StateCity,round((Count_crime_type/Total_crime )* 100,2) violent_crimes_percentage FROM  CTE; 
 
 
-- question 12. What is the distribution of crime types among different age groups of victims?
SELECT Crime_Type,COUNT(*) as age_distribution,Victim_Age  From nigeria_crime_rate_dataset
group by 1,3;
SELECT CASE  
WHEN Victim_Age BETWEEN 0 AND 25 THEN "0-25"
WHEN Victim_Age BETWEEN 25 AND 45 THEN "25-45"
WHEN Victim_Age BETWEEN 45 AND 65 THEN "45-65"
WHEN Victim_Age BETWEEN 65 AND 80 THEN "65-80"
END AS Victims_Age_Group,COUNT(*),Crime_Type from nigeria_crime_rate_dataset
group by 1,3
order by 1 desc;


-- question 13. Identify the top 5 officers based on case closure rates and their average response times.

With A  AS (SELECT Officer_ID,count(Outcome) as Case_closed,ROUND(AVG(Response_Time)) AS AVG_Response_Time,
(SELECT COUNT(*) from nigeria_crime_rate_dataset where Outcome ='Closed') as Total_Outcome
 FROM nigeria_crime_rate_dataset
WHERE Outcome = "Closed"
GROUP BY 1
ORDER BY 2 DESC,3
LIMIT 5)

SELECT Officer_ID,Case_closed,AVG_Response_Time,Total_Outcome,
ROUND((Case_closed/Total_Outcome)* 100,2) as Case_Closure_rate from A;


-- question 14. Calculate the monthly increase or decrease in crime rates per state and rank them by region?
-- LAG IS USED TO ACCESS PREVIOUS ROWS eg
WITH A AS (WITH CTE AS (SELECT State,MONTH(Date_Reported) Month_num,Monthname(Date_Reported) Months,
COUNT(Crime_Type) current_month_crimes,
LAG( COUNT(Crime_Type),1,0) OVER(PARTITION BY State ORDER BY MONTH(Date_Reported))AS Previous_Monh_crimes 
FROM nigeria_crime_rate_dataset
GROUP BY 1,2,3
ORDER BY 1)
SELECT *,(current_month_crimes - Previous_Monh_crimes) as Previous_Monh_crimes_diff,
ROUND(((current_month_crimes - Previous_Monh_crimes)/Previous_Monh_crimes) *100) as Percentage_Monthly_Crime_diff FROM CTE
ORDER BY 1,Month_num)
SELECT State,Month_num,Months,Percentage_Monthly_Crime_diff,
RANK() OVER(PARTITION BY Months ORDER BY Percentage_Monthly_Crime_diff ) as RANKS FROM A;


 -- question 15. Find the average severity of crimes over time for each state and determine if there is a significant upward or downward trend.
 
 SELECT YEAR(Date_Reported), state,ROUND(avg(Severity),1)
 from nigeria_crime_rate_dataset
 group by 1,2
  ORDER BY 1 DESC,3 DESC;
 




-- question 1. What is the average response time by crime type, and how does it compare across states?
SELECT Crime_Type,State,ROUND(AVG(Response_Time))
FROM nigeria_crime_rate_dataset
GROUP BY 1,2
ORDER BY 1 DESC,2 DESC,3 DESC;

      



-- question 2 Which cities have the highest rates of specific crimes (e.g., Theft), and how do they rank within each state?
 
WITH A AS (SELECT State,City,Crime_Type,COUNT(Crime_Type) AS Crimerate,
RANK()OVER(PARTITION BY Crime_Type ORDER BY COUNT(Crime_Type) DESC) AS RANKS
FROM nigeria_crime_rate_dataset
GROUP BY 1,2,3
ORDER BY 3,4 DESC)
SELECT City,Crime_Type, Crimerate, RANKS FROM A
where RANKS = 1
order by State, RANKS ;
    
	

    -- question 3. What is the trend of crime severity over time, especially in major cities?
    
SELECT City,YEAR(Date_Reported),ROUND(AVG(Severity),2)
FROM nigeria_crime_rate_dataset
where city in ('Ibadan','Port Harcourt','Lekki','Nsuka','Wuse','Zaria','Wari','Asaba','Kaduna North')
GROUP BY 1,2
ORDER BY 2,3 DESC;

    -- question 4 Identify the top 5 states with the highest percentage of unsolved cases.
 WITH A AS (SELECT State,Count(Outcome) AS UNRESOLVED,(SELECT COUNT(Outcome) from nigeria_crime_rate_dataset WHERE Outcome IN ("In Court","Open"))
    from nigeria_crime_rate_dataset
    WHERE Outcome IN ("Open","In Court")
    group by 1
    ORDER BY 2 DESC
    LIMIT 5)
    SELECT State,UNRESOLVED, ROUNd((UNRESOLVED
    /
    (SELECT COUNT(Outcome) from nigeria_crime_rate_dataset
    WHERE Outcome IN ("In Court","Open"))) * 100) as unsolved_percentage
    FROM A;
    
  

-- question 5. What is the monthly trend in the number of arrests by crime type
select Crime_Type,monthname(Date_Reported) as monthlytrend,
count(Arrest_Made) as Arrestmade
FROM
    nigeria_crime_rate_dataset
    where Arrest_Made = 'yes'
GROUP BY 1,2
order by 2 desc, 3 desc;
   
  
  
  
  -- question 6.   Which officers have handled the most severe cases, and what is the average severity rating they deal with?
  
  select Officer_ID,COUNT(Severity),ROUND(AVG(Severity)) from nigeria_crime_rate_dataset
  WHERE Severity >=3
  GROUP BY 1
  ORDER BY 2 DESC;
  
  

 -- question 7 .Calculate the average age difference between victims and suspects by crime type and city.

SELECT City,Crime_Type,ROUND(AVG(Victim_Age)-AVG(Suspect_Age)) AS AVG_DIFF_AGE FROM nigeria_crime_rate_dataset
WHERE Suspect_Age <>""
GROUP BY 1,2
ORDER BY 1 DESC, 2 DESC;

SELECT City,ROUND(AVG(Victim_Age)-AVG(Suspect_Age)) AS Age_DifF FROM nigeria_crime_rate_dataset
WHERE Suspect_Age <>""
GROUP BY 1;


 -- question 8 .What percentage of crimes are reported by citizens versus authorities, and does this vary by region?
SELECT State,Reported_By,count(Crime_Type) as Crimes_reported_by from nigeria_crime_rate_dataset
group by 1,2;
 WITH CTE1 AS (SELECT CASE
WHEN State IN ('Enugu','Abia','Imo','Anambra','Ebonyi') THEN 'SOUTH_East' 
WHEN State IN ('Ondo','Ekiti','Lagos','Ogun','Oyo','Osun') THEN 'SOUTH_West'
WHEN State IN ('Kano','kaduna','Katsin','Kebbi','Sokoto','Jigawa','Zamfara') THEN 'North_West' 
WHEN State IN ('Kwara','Kogi','Abuja','Niger','Nasarawa','Plateau','Benue') THEN 'North_Central'  
WHEN State IN ('Borno','Adamawa','Bauchi','Gombe','Taraba','Yobe') THEN 'North_East'
WHEN State IN ('Delta','Cross_River','Rivers','Akwa_Ibom','Bayelsa','Edo') THEN 'South_South'  
END AS Report_By_Region,State,Reported_By,COUNT(*) AS Reported_cases,(SELECT COUNT(*) 
FROM nigeria_crime_rate_dataset) AS Total_reported_cases
from nigeria_crime_rate_dataset 
Group By 1,2,3)
SELECT Report_By_Region,Reported_By,ROUND((Reported_cases/Total_reported_cases)* 100,2) AS Percentage_by_Crimes FROM CTE1
ORDER BY 1,3 DESC;


 -- question 9. Find the top 3 cities with the highest response times and analyze the average severity of cases in these cities.
 SELECT City,ROUND(AVG(Response_Time)),
 ROUND(AVG(Severity))
 FROM nigeria_crime_rate_dataset
 GROUP BY 1
 ORDER BY 2 DESC
 LIMIT 3 ;
 
 
 
  -- question 10. What is the average case resolution time by crime type, and how does it vary between states?
SELECT State,Crime_Type,ROUND(AVG(datediff(CURDATE(),Date_Reported)/365)) AS CASE_RESOLUTION FROM nigeria_crime_rate_dataset
GROUP BY 1,2;

 -- question 11. Identify the state and city combinations with the highest rate of violent crimes (e.g., Homicide, Assault).
 WITH CTE AS (SELECT CONCAT(City,",",State) as StateCity,COUNT(Crime_Type) as Count_crime_type,( SELECT COUNT(*) FROM nigeria_crime_rate_dataset) Total_crime
FROM nigeria_crime_rate_dataset
 WHERE Crime_Type NOT IN ('Fraud','Theft')
 GROUP BY 1
 ORDER BY 2 DESC)
 SELECT StateCity,round((Count_crime_type/Total_crime )* 100,2) violent_crimes_percentage FROM  CTE; 
 
 
-- question 12. What is the distribution of crime types among different age groups of victims?
SELECT Crime_Type,COUNT(*) as age_distribution,Victim_Age  From nigeria_crime_rate_dataset
group by 1,3;
SELECT CASE  
WHEN Victim_Age BETWEEN 0 AND 25 THEN "0-25"
WHEN Victim_Age BETWEEN 25 AND 45 THEN "25-45"
WHEN Victim_Age BETWEEN 45 AND 65 THEN "45-65"
WHEN Victim_Age BETWEEN 65 AND 80 THEN "65-80"
END AS Victims_Age_Group,COUNT(*),Crime_Type from nigeria_crime_rate_dataset
group by 1,3
order by 1 desc;


-- question 13. Identify the top 5 officers based on case closure rates and their average response times.

With A  AS (SELECT Officer_ID,count(Outcome) as Case_closed,ROUND(AVG(Response_Time)) AS AVG_Response_Time,
(SELECT COUNT(*) from nigeria_crime_rate_dataset where Outcome ='Closed') as Total_Outcome
 FROM nigeria_crime_rate_dataset
WHERE Outcome = "Closed"
GROUP BY 1
ORDER BY 2 DESC,3
LIMIT 5)

SELECT Officer_ID,Case_closed,AVG_Response_Time,Total_Outcome,
ROUND((Case_closed/Total_Outcome)* 100,2) as Case_Closure_rate from A;


-- question 14. Calculate the monthly increase or decrease in crime rates per state and rank them by region?

WITH A AS (WITH CTE AS (SELECT State,MONTH(Date_Reported) Month_num,Monthname(Date_Reported) Months,
COUNT(Crime_Type) current_month_crimes,
LAG( COUNT(Crime_Type),1,0) OVER(PARTITION BY State ORDER BY MONTH(Date_Reported))AS Previous_Monh_crimes 
FROM nigeria_crime_rate_dataset
GROUP BY 1,2,3
ORDER BY 1)
SELECT *,(current_month_crimes - Previous_Monh_crimes) as Previous_Monh_crimes_diff,
ROUND(((current_month_crimes - Previous_Monh_crimes)/Previous_Monh_crimes) *100) as Percentage_Monthly_Crime_diff FROM CTE
ORDER BY 1,Month_num)
SELECT State,Month_num,Months,Percentage_Monthly_Crime_diff,
RANK() OVER(PARTITION BY Months ORDER BY Percentage_Monthly_Crime_diff ) as RANKS FROM A;


 -- question 15. Find the average severity of crimes over time for each state and determine if there is a significant upward or downward trend.
 
 SELECT YEAR(Date_Reported), state,ROUND(avg(Severity),1)
 from nigeria_crime_rate_dataset
 group by 1,2
 ORDER BY 1 DESC,3 DESC;