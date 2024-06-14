-- Task: Create a function SafeDiv that divides (and returns) the first number by the second number, or returns 0 if the second number is equal to 0

-- Drop the function if it already exists
DROP FUNCTION IF EXISTS SafeDiv;

-- Create the SafeDiv function
DELIMITER //

CREATE FUNCTION SafeDiv(a INT, b INT) RETURNS FLOAT
BEGIN
	IF b = 0 THEN
		RETURN 0;
	ELSE
		RETURN a / b;
	END IF;
END //

DELIMITER ;
