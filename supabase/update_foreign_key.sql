-- Run this in Supabase SQL Editor to update the foreign key constraint

-- Step 1: Drop the existing foreign key constraint
ALTER TABLE order_items 
DROP CONSTRAINT order_items_product_id_fkey;

-- Step 2: Make product_id nullable
ALTER TABLE order_items 
ALTER COLUMN product_id DROP NOT NULL;

-- Step 3: Add new foreign key constraint with SET NULL on delete
ALTER TABLE order_items 
ADD CONSTRAINT order_items_product_id_fkey 
FOREIGN KEY (product_id) 
REFERENCES products(id) 
ON DELETE SET NULL;

-- Verify the change
SELECT 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    rc.delete_rule
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
  ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
  ON ccu.constraint_name = tc.constraint_name
JOIN information_schema.referential_constraints AS rc
  ON tc.constraint_name = rc.constraint_name
WHERE tc.table_name = 'order_items' 
  AND tc.constraint_type = 'FOREIGN KEY'
  AND kcu.column_name = 'product_id';
