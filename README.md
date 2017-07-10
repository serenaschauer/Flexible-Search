# Flexible-Search

Requirement Specifications:

Introduction:
A module for OpenMRS system that implements a flexible search system.

Scope:
The scope of this module is to create a flexible search engine, that allows the user to 
search for records of patients based on the following search criteria:

1. First Name
	- When a user is searching for a person by First Name our "Flexible Search" will only 
	  show First Names who's fist letter matches your search.
	- When a flexibility of --00%-- is chosen, only exact matches will be shown.
	- When a flexibility of --10%--, --20%--, --30%--, --40%--, or--50%-- is chosen people 
	  whose first names that have a LEVENSHTEIN distance that is less than the number of 
	  characters of the name they searched multiplied by the percentage they chose.
	- When searching by First Name and Flexibility is not --00%--, then names that match the 
	  search, but also has more letters after will appear as well. (Ex: When searching for 
	  "John", "Johnpaul" and "Johnstone" will appear as well. When searching for "Joe", "Joel"
	  and "Joseph" will appear even if the levenshtein distance is greater than the number of
    	  characters in the word multiplied by the percentage).
2. Last Name
	When a user is searching for a person by Last Name our "Flexible Search" will only 
	show Last Names who's fist letter matches your search.
3. Patient ID
	- When searching by ID and Flexibility is --00%--, then only ID's with that exact match 
	  should appear.
	- When a flexibility of --10%--, --20%--, --30%--, --40%--, or--50%-- is chosen people 
	  whose ID has a LEVENSHTEIN distance that is less than the number of 
	  characters of the ID they searched by multiplied by the percentage they chose.
4. Address
	- When searching for address a user can search by address, city/province, postal code,
	  state, and country individually or in combination. 
5. Birthdate
	- When entering a birthdate a user should enter a date in the format of mm-dd-yyyy 
	  or mm/dd/yyyy.
	- Again When searching by Birthdate and Flexibility is --00%--, then only people whose
	  birthdays with that exact match should appear.
	- When a flexibility of --10%--, --20%--, --30%--, --40%--, or--50%-- is chosen people 
	  whose birthdays have LEVENSHTEIN distance that is less than the number of 
	  characters of the birthdate they searched by multiplied by the percentage they chose.
6. Day Of Last Encounter
	- When entering a last date of encounter a user should enter a date in the format of
	  mm-dd-yyyy or mm/dd/yyyy.
	- Again When searching by Last Date of Encounter and Flexibility is --00%--, then 
	  only people whose date of last encounter with that exact match should appear.
	- When a flexibility of --10%--, --20%--, --30%--, --40%--, or--50%-- is chosen people 
	  whose birthdays have LEVENSHTEIN distance that is less than the number of 
	  characters of the birthdate they searched by multiplied by the percentage they chose.


Each time a user searches for a person, the persons ID, First Name, Last Name, DOB, Gender, 
Address, and Date of Last Encounter will appear.

The limiting feature also lets a user select how many rows they want to appear weather it is
10, 25,50, or 100 rows.

------------------------------------------------------------------------------------------------------

The flexibility of the search will be dependent on the user. The user will be able to select from 
different levels of flexibility, to search for exact query or allow for errors or imprecise 
matches.

------------------------------------------------------------------------------------------------------

More Specific Requirements on the flexibility the user chooses:

Flexibility Number --00%-- (The Least Flexible Search Query)
Flexibility Number --10%--  
Flexibility Number --20%-- 
Flexibility Number --30%--
Flexibility Number --40%--
Flexibility Number --50%-- (The Most Flexible Search Query)
