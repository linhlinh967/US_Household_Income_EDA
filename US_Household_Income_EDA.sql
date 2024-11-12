-- DESCRIPTIVE ANALYSIS
-- Summarizing Data by State
SELECT State_ab, State_Name, AVG(ALand), AVG(AWater)
FROM US_Household_Income
GROUP BY State_ab, State_Name
ORDER BY AVG(ALand) DESC;
-- Filtering Cities by Population Range
SELECT City, State_Name, County, ALand
FROM US_Household_Income
WHERE ALand BETWEEN 50000000 AND 100000000
ORDER BY City;
-- Counting Cities per State
SELECT State_Name, State_ab, Count(DISTINCT City)
FROM US_Household_Income
GROUP BY State_Name, State_ab
ORDER BY Count(DISTINCT City) DESC;
-- Identifying Counties with Significant Water Area
SELECT County, State_Name, SUM(AWater)
FROM US_Household_Income
GROUP BY County, State_Name
ORDER BY SUM(AWater) DESC;
-- Finding Cities Near Specific Coordinates
SELECT 
    City,
    State_Name,
    County,
    Lat,
    Lon
FROM US_Household_Income
WHERE Lat BETWEEN 30 AND 35
    AND Lon BETWEEN -90 AND -85
ORDER BY Lat ASC, Lon ASC;
-- Using Window Functions for Ranking
SELECT 
    City,
    State_Name,
    ALand AS Land_Area,
    RANK() OVER (PARTITION BY State_Name ORDER BY ALand DESC) AS Ranking
FROM US_Household_Income
ORDER BY State_Name, Ranking;
-- Creating Aggregate Reports
SELECT 
    State_Name,
    State_ab,
    COUNT(City) AS Number_of_Cities,
    SUM(ALand) AS Total_Land_Area,
    SUM(AWater) AS Total_Water_Area
FROM US_Household_Income
GROUP BY State_Name, State_ab
ORDER BY Total_Land_Area DESC;
-- Subqueries for Detailed Analysis
SELECT 
    City,
    State_Name,
    ALand AS Land_Area
FROM US_Household_Income
WHERE ALand > (SELECT AVG(ALand) FROM US_Household_Income)
ORDER BY ALand DESC;
-- Identifying Cities with High Water to Land Ratios
SELECT 
    City,
    State_Name,
    ALand AS Land_Area,
    AWater AS Water_Area,
    (AWater / ALand) * 100 AS Water_To_Land_Ratio
FROM US_Household_Income
WHERE AWater > 0.5 * ALand
ORDER BY Water_To_Land_Ratio DESC;
-- Dynamic SQL for Custom Reports
DELIMITER //

CREATE PROCEDURE GetStateReport(IN stateAbbrev VARCHAR(2))
BEGIN
    -- Summary report: total number of cities, average land area, and average water area
    SELECT 
        State_Name,
        State_ab,
        COUNT(City) AS Total_Cities,
        AVG(ALand) AS Avg_Land_Area,
        AVG(AWater) AS Avg_Water_Area
    FROM US_Household_Income
    WHERE State_ab = stateAbbrev
    GROUP BY State_Name, State_ab;
    -- Detailed report: list of all cities with their land and water areas
    SELECT 
        City,
        State_Name,
        ALand AS Land_Area,
        AWater AS Water_Area
    FROM US_Household_Income
    WHERE State_ab = stateAbbrev
    ORDER BY City;
END; //
DELIMITER ;
-- Creating and Using Temporary Tables
-- Step 1: Create a temporary table for the top 20 cities by land area
CREATE TEMPORARY TABLE Top20CitiesByLandArea AS
SELECT 
    City,
    State_Name,
    ALand AS Land_Area,
    AWater AS Water_Area
FROM US_Household_Income
ORDER BY ALand DESC
LIMIT 20;
SELECT 
    City,
    State_Name,
    Land_Area,
    Water_Area,
    (SELECT AVG(Water_Area) FROM Top20CitiesByLandArea) AS Avg_Water_Area
