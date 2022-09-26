-- Cleaning data in SQL


Select *
From [Project 2].dbo.Nashville_Housing 

---------------
--Standardize Date Format

Select SaleDate, CONVERT (Date,SaleDate) AS SaleDateConverted
From [Project 2].dbo.Nashville_Housing  

Update [Project 2].dbo.Nashville_Housing  
SET SaleDate = CONVERT (Date,SaleDate)

AlTER TABLE [Project 2].dbo.Nashville_Housing
Add SaleDateConverted Date; 

Update [Project 2].dbo.Nashville_Housing  
SET SaleDateConverted = CONVERT (Date,SaleDate)

Select SaleDateConverted /*Verify the new SaleDateConverted Column*/
From [Project 2].dbo.Nashville_Housing  

-------------------------------
--Populate Property Address Data

Select *
From [Project 2].dbo.Nashville_Housing   
--Where PropertyAddress is null 
Order by ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Project 2].dbo.Nashville_Housing a
JOIN [Project 2].dbo.Nashville_Housing b
 On a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From  [Project 2].dbo.Nashville_Housing a
JOIN [Project 2].dbo.Nashville_Housing b
 On a.ParcelID = b.ParcelID
 AND a.[UniqueID] <> b.[UniqueID]
 Where a.PropertyAddress is null

 -------------------------
 --Splitting address into Columns (Property Address to Address, City, State)

 Select PropertyAddress
 From [Project 2].dbo.Nashville_Housing
 
 SELECT
 SUBSTRING(PropertyAddress,	1, CHARINDEX(',', PropertyAddress)-1) as Address
 , SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City

 From  [Project 2].dbo.Nashville_Housing

 AlTER TABLE [Project 2].dbo.Nashville_Housing
Add PropertySplitAddress Nvarchar(255); 

Update [Project 2].dbo.Nashville_Housing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,	1, CHARINDEX(',', PropertyAddress)-1)

 AlTER TABLE [Project 2].dbo.Nashville_Housing
Add PropertySplitCity Nvarchar(255); 

Update [Project 2].dbo.Nashville_Housing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) 

Select * /*Verify the results*/
 From [Project 2].dbo.Nashville_Housing

/*Another way to Split texts into columns (using PARSENAME), example with OwnerAddress Column*/

 Select OwnerAddress
 From [Project 2].dbo.Nashville_Housing

 Select
 PARSENAME (REPLACE (OwnerAddress,',','.'),1) AS State,
 PARSENAME (REPLACE (OwnerAddress,',','.'),2) AS City,
 PARSENAME (REPLACE (OwnerAddress,',','.'),3) AS Address
 From [Project 2].dbo.Nashville_Housing

 AlTER TABLE [Project 2].dbo.Nashville_Housing
Add OwnerSplitState Nvarchar(255); 

Update [Project 2].dbo.Nashville_Housing
SET OwnerSplitState = PARSENAME (REPLACE (OwnerAddress,',','.'),1)

 AlTER TABLE [Project 2].dbo.Nashville_Housing
Add OwnerSplitCity Nvarchar(255); 

Update [Project 2].dbo.Nashville_Housing
SET OwnerSplitCity = PARSENAME (REPLACE (OwnerAddress,',','.'),2)

 AlTER TABLE [Project 2].dbo.Nashville_Housing
Add OwnerSplitAddress Nvarchar(255); 

Update [Project 2].dbo.Nashville_Housing
SET OwnerSplitAddress =  PARSENAME (REPLACE (OwnerAddress,',','.'),3)

Select * /*Verify the results*/
 From [Project 2].dbo.Nashville_Housing

 ---------------------------
 --Change Y and N in the column 'SoldAsVacant' to Yes and No

 Select Distinct (SoldAsVacant), Count (SoldAsVacant)
 From [Project 2].dbo.Nashville_Housing
 Group by SoldAsVacant
 Order by 2

 Select SoldAsVacant,
 Case when SoldAsVacant = 'Y' THEN 'yes'
	when SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END AS SoldAsVacant_sorting
 From [Project 2].dbo.Nashville_Housing

 Update [Project 2].dbo.Nashville_Housing
SET SoldAsVacant =  Case when SoldAsVacant = 'Y' then 'Yes'
					When SoldAsVacant = 'N' then 'No'
					ELSE SoldAsVacant
					END

Select Distinct (SoldAsVacant), Count (SoldAsVacant) /*Verify the results*/
 From [Project 2].dbo.Nashville_Housing
 Group by SoldAsVacant
 Order by 2

 --------------------
 ---Remove Duplicates

 WITH RowNumCTE AS(
 Select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID, PropertyAddress,SalePrice, SaleDate, LegalReference
				ORDER BY UniqueID
				) row_num

 From [Project 2].dbo.Nashville_Housing
 )
DELETE
 From RowNumCTE
 Where row_num > 1
--Order by PropertyAddress

WITH RowNumCTE AS(
 Select *,
	ROW_NUMBER() over (
	PARTITION BY ParcelID, PropertyAddress,SalePrice, SaleDate, LegalReference
				ORDER BY UniqueID
				) row_num

 From [Project 2].dbo.Nashville_Housing
 )
SELECT * /*Verify the command*/
 From RowNumCTE
 Where row_num > 1
 Order by PropertyAddress

----------------------------
--Delete unused columns

Select * 
 From [Project 2].dbo.Nashville_Housing

 ALTER TABLE [Project 2].dbo.Nashville_Housing
 DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

 ALTER TABLE [Project 2].dbo.Nashville_Housing
 DROP COLUMN SaleDate



