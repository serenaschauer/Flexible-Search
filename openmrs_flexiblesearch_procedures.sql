/**********************************************************************************************************
*
*   This Creates the Levenshtein Function
*
***********************************************************************************************************/
 
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `levenshtein`( s1 VARCHAR(255), s2 VARCHAR(255) ) RETURNS int(11)
    DETERMINISTIC
BEGIN
DECLARE s1_len, s2_len, i, j, c, c_temp, cost INT;
DECLARE s1_char CHAR;
-- max strlen=255
DECLARE cv0, cv1 VARBINARY(256);
SET s1_len = CHAR_LENGTH(s1), s2_len = CHAR_LENGTH(s2), cv1 = 0x00, j = 1, i = 1, c = 0;
IF s1 = s2 THEN
RETURN 0;
ELSEIF s1_len = 0 THEN
RETURN s2_len;
ELSEIF s2_len = 0 THEN
RETURN s1_len;
ELSE
WHILE j <= s2_len DO
SET cv1 = CONCAT(cv1, UNHEX(HEX(j))), j = j + 1;
END WHILE;
WHILE i <= s1_len DO
SET s1_char = SUBSTRING(s1, i, 1), c = i, cv0 = UNHEX(HEX(i)), j = 1;
WHILE j <= s2_len DO
SET c = c + 1;
IF s1_char = SUBSTRING(s2, j, 1) THEN
SET cost = 0; ELSE SET cost = 1;
END IF;
SET c_temp = CONV(HEX(SUBSTRING(cv1, j, 1)), 16, 10) + cost;
IF c > c_temp THEN SET c = c_temp; END IF;
SET c_temp = CONV(HEX(SUBSTRING(cv1, j+1, 1)), 16, 10) + 1;
IF c > c_temp THEN
SET c = c_temp;
END IF;
SET cv0 = CONCAT(cv0, UNHEX(HEX(c))), j = j + 1;
END WHILE;
SET cv1 = cv0, i = i + 1;
END WHILE;
END IF;
RETURN c;
END$$
DELIMITER ;




/**********************************************************************************************************
*
*   This procedure is for searching by First Name Only 
*
***********************************************************************************************************/


DELIMITER $$
drop procedure if exists openmrs.person_name_given_name;
$$
DELIMITER $$
create procedure openmrs.person_name_given_name (in inLike varchar(255),
                                                 in inLevenshtein varchar(255), 
												 in inLevenshteinDistance decimal(10,10),
                                                 in inLevenshteinFirstCharMustMatch int,
                                                 in num_limit int   )
/*
 This procedure optionally uses "Levenstein" logic or "Like" logic or both to find records.
 
 This procedure returns rows if:
     the column in question is "like" the inLike parameter
       or
	 the column in question vs. the inLevenshtein parameter is within the distance
          specified in the inLevenshteinDistance parameter.
	
    First character must match logic is applied to "Levenshtein" records 
      if the inLevenshteinFirstCharMustMatch parameter is 1.
      
	No "like" records are returned if the inLike parameter is null.
    
    No "Levenshtein" records are returned if the inLevenshtein parameter is null.
    
    The last parameter is indicating how many rows you want to show
*/


 begin

	# return the 12 columns we want
select * from 
 (
 select p.person_id, pn.given_name, pn.family_name, DATE_FORMAT(p.birthdate, '%m/%d/%Y') as birthdate, p.gender,
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country,
		MAX(DATE_FORMAT(e.encounter_datetime, '%m/%d/%Y')) AS last_visit_date
	
# from these tables
 from person p
       left outer join
	  person_name pn
	   on pn.person_id = p.person_id
       left outer join
      person_address pa
       on pa.person_id = pn.person_id
	   left outer join
      patient pat
       on pat.patient_id = p.person_id
       left outer join
      encounter e
       on e.patient_id = pat.patient_id
   where pn.given_name like inLike
       # match the ID's to each table  
		and inLike is not null
 group by p.person_id
  union
  
   # return the 12 columns we want
 select p.person_id, pn.given_name, pn.family_name, DATE_FORMAT(p.birthdate, '%m/%d/%Y') as birthdate, p.gender, 
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country,
		MAX(DATE_FORMAT(e.encounter_datetime, '%m/%d/%Y')) AS last_visit_date
 	# from these tables
from person p
       left outer join
	  person_name pn
	   on pn.person_id = p.person_id
       left outer join
      person_address pa
       on pa.person_id = pn.person_id
	   left outer join
      patient pat
       on pat.patient_id = p.person_id
       left outer join
      encounter e
       on e.patient_id = pat.patient_id
   where levenshtein(given_name, inLevenshtein) <= ROUND(inLevenshteinDistance * char_length(inLevenshtein))  
     # match the ID's to each table  
   and (substr(given_name, 1, 1) = substr(inLevenshtein, 1, 1) or inLevenshteinFirstCharMustMatch = 0)
   and inLevenshtein is not null
   group by p.person_id
) a
   #group by a.person_id
   order by levenshtein(a.given_name, inLevenshtein) asc
     # limiting feature
   limit num_limit
  ;

 end;
