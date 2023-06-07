------------------------------Cleaning Data Using SQL Queries------------------------------------

---Viewing The Whole Dataset--------------------------------------------------------------------

SELECT *
FROM [Nashville Housing Data].[dbo].[Nashville Housing]


----Populate property address data----------------------------------------------------------------------------------------------------

SELECT *
FROM [Nashville Housing Data].[dbo].[Nashville Housing]
---WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Nashville Housing Data].[dbo].[Nashville Housing] AS A
JOIN [Nashville Housing Data].[dbo].[Nashville Housing] AS B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress,B.PropertyAddress)
FROM [Nashville Housing Data].[dbo].[Nashville Housing] AS A
JOIN [Nashville Housing Data].[dbo].[Nashville Housing] AS B
ON A.ParcelID = B.ParcelID
AND A.UniqueID <> B.UniqueID
WHERE A.PropertyAddress IS NULL 


---------------Breaking out address into individual cololumns (Address, City, State)
SELECT PropertyAddress 
FROM [Nashville Housing Data].[dbo].[Nashville Housing]
--WHERE PropertyAddress IS NULL
---ORDER BY ParcelID

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress )-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress )+1, LEN(PropertyAddress)) AS Address
FROM [Nashville Housing Data].[dbo].[Nashville Housing]

ALTER TABLE [Nashville Housing Data].[dbo].[Nashville Housing]
ADD PropertySplitAddress NVARCHAR(300)
 
UPDATE [Nashville Housing Data].[dbo].[Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress )-1)


ALTER TABLE [Nashville Housing Data].[dbo].[Nashville Housing]
ADD PropertyCityAddress NVARCHAR(300)
 
UPDATE [Nashville Housing Data].[dbo].[Nashville Housing]
SET PropertyCityAddress = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress )+1, LEN(PropertyAddress))


SELECT *
FROM [Nashville Housing Data].[dbo].[Nashville Housing]


--Owners Address

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
       PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM [Nashville Housing Data].[dbo].[Nashville Housing];


ALTER TABLE [Nashville Housing Data].[dbo].[Nashville Housing]
ADD OwnerSplitAddress NVARCHAR(300)
 
UPDATE [Nashville Housing Data].[dbo].[Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE [Nashville Housing Data].[dbo].[Nashville Housing]
ADD OwnerSplitCity NVARCHAR(300)
 
UPDATE [Nashville Housing Data].[dbo].[Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE [Nashville Housing Data].[dbo].[Nashville Housing]
ADD OwnerSplitState NVARCHAR(300)
 
UPDATE [Nashville Housing Data].[dbo].[Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

SELECT *
FROM [Nashville Housing Data].[dbo].[Nashville Housing]


-----------Change Y and N to Yes and No in "Sold As vacant" field-------------------

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM [Nashville Housing Data].[dbo].[Nashville Housing]
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant
, CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END
FROM [Nashville Housing Data].[dbo].[Nashville Housing]


UPDATE [Nashville Housing Data].[dbo].[Nashville Housing]
SET SoldAsVacant= CASE 
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	  ELSE SoldAsVacant
	  END


----------------------Removing Duplicates--------------------------------------------------------------------

WITH RowNumCTE AS(
SELECT *,
  ROW_NUMBER() OVER(
  PARTITION BY ParcelID,
               PropertyAddress,
			   SalePrice,
			   SaleDate,
			   LegalReference
			   ORDER BY 
			   UniqueID
			   ) row_num

FROM [Nashville Housing Data].[dbo].[Nashville Housing]
--ORDER BY ParcelID
)

SELECT * 
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress


--------------Deleting Unused columns-----

SELECT *
FROM [Nashville Housing Data].[dbo].[Nashville Housing]

ALTER TABLE [Nashville Housing Data].[dbo].[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate