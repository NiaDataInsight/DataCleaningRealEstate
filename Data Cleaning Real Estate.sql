/*

Cleaning Data in SQL Queries

*/

SELECT * FROM `data cleaning`.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

SELECT 
    SaleDate,
    DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%Y/%m/%d') AS FormattedSaleDate
FROM `data cleaning`.NashvilleHousing;

Explanation:
STR_TO_DATE:

Purpose: Converts a string representation of a date and time into a proper MySQL date/time value.

Syntax: STR_TO_DATE(str, format)

str: The string you want to convert to a date.
format: The format of the date string you're providing.

Example:
STR_TO_DATE('April 9, 2013', '%M %e, %Y') 
-- Output: 2013-04-09 (a proper MySQL date)

In this example, STR_TO_DATE takes a string ('April 9, 2013') and a format specifier ('%M %e, %Y') and converts it into a MySQL date.

Updated the column
-- If it doesn't Update properly

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN FormattedSaleDate DATE;

-- Step 2: Update the new column with converted dates
UPDATE `data cleaning`.NashvilleHousing
SET FormattedSaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

-- Step 3: Verify the update
SELECT SaleDate, FormattedSaleDate
FROM `data cleaning`.NashvilleHousing;

-- Step 4: If satisfied, drop the old column
-- ALTER TABLE `data cleaning`.NashvilleHousing DROP COLUMN SaleDate;

-- Populate Property Address data

-	Check the null in the propertyaddress
SELECT *
FROM `data cleaning`.NashvilleHousing
WHERE PropertyAddress IS NULL OR TRIM(PropertyAddress) = '';

Make sure to use single quotes ('') for empty strings, and the TRIM function is added to ensure that strings with only spaces are also considered as empty. Adjust the table and column names according to your actual schema and column names.

SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM `data cleaning`.NashvilleHousing A
JOIN `data cleaning`.NashvilleHousing B
	ON A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
    WHERE A.PropertyAddress IS NULL OR TRIM(A.PropertyAddress) = '';

SELECT 
    A.ParcelID, 
    A.PropertyAddress AS Original_PropertyAddress_A,
    B.ParcelID AS ParcelID_B,
    B.PropertyAddress AS Original_PropertyAddress_B,
    COALESCE(NULLIF(TRIM(A.PropertyAddress), ''), B.PropertyAddress) AS Updated_PropertyAddress
FROM 
    `data cleaning`.NashvilleHousing A
JOIN 
    `data cleaning`.NashvilleHousing B
ON 
    A.ParcelID = B.ParcelID
    AND A.UniqueID <> B.UniqueID
WHERE 
    TRIM(A.PropertyAddress) = '';




---------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM `data cleaning`.NashvilleHousing

We change charindex to locate in Mysql workbench

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) as Address
FROM `data cleaning`.NashvilleHousing;

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) as Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH (PropertyAddress)) as Address
FROM `data cleaning`.NashvilleHousing;

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN PropertySplitAddress VARCHAR (255);

-- Step 2: Update the new column with converted dates
UPDATE `data cleaning`.NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) 

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN PropertySplitCity VARCHAR (255);

-- Step 2: Update the new column with converted dates
UPDATE `data cleaning`.NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1 , LENGTH (PropertyAddress))

-To do substring but faster  substring_index (equal as parsname)

SELECT
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3) AS OwnerSplitAddress,
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2) AS OwnerSplitCity,
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) AS OwnerSplitState	
FROM `data cleaning`.NashvilleHousing;

Explanation on why in parsename we use 1 and in substring index we use -1
he reason for using 1 in PARSENAME and -1 in SUBSTRING_INDEX has to do with the different conventions these functions use for indexing parts of a string.

In SQL Server's PARSENAME:

PARSENAME is designed to parse parts of a four-part SQL Server object name (like a table or column with a schema, table, and column name).
The parts are indexed from right to left, with 1 referring to the rightmost part.
In MySQL's SUBSTRING_INDEX:

