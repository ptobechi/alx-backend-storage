-- Task: Create a stored procedure ComputeAverageWeightedScoreForUser to compute and store the average weighted score for a user

-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS ComputeAverageWeightedScoreForUser;

-- Create the stored procedure ComputeAverageWeightedScoreForUser
DELIMITER //

CREATE PROCEDURE ComputeAverageWeightedScoreForUser(IN user_id INT)
BEGIN
	DECLARE total_weighted_score FLOAT;
	DECLARE total_weight INT;

	-- Calculate the total weighted score and total weight for the user
	SELECT SUM(c.score * p.weight), SUM(p.weight)
	INTO total_weighted_score, total_weight
	FROM corrections c
	JOIN projects p ON c.project_id = p.id
	WHERE c.user_id = user_id;

	-- Update the user's average_score with the calculated weighted average score
	IF total_weight > 0 THEN
		UPDATE users
		SET average_score = total_weighted_score / total_weight
		WHERE id = user_id;
	ELSE
		UPDATE users
		SET average_score = 0
		WHERE id = user_id;
	END IF;
END //

DELIMITER ;
