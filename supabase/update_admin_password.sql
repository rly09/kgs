-- Run this in Supabase SQL Editor to update admin password to plain text

-- Update existing admin password from bcrypt hash to plain text
UPDATE admins 
SET password_hash = 'admin123' 
WHERE email = 'admin@kpgshop.com';

-- Verify the update
SELECT id, email, password_hash, name FROM admins WHERE email = 'admin@kpgshop.com';