FROM Top20CitiesByLandArea;
-- Complex Multi-Level Subqueries
SELECT 
    State_Name,
    AVG(ALand) AS Avg_Land_Area
FROM US_Household_Income
GROUP BY State_Name
HAVING AVG(ALand) > (SELECT AVG(ALand) FROM US_Household_Income)
ORDER BY Avg_Land_Area DESC;
-- Optimizing Indexes for Query Performance
EXPLAIN  
	SELECT 
		State_Name, 
		City, 
        County
    FROM US_Household_Income;
CREATE INDEX index_1 ON US_Household_Income(State_Name, City, County);
EXPLAIN  
	SELECT 
		State_Name, 
		City, 
        County
    FROM US_Household_Income;
-- Recursive Common Table Expressions (CTEs)
WITH RECURSIVE CumulativeLandArea AS (
    -- Anchor member: Select the first city in each state
    SELECT 
        City,
        State_Name,
        ALand AS Land_Area,
        ALand AS Cumulative_Land_Area
    FROM US_Household_Income
    WHERE City = (SELECT MIN(City) FROM US_Household_Income AS uhi WHERE uhi.State_Name = US_Household_Income.State_Name)
    UNION ALL
    -- Recursive member: Select the next city and add its land area to the cumulative total
    SELECT 
        uhi.City,
        uhi.State_Name,
        uhi.ALand AS Land_Area,
        cla.Cumulative_Land_Area + uhi.ALand AS Cumulative_Land_Area
    FROM US_Household_Income uhi
    JOIN CumulativeLandArea cla ON uhi.State_Name = cla.State_Name AND uhi.City > cla.City)
SELECT 
    City,
    State_Name,
    Land_Area,
    Cumulative_Land_Area
FROM CumulativeLandArea
ORDER BY State_Name, City;
-- Data Anomalies Detection
WITH AVG_ALand_by_state AS (
SELECT 
		State_Name,
		AVG(ALand) AS avg_ALand,
		stddev(ALand) AS stddev_ALand
FROM US_Household_Income
GROUP BY State_Name), 
Anomalies_Score AS (
SELECT a.State_Name, City, ALand, avg_ALand, stddev_ALand
FROM US_Household_Income a
LEFT JOIN AVG_ALand_by_state b ON a.State_Name = b.State_Name)
SELECT State_Name, City, (ALand - avg_ALand)/stddev_ALand AS z_score
FROM Anomalies_Score
WHERE (ALand - avg_ALand)/stddev_ALand NOT BETWEEN -2 and 2;
-- Stored Procedures for Complex Calculations
DELIMITER //

CREATE PROCEDURE PredictAreaTrends(
    IN input_city VARCHAR(100),
    IN input_state VARCHAR(100),
    OUT predicted_land_area DECIMAL(10, 2),
    OUT predicted_water_area DECIMAL(10, 2)
)
BEGIN
    DECLARE slope_land DECIMAL(10, 5);
    DECLARE intercept_land DECIMAL(10, 5);
    DECLARE slope_water DECIMAL(10, 5);
    DECLARE intercept_water DECIMAL(10, 5);
    DECLARE current_year INT;
    DECLARE next_year INT;

    -- Get the current year
    SET current_year = YEAR(CURDATE());
    SET next_year = current_year + 1;

    -- Calculate the slope and intercept for land area using linear regression
    SELECT 
        SUM((YEAR(date_recorded) - AVG(YEAR(date_recorded))) * (land_area - AVG(land_area))) /
        SUM(POW(YEAR(date_recorded) - AVG(YEAR(date_recorded)), 2)),
        AVG(land_area) - (slope_land * AVG(YEAR(date_recorded)))
    INTO 
        slope_land, intercept_land
    FROM 
        US_Household_Income
    WHERE 
        City = input_city AND State_Name = input_state;

    -- Calculate the slope and intercept for water area using linear regression
    SELECT 
        SUM((YEAR(date_recorded) - AVG(YEAR(date_recorded))) * (water_area - AVG(water_area))) /
        SUM(POW(YEAR(date_recorded) - AVG(YEAR(date_recorded)), 2)),
        AVG(water_area) - (slope_water * AVG(YEAR(date_recorded)))
    INTO 
        slope_water, intercept_water
    FROM 
        US_Household_Income
    WHERE 
        City = input_city AND State_Name = input_state;

    -- Calculate predicted values for the next year
    SET predicted_land_area = intercept_land + (slope_land * next_year);
    SET predicted_water_area = intercept_water + (slope_water * next_year);
