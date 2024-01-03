#This is the data cleaning process

SELECT*
FROM customer_sweepstakes
;

#step 1: always ensure that you have a duplicate of the table that you will be cleaning. This is important because the table will be altered and data will be deleted

#Step 2: Rename any column that doesn't have a proper name
ALTER TABLE customer_sweepstakes RENAME COLUMN `Are you over 18?` TO `OVER_18`
;

ALTER TABLE customer_sweepstakes RENAME COLUMN `ï»¿sweepstake_id` TO `sweepstake_id`
;

#Step 3: Identify the number of duplicates 

#OPTION A
SELECT customer_id, COUNT(customer_id)
FROM customer_sweepstakes
GROUP BY customer_id
HAVING COUNT(customer_id) > 1
;

#OPTION B
SELECT*
FROM (SELECT customer_id,
ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id) AS row_num
FROM customer_sweepstakes) AS table_num
WHERE row_num > 1;

#STEP 4: Delete duplicate rows
DELETE FROM customer_sweepstakes
WHERE sweepstake_id IN (
	SELECT sweepstake_id 
	FROM (
		SELECT sweepstake_id,
		ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY customer_id) AS row_num
		FROM customer_sweepstakes) AS table_num
		WHERE row_num > 1
        );

#STANDERDIZING the data (check if things like phone numbers, birth dates and things like YES(Y) and NO (N) so they can have the same consistent pattern).

#Ex: Phone number: some numbers might be 635-573-9754 or 7292879456 or (975)357-7663 (none of these are consistent with each other

SELECT phone, REGEXP_REPLACE(phone, '[[\]\\[!@#$%.&*`~^_{}:;<>/\\|()-]+]','') #this is replacing all symbol with a space
FROM customer_sweepstakes
;

UPDATE customer_sweepstakes
SET phone = REGEXP_REPLACE(phone, '[[\]\\[!@#$%.&*`~^_{}:;<>/\\|()-]+]','')
;

SELECT phone
FROM customer_sweepstakes
;

#NOW SEPERATE THE NUMBERS AND THEN BRING THEM BACK TOGETHER WITH DASHES TO MAKE THEM MORE UNIFORM

#SEPARATING PHASE
SELECT phone, SUBSTRING(PHONE,1,3), SUBSTRING(PHONE,4,3), SUBSTRING(PHONE,7,4)
FROM customer_sweepstakes
;

#BRING THE NUMBER BACK TOGETHER PHASE (WITH DASHES)
SELECT phone, CONCAT(SUBSTRING(PHONE,1,3), '-', SUBSTRING(PHONE,4,3), '-', SUBSTRING(PHONE,7,4))
FROM customer_sweepstakes
WHERE phone != ''
;

UPDATE customer_sweepstakes
SET phone = CONCAT(SUBSTRING(PHONE,1,3), '-', SUBSTRING(PHONE,4,3), '-', SUBSTRING(PHONE,7,4))
WHERE phone != ''
;

SELECT phone
FROM customer_sweepstakes
;

#STEP 5: making items in a column uniform

SELECT OVER_18,
CASE 
	WHEN OVER_18 = 'Yes' THEN 'Y'
    WHEN OVER_18 = 'No' THEN 'N'
    ELSE OVER_18
END
FROM customer_sweepstakes;

UPDATE customer_sweepstakes
SET OVER_18 = CASE 
	WHEN OVER_18 = 'Yes' THEN 'Y'
    WHEN OVER_18 = 'No' THEN 'N'
    ELSE OVER_18
END
;

SELECT *
FROM customer_sweepstakes;

#STEP 7: SEPARATING COLUMNS 

SELECT address,
SUBSTRING_INDEX(address,',',1) AS Street,
SUBSTRING_INDEX(SUBSTRING_INDEX(address,',',2),',',-1) AS City,
SUBSTRING_INDEX(address,',',-1) AS State
FROM customer_sweepstakes;

#CREATING NEW COLUMN TO SET DATA IN FROM SPLIT COLUMNS

ALTER TABLE customer_sweepstakes
ADD COLUMN Street VARCHAR(50) AFTER address,
ADD COLUMN City VARCHAR(50) AFTER Street,
ADD COLUMN State VARCHAR(50) AFTER City
;

#adding data to column
SELECT address,
SUBSTRING_INDEX(address,',',1) AS Street,
SUBSTRING_INDEX(SUBSTRING_INDEX(address,',',2),',',-1) AS City,
SUBSTRING_INDEX(address,',',-1) AS State
FROM customer_sweepstakes;

UPDATE customer_sweepstakes
SET Street = SUBSTRING_INDEX(address,',',1)
;

UPDATE customer_sweepstakes
SET City = SUBSTRING_INDEX(SUBSTRING_INDEX(address,',',2),',',-1)
;

UPDATE customer_sweepstakes
SET State = SUBSTRING_INDEX(address,',',-1)
;

SELECT *
FROM customer_sweepstakes;

# MAKE THE STATES CONSISTENT...MAKE SURE THEY ARE ALL IN UPPERCASE 

SELECT state, UPPER(state)
FROM customer_sweepstakes
;

UPDATE customer_sweepstakes
SET state = UPPER(state)
;

#STEP 8: WORKING WITH NULL VALUES 

UPDATE customer_sweepstakes
SET phone = NULL
WHERE phone = ''
;

UPDATE customer_sweepstakes
SET income = NULL
WHERE income = ''
;

SELECT *
FROM customer_sweepstakes;


#STEP 9: DELETING COLUMNS

ALTER TABLE customer_sweepstakes
DROP address,
DROP favorite_color
;


