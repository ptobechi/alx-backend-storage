-- Task: Create an index idx_name_first on the table names to index only the first letter of the name column

-- Drop the index if it already exists
DROP INDEX IF EXISTS idx_name_first ON names;

-- Create the index idx_name_first
CREATE INDEX idx_name_first ON names (name(1));
