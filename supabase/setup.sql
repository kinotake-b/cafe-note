-- cafe-note 用のテーブル(Supabase の SQL Editor に貼って Run する)
-- レシピ帳(recipe-app/supabase/setup.sql)と同じ Supabase プロジェクトに作る。ログインも同じアカウントで使う。
-- 1人ごとにデータを分け,本人だけが読み書きできるようにする(RLS=行ごとのアクセス制限)

-- カフェの記録:1件=1行.消したものは deleted=true にして残す(別の端末に「消した」を伝えるため)
create table if not exists public.cafe_items (
  user_id    uuid        not null references auth.users(id) on delete cascade,
  id         text        not null,
  data       jsonb       not null,
  updated_at timestamptz not null default now(),
  deleted    boolean     not null default false,
  primary key (user_id, id)
);

-- 自分で足したタグなど,1人1行
create table if not exists public.cafe_meta (
  user_id    uuid        primary key references auth.users(id) on delete cascade,
  data       jsonb       not null,
  updated_at timestamptz not null default now()
);

alter table public.cafe_items enable row level security;
alter table public.cafe_meta  enable row level security;

drop policy if exists "own cafe items" on public.cafe_items;
create policy "own cafe items" on public.cafe_items
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

drop policy if exists "own cafe meta" on public.cafe_meta;
create policy "own cafe meta" on public.cafe_meta
  for all to authenticated
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);
