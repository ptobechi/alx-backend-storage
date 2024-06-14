-- Task: Create a stored procedure ComputeAverageWeightedScoreForUsers to compute and store the average weighted score for all users

-- Drop the procedure if it already exists
DROP PROCEDURE IF EXISTS ComputeAverageWeightedScoreForUsers;

-- Create the stored procedure ComputeAverageWeightedScoreForUsers
DELIMITER //

CREATE PROCEDURE ComputeAverageWeightedScoreForUsers()
BEGIN
	DECLARE done INT DEFAULT FALSE;
	DECLARE user_id INT;
	DECLARE total_weighted_score FLOAT;
	DECLARE total_weight INT;
	DECLARE cur_users CURSOR FOR SELECT id FROM users;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

	OPEN cur_users;

	read_loop: LOOP
	FETCH cur_users INTO user_id;
	IF done THEN
		LEAVE read_loop;
			END IF;

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
	END LOOP;

	CLOSE cur_users;
END //

DELIMITER ;