$$

/**********************************************************************************************************
*
*   This procedure is for searching by Last Name Only 
*
***********************************************************************************************************/

DELIMITER $$
drop procedure if exists openmrs.person_name_family_name;
$$
DELIMITER $$
create procedure openmrs.person_name_family_name (in inLike varchar(255),
                                                 in inLevenshtein varchar(255), 
												 in inLevenshteinDistance decimal(10,10),
                                                 in inLevenshteinFirstCharMustMatch int,
                                                 in num_limit int   )
 /*
 This procedure optionally uses "Levenstein" logic or "Like" logic or both to find records.
 
 This procedure returns rows if:
     the column in question is "like" the inLike parameter
       or
	 the column in question vs. the inLevenshtein parameter is within the distance
          specified in the inLevenshteinDistance parameter.
	
    First character must match logic is applied to "Levenshtein" records 
      if the inLevenshteinFirstCharMustMatch parameter is 1.
      
	No "like" records are returned if the inLike parameter is null.
    
    No "Levenshtein" records are returned if the inLevenshtein parameter is null.
    
    The last parameter is indicating how many rows you want to show
*/
 
 begin
  # return the 12 columns we want
 select * from 
 (
 select p.person_id, pn.given_name, pn.family_name, DATE_FORMAT(p.birthdate, '%m/%d/%Y') as birthdate, p.gender,
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country,
		MAX(DATE_FORMAT(e.encounter_datetime, '%m/%d/%Y')) AS last_visit_date
	
# from these tables
 from person p
       left outer join
	  person_name pn
	   on pn.person_id = p.person_id
       left outer join
      person_address pa
       on pa.person_id = pn.person_id
	   left outer join
      patient pat
       on pat.patient_id = p.person_id
       left outer join
      encounter e
       on e.patient_id = pat.patient_id

where pn.family_name like inLike

		and inLike is not null
   group by p.person_id
  union
  
   # return the 12 columns we want
 select p.person_id, pn.given_name, pn.family_name, DATE_FORMAT(p.birthdate, '%m/%d/%Y') as birthdate, p.gender, 
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country,
		MAX(DATE_FORMAT(e.encounter_datetime, '%m/%d/%Y')) AS last_visit_date
 	# from these tables
from person p
       left outer join
	  person_name pn
	   on pn.person_id = p.person_id
       left outer join
      person_address pa
       on pa.person_id = pn.person_id
	   left outer join
      patient pat
       on pat.patient_id = p.person_id
       left outer join
      encounter e
       on e.patient_id = pat.patient_id
   where levenshtein(family_name, inLevenshtein) <= ROUND(inLevenshteinDistance * char_length(inLevenshtein))  
   and (substr(family_name, 1, 1) = substr(inLevenshtein, 1, 1) or inLevenshteinFirstCharMustMatch = 0)
   and inLevenshtein is not null
   group by p.person_id
) a
   order by levenshtein(a.family_name, inLevenshtein) asc
     # limiting feature
   limit num_limit
  ;
 end;
$$


/**********************************************************************************************************
*
*   This procedure is for searching by Address  Only 
*
***********************************************************************************************************/
DELIMITER $$
drop procedure if exists openmrs.person_address;
$$
DELIMITER $$
create procedure openmrs.person_address (	in inLevenshtein_add1 varchar(255),
											in inLevenshtein_add2 varchar(255),
											in inLevenshtein_city varchar(255),
											in inLevenshtein_state varchar(255),
											in inLevenshtein_zip varchar(255),
											in inLevenshtein_country varchar(255),
											in inLevenshteinDistance decimal(10,10),
											in inLevenshteinFirstCharMustMatch int,
                                            in num_limit int  )

 begin
 
  # return the 12 columns we want
 select pn.person_id, pn.given_name, pn.family_name, DATE_FORMAT(p.birthdate, '%m/%d/%Y') as birthdate, p.gender, 
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country,
		MAX(DATE_FORMAT(e.encounter_datetime, '%m/%d/%Y')) AS last_visit_date

 	# from these tables
