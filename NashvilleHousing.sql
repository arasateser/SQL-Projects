----First SELECT rowS are shows the related problems
--ALL THE DATABASE
SELECT *
FROM DBO.nashville




--Standartize date
SELECT SaleDate, CONVERT(Date,SaleDate)
FROM DBO.nashville

ALTER TABLE dbo.nashville
Add SaleDateConverted Date;

UPDATE nashville
SET SaleDateConverted = CONVERT(Date,SaleDate)




--Populating empty cells in PropertyAdress
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b ON a.[UniqueID ] <> b.[UniqueID ] and a.ParcelID = b.ParcelID
WHERE a.PropertyAddress is null 

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM nashville a
JOIN nashville b ON a.[UniqueID ] <> b.[UniqueID ] and a.ParcelID = b.ParcelID
WHERE a.PropertyAddress is null 




----Breaking out the OwnerAdress into columns NOT FINISHED
--SELECT OwnerAddress, SUBSTRING(OwnerAddress,1,CHARINDEX(',',OwnerAddress)-1) AS First,
--	SUBSTRING(OwnerAddress,CHARINDEX(',',OwnerAddress)+1,LEN(OwnerAddress)) AS Second
--FROM nashville

SELECT OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',','.'),3),
					 PARSENAME(REPLACE(OwnerAddress,',','.'),2),
					 PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM nashville

ALTER TABLE dbo.nashville
ADD OwnerAddress_Address VARCHAR(255)

UPDATE dbo.nashville
SET OwnerAddress_Address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE dbo.nashville
ADD OwnerAddress_City VARCHAR(255)

UPDATE dbo.nashville
SET OwnerAddress_City = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE dbo.nashville
ADD OwnerAddress_State VARCHAR(255)

UPDATE dbo.nashville
SET OwnerAddress_State = PARSENAME(REPLACE(OwnerAddress,',','.'),1)




--Breaking out the PropertyAdress into columns
SELECT PropertyAddress, SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS First,
	SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Second
FROM nashville

ALTER TABLE dbo.nashville
ADD PropertyAddress_Address VARCHAR(255);

UPDATE dbo.nashville
SET PropertyAddress_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE dbo.nashville
ADD PropertyAddress_City VARCHAR(255);

UPDATE dbo.nashville
SET PropertyAddress_City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))




--Chaning Y and N values in SoldAsVacant to Yes and No
SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM nashville

UPDATE nashville
SET SoldAsVacant=
					CASE
						WHEN SoldAsVacant = 'Y' THEN 'Yes'
						WHEN SoldAsVacant = 'N' THEN 'No'
						ELSE SoldAsVacant
					END




-- Removing the dublicate rows
WITH Row_numCTE AS(
SELECT ROW_NUMBER() OVER(PARTITION BY ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice,OwnerName,OwnerAddress,BuildingValue
					ORDER BY UniqueID) row_num, *
FROM nashville
) 
SELECT *
FROM Row_numCTE
WHERE row_num > 1

WITH Row_numCTE AS(
SELECT ROW_NUMBER() OVER(PARTITION BY ParcelID,LandUse,PropertyAddress,SaleDate,SalePrice,OwnerName,OwnerAddress,BuildingValue
					ORDER BY UniqueID) row_num, *
FROM nashville
) 
DELETE
FROM Row_numCTE
WHERE row_num > 1




--Delete splited/converted columns

ALTER TABLE dbo.nashville
DROP COLUMN PropertyAddress, SaleDate, OwnerAddress