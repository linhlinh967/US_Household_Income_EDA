-- Check the Dataset
DESCRIBE US_Household_Income;
SELECT * 
FROM US_Household_Income;
-- The Type column may cause error while processing, so alter the name
ALTER TABLE US_Household_Income CHANGE COLUMN Type Type_ VARCHAR(12) NOT NULL;
-- Find the STRING data column and remove blank space
SELECT COLUMN_NAME 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'US_Household_Income' AND DATA_TYPE IN ('char', 'varchar', 'text');
UPDATE US_Household_Income
SET State_ab = TRIM(State_ab),
State_name = TRIM(State_name),
County = TRIM(County),
City = TRIM(City),
Place = TRIM(Place),
Type_ = TRIM(Type_),
Primary_ = TRIM(Primary_),
Area_Code = TRIM(Area_Code);
-- Check EVERY SINGLE LINE for NULL value and data consistency
SELECT 
    row_id, 
    id, 
    State_Code, 
    State_Name, 
    State_ab, 
    County, 
    City, 
    Place, 
    Type_, 
    Primary_, 
    Zip_Code, 
    Area_Code, 
    ALand, 
    AWater, 
    Lat, 
    Lon
FROM 
    US_Household_Income
WHERE 
    row_id IS NULL OR
    id IS NULL OR
    State_Code IS NULL OR
    State_Name IS NULL OR
    State_ab IS NULL OR
    County IS NULL OR
    City IS NULL OR
    Place IS NULL OR
    Type_ IS NULL OR
    Primary_ IS NULL OR
    Zip_Code IS NULL OR
    Area_Code IS NULL OR
    ALand IS NULL OR
    AWater IS NULL OR
    Lat IS NULL OR
    Lon IS NULL;
-- There is a null value in Place column, DELETE it
DELETE FROM US_Household_Income
WHERE Place IS NULL;
-- Data consistency in every single line
SELECT * FROM US_Household_Income WHERE row_id NOT REGEXP '[0-9]';
SELECT * FROM US_Household_Income WHERE id NOT REGEXP '[0-9]';
SELECT * FROM US_Household_Income WHERE State_Code NOT REGEXP '[0-9]';
SELECT * FROM US_Household_Income WHERE Zip_Code NOT REGEXP '[0-9]{5}'; -- There is some returned row that only have 4 characters zip_code
SELECT * FROM US_Household_Income WHERE Area_Code NOT REGEXP '[0-9]{3}'; -- Only 1 row was returned 'M' as Area_Code
SELECT * FROM US_Household_Income WHERE ALand NOT REGEXP '[0-9]';
SELECT * FROM US_Household_Income WHERE AWater NOT REGEXP '[0-9]';
SELECT * FROM US_Household_Income WHERE Lat NOT REGEXP '[0-9]';
SELECT * FROM US_Household_Income WHERE Lon NOT REGEXP '[0-9]';
SELECT * FROM US_Household_Income WHERE State_Name REGEXP '^[a-z]+$';
SELECT * FROM US_Household_Income WHERE State_ab NOT REGEXP '[A-Z]{2}';
SELECT * FROM US_Household_Income WHERE City NOT REGEXP '[A-Za-z]';
SELECT * FROM US_Household_Income WHERE Type_ NOT REGEXP '[A-Za-z]';
SELECT * FROM US_Household_Income WHERE Primary_ NOT REGEXP '[A-Za-z]';
-- Data consistency in partycular column Type_ Primary_ Zip_Code Area_Code
SELECT Type_ FROM US_Household_Income GROUP BY Type_; -- The values show CPD/CDP and Boroughs/Borough type
DELETE FROM US_Household_Income
WHERE Type_ = '0';
UPDATE US_Household_Income
SET Type_ = CASE 
    WHEN Type_ = 'CPD' THEN 'CDP' -- census-designated place
    WHEN Type_ = 'Boroughs' THEN 'Borough'
END
WHERE Type_ IN ('CPD', 'Boroughs');
SELECT Primary_ FROM US_Household_Income GROUP BY Primary_;
UPDATE US_Household_Income
SET Primary_ = 'Place'
WHERE Primary_ = 'place';
SELECT DISTINCT State_ab, Zip_Code 
FROM US_Household_Income
WHERE Zip_Code NOT REGEXP '[0-9]{5}'; -- The returned zipcode lack of the 1st '0' number
UPDATE US_Household_Income
SET Zip_Code = CONCAT('0', Zip_Code)
WHERE Zip_Code NOT REGEXP '[0-9]{5}';
DELETE FROM US_Household_Income
WHERE Area_Code NOT REGEXP '[0-9]{3}';
-- Duplicate row
WITH duplicate_row AS (
    SELECT id
    FROM US_Household_Income
    GROUP BY id, State_Code, County, City, Zip_Code
    HAVING COUNT(*) > 1
),
numbered_rows AS (
    SELECT row_id
    FROM (
        SELECT row_id, id, ROW_NUMBER() OVER (PARTITION BY id ORDER BY id ASC) AS rn
        FROM US_Household_Income
        WHERE id IN (SELECT id FROM duplicate_row)
    ) AS subquery
    WHERE rn > 1
)
DELETE FROM US_Household_Income
WHERE row_id IN (SELECT row_id FROM numbered_rows);
-- Create PROCEDURE and EVENT for every week automatic cleaning

DELIMITER //

CREATE PROCEDURE data_cleaning() 
BEGIN 
	UPDATE US_Household_Income
	SET State_ab = TRIM(State_ab),
	State_name = TRIM(State_name),
	County = TRIM(County),
	City = TRIM(City),
	Place = TRIM(Place),
	Type_ = TRIM(Type_),
	Primary_ = TRIM(Primary_),
	Area_Code = TRIM(Area_Code);
	
    DELETE FROM US_Household_Income
		WHERE Place IS NULL;
    
    UPDATE US_Household_Income
		SET Type_ = CASE 
			WHEN Type_ = 'CPD' THEN 'CDP' -- census-designated place
			WHEN Type_ = 'Boroughs' THEN 'Borough'
		END
	WHERE Type_ IN ('CPD', 'Boroughs');
    
    UPDATE US_Household_Income
		SET Zip_Code = CONCAT('0', Zip_Code)
		WHERE Zip_Code NOT REGEXP '[0-9]{5}';
	
    DELETE FROM US_Household_Income
		WHERE Area_Code NOT REGEXP '[0-9]{3}';
	
    UPDATE US_Household_Income
		SET Primary_ = 'Place'
		WHERE Primary_ = 'place';
END //

DELIMITER ;
-- Check if event scheduler is enabled
SHOW VARIABLES LIKE 'event_scheduler';
-- Enable the event scheduler globally
SET GLOBAL event_scheduler = ON;
-- Create an event that runs the data cleaning procedure every 7 days
DELIMITER $$ 
CREATE EVENT data_clean_weekly
ON SCHEDULE EVERY 7 DAY
DO
BEGIN
    CALL data_cleaning();
END$$
DELIMITER ;
SHOW EVENTS;