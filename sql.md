create extension if not exists pgcrypto;
create extension if not exists vector;

-- =========================================================
-- ENUMS
-- =========================================================

create type goal_status as enum (
'ACTIVE',
'PAUSED',
'COMPLETED',
'ARCHIVED'
);

create type journey_status as enum (
'PENDING',
'PROCESSING',
'READY',
'FAILED'
);

create type journey_node_state as enum (
'COMPLETED',
'CURRENT',
'NEEDS_ATTENTION',
'UPCOMING',
'LOCKED',
'SKIPPED'
);

create type concept_status as enum (
'NOT_LEARNED',
'LEARNING',
'UNCERTAIN',
'MASTERED',
'NEEDS_REVIEW'
);

create type session_type as enum (
'LEARN',
'REVISE',
'PRACTICE',
'PROVE',
'TEACH',
'REMEDIATE',
'REFLECT'
);

create type session_status as enum (
'CREATED',
'IN_PROGRESS',
'COMPLETED',
'ABANDONED'
);

create type evidence_type as enum (
'RECALL',
'PRACTICE',
'EXPLANATION',
'TEACH_BACK',
'PROJECT',
'ASSESSMENT',
'DELAYED_RETRIEVAL'
);

create type recommendation_type as enum (
'LEARN',
'REVISE',
'PRACTICE',
'PROVE',
'TEACH',
'REMEDIATE',
'SKIP',
'REFLECT'
);

create type resource_type as enum (
'PDF',
'TEXT',
'LINK',
'NOTE'
);

create type resource_status as enum (
'UPLOADING',
'PROCESSING',
'EXTRACTING',
'INDEXING',
'READY',
'FAILED'
);

-- =========================================================
-- PROFILES
-- =========================================================

create table profiles (
id uuid primary key references auth.users(id) on delete cascade,
display_name text,
timezone text default 'Asia/Kolkata',
daily_minutes integer default 30,
preferences jsonb default '{}'::jsonb,
created_at timestamptz default now(),
updated_at timestamptz default now()
);

-- =========================================================
-- GOALS
-- =========================================================

create table goals (
id uuid primary key default gen_random_uuid(),
user_id uuid not null references profiles(id) on delete cascade,

title text not null,
description text,
deadline date,

current_level text,
existing_knowledge text,
constraints jsonb default '[]'::jsonb,

daily_minutes integer default 30,

status goal_status default 'ACTIVE',

created_at timestamptz default now(),
updated_at timestamptz default now()
);

create index goals_user_idx on goals(user_id);
create index goals_status_idx on goals(status);

-- =========================================================
-- JOURNEYS
-- =========================================================

create table journeys (
id uuid primary key default gen_random_uuid(),

goal_id uuid not null references goals(id) on delete cascade,

title text not null,

version integer default 1,

status journey_status default 'PENDING',

progress numeric(5,2) default 0,

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now(),
updated_at timestamptz default now()
);

create index journeys_goal_idx on journeys(goal_id);

-- =========================================================
-- CONCEPTS
-- =========================================================

create table concepts (
id uuid primary key default gen_random_uuid(),

name text not null,
description text,

domain text,

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now(),

unique(name, domain)
);

-- =========================================================
-- JOURNEY NODES
-- =========================================================

create table journey_nodes (
id uuid primary key default gen_random_uuid(),

journey_id uuid not null references journeys(id) on delete cascade,

concept_id uuid references concepts(id) on delete set null,

title text not null,
subtitle text,

phase text,

node_order integer not null,

estimated_minutes integer,

state journey_node_state default 'UPCOMING',

progress numeric(5,2) default 0,

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now(),
updated_at timestamptz default now()
);

create index journey_nodes_journey_idx
on journey_nodes(journey_id);

create index journey_nodes_concept_idx
on journey_nodes(concept_id);

-- =========================================================
-- CONCEPT GRAPH
-- =========================================================

create table concept_edges (
id uuid primary key default gen_random_uuid(),

source_concept_id uuid not null
references concepts(id) on delete cascade,

target_concept_id uuid not null
references concepts(id) on delete cascade,

relationship_type text not null,

weight numeric(5,2) default 1,

metadata jsonb default '{}'::jsonb,

unique(
source_concept_id,
target_concept_id,
relationship_type
)
);

create index concept_edges_source_idx
on concept_edges(source_concept_id);

