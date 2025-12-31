-- ============================================
-- KPG Shop - Supabase Storage Configuration
-- ============================================
-- Run this in Supabase SQL Editor to configure storage

-- Create storage bucket for product images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'product-images',
  'product-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
);

-- Storage policies
-- Anyone can view product images (public bucket)
CREATE POLICY "Public can view product images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'product-images');

-- Service role can upload (enforced via API)
CREATE POLICY "Service role can upload product images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'product-images');

-- Service role can update
CREATE POLICY "Service role can update product images"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'product-images')
  WITH CHECK (bucket_id = 'product-images');

-- Service role can delete
CREATE POLICY "Service role can delete product images"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'product-images');
