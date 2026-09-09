-- ============================================================
--  YOU FIRST — response store
--  Paste this whole file into Supabase → SQL Editor → Run.
--  Safe to run twice; it will not duplicate anything.
-- ============================================================

create table if not exists public.responses (
  id          uuid primary key default gen_random_uuid(),
  created_at  timestamptz not null default now(),

  answer_one  text,                                   -- Q1, free text
  rating_two  smallint,                               -- Q2, 1–10, null if never moved
  allow_auto  text,                                   -- Q3, 'Yes' | 'No'
  why_not     text,                                   -- Q3 follow-up, only when No
  age_band    text,
  city        text,
  consent     boolean not null default false,
  page        text,                                   -- which URL it was filled on

  -- guards against a junk or abusive payload reaching the table at all
  constraint rating_in_range   check (rating_two is null or rating_two between 1 and 10),
  constraint allow_auto_valid  check (allow_auto is null or allow_auto in ('Yes','No')),
  constraint answer_one_length check (answer_one is null or char_length(answer_one) <= 5000),
  constraint why_not_length    check (why_not    is null or char_length(why_not)    <= 5000),
  constraint city_length       check (city       is null or char_length(city)       <= 120)
);

create index if not exists responses_created_at_idx on public.responses (created_at desc);

-- ============================================================
--  Row Level Security
--
--  RLS is deny-by-default: any action without a matching policy
--  is refused. We add exactly ONE policy — insert — so the anon
--  key published in the landing page can drop a response in and
--  do nothing else. It cannot read, edit or delete a single row,
--  which is what keeps the key safe to ship in public HTML.
--
--  The dashboard reads with the service_role key, which bypasses
--  RLS. That key must never appear in anything you deploy.
-- ============================================================

alter table public.responses enable row level security;

drop policy if exists "public form may insert" on public.responses;
create policy "public form may insert"
  on public.responses
  for insert
  to anon
  with check (
    consent = true                                    -- refuse anything without consent
    and (answer_one is not null or rating_two is not null or allow_auto is not null)
  );

-- No select / update / delete policy for anon, by design.

-- ============================================================
--  Check it worked: this should return one row reading 't'
-- ============================================================
select relrowsecurity as rls_is_on
from pg_class
where oid = 'public.responses'::regclass;
