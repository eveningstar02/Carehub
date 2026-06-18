-- Add persistent user role support to user_profiles

alter table if exists public.user_profiles
  add column if not exists role text default 'contributor'
    check (role in ('admin', 'donor', 'contributor'));

-- For existing rows, ensure role is set to contributor if null
update public.user_profiles
set role = 'contributor'
where role is null;

-- Ensure the auth signup trigger will populate role from user metadata
create or replace function public.handle_new_auth_user()
returns trigger language plpgsql as $$
begin
  insert into public.user_profiles (id, email, provider, full_name, avatar_url, role)
    values (
      new.id,
      new.email,
      new.raw_user_meta_data->>'provider',
      new.user_metadata->>'full_name',
      new.user_metadata->>'avatar_url',
      coalesce(new.user_metadata->>'role', 'contributor')
    )
  on conflict (id) do nothing;

  insert into public.user_settings (user_id)
    values (new.id)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

-- Re-create trigger for auth.users in case it was overridden
DROP TRIGGER IF EXISTS on_user_created ON auth.users;
CREATE TRIGGER on_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_auth_user();
