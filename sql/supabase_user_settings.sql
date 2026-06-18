-- Supabase SQL: create user_profiles and user_settings tables, enable RLS and policies

BEGIN;

CREATE TABLE IF NOT EXISTS public.user_profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text,
  provider text,
  full_name text,
  avatar_url text,
  language text DEFAULT 'en',
  created_at timestamptz DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.user_settings (
  user_id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  auto_sync boolean DEFAULT false,
  analytics_enabled boolean DEFAULT true,
  low_stock_threshold integer DEFAULT 10,
  expiry_alert_days integer DEFAULT 14,
  onboarding_seen boolean DEFAULT false,
  updated_at timestamptz DEFAULT now()
);

-- Enable row level security so only the owner can access their row
ALTER TABLE public.user_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_manage_own_settings" ON public.user_settings
  FOR ALL
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Also protect profiles table
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_manage_own_profiles" ON public.user_profiles
  FOR ALL
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- Create function to auto-initialize profile and settings for new auth users
CREATE OR REPLACE FUNCTION public.handle_new_auth_user()
RETURNS trigger LANGUAGE plpgsql AS $$
BEGIN
  -- Insert into profiles if not exists
  INSERT INTO public.user_profiles (id, email, provider, full_name, avatar_url, language)
  VALUES (NEW.id, NEW.email, NEW.raw_user_meta->>'provider' , NEW.user_metadata->>'full_name', NEW.user_metadata->>'avatar_url', 'en')
  ON CONFLICT (id) DO NOTHING;

  -- Insert default settings if not exists
  INSERT INTO public.user_settings (user_id)
  VALUES (NEW.id)
  ON CONFLICT (user_id) DO NOTHING;

  RETURN NEW;
END;
$$;

-- Create trigger on auth.users to call the function after insert
-- Supabase allows creating triggers on auth.users in the SQL editor
CREATE TRIGGER on_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION public.handle_new_auth_user();

COMMIT;

-- Note: If your DB does not permit triggers on auth.users, run ensureDefaultsForCurrentUser from the client after sign-in.