SUBSTRING_INDEX is designed to split a string into parts based on a delimiter.
The index -1 is used to refer to the last part of the string.
So, in the case of your specific query transformation:

In the SQL Server query, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) is using 1 because it wants the rightmost part after replacing commas with dots.
In the MySQL equivalent, SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) is using -1 because it wants the last part after replacing commas with dots.
It's essentially a difference in indexing conventions between the two functions.

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN OwnerSplitAddress VARCHAR (255);

-- Step 2: Update the new column with converted dates
UPDATE `data cleaning`.NashvilleHousing
SET OwnerSplitAddress  = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3)

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN OwnerSplitCity VARCHAR (255);

-- Step 2: Update the new column with converted dates
UPDATE `data cleaning`.NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3)

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN OwnerSplitState VARCHAR (255);

-- Step 2: Update the new column with converted dates
UPDATE `data cleaning`.NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3)


--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT SoldAsVacant
FROM `data cleaning`.NashvilleHousing;

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM `data cleaning`.NashvilleHousing
Group by SoldAsVacant
order by 2


SELECT
    SoldAsVacant,
    CASE 
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END AS TransformedSoldAsVacant
FROM `data cleaning`.NashvilleHousing;


-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN TransformedSoldAsVacant
 VARCHAR (255);

UPDATE `data cleaning`.NashvilleHousing
SET SoldAsVacant = CASE
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;

-------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY ParcelID,
                         PropertyAddress,
                         SalePrice,
                         SaleDate,
                         LegalReference
            ORDER BY UniqueID
        ) AS row_num
    FROM `data cleaning`.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;

In MySQL, you cannot directly delete from a CTE (Common Table Expression) as you've attempted in your query. MySQL doesn't support using CTEs directly in the DELETE statement.

However, you can achieve the same result using a multi-table DELETE statement. Here's how you can modify your query:

DELETE n
FROM `data cleaning`.NashvilleHousing n
JOIN (
    SELECT UniqueID,
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID,
                            PropertyAddress,
                            SalePrice,
                            SaleDate,
                            LegalReference
               ORDER BY UniqueID
           ) AS row_num
    FROM `data cleaning`.NashvilleHousing
) AS RowNumCTE
ON n.UniqueID = RowNumCTE.UniqueID
WHERE row_num > 1;

This query uses a subquery in the JOIN clause to identify the rows to be deleted based on the ROW_NUMBER() window function. Adjust the column names as needed based on your actual database schema. Before running any delete operation, it's a good practice to have a backup of your data or test the query on a small subset to ensure it behaves as expected.

TO CHECK IF THERE IS STILL DUPLICATES RUN THE FIRST QUERY AGAIN. IF OIT REYURN ON 0 MEANS WE DELETED ALL THE DUPLICATES

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

Unfortunately, in MySQL, you can only drop one column at a time using the ALTER TABLE statement.

If you want to drop multiple columns, you need to issue separate ALTER TABLE statements for each column. Here is the corrected syntax:

ALTER TABLE `data cleaning`.NashvilleHousing
DROP COLUMN OwnerAddress;

ALTER TABLE `data cleaning`.NashvilleHousing
DROP COLUMN TaxDistrict;

ALTER TABLE `data cleaning`.NashvilleHousing
DROP COLUMN PropertyAddress;

ALTER TABLE `data cleaning`.NashvilleHousing
DROP COLUMN SaleDate;

ALTER TABLE `data cleaning`.NashvilleHousing
DROP COLUMN TransformedSoldAsVacant;

ALTER TABLE `data cleaning`.NashvilleHousing
DROP COLUMN ropertySplitCity;

Please execute these statements one by one. Each statement drops a single column from the table. I appreciate your understanding, and I apologize for any inconvenience caused by the confusion.

select *
FROM `data cleaning`.NashvilleHousing
