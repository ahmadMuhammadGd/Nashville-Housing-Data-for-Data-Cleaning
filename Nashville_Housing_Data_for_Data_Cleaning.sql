SELECT *
FROM [dbo].[Nashville Housing Data for Data Cleaning];

/*
------------------------------------------------------------------------------------------
							                H A N D L I N G    N U L L S
------------------------------------------------------------------------------------------
*/

-- Duplicated parcelIds are found for the same property address, 
-- Some property addresses are NULLs, it can be populated with parcelId.
SELECT A.UniqueID, A.ParcelID, A.PropertyAddress, B.UniqueID, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress) AS POPULATED_PropertyAddress
FROM [dbo].[Nashville Housing Data for Data Cleaning] A
JOIN [dbo].[Nashville Housing Data for Data Cleaning] B
ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM [dbo].[Nashville Housing Data for Data Cleaning] A
JOIN [dbo].[Nashville Housing Data for Data Cleaning] B
ON A.ParcelID = B.ParcelID AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL;


/*
------------------------------------------------------------------------------------------
							            D A T A    M A N I P U L A T I N G    
------------------------------------------------------------------------------------------
*/
-- BREAKING ADDRESS DOWN TO: ADDRESS, CITY
SELECT PropertyAddress, 
		SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS PROP_ADDRESS,
		SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS PROP_CITY,
		SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress)-1) AS OWNER_ADDRESS,
		SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress)+1, LEN(OwnerAddress)) AS OWNER_CITY
FROM [dbo].[Nashville Housing Data for Data Cleaning];

-- Step 1: Add new columns to the table

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN		PROPERTY_ADDRESS, PROPERTY_CITY, OWNER_ADDRESS, OWNER_CITY;

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning] ADD
		PROPERTY_ADDRESS	VARCHAR(250);
ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning] ADD
		PROPERTY_CITY		VARCHAR(250);
ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning] ADD
		OWNER_ADDRESS		VARCHAR(250);
ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning] ADD
		OWNER_CITY			VARCHAR(250);

-- Step 2: Update the new columns with values
UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET PROPERTY_ADDRESS = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1),
    PROPERTY_CITY = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)),
    OWNER_ADDRESS = SUBSTRING(OwnerAddress, 1, CHARINDEX(',', OwnerAddress) - 1),
    OWNER_CITY = SUBSTRING(OwnerAddress, CHARINDEX(',', OwnerAddress) + 1, LEN(OwnerAddress));

/*
------------------------------------------------------------------------------------------
						            	 C H A N G E    T O    YES   AND    NO    
------------------------------------------------------------------------------------------
*/
SELECT 
    CAST(SoldAsVacant AS VARCHAR) AS S,
    CASE 
        WHEN SoldAsVacant = 0 THEN 'NO'
        WHEN SoldAsVacant = 1 THEN 'YES'
        ELSE CAST(SoldAsVacant AS VARCHAR)
	END
FROM [dbo].[Nashville Housing Data for Data Cleaning];

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
ADD IFSoldAsVacant	VARCHAR (50);

UPDATE [dbo].[Nashville Housing Data for Data Cleaning]
SET IFSoldAsVacant =    
	CASE 
        WHEN SoldAsVacant = 0 THEN 'NO'
        WHEN SoldAsVacant = 1 THEN 'YES'
        ELSE CAST(SoldAsVacant AS VARCHAR)
	END

ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN SoldAsVacant;


/*
------------------------------------------------------------------------------------------
						        	R E M O V I N G   D U P L I C A T E S    
------------------------------------------------------------------------------------------
*/
WITH ROWNUM_CTE AS (
SELECT *, ROW_NUMBER() OVER ( 
							PARTITION BY PARCELID, PROPERTYADDRESS, SALEPRICE, SALEDATE, LEGALREFERENCE
							ORDER BY UNIQUEID
							)ROWNUM
FROM [dbo].[Nashville Housing Data for Data Cleaning]
)

DELETE FROM ROWNUM_CTE WHERE ROWNUM > 1;


/*
------------------------------------------------------------------------------------------
					        	D E L E T E    U N U E S A B L    C O L U M N S    
------------------------------------------------------------------------------------------
*/

SELECT *
FROM [dbo].[Nashville Housing Data for Data Cleaning]

-- Drop PropertyAddress column
ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN PropertyAddress;

-- Drop OWNERADDRESS column
ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN OWNERADDRESS;

-- Drop TAXDISTRICT column
ALTER TABLE [dbo].[Nashville Housing Data for Data Cleaning]
DROP COLUMN TAXDISTRICT;

