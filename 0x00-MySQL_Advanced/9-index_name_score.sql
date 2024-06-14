-- Task: Create an index idx_name_first_score on the table names to index only the first letter of the name column and the score column

-- Drop the index if it already exists
DROP INDEX IF EXISTS idx_name_first_score ON names;

-- Create the index idx_name_first_score
CREATE INDEX idx_name_first_score ON names (name(1), score);