from person p
       left outer join
	  person_name pn
	   on pn.person_id = p.person_id
       left outer join
      person_address pa
       on pa.person_id = pn.person_id
	   left outer join
      patient pat
       on pat.patient_id = p.person_id
       left outer join
      encounter e
       on e.patient_id = pat.patient_id
   where 

		#address 1 given in address 2
		(  levenshtein(RTRIM(REVERSE(SUBSTRING(REVERSE(inLevenshtein_add1),LOCATE(" ",REVERSE(inLevenshtein_add1))))), RTRIM(REVERSE(SUBSTRING(REVERSE(pa.address1),LOCATE(" ",REVERSE(pa.address1)))))) <=  ROUND(inLevenshteinDistance * char_length(RTRIM(REVERSE(SUBSTRING(REVERSE(inLevenshtein_add1),LOCATE(" ",REVERSE(inLevenshtein_add1)))))))   OR inLevenshtein_add1 IS NULL  )
		and ( (pa.address1 is not null and inLevenshtein_add1 is not null) or (pa.address1 is not null and inLevenshtein_add1 is null) or (pa.address1 is null and inLevenshtein_add1 is null))

		# address 2 given in address 2
		and ( levenshtein( SUBSTRING(pa.address2, LOCATE(' ', pa.address2)+1) , SUBSTRING(inLevenshtein_add2, LOCATE(' ', inLevenshtein_add2)+1) ) <= ROUND(inLevenshteinDistance * CHAR_LENGTH(SUBSTRING(inLevenshtein_add2, LOCATE(' ', inLevenshtein_add2)+1)))  OR inLevenshtein_add2 is null )
		and ( (pa.address2 is not null and inLevenshtein_add2 is not null) or (pa.address2 is not null and inLevenshtein_add2 is null) or (pa.address2 is null and inLevenshtein_add2 is null))

		# city/village 
		and ( (levenshtein(pa.city_village, inLevenshtein_city) <= ROUND(inLevenshteinDistance * char_length(inLevenshtein_city))  ) OR  inLevenshtein_city IS NULL ) 
		and ( (pa.city_village is not null and inLevenshtein_city is not null) or (pa.city_village is not null and inLevenshtein_city is null) or (pa.city_village is null and inLevenshtein_city is null))

		#state/province
		and ( (levenshtein(pa.state_province, inLevenshtein_state) <= ROUND(inLevenshteinDistance * char_length(inLevenshtein_state))  ) OR  inLevenshtein_state IS NULL ) 
		and ( (pa.state_province is not null and inLevenshtein_state is not null) or (pa.state_province is not null and inLevenshtein_state is null) or (pa.state_province is null and inLevenshtein_state is null))
		
        # zip
        and ( (levenshtein(pa.postal_code, inLevenshtein_zip) <= ROUND(inLevenshteinDistance * char_length(inLevenshtein_zip))  ) OR  inLevenshtein_zip IS NULL ) 
		and ( (pa.postal_code is not null and inLevenshtein_zip is not null) or (pa.postal_code is not null and inLevenshtein_zip is null) or (pa.postal_code is null and inLevenshtein_zip is null))

		# country
		and ( (levenshtein(pa.country, inLevenshtein_country) <= ROUND(inLevenshteinDistance * char_length(inLevenshtein_country))  ) OR  inLevenshtein_country IS NULL ) 
		and ( (pa.country is not null and inLevenshtein_country is not null) or (pa.country is not null and inLevenshtein_country is null) or (pa.country is null and inLevenshtein_country is null))

		# city -- first letter matching
		and ( (substr(city_village, 1, 1) = substr(inLevenshtein_city, 1, 1) or inLevenshteinFirstCharMustMatch = 0)  OR inLevenshtein_city is null )
		    # match the ID's to each table  


   group by pn.person_id

  order by  
  
        case when inLevenshtein_add1 is not null then levenshtein(RTRIM(REVERSE(SUBSTRING(REVERSE(inLevenshtein_add1),LOCATE(" ",REVERSE(inLevenshtein_add1))))), RTRIM(REVERSE(SUBSTRING(REVERSE(pa.address1),LOCATE(" ",REVERSE(pa.address1))))))  
			when inLevenshtein_city is not null then levenshtein(pa.city_village, inLevenshtein_city) 
			when inLevenshtein_state is not null then levenshtein(pa.state_province, inLevenshtein_state)
			when inLevenshtein_zip is not null then levenshtein(pa.postal_code, inLevenshtein_zip)
			when inLevenshtein_country is not null then levenshtein(pa.country, inLevenshtein_country)
            when inLevenshtein_add2 is not null then levenshtein( SUBSTRING(pa.address2, LOCATE(' ', pa.address2)+1) , SUBSTRING(inLevenshtein_add2, LOCATE(' ', inLevenshtein_add2)+1) )
        end
	  # limiting feature
	limit num_limit
  ;
 end;
