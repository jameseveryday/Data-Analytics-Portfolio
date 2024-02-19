-- Returning all records
SELECT *
FROM invoices;

-- Checking if there are erroneous data where there is dispute_lost but is not disputed
-- Should have NO data
SELECT disputed, dispute_lost
FROM invoices
WHERE disputed = 0
AND dispute_lost = 1;

-- Checking wrong spelling in country
SELECT country
FROM invoices
GROUP BY country;

-- Checking duplicates in invoice_number
-- Should be the same total number of rows as SELECT * FROM invoices;
-- Invoice number is a unique identifer
SELECT invoice_number
FROM invoices
GROUP BY invoice_number;

-- Processing time in which invoices are settled. Either with or without disputes
SELECT ROUND(AVG(days_to_settle),0) AS average_processing_time
FROM invoices;

-- Processing time for the company to settle disputes
SELECT ROUND(AVG(days_to_settle),0) AS average_disputed_processing_time
FROM invoices
WHERE disputed = 1;

-- Percentage of disputes received by the company that were lost
SELECT (
	SELECT COUNT(*)
	FROM invoices
	WHERE disputed = 1
	AND dispute_lost = 1
	) AS total_invoices_disputed_lost,
	
	COUNT(disputed) AS total_invoices,
	
	ROUND(
		ROUND(
			(SELECT ROUND(COUNT(*),4)
			FROM invoices
			WHERE disputed = 1
			AND dispute_lost = 1)
			/
			(SELECT ROUND(COUNT(*),2)
			FROM invoices)
		,4)
	* 100,2) AS percentage_of_disputed_lost_to_disputed
FROM invoices;
	
-- Percentage of revenue lost from disputes
-- Based on task description should be around 5%
SELECT (
	SELECT SUM(invoice_amount_usd)
	FROM invoices
	WHERE disputed = 1
	AND dispute_lost = 1) AS total_amount_disputed_lost_usd,
	
	SUM(invoice_amount_usd) AS total_amount_usd,
	
	ROUND(
		ROUND(
			(SELECT ROUND(SUM(invoice_amount_usd),4)
			FROM invoices
			WHERE disputed = 1
			AND dispute_lost = 1)
			/
			(SELECT ROUND(SUM(invoice_amount_usd),2)
			FROM invoices)
		,4)
	* 100,2) AS percentage_of_disputed_lost
FROM invoices;

-- Country where the company reached the highest losses from lost disputes (in USD)
SELECT country, SUM(invoice_amount_usd) AS disputed_amount_lost
FROM invoices
WHERE disputed = 1 AND dispute_lost = 1
GROUP BY country
ORDER BY SUM(invoice_amount_usd) DESC;