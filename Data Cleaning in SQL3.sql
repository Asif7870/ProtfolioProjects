select * 
from Natshaville.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------
---- Standardize Salesdate

select SaleDate, convert(Date,SaleDate)
from Natshaville.dbo.NashvilleHousing

----- Adding of the column using Alter (DDL command) (col_name,datatype)

Alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = convert(Date,SaleDate)

-------After updating a column is added 
select * 
from Natshaville.dbo.NashvilleHousing

-----------------------------------------------------------------------------------------------------
--------Populate property address data (ParcelID is same for common PropertyAddress)

select * from
Natshaville.dbo.NashvilleHousing
---where PropertyAddress is null
order by ParcelID

----- Checking where is Null in PopertyAddress and Applying joins on it ISNULL commands fulfill the Data Value in seperate column

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,
isnull(a.PropertyAddress,b.PropertyAddress)
from Natshaville.dbo.NashvilleHousing a
join Natshaville.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

---- Filling up the data using Alisas 
Update a 
Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Natshaville.dbo.NashvilleHousing a
join Natshaville.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

select * from
Natshaville.dbo.NashvilleHousing
---where PropertyAddress is null
order by ParcelID

-----------------------------------------------------------------------------------------------------
------Breaking Out PropertyAddress in individual columns (Address, City, State)

--------Using CHARINDEX  & SUBSTRING

select PropertyAddress from
Natshaville.dbo.NashvilleHousing
---where PropertyAddress is null
order by ParcelID

select SUBSTRING (PropertyAddress, 1, CHARINDEX( ',',PropertyAddress) -1) as Address,
SUBSTRING (PropertyAddress,  CHARINDEX( ',',PropertyAddress) +1 , LEN(PropertyAddress)) as Address
from Natshaville.dbo.NashvilleHousing


Alter table NashvilleHousing
add PropertySplitAddress NVARCHAR (255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING (PropertyAddress, 1, CHARINDEX( ',',PropertyAddress) -1)

Alter table NashvilleHousing
add PropertySplitCity NVARCHAR (255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING (PropertyAddress,  CHARINDEX( ',',PropertyAddress) +1, LEN(PropertyAddress))


------Breaking Out OwnerAddress in individual columns (Address, City, State)

Select OwnerAddress from Natshaville.dbo.NashvilleHousing
----where OwnerAddress is not null


Select Substring (OwnerAddress,1,CHARINDEX(',' ,OwnerAddress) -1) as Address_1,
Substring (OwnerAddress, CHARINDEX(',' ,OwnerAddress) +1,LEN(OwnerAddress)) as Address_
from Natshaville.dbo.NashvilleHousing

Alter table NashvilleHousing
add OwnerSplitAddress NVARCHAR (255)

update NashvilleHousing
SET OwnerSplitAddress =  Substring (OwnerAddress,1,CHARINDEX(',' ,OwnerAddress) -1)

Alter table NashvilleHousing
add OwnerSplitState_City NVARCHAR (255)

update NashvilleHousing
SET OwnerSplitState_City =  Substring (OwnerAddress, CHARINDEX(',' ,OwnerAddress) +1,LEN(OwnerAddress))

---------------------------------------------------------------------------------------------------------
---Chnage Y to "Yes" & N to "No" in "Sold as Vacant column "

select Distinct (SoldAsVacant),COUNT(*) 
from Natshaville.dbo.NashvilleHousing group by SoldAsvacant

Update NashvilleHousing
set SoldAsVacant =
case when SoldAsVacant ='Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end 
from Natshaville.dbo.NashvilleHousing

select SoldAsVacant
from Natshaville.dbo.NashvilleHousing

------------------------------------------------------------------------------------------------------

----Remove Duplicates

WITH RowNumCTE
AS (
select *, ROW_NUMBER() 
         OVER(Partition by ParcelID,
		      PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference
			  Order By UniqueID) as Row_Num
from Natshaville.dbo.NashvilleHousing
--order by ParcelID
)

select * from RowNumCTE 
where Row_Num =2


Delete 
from RowNumCTE 
where Row_Num >1 

 ------------------------------------------------------------------------------------------------
 create view 
 GistofNashvilleHousing
 as
 WITH RowNumCTE
AS (
select *, ROW_NUMBER() 
         OVER(Partition by ParcelID,
		      PropertyAddress,
			  SaleDate,
			  SalePrice,
			  LegalReference
			  Order By UniqueID) as Row_Num
from Natshaville.dbo.NashvilleHousing
--order by ParcelID
)
select * from RowNumCTE 

--------------------------------------------------------------------------------------------------
-- Delete Unused Columns 

select *
from Natshaville.dbo.NashvilleHousing


alter table Natshaville.dbo.NashvilleHousing
drop column PropertyAddress,OwnerAddress,TaxDistrict


alter table Natshaville.dbo.NashvilleHousing
drop column SaleDate