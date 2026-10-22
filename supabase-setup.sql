-- list.exe sync setup: paste into Supabase → SQL Editor → New query → Run
-- Uses the same project, logins and members list as quest.exe and tokyo.exe, so there is nothing to edit.

create table if not exists public.list_docs (
  id text primary key,
  kind text not null,
  data jsonb,
  deleted boolean not null default false,
  updated_at timestamptz not null default now()
);
alter table public.list_docs enable row level security;

drop policy if exists "members read" on public.list_docs;
drop policy if exists "members add" on public.list_docs;
drop policy if exists "members change" on public.list_docs;
create policy "members read"   on public.list_docs for select to authenticated using (public.is_member());
create policy "members add"    on public.list_docs for insert to authenticated with check (public.is_member());
create policy "members change" on public.list_docs for update to authenticated using (public.is_member()) with check (public.is_member());

drop trigger if exists docs_touch on public.list_docs;
create trigger docs_touch before insert or update on public.list_docs for each row execute function public.docs_touch();

do $$ begin
  alter publication supabase_realtime add table public.list_docs;
exception when duplicate_object then null; end $$;
