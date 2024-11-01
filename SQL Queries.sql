-- --------------------------SQL CASE STUDY --------------------------------------
-- -------------------------------------------------------------------------------
# Q1 Fetch all the paintings which are not displayed on any museums
SELECT 		w.work_id,w.name,w.artist_id,
			a.full_name
FROM		work w
JOIN		artist a ON	w.artist_id=a.artist_id
WHERE		w.museum_id is null
ORDER BY	artist_id,work_id;
-- -------------------------------------------------------------------------------
# Q2. Are there museums without any paintings?

SELECT      m.museum_id, m.name
FROM        museum m
WHERE       m.museum_id NOT IN 
            (SELECT DISTINCT museum_id
             FROM work
             WHERE museum_id IS NOT NULL
             order by museum_id);
-- Alternative query to verify the number of paintings in museums------------------

SELECT      m.museum_id,m.name,
            COUNT(w.museum_id) AS 'No of paintings'
FROM        museum m
LEFT JOIN   work w ON w.museum_id = m.museum_id   
GROUP BY    m.museum_id, m.name
ORDER BY    COUNT(w.museum_id),m.museum_id;
-- --------------------------------------------------------------------------------
# Q3. How many paintings have an asking price of more than their regular price?
Select 		work_id,count(size_id) as 'Paintings asking_price>regular_price'
FROM 		product_size
WHERE		sale_price>regular_price
group by	work_id;
-- --------------------------------------------------------------------------------
# Q4 Identify the paintings whose asking price is less than 50% of its regular price
Select 		ps.work_id,
			w.name
FROM 		product_size ps
JOIN		work w ON w.work_id=ps.work_id
WHERE		ps.sale_price<(ps.regular_price/2)
GROUP BY	ps.work_id,w.name
ORDER BY	work_id,name;
-- ---------------------------------------------------------------------------------
# Q5 Which canva size costs the most?
SELECT		cs.width,cs.height,
			ps.size_id
FROM		canvas_size cs
JOIN		product_size ps ON ps.size_id=cs.size_id
WHERE		ps.sale_price=(SELECT MAX(ps.sale_price) FROM product_size ps);
-- 6. Delete duplicate records from work, product_size, subject and image_link tables----------
WITH CTE AS ( #We need to use a CTE as a partition to have a table showing the repeated entries
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY work_id,size_id,sale_price,regular_price ORDER BY work_id) AS row_num #count rows and restart on work id and others
    FROM product_size
    order by row_num # show the max number of repeated at the end of the list
)
DELETE FROM product_size # Delete all the information where the work id is in the previous CTE table and its row)number  is higher than 1
WHERE work_id IN (
    SELECT work_id
    FROM CTE
    WHERE row_num > 1
);
-- ---------7. Identify the museums with invalid city information in the given dataset----------------------------------------------------------------------
SELECT *
FROM museum
WHERE city REGEXP '^[0-9]' OR city IS NULL;

-- ------------Fetch the top 10 most famous painting subject
select * 
	from (
		select s.subject,count(1) as no_of_paintings
		,rank() over(order by count(1) desc) as ranking
		from work w
		join subject s on s.work_id=w.work_id
		group by s.subject ) as ranktable
	where ranking <= 10;