END //

DELIMITER ;
-- Implementing Triggers for Data Integrity
DELIMITER //

CREATE TRIGGER UpdateSummaryTable
AFTER INSERT ON US_Household_Income
FOR EACH ROW
BEGIN
    INSERT INTO SummaryTable (State_Name, Total_Land_Area, Total_Water_Area, City_Count)
    VALUES (NEW.State_Name, NEW.ALand, NEW.AWater, 1)
    ON DUPLICATE KEY UPDATE
    Total_Land_Area = Total_Land_Area + NEW.ALand,
    Total_Water_Area = Total_Water_Area + NEW.AWater,
    City_Count = City_Count + 1;
END //

DELIMITER ;

-- Advanced Data Encryption and Security
-- Encrypt data
UPDATE US_Household_Income 
SET Zip_Code = AES_ENCRYPT(Zip_Code, 'secret_key'), 
    Area_Code = AES_ENCRYPT(Area_Code, 'secret_key');

-- Decrypt data for authorized users
SELECT 
    City,
    State_Name,
    AES_DECRYPT(Zip_Code, 'secret_key') AS Decrypted_Zip_Code,
    AES_DECRYPT(Area_Code, 'secret_key') AS Decrypted_Area_Code
FROM US_Household_Income;

-- Geospatial Analysis using Haversine formula
SELECT 
    City,
    State_Name,
    County,
    (6371 * ACOS(COS(RADIANS(given_lat)) * COS(RADIANS(Lat)) *
    COS(RADIANS(Lon) - RADIANS(given_lon)) +
    SIN(RADIANS(given_lat)) * SIN(RADIANS(Lat)))) AS Distance
FROM US_Household_Income
HAVING Distance <= given_radius
ORDER BY Distance;

-- Analyzing Correlations
SELECT 
    State_Name,
    CORR(ALand, AWater) AS Correlation_Coefficient
FROM US_Household_Income
GROUP BY State_Name;

-- Hotspot Detection

WITH StateStats AS (
    SELECT 
        State_Name,
        AVG(ALand) AS Avg_Land,
        STDDEV(ALand) AS StdDev_Land,
        AVG(AWater) AS Avg_Water,
        STDDEV(AWater) AS StdDev_Water
    FROM US_Household_Income
    GROUP BY State_Name
),
Hotspots AS (
    SELECT 
        u.City,
        u.State_Name,
        u.ALand,
        u.AWater,
        (u.ALand - s.Avg_Land) / s.StdDev_Land AS Land_ZScore,
        (u.AWater - s.Avg_Water) / s.StdDev_Water AS Water_ZScore
    FROM US_Household_Income u
    JOIN StateStats s ON u.State_Name = s.State_Name
    WHERE ABS((u.ALand - s.Avg_Land) / s.StdDev_Land) > 2
       OR ABS((u.AWater - s.Avg_Water) / s.StdDev_Water) > 2
)
SELECT 
    City, 
    State_Name, 
    ALand, 
    AWater, 
    Land_ZScore, 
    Water_ZScore
FROM Hotspots;
-- Resource Allocation Optimization	
WITH TotalAreas AS (
    SELECT 
        City,
        State_Name,
        ALand,
        AWater,
        (ALand + AWater) AS Total_Area
    FROM US_Household_Income
),
ResourceDistribution AS (
    SELECT 
        City,
        State_Name,
        ALand,
        AWater,
        Total_Area,
        (Total_Area / (SELECT SUM(Total_Area) FROM TotalAreas)) * total_resources AS Allocated_Resources
    FROM TotalAreas
)
SELECT 
    City, 
    State_Name, 
    ALand, 
    AWater, 
    Allocated_Resources
FROM ResourceDistribution
ORDER BY Allocated_Resources DESC;
