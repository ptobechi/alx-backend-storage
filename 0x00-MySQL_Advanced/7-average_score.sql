-- Task: Create stored procedure ComputeAverageScoreForUser to compute and store the average score for a user

-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS ComputeAverageScoreForUser;

-- Create the ComputeAverageScoreForUser procedure
DELIMITER //

CREATE PROCEDURE ComputeAverageScoreForUser(IN user_id INT)
BEGIN
	DECLARE avg_score FLOAT;

	-- Calculate the average score for the given user_id
	SELECT AVG(score) INTO avg_score
	FROM corrections
	WHERE user_id = user_id;

	-- Update the average score in the users table
	UPDATE users
	SET average_score = avg_score
	WHERE id = user_id;
END //

DELIMITER ;
