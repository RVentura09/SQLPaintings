-- --------------------------SQL CASE STUDY --------------------------------------
-- -------------------------------------------------------------------------------
# Q1. Fetch all the paintings which are not displayed on any museums
SELECT 		w.work_id,w.name,w.artist_id,
			a.full_name
FROM		work w
JOIN		artist a ON	w.artist_id=a.artist_id
WHERE		w.museum_id IS NULL
ORDER BY	artist_id,work_id;





-- -------------------------------------------------------------------------------
# Q2. Are there museums without any paintings?

SELECT      m.museum_id, m.name
FROM        museum m
WHERE       m.museum_id NOT IN 
            (SELECT DISTINCT museum_id
             FROM work
             WHERE museum_id IS NOT NULL
             ORDER BY museum_id);
-- Alternative query to verify the number of paintings in museums------------------

SELECT      m.museum_id,m.name,
            COUNT(w.museum_id) AS 'No of paintings'
FROM        museum m
LEFT JOIN   work w ON w.museum_id = m.museum_id   
GROUP BY    m.museum_id, m.name
ORDER BY    COUNT(w.museum_id),m.museum_id;





-- --------------------------------------------------------------------------------
# Q3. How many paintings have an asking price of more than their regular price?
SELECT 		work_id,count(size_id) AS 'Paintings asking_price>regular_price'
FROM 		product_size
WHERE		sale_price>regular_price
GROUP BY	work_id;





-- --------------------------------------------------------------------------------
# Q4. Identify the paintings whose asking price is less than 50% of its regular price
SELECT 		ps.work_id,
			w.name
FROM 		product_size ps
JOIN		work w ON w.work_id=ps.work_id
WHERE		ps.sale_price<(ps.regular_price/2)
GROUP BY	ps.work_id,w.name
ORDER BY	work_id,name;





-- ---------------------------------------------------------------------------------
# Q5. Which canva size costs the most?
SELECT		cs.width,cs.height,
			ps.size_id
FROM		canvas_size cs
JOIN		product_size ps ON ps.size_id=cs.size_id
WHERE		ps.sale_price=(	SELECT	MAX(ps.sale_price)
							FROM product_size ps);





-- Q6. Delete duplicate records from work, product_size, subject and image_link tables----------
WITH CTE AS ( #We need to use a CTE as a partition to have a table showing the repeated entries
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY work_id,size_id,sale_price,regular_price ORDER BY work_id) AS row_num #count rows and restart on work id and others
    FROM product_size
    ORDER BY row_num # show the max number of repeated at the end of the list
)

DELETE FROM product_size # Delete all the information where the work id is in the previous CTE table and its row)number  is higher than 1
WHERE work_id IN (
    SELECT work_id
    FROM CTE
    WHERE row_num > 1
);







-- Q7. Identify the museums with invalid city information in the given dataset----------------------------------------------------------------------
SELECT 		*
FROM 		museum
WHERE 		city REGEXP '^[0-9]' OR city IS NULL;






-- Q8. Fetch the top 10 most famous painting subject
SELECT		* 
FROM 		(SELECT 	s.subject,count(1) AS no_of_paintings
						,RANK() OVER(ORDER BY count(1) desc) AS ranking
			FROM work w
			JOIN subject s ON s.work_id=w.work_id
			GROUP BY s.subject ) AS rank_table
WHERE ranking <= 10;





-- -------------------------------------------------------------------------------------------------------------
-- Q9. Identify the museums which are open on both Sunday and Monday. Display museum name, city.
SELECT		m.museum_id,m.name,m.city,m.state,m.country
FROM		museum m 
JOIN		museum_hours mh ON m.museum_id=mh.museum_id
WHERE		mh.day='Sunday' AND EXISTS ( SELECT * 
										FROM museum_hours mh1
                                        WHERE mh1.day='Monday' AND mh.museum_id=mh1.museum_id);
                                        

			

-- ----------------------------------------------------------------------------------------------------------------
-- Q10. How many museums are open every single day?
# This will provide us with a list of all museums that open every single day
SELECT		mh.museum_id,count(mh.day) as Opening_Days_Per_Week,
			m.name
FROM		museum_hours mh
JOIN		museum m ON m.museum_id=mh.museum_id
GROUP BY	mh.museum_id,m.name
HAVING		count(mh.day)=7 ;

-- ---------------------------------------------------------------------------
# If we are interested in knowing only the sum of museums that open every day we can use count on the previous query
# which will provide us the total number of museums that open every single day
SELECT 		COUNT(1) AS TotalCount
FROM  		(SELECT		mh.museum_id,count(mh.day) as Opening_Days_Per_Week,
			m.name
            FROM		museum_hours mh
            JOIN		museum m ON m.museum_id=mh.museum_id
            GROUP BY	mh.museum_id,m.name
            HAVING		count(mh.day)=7 )as TotalCount ;
            
            
            
            
-- -----------------------------------------------------------------------------------------------------------------
-- Q11. Which are the top 5 most popular museum? (Popularity is defined based on most no of paintings in a museum)
	
SELECT		m.name, m.city,m.country,
			x.no_of_painintgs
FROM		(SELECT		m.museum_id, count(m.museum_id) AS no_of_painintgs
						,RANK() OVER(ORDER BY count(m.museum_id) desc) AS rnk
			FROM 		work w
			JOIN 		museum m ON m.museum_id=w.museum_id
			GROUP BY	m.museum_id) x
JOIN		museum m ON m.museum_id=x.museum_id
WHERE 		x.rnk<=5