# Nashville-Housing-Data-for-Data-Cleaning
Data's link: https://www.kaggle.com/datasets/tmthyjames/nashville-housing-data

A SQL script for handling nulls, manipulating data, removing duplicates, and deleting unused columns in the "Nashville Housing Data" table.
This script aims to handle null values, manipulate data, remove duplicates, and delete unnecessary columns in the "Nashville Housing Data for Data Cleaning" table.

Handling Nulls:
- Duplicated parcelIds are identified for the same property address.
- Property addresses that are null can be populated with the corresponding parcelId.

Data Manipulating:
- The script breaks down the address into address and city components for both the property address and owner address.

Change to Yes and No:
- The "SoldAsVacant" column is converted to display "YES" for a value of 1, "NO" for a value of 0, and the original value for any other cases.

Removing Duplicates:
- Duplicates are removed based on the combination of parcelId, property address, sale price, sale date, and legal reference.

Deleting Unused Columns:
- The script drops the "PropertyAddress," "OwnerAddress," and "TaxDistrict" columns from the table.

Please note that running these SQL statements will modify the data and structure of the table. It is recommended to back up the data before making any changes.