create index concept_edges_target_idx
on concept_edges(target_concept_id);

-- =========================================================
-- LEARNER CONCEPT STATE
-- =========================================================

create table learner_concepts (
id uuid primary key default gen_random_uuid(),

user_id uuid not null
references profiles(id) on delete cascade,

concept_id uuid not null
references concepts(id) on delete cascade,

mastery_score numeric(5,2) default 0,
confidence_score numeric(5,2) default 0,
retention_score numeric(5,2) default 0,
risk_score numeric(5,2) default 0,

status concept_status default 'NOT_LEARNED',

evidence_count integer default 0,

last_seen_at timestamptz,
last_retrieved_at timestamptz,
next_review_at timestamptz,

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now(),
updated_at timestamptz default now(),

unique(user_id, concept_id)
);

create index learner_concepts_user_idx
on learner_concepts(user_id);

create index learner_concepts_risk_idx
on learner_concepts(user_id, risk_score desc);

-- =========================================================
-- MISCONCEPTIONS
-- =========================================================

create table misconceptions (
id uuid primary key default gen_random_uuid(),

user_id uuid not null
references profiles(id) on delete cascade,

concept_id uuid
references concepts(id) on delete cascade,

tag text not null,

description text,

severity numeric(5,2) default 0,

occurrences integer default 1,

resolved boolean default false,

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now(),
updated_at timestamptz default now()
);

create index misconceptions_user_idx
on misconceptions(user_id);

-- =========================================================
-- LEARNING SESSIONS
-- =========================================================

create table sessions (
id uuid primary key default gen_random_uuid(),

user_id uuid not null
references profiles(id) on delete cascade,

goal_id uuid
references goals(id) on delete cascade,

journey_node_id uuid
references journey_nodes(id) on delete set null,

concept_id uuid
references concepts(id) on delete set null,

recommendation_id uuid,

type session_type not null,

status session_status default 'CREATED',

started_at timestamptz,
completed_at timestamptz,

score numeric(5,2),

confidence numeric(5,2),

result jsonb default '{}'::jsonb,

created_at timestamptz default now(),
updated_at timestamptz default now()
);

create index sessions_user_idx
on sessions(user_id);

create index sessions_concept_idx
on sessions(concept_id);

-- =========================================================
-- EVIDENCE
-- =========================================================

create table evidence (
id uuid primary key default gen_random_uuid(),

user_id uuid not null
references profiles(id) on delete cascade,

concept_id uuid not null
references concepts(id) on delete cascade,

session_id uuid
references sessions(id) on delete set null,

type evidence_type not null,

score numeric(5,2),

confidence numeric(5,2),

details jsonb default '{}'::jsonb,

created_at timestamptz default now()
);

create index evidence_user_idx
on evidence(user_id);

create index evidence_concept_idx
on evidence(concept_id);

-- =========================================================
-- RESOURCES
-- =========================================================

create table resources (
id uuid primary key default gen_random_uuid(),

user_id uuid not null
references profiles(id) on delete cascade,

title text not null,

type resource_type not null,

storage_path text,

source_url text,

status resource_status default 'UPLOADING',

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now(),
updated_at timestamptz default now()
);

create index resources_user_idx
on resources(user_id);

-- =========================================================
-- RESOURCE CHUNKS / VECTOR STORE
-- =========================================================

create table resource_chunks (
id uuid primary key default gen_random_uuid(),

resource_id uuid not null
references resources(id) on delete cascade,

chunk_index integer not null,

content text not null,

metadata jsonb default '{}'::jsonb,

embedding vector(1536),

created_at timestamptz default now()
);

create index resource_chunks_resource_idx
on resource_chunks(resource_id);

-- =========================================================
-- RESOURCE ↔ CONCEPT
-- =========================================================

create table resource_concepts (
resource_id uuid not null
references resources(id) on delete cascade,

concept_id uuid not null
references concepts(id) on delete cascade,

relevance numeric(5,2) default 1,

primary key(resource_id, concept_id)
);

-- =========================================================
-- MENTOR THREADS
-- =========================================================

create table mentor_threads (
id uuid primary key default gen_random_uuid(),

user_id uuid not null
references profiles(id) on delete cascade,

goal_id uuid
references goals(id) on delete set null,

title text,

created_at timestamptz default now(),
updated_at timestamptz default now()
);

-- =========================================================
-- MENTOR MESSAGES
-- =========================================================

