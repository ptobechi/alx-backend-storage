-- Create a temporary table to store the aggregated fan counts by origin
CREATE TEMPORARY TABLE IF NOT EXISTS temp_origin_fans AS
SELECT origin, COUNT(*) AS nb_fans
FROM metal_bands
GROUP BY origin;

-- Rank the origins based on the number of non-unique fans
SELECT origin, nb_fans
FROM temp_origin_fans
ORDER BY nb_fans DESC;
