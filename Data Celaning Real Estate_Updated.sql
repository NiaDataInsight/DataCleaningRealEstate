/*

Cleaning Data in SQL Queries with MySQL Workbench

*/

SELECT * FROM `data cleaning`.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format
STR_TO_DATE:

Purpose: Converts a string representation of a date and time into a proper MySQL date/time value.

SELECT 
    SaleDate,
    DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %e, %Y'), '%Y/%m/%d') AS FormattedSaleDate
FROM `data cleaning`.NashvilleHousing;

Updated the column.
-- If it doesn't Update properly

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN FormattedSaleDate DATE;

-- Step 2: Update the new column with converted dates
UPDATE `data cleaning`.NashvilleHousing
SET FormattedSaleDate = STR_TO_DATE(SaleDate, '%M %e, %Y');

-- Step 3: Verify the update
SELECT SaleDate, FormattedSaleDate
FROM `data cleaning`.NashvilleHousing;

--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address data

--Check the null in the PropertyAddress
TRIM function is added to ensure that strings with only spaces are also considered as empty.

SELECT *
FROM `data cleaning`.NashvilleHousing
WHERE PropertyAddress IS NULL OR TRIM(PropertyAddress) = '';


The COALESCE function returns the first non-NULL value in a list. If all values are NULL, it returns NULL.

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
-- Locate and Substring

SELECT PropertyAddress
FROM `data cleaning`.NashvilleHousing

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) as Address
FROM `data cleaning`.NashvilleHousing;

SELECT 
    SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) as Address,
    SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH (PropertyAddress)) as Address
FROM `data cleaning`.NashvilleHousing;

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN PropertySplitAddress VARCHAR (255);

-- Step 2: Update the new column with converted PropertySplitAddress
UPDATE `data cleaning`.NashvilleHousing
SET PropertySplitAddress  = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1) 

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN PropertySplitCity VARCHAR (255);

-- Step 2: Update the new column with converted PropertySplitCity
UPDATE `data cleaning`.NashvilleHousing
SET PropertySplitCity= SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1 , LENGTH (PropertyAddress))


-- To do substring but faster  substring_index (equal as parsname)
-- SUBSTRING_INDEX is designed to split a string into parts based on a delimiter.

SELECT
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3) AS OwnerSplitAddress,
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -2) AS OwnerSplitCity,
    SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -1) AS OwnerSplitState	
FROM `data cleaning`.NashvilleHousing;

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN OwnerSplitAddress VARCHAR (255);

-- Step 2: Update the new column with converted OwnerSplitAddress  
UPDATE `data cleaning`.NashvilleHousing
SET OwnerSplitAddress  = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3)

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN OwnerSplitCity VARCHAR (255);

-- Step 2: Update the new column with converted OwnerSplitCity
UPDATE `data cleaning`.NashvilleHousing
SET OwnerSplitCity = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3)

-- Step 1: Add a new column
ALTER TABLE `data cleaning`.NashvilleHousing ADD COLUMN OwnerSplitState VARCHAR (255);

-- Step 2: Update the new column with converted OwnerSplitState
UPDATE `data cleaning`.NashvilleHousing
SET OwnerSplitState = SUBSTRING_INDEX(REPLACE(OwnerAddress, ',', '.'), '.', -3)
--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
-- SELECT DISTINCT and CASE

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
-- CTE, Partition by, Join

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

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns
-- Drop multiple columns by issuing separate ALTER TABLE statements for each column.

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

select *
FROM `data cleaning`.NashvilleHousing


