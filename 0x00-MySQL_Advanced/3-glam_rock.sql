-- Create a temporary table to store bands with Glam rock as their main style and their lifespan
CREATE TEMPORARY TABLE IF NOT EXISTS glam_rock_bands AS
SELECT band_name,
YEAR(CURDATE()) - CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(lifespan, '-', -1), ' ', 1) AS UNSIGNED) AS lifespan
FROM metal_bands
WHERE main_style LIKE '%Glam rock%';

-- List the bands with Glam rock as their main style, ranked by their longevity
SELECT band_name, lifespan
FROM glam_rock_bands
ORDER BY lifespan DESC;
