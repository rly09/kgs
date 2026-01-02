-- ============================================
-- KPG Shop - Payment QR Storage Configuration
-- ============================================
-- Run this in Supabase SQL Editor to add payment QR storage
-- This follows the same pattern as product-images storage

-- Create storage bucket for payment QR codes
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'payment-qr',
  'payment-qr',
  true,
  5242880, -- 5MB limit
  ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Storage policies
-- Anyone can view payment QR (public bucket)
CREATE POLICY "Public can view payment QR"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'payment-qr');

-- Service role can upload (enforced via API)
CREATE POLICY "Service role can upload payment QR"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'payment-qr');

-- Service role can update
CREATE POLICY "Service role can update payment QR"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'payment-qr')
  WITH CHECK (bucket_id = 'payment-qr');

-- Service role can delete
CREATE POLICY "Service role can delete payment QR"
  ON storage.objects FOR DELETE
  USING (bucket_id = 'payment-qr');
