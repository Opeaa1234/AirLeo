
-- AirLeo community accounts, moderation and consent-based analytics.
create schema if not exists private;
-- This migration is isolated to airleo_-prefixed public tables and a private helper.
create table if not exists public.airleo_analytics_events (
  id bigint generated always as identity primary key,
  event_type text not null default 'page_view' check (event_type = 'page_view'),
  page_path text not null default '/',
  session_id uuid not null,
  created_at timestamptz not null default now()
);
create table if not exists public.airleo_profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'AirLeo member' check (char_length(display_name) between 1 and 60),
  email text,
  last_sign_in_at timestamptz,
  is_admin boolean not null default false,
  created_at timestamptz not null default now()
);
create table if not exists public.airleo_community_posts (
  id uuid primary key default gen_random_uuid(),
  author_id uuid not null references auth.users(id) on delete cascade,
  body text not null check (char_length(body) between 1 and 1000),
  created_at timestamptz not null default now(),
  status text not null default 'pending' check (status in ('pending','approved','rejected'))
);
create index if not exists airleo_analytics_created_at_idx on public.airleo_analytics_events(created_at desc);
create index if not exists airleo_posts_created_at_idx on public.airleo_community_posts(created_at desc);
create index if not exists airleo_posts_author_id_idx on public.airleo_community_posts(author_id);

alter table public.airleo_analytics_events enable row level security;
alter table public.airleo_profiles enable row level security;
alter table public.airleo_community_posts enable row level security;

revoke all on public.airleo_analytics_events from anon, authenticated;
grant insert on public.airleo_analytics_events to anon, authenticated;
grant select on public.airleo_analytics_events to authenticated;
revoke all on public.airleo_profiles from anon, authenticated;
grant select (user_id, display_name, is_admin, email, last_sign_in_at, created_at) on public.airleo_profiles to authenticated;
grant update (display_name) on public.airleo_profiles to authenticated;
revoke all on public.airleo_community_posts from anon, authenticated;
grant select on public.airleo_community_posts to anon, authenticated;
grant insert on public.airleo_community_posts to authenticated;
grant update (status) on public.airleo_community_posts to authenticated;

create or replace function private.is_airleo_admin()
returns boolean language sql stable security definer set search_path = ''
as $$
  select exists (
    select 1 from public.airleo_profiles p
    where p.user_id = (select auth.uid()) and p.is_admin = true
  );
$$;
revoke all on function private.is_airleo_admin() from public, anon;
grant usage on schema private to authenticated;
grant execute on function private.is_airleo_admin() to authenticated;

create or replace function public.handle_airleo_new_user()
returns trigger language plpgsql security definer set search_path = ''
as $$
begin
  insert into public.airleo_profiles (user_id, display_name, email, last_sign_in_at)
  values (
    new.id,
    coalesce(nullif(new.raw_user_meta_data ->> 'display_name',''), 'AirLeo member'),
    new.email,
    new.last_sign_in_at
  )
  on conflict (user_id) do update
    set email = excluded.email,
        last_sign_in_at = excluded.last_sign_in_at;
  return new;
end;
$$;
revoke all on function public.handle_airleo_new_user() from public, anon, authenticated;
drop trigger if exists on_airleo_auth_user_created on auth.users;
create trigger on_airleo_auth_user_created after insert or update of email, last_sign_in_at on auth.users
for each row execute function public.handle_airleo_new_user();

drop policy if exists "airleo analytics insert only" on public.airleo_analytics_events;
create policy "airleo analytics insert only" on public.airleo_analytics_events
for insert to anon, authenticated with check (
  event_type = 'page_view' and page_path like '/%' and length(page_path) <= 300
);
drop policy if exists "airleo analytics admin read" on public.airleo_analytics_events;
create policy "airleo analytics admin read" on public.airleo_analytics_events
for select to authenticated using ((select private.is_airleo_admin()));

drop policy if exists "airleo profiles read self or admin" on public.airleo_profiles;
create policy "airleo profiles read self or admin" on public.airleo_profiles
for select to authenticated using (
  user_id = (select auth.uid()) or (select private.is_airleo_admin())
);
drop policy if exists "airleo profiles update self" on public.airleo_profiles;
create policy "airleo profiles update self" on public.airleo_profiles
for update to authenticated using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));

drop policy if exists "airleo posts insert own" on public.airleo_community_posts;
create policy "airleo posts insert own" on public.airleo_community_posts
for insert to authenticated with check (
  author_id = (select auth.uid()) and status = 'pending'
);
drop policy if exists "airleo public and member post reads" on public.airleo_community_posts;
create policy "airleo public and member post reads" on public.airleo_community_posts
for select to anon using (status = 'approved');
drop policy if exists "airleo member and admin post reads" on public.airleo_community_posts;
create policy "airleo member and admin post reads" on public.airleo_community_posts
for select to authenticated using (
  status = 'approved' or author_id = (select auth.uid())
  or (select private.is_airleo_admin())
);
drop policy if exists "airleo posts admin update" on public.airleo_community_posts;
create policy "airleo posts admin update" on public.airleo_community_posts
for update to authenticated using ((select private.is_airleo_admin()))
with check ((select private.is_airleo_admin()));
