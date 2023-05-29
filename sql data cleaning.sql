-- Cleaning Data in Queries

Select *
From Project.dbo.NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT (Date,SaleDate) As DateSale
From Project.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate) --Not working

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address Data

Select *
From Project.dbo.NashvilleHousing
-- Where PropertyAddress is null
Order by ParcelID

Select n.ParcelID, n.PropertyAddress,h.ParcelID, h.PropertyAddress, ISNULL(n.PropertyAddress,h.PropertyAddress)
From Project.dbo.NashvilleHousing n
Join Project.dbo.NashvilleHousing h
	on n.ParcelID = h.ParcelID
	AND n.[UniqueID] <> h.[UniqueID]
Where n.PropertyAddress is null


Update n
	Set PropertyAddress = ISNULL(n.PropertyAddress,h.PropertyAddress)
	From Project.dbo.NashvilleHousing n
Join Project.dbo.NashvilleHousing h
	on n.ParcelID = h.ParcelID
	AND n.[UniqueID] <> h.[UniqueID]
	Where n.PropertyAddress is null

-- Break out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From Project.dbo.NashvilleHousing
-- Where PropertyAddress is null
--Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address

From Project.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


Select *
From Project.dbo.NashvilleHousing


Select
PARSENAME (REPLACE(OwnerAddress, ',','.'),3) As Address,
PARSENAME (REPLACE(OwnerAddress, ',','.'),2) As City,
PARSENAME (REPLACE(OwnerAddress, ',','.'),1) As State
From Project.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME (REPLACE(OwnerAddress, ',','.'),3) 


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME (REPLACE(OwnerAddress, ',','.'),2) 

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME (REPLACE(OwnerAddress, ',','.'),1) 

Select *
From Project.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "SoldAsVacant" field

Select Distinct (SoldAsVacant),	Count (SoldAsVacant)
From Project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From Project.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End



-- Remove duplicate


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Project.dbo.NashvilleHousing
-- order by parcelID
)
Delete 
From RowNumCTE
Where row_num > 1
-- Order by PropertyAddress

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From Project.dbo.NashvilleHousing
-- order by parcelID
)
Select *
From RowNumCTE
Where row_num > 1
 Order by PropertyAddress




-- Delete Unused Columns

Select *
From Project.dbo.NashvilleHousing

Alter TABLE Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict

Alter TABLE Project.dbo.NashvilleHousing
DROP COLUMN SaleDate