create table mentor_messages (
id uuid primary key default gen_random_uuid(),

thread_id uuid not null
references mentor_threads(id) on delete cascade,

user_id uuid not null
references profiles(id) on delete cascade,

role text not null,

content text not null,

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now()
);

create index mentor_messages_thread_idx
on mentor_messages(thread_id, created_at);

-- =========================================================
-- RECOMMENDATIONS
-- =========================================================

create table recommendations (
id uuid primary key default gen_random_uuid(),

user_id uuid not null
references profiles(id) on delete cascade,

goal_id uuid
references goals(id) on delete cascade,

concept_id uuid
references concepts(id) on delete set null,

journey_node_id uuid
references journey_nodes(id) on delete set null,

type recommendation_type not null,

title text not null,

description text,

reason text,

priority numeric(6,4),

estimated_minutes integer,

accepted boolean,

completed boolean default false,

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now()
);

create index recommendations_user_idx
on recommendations(user_id, created_at desc);

-- =========================================================
-- REVISION
-- =========================================================

create table review_items (
id uuid primary key default gen_random_uuid(),

user_id uuid not null
references profiles(id) on delete cascade,

concept_id uuid not null
references concepts(id) on delete cascade,

due_at timestamptz not null,

interval_days integer default 1,

successful_retrievals integer default 0,

failed_retrievals integer default 0,

last_result numeric(5,2),

metadata jsonb default '{}'::jsonb,

created_at timestamptz default now(),
updated_at timestamptz default now(),

unique(user_id, concept_id)
);

create index review_items_due_idx
on review_items(user_id, due_at);

-- =========================================================
-- UPDATED_AT FUNCTION
-- =========================================================

create or replace function update_updated_at()
returns trigger
language plpgsql
as $$
begin
new.updated_at = now();
return new;
end;
$$;

-- =========================================================
-- UPDATED_AT TRIGGERS
-- =========================================================

create trigger profiles_updated_at
before update on profiles
for each row execute function update_updated_at();

create trigger goals_updated_at
before update on goals
for each row execute function update_updated_at();

create trigger journeys_updated_at
before update on journeys
for each row execute function update_updated_at();

create trigger journey_nodes_updated_at
before update on journey_nodes
for each row execute function update_updated_at();

create trigger learner_concepts_updated_at
before update on learner_concepts
for each row execute function update_updated_at();

create trigger misconceptions_updated_at
before update on misconceptions
for each row execute function update_updated_at();

create trigger sessions_updated_at
before update on sessions
for each row execute function update_updated_at();

create trigger resources_updated_at
before update on resources
for each row execute function update_updated_at();

create trigger mentor_threads_updated_at
before update on mentor_threads
for each row execute function update_updated_at();

create trigger review_items_updated_at
before update on review_items
for each row execute function update_updated_at();









alter table profiles enable row level security;
alter table goals enable row level security;
alter table journeys enable row level security;
alter table journey_nodes enable row level security;
alter table learner_concepts enable row level security;
alter table misconceptions enable row level security;
alter table sessions enable row level security;
alter table evidence enable row level security;
alter table resources enable row level security;
alter table resource_chunks enable row level security;
alter table resource_concepts enable row level security;
alter table mentor_threads enable row level security;
alter table mentor_messages enable row level security;
alter table recommendations enable row level security;
alter table review_items enable row level security;








create policy "users can view own profile"
on profiles
for select
using (auth.uid() = id);

create policy "users can update own profile"
on profiles
for update
using (auth.uid() = id);

create policy "users can manage own goals"
on goals
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can view own journeys"
on journeys
for select
using (
exists (
select 1
from goals
where goals.id = journeys.goal_id
and goals.user_id = auth.uid()
)
);

create policy "users can view own journey nodes"
on journey_nodes
for select
using (
exists (
select 1
from journeys
join goals on goals.id = journeys.goal_id
where journeys.id = journey_nodes.journey_id
and goals.user_id = auth.uid()
)
);

create policy "users can manage own learner concepts"
on learner_concepts
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own misconceptions"
on misconceptions
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own sessions"
on sessions
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own evidence"
on evidence
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own resources"
on resources
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own mentor threads"
on mentor_threads
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own mentor messages"
on mentor_messages
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own recommendations"
on recommendations
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);

create policy "users can manage own reviews"
on review_items
for all
using (auth.uid() = user_id)
with check (auth.uid() = user_id);