$$





/**********************************************************************************************************
*
*   This procedure is for searching by Last Encounter Date Only 
*
***********************************************************************************************************/
call openmrs.encounter_encounter_datetime('02/15/2006',.5,100)
select * from openmrs.encounter

DELIMITER $$
drop procedure if exists openmrs.encounter_encounter_datetime;
$$
DELIMITER $$
create procedure openmrs.encounter_encounter_datetime (in given_date varchar(255),
													   in inLevenshteinDistance decimal(10,10),
                                                       in num_limit int   )
 begin


select * from 
(
select pn.person_id, pn.given_name, pn.family_name, p.birthdate, p.gender,
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country,
        DATE(max(e.encounter_datetime)) AS max_encounter_datetime

from person p
       left outer join
	  person_name pn
	   on pn.person_id = p.person_id
       left outer join
      person_address pa
       on pa.person_id = pn.person_id
	   left outer join
      patient pat
       on pat.patient_id = p.person_id
       left outer join
      encounter e
       on e.patient_id = pat.patient_id

group by pn.person_id, pn.given_name, pn.family_name, p.birthdate, p.gender,
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country
) a

where levenshtein( date_format(STR_TO_DATE(replace(given_date, '/', '-'), '%m-%d-%Y'), '%m-%d-%Y') ,
                    DATE_FORMAT(a.max_encounter_datetime,'%m-%d-%Y'))
		<= ROUND(inLevenshteinDistance * char_length(given_date)) 

order by levenshtein( date_format(STR_TO_DATE(replace(given_date, '/', '-'), '%m-%d-%Y'), '%m-%d-%Y') , 
                      DATE_FORMAT(a.max_encounter_datetime,'%m-%d-%Y'))  asc

limit num_limit

  ;
 end;
$$



/**********************************************************************************************************
*
*   This procedure is for searching by ID only
*
***********************************************************************************************************/
DELIMITER $$
drop procedure if exists openmrs.person_person_id;
$$
DELIMITER $$
create procedure openmrs.person_person_id (in given_id int,
										   in inLevenshteinDistance decimal(10,10),
                                           in num_limit int)
 begin

 select pn.person_id, pn.given_name, pn.family_name, DATE_FORMAT(p.birthdate, '%m/%d/%Y') as birthdate, p.gender,
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country,
		DATE_FORMAT(e.encounter_datetime, '%m/%d/%Y') AS last_visit_date

 from person p
       left outer join
	  person_name pn
	   on pn.person_id = p.person_id
       left outer join
      person_address pa
       on pa.person_id = pn.person_id
	   left outer join
      patient pat
       on pat.patient_id = p.person_id
       left outer join
      encounter e
       on e.patient_id = pat.patient_id
      
 where  
        levenshtein(p.person_id, given_id) <= ROUND(inLevenshteinDistance * char_length(given_id))  

group by
		pn.person_id
order by 
		levenshtein(p.person_id, given_id) asc
	  # limiting feature        
limit num_limit

  ;
 end;
$$

/**********************************************************************************************************
*
*   This procedure is for searching by Birthdate Only 
*
***********************************************************************************************************/

DELIMITER $$
drop procedure if exists openmrs.person_birthdate;
$$
DELIMITER $$
create procedure openmrs.person_birthdate (in given_date varchar(255),
										   in inLevenshteinDistance decimal(10,10),
                                           in num_limit int   )
 begin
 # return the 12 columns we want
 select pn.person_id, pn.given_name, pn.family_name, DATE_FORMAT(p.birthdate, '%m/%d/%Y') as birthdate, p.gender,
		pa.address1, pa.address2, pa.city_village, pa.state_province, pa.postal_code, pa.country
         ,
  		MAX(DATE_FORMAT(e.encounter_datetime, '%m/%d/%Y')) AS last_visit_date
  		#DATE_FORMAT(e.encounter_datetime, '%m/%d/%Y') AS last_visit_date
      
 	# from these tables
from person p
       left outer join
	  person_name pn
	   on pn.person_id = p.person_id
       left outer join
      person_address pa
       on pa.person_id = pn.person_id
	   left outer join
      patient pat
       on pat.patient_id = p.person_id
       left outer join
      encounter e
       on e.patient_id = pat.patient_id
      
   where 
		levenshtein( STR_TO_DATE(replace(given_date, '/', '-'), '%m-%d-%Y') , p.birthdate) <= ROUND(inLevenshteinDistance * char_length(given_date))  
  group by pn.person_id
  order by levenshtein( STR_TO_DATE(replace(given_date, '/', '-'), '%m-%d-%Y') , p.birthdate)
	  # limiting feature
  limit num_limit
  ;
 end;
$$


