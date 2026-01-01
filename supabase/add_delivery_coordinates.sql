-- Add delivery coordinates to orders table
ALTER TABLE orders 
ADD COLUMN delivery_latitude DOUBLE PRECISION,
ADD COLUMN delivery_longitude DOUBLE PRECISION;

-- Add comment
COMMENT ON COLUMN orders.delivery_latitude IS 'Customer delivery location latitude';
COMMENT ON COLUMN orders.delivery_longitude IS 'Customer delivery location longitude';
