# SKILLTWIN

## Personal AI Mentor & Adaptive Goal Journey

**Product Requirements • UX Specification • Technical Architecture • MVP Roadmap**

> **North Star:** Tell SkillTwin where you want to go. Your mentor figures out what you should do next.

**Reference UI:** The supplied roadmap reference uses a clean mobile layout with a continuous orange winding path connecting circular milestone nodes. The uploaded wireframe follows this visual language.

> **North Star: Tell SkillTwin where you want to go. Your mentor figures out what you should do next.**

Reference UI supplied for the desired winding roadmap experience.

### Document Contents

## 1. Product Vision & Positioning

## 2. Product Principles

## 3. Target Users & Use Cases

## 4. Core User Experience

## 5. Information Architecture

## 6. Screen-by-Screen Flutter UX Specification

## 7. Signature Roadmap UI

## 8. AI Mentor Intelligence

## 9. Learner Twin / Learner State

## 10. Adaptive Learning & Intervention Engine

## 11. Knowledge Graph & Knowledge Debt

## 12. Content, Notes & Resource Intelligence

## 13. Teach Mode & Voice

## 14. Retention & Revision System

## 15. Technical Architecture

## 16. Backend / FastAPI Architecture

## 17. Supabase Database Model

## 18. API Contract

## 19. AI / LLM Architecture

## 20. RAG & Document Pipeline

## 21. Flutter Project Structure

## 22. Security, Privacy & Reliability

## 23. Notifications & Background Jobs

## 24. MVP Scope

## 25. Development Roadmap

## 26. Demo Story

## 27. Success Metrics

## 28. Future Expansion

## 1. Product Vision & Positioning

SkillTwin is a Flutter-based personal AI mentor that guides a learner from their current state to a specific outcome. The product is not primarily a chatbot, course platform, or quiz generator. It is a persistent guidance system that maintains a model of the learner, understands the goal, builds an adaptive journey, decides the next best action, and updates the plan as evidence accumulates.

| Core product statement
Give SkillTwin a goal. It builds the journey, learns what you know, identifies what is blocking you, and continuously tells you what to do next. |
| --- |

### Positioning

| Traditional learning app | SkillTwin |
| --- | --- |
| Shows courses and modules | Maintains a living journey toward an outcome |
| User decides what to study | Mentor recommends the next best action |
| Completion = progress | Evidence = progress |
| Generic revision | Revision based on retention and mistakes |
| Answers questions | Understands the learner's state and guides decisions |
| Static roadmap | Roadmap adapts to performance, time and goals |

### North-star experience

When the user opens the app, they should immediately understand: where I am, where I am going, why the mentor wants me to do something, and what I can do right now.

## 2. Product Principles

Goal-first: every recommendation should connect to the user's chosen outcome.

Mentor-first: the primary experience is guidance, not content browsing.

Action over information: the app should reduce decision fatigue and surface one clear next move.

Evidence over completion: mastery is based on demonstrated understanding and repeated evidence.

Adaptive by default: the roadmap can reorder, pause, accelerate or revisit topics.

Explain the why: recommendations should show concise reasoning when the user asks.

Avoid overload: the mentor should actively tell users what not to study yet.

Persistent context: the mentor remembers goals, history, weaknesses, resources and learning patterns.

LLM as reasoning layer, not database: deterministic state and business rules stay outside the model.

## 3. Target Users & Use Cases

| Persona | Goal | Example SkillTwin journey |
| --- | --- | --- |
| Student | Pass an exam | Syllabus → diagnostic → daily plan → revision → mock tests |
| Job seeker | Become job-ready | Target role → skill graph → projects → interview evidence |
| Developer | Learn a new stack | Current skills → prerequisite gaps → project-driven learning |
| Founder | Build a product | Goal → milestones → research → build → review → next action |
| Professional | Certification / promotion | Competencies → evidence → targeted remediation |

### Universal goal schema

Goal title

Desired outcome

Deadline or target date

Current level

Available time per day/week

Preferred learning resources

Constraints

Optional target benchmark (exam score, role, certification, project outcome, etc.)

## 4. Core User Experience

The complete product loop is:

GOAL → ASSESS → PLAN → ACT → OBSERVE → UPDATE → ADAPT → NEXT BEST ACTION

### Primary journey

User creates a goal in natural language.

Mentor asks only the minimum questions needed to establish a baseline.

Backend generates a structured journey and concept/prerequisite map.

User completes a short diagnostic.

Learner state is initialized with confidence and evidence.

Home screen surfaces the first recommended action.

User completes a learning, practice, revision or proof session.

Session evaluator updates mastery, confidence, misconception and retention state.

Recommendation engine chooses the next best action.

Journey roadmap changes when evidence justifies it.

### Core actions

| Action | Purpose | Typical duration |
| --- | --- | --- |
| Learn | Introduce a new concept or missing prerequisite | 10–30 min |
| Revise | Recover declining or weak knowledge | 3–15 min |
| Practice | Apply knowledge to problems | 5–30 min |
| Prove | Verify whether mastery is real | 5–15 min |
| Teach | Explain a concept to the mentor by voice/text | 3–10 min |
| Reflect | Review progress and plan adjustments | 2–5 min |

## 5. Information Architecture

Flutter App
├── Home
├── Journey
├── Twin
├── Library
└── Profile
 └── Global Mentor access from every screen

Home
├── Today's recommendation
├── Mentor note
├── Current goal
├── Daily plan
└── Quick actions

Journey
├── Winding roadmap
├── Phases
├── Concepts
├── Prerequisites
└── Goal progress

Twin
├── Overall mastery
├── Skill/concept map
├── Weaknesses
├── Retention risk
├── Evidence
└── Learning patterns

Library
├── Uploaded PDFs
├── Notes
├── Links
├── Generated summaries
└── Saved resources

Profile
├── Goals
├── Time availability
├── Preferences
├── Notifications
└── Account

## 6. Screen-by-Screen Flutter UX Specification

| Screen | Required UI / behavior |
| --- | --- |
| Splash / Session Restore | ['Brand mark', 'Silent auth/session restoration', 'Load active goal and cached mentor state', 'Fallback to login if session expired'] |
| Onboarding | ['Goal input', 'Deadline', 'Current level', 'Daily time', 'Existing resources', 'Optional preferences', 'Mentor introduction'] |
| Home | ['Greeting', 'Goal progress', "Today's next action", 'Why this action', 'Daily checklist', 'Mentor note', 'Quick start'] |
| Mentor Chat | ['Persistent conversation', 'Goal-aware responses', 'Suggested actions', 'Context cards', 'Voice input', 'Session launch'] |
| Journey | ['Winding path', 'Phase nodes', 'Current node', 'Completed nodes', 'Locked/upcoming nodes', 'Progress', 'Node details'] |
| Concept Detail | ['Mastery', 'Confidence', 'Retention risk', 'Evidence', 'Misconceptions', 'Prerequisites', 'Mentor recommendation'] |
| Twin | ['Overall state', 'Skill clusters', 'Knowledge graph', 'Weaknesses', 'Evidence', 'History'] |
| Library | ['Upload', 'Resource cards', 'Processing status', 'Concept extraction', 'Search/filter', 'Generated notes'] |
| Learning Session | ['Goal', 'Context', 'Learn/Practice/Prove stages', 'Hints', 'Answer', 'Feedback', 'Completion'] |
| Teach Mode | ['Voice recorder', 'Live transcript', 'Mentor prompts', 'Understanding report', 'Fix weakness action'] |
| Revision | ['Due concepts', '3–10 minute queue', 'Retrieval questions', 'Confidence', 'Next review date'] |
| Profile | ['Account', 'Goals', 'Time', 'Preferences', 'Notification controls', 'Data/privacy controls'] |

## 7. Signature Roadmap UI — Winding Journey

The roadmap should visually resemble the supplied reference: a clean mobile card-based screen with a continuous orange winding path connecting circular milestone nodes. This is not merely decorative; it is the user's visual representation of the journey.

Conceptual SkillTwin roadmap wireframe inspired by the supplied reference image.

### Roadmap node states

| State | Visual treatment | Behavior |
| --- | --- | --- |
| Completed | Filled orange node + check/icon | Tappable; shows evidence and completion |
| Current | Filled/highlighted node with stronger emphasis | Primary CTA; opens current phase |
| Needs attention | Orange/outlined warning treatment | Mentor explains why remediation is needed |
| Upcoming | Light node / muted label | Visible but not actionable until prerequisites are met |
| Locked | Muted node | Shows prerequisite or condition preventing access |
| Skipped | Dashed/muted path | Can be revisited if later evidence indicates a gap |

### Roadmap rules

The path is generated from journey phases, not individual chat messages.

Node positions should alternate left/right to create the winding effect.

The path must remain readable on small phones and support scrolling.

The current node should always be visible near the top when the Journey screen opens.

Tapping a node opens a bottom sheet or detail screen with mastery, evidence, prerequisites and CTA.

The mentor may insert a remediation node without destroying the user's overall journey.

Completed nodes remain visible as a history of progress.

The roadmap can visually distinguish 'recommended next' from merely 'available'.

### Reference visual language

Warm off-white page background.

Orange as the primary action/path color.

White cards with soft rounded corners.

Black/dark charcoal primary text.

Minimal iconography inside circular roadmap nodes.

Bottom navigation with 4–5 destinations.

Avoid dense dashboards; prioritize a single clear journey.

## 8. AI Mentor Intelligence

The Mentor is an orchestration layer, not a single giant prompt.

User message
 ↓
Mentor API
 ↓
Load learner state + goal + journey + recent evidence
 ↓
Recommendation / policy layer
 ↓
Retrieve only relevant context
 ↓
LLM generates mentor response
 ↓
Structured action + natural-language explanation
 ↓
Flutter renders message + CTA

### Mentor responsibilities

Translate a vague goal into an actionable journey.

Explain why a topic or action is recommended.

Decide whether to learn, revise, practice, prove, skip or remediate.

Keep the learner focused on the chosen outcome.

Use prior mistakes and evidence in future interactions.

Detect when the learner is moving too quickly or repeating content unnecessarily.

Recommend high-value resources while filtering low-value noise.

Summarize progress and update the user's understanding state.

### Mentor response contract

{
 "message": "I would fix probability before starting model evaluation.",
 "intent": "REMEDIATE",
 "target_concept_id": "probability_basics",
 "estimated_minutes": 12,
 "reason": "Recent retrieval accuracy is low and the concept is a prerequisite.",
 "cta": "Start 12-minute repair session"
}

## 9. Learner Twin / Learner State

The twin is the persistent state that allows the mentor to be genuinely personalized.

| Dimension | Examples | Updated by |
| --- | --- | --- |
| Knowledge | Concept mastery | Assessments, problems, explanations |
| Confidence | Self-reported confidence | User ratings, consistency |
| Retention | Estimated recall probability | Delayed retrieval |
| Misconceptions | Repeated conceptual errors | Evaluator + error patterns |
| Behavior | Hint use, pace, skipped sessions | App telemetry |
| Preferences | Examples-first, concise notes | Onboarding + interactions |
| Evidence | Projects, teach-backs, tests | Verified activities |

### Concept state

ConceptState
- concept_id
- mastery_score: 0..100
- confidence_score: 0..100
- retention_score: 0..100
- risk_score: 0..100
- status: NOT_LEARNED | LEARNING | UNCERTAIN | MASTERED | NEEDS_REVIEW
- misconception_tags[]
- evidence_count
- last_seen_at
- next_review_at
- prerequisite_status

## 10. Adaptive Learning & Intervention Engine

The engine converts learner state into the next best action.

Priority =
 Goal relevance
+ prerequisite importance
+ mastery gap
+ retention risk
+ deadline pressure
+ recent error severity
- already demonstrated evidence
- unnecessary repetition

| Condition | Recommended intervention |
| --- | --- |
| Prerequisite missing | Fix prerequisite first |
| Low mastery + never learned | Learn |
| Moderate mastery + repeated errors | Targeted practice |
| High mastery + high retention risk | Retrieval revision |
| High mastery + strong evidence | Progress / skip |
| High confidence + low evidence | Prove |
| Correct answers + weak explanations | Teach-back |
| Same misconception repeated | Misconception repair |

## 11. Knowledge Graph & Knowledge Debt

Every goal is represented as a graph of skills/concepts and prerequisite relationships. The graph enables the mentor to trace a visible weakness back to an underlying blocker.

Neural Networks
 ├── Backpropagation
 │ ├── Chain Rule
 │ └── Derivatives
 └── Gradient Descent

If Backpropagation is weak:
 inspect prerequisite evidence
 → Chain Rule weak?
 → Derivatives weak?
 → create a remediation action

### Knowledge debt

Knowledge debt is a foundational gap that continues to create downstream failures. The UI should show it as a mentor insight, not as a scary score.

## 12. Content, Notes & Resource Intelligence

User uploads PDF/notes or adds a link.

System extracts text and metadata.

Concepts and prerequisites are detected.

Relevant content is associated with journey concepts.

Mentor selects only the relevant sections for current actions.

Generated notes are personalized to known weaknesses.

The system can label resources KEEP, USE NOW, REFERENCE, or IGNORE FOR NOW.

### Personalized notes example

| NOTES FOR YOU
You already understand the definition of precision and recall. The part you repeatedly confuse is when a false positive matters more than a false negative. Your next revision should use scenarios rather than definitions. |
| --- |

## 13. Teach Mode & Voice

Microphone → Speech-to-Text → Mentor prompt → LLM evaluator → Understanding report → Learner state update

### Understanding report

| Signal | Meaning |
| --- | --- |
| Conceptual accuracy | Are the core claims correct? |
| Completeness | Did the explanation cover necessary components? |
| Reasoning | Does the learner connect cause and effect correctly? |
| Confidence | How certain is the learner and is it calibrated? |
| Transfer | Can the learner apply the principle outside the exact example? |
| Misconceptions | Which incorrect mental models are present? |

Voice is a differentiator, but it should be implemented after the core mentor and adaptive loop work reliably.

## 14. Retention & Revision System

The first version does not need a scientifically perfect forgetting model. It needs a transparent, consistent prioritization system that improves with evidence.

Track last successful retrieval.

Track delayed retrieval performance.

Increase review priority after repeated failures.

Reduce review frequency after repeated successful retrieval.

Prioritize concepts that are both important to the goal and at risk of being forgotten.

Expose the next review as a small action rather than a giant revision queue.

### Revision card

RECURSION
Mastery: 78%
Retention risk: HIGH
Last strong retrieval: 9 days ago

Mentor:
"Give me 4 minutes. I want to check whether the mental
model is still intact."

[START RETRIEVAL]

## 15. Technical Architecture

| Recommended stack
Flutter + FastAPI + Supabase/PostgreSQL + pgvector + one LLM provider. Keep the initial backend as a modular monolith; do not split into microservices for the MVP. |
| --- |

FLUTTER
 │
 HTTPS / JSON
 │
 FASTAPI
 │
 ┌──────────────┼────────────────┐
 │ │ │
 DOMAIN LOGIC AI ORCHESTRATOR RESOURCE PIPELINE
 │ │ │
 ▼ ▼ ▼
 PostgreSQL LLM PDF/Text extraction
 + pgvector Embeddings chunking / indexing
 Auth / Storage
 SUPABASE

### Why FastAPI?

FastAPI gives a clean server-side boundary between Flutter and the intelligence layer. It can own recommendation logic, learner-state updates, LLM orchestration, document processing, background jobs and future provider changes without shipping sensitive logic to the client.

### What belongs where

| Layer | Responsibilities |
| --- | --- |
| Flutter | UI, navigation, local cache, animations, audio capture, rendering |
| FastAPI | Business logic, mentor orchestration, recommendations, assessments, state updates |
| Supabase | Auth, PostgreSQL, file storage, pgvector |
| LLM | Generation, reasoning, evaluation, explanation |
| Background worker | PDF processing, embeddings, scheduled revision jobs |

## 16. Backend / FastAPI Architecture

backend/
├── app/
│ ├── main.py
│ ├── api/
│ │ ├── auth.py
│ │ ├── goals.py
│ │ ├── journey.py
│ │ ├── mentor.py
│ │ ├── sessions.py
│ │ ├── assessments.py
│ │ ├── concepts.py
│ │ ├── resources.py
│ │ └── voice.py
│ ├── services/
│ │ ├── mentor_service.py
│ │ ├── planner_service.py
│ │ ├── learner_model.py
│ │ ├── assessment_service.py
│ │ ├── knowledge_service.py
│ │ ├── resource_service.py
│ │ └── llm_service.py
│ ├── models/
│ ├── schemas/
│ ├── repositories/
│ ├── core/
│ └── workers/
└── tests/

### Important design rule

Do not make the LLM the source of truth. The database and deterministic services own learner state. The LLM receives relevant state and returns structured outputs that are validated before being stored.

## 17. Supabase Database Model

| Table | Important fields |
| --- | --- |
| profiles | id, name, timezone, preferences |
| goals | id, user_id, title, description, deadline, daily_minutes, status |
| journeys | id, goal_id, version, progress, status |
| journey_nodes | id, journey_id, concept_id, order, state, position_x, position_y |
| concepts | id, name, description, domain |
| concept_edges | source_id, target_id, relationship_type, weight |
| learner_concepts | user_id, concept_id, mastery, confidence, retention, risk, status |
| misconceptions | id, user_id, concept_id, tag, severity, status |
| resources | id, user_id, title, type, storage_path, processing_status |
| resource_chunks | id, resource_id, content, embedding |
| sessions | id, user_id, goal_id, type, started_at, completed_at |
| evidence | id, user_id, concept_id, type, score, source_session_id |
| mentor_messages | id, user_id, role, content, created_at |
| review_items | id, user_id, concept_id, due_at, interval, last_result |

### Row-level security

Every user-owned row should be protected so a user can only access their own goals, learner state, sessions and resources.

## 18. API Contract

| Method | Endpoint | Purpose |
| --- | --- | --- |
| POST | /goals | Create goal and start journey generation |
| GET | /goals/{id} | Get goal state |
| GET | /journeys/{id} | Get roadmap nodes and progress |
| GET | /mentor/today | Get current best action |
| POST | /mentor/message | Send mentor message |
| POST | /sessions | Start learning/practice/prove session |
| POST | /sessions/{id}/complete | Evaluate and update learner state |
| GET | /concepts/{id} | Get concept state and evidence |
| POST | /resources/upload | Create resource processing job |
| GET | /resources/{id} | Get resource and processing status |
| POST | /teach/evaluate | Evaluate teach-back |
| GET | /revision/next | Get next retrieval items |

## 19. AI / LLM Architecture

Use a provider abstraction so the application can switch models without rewriting product logic.

LLMProvider
├── generate()
├── structured_output()
├── embed()
└── moderate()

MentorService
├── get_user_state()
├── get_goal_context()
├── retrieve_relevant_evidence()
├── decide_action()
├── generate_response()
└── persist_decision()

### Minimize AI cost

Use deterministic recommendation rules for obvious cases.

Use smaller/cheaper models for classification, tagging and simple extraction.

Use the stronger model only for roadmap generation, difficult diagnosis and high-value mentor reasoning.

Cache generated concept summaries and repeated resource explanations.

Send only relevant learner state and retrieved chunks instead of entire histories.

Store structured results so the same reasoning does not need to be regenerated.

## 20. RAG & Document Pipeline

Upload PDF
 ↓
Object Storage
 ↓
Text extraction
 ↓
Clean + chunk
 ↓
Concept/entity extraction
 ↓
Embedding generation
 ↓
pgvector
 ↓
Link chunks → concepts → journey nodes
 ↓
Mentor retrieves only relevant material

For MVP, start with PDFs and plain text. Add web pages, video transcripts and other formats later.

## 21. Flutter Project Structure

lib/
├── app/
│ ├── router/
│ ├── theme/
│ └── bootstrap/
├── core/
│ ├── networking/
│ ├── storage/
│ ├── audio/
│ └── widgets/
├── features/
│ ├── onboarding/
│ ├── home/
│ ├── mentor/
│ ├── journey/
│ ├── twin/
│ ├── library/
│ ├── sessions/
│ ├── teach_mode/
│ └── profile/
└── main.dart

### State management

Use Riverpod or an equivalent predictable state-management approach. Keep API models, domain models and UI state separated.

## 22. Security, Privacy & Reliability

Never place LLM API secrets in the Flutter application.

Authenticate every user request.

Apply database row-level security.

Validate all structured LLM outputs server-side.

Limit upload size and accepted MIME types.

Treat uploaded documents as user data; provide deletion controls.

Avoid sending unnecessary personal information to the LLM.

Log AI decisions in structured form for debugging and evaluation.

Use retries with exponential backoff for provider failures.

Provide graceful fallbacks when AI generation fails.

## 23. Notifications & Background Jobs

Daily mentor recommendation.

Due revision reminder.

Milestone reached.

Goal deadline approaching.

Resource processing completed.

Mentor follow-up after a missed session.

Do not use noisy gamification. Notifications should feel like useful mentor interventions.

## 24. MVP Scope

### Must have

Authentication

Goal onboarding

AI-generated journey

Winding roadmap UI

Home screen with next best action

Mentor chat

Basic learner state

Learning/practice/prove session

Mastery updates

PDF upload and basic concept extraction

Basic personalized notes

Basic revision queue

### Should have

Teach Mode with voice

Misconception detection

Knowledge graph

Knowledge debt explanation

Push notifications

### Do later

Multi-goal portfolio

Enterprise dashboards

Teacher dashboards

Advanced retention modeling

Complex graph database

Social/community features

Marketplace of mentors/resources

## 25. Development Roadmap

| Phase | Deliverable |
| --- | --- |
| Phase 0 — Foundation | Set up Flutter, FastAPI, Supabase, auth, environment management, API client and design system. |
| Phase 1 — UI Prototype | Build onboarding, Home, Mentor, Journey winding roadmap, Twin, Library and Profile with mock data. |
| Phase 2 — Real Goal Engine | Natural-language goal → structured goal → initial journey → persisted roadmap. |
| Phase 3 — Mentor Core | Goal-aware chat, next-best-action endpoint, structured mentor responses, action CTAs. |
| Phase 4 — Learner Model | Concept states, mastery, confidence, evidence, sessions and updates. |
| Phase 5 — Adaptive Sessions | Learn, practice, prove, targeted remediation and basic revision. |
| Phase 6 — Resource Intelligence | PDF upload, extraction, embeddings, concept linking and personalized notes. |
| Phase 7 — Teach Mode | Speech-to-text, teach-back evaluation and understanding report. |
| Phase 8 — Polish & Demo | Animations, error states, analytics, notifications, performance, onboarding polish and end-to-end demo. |

### Recommended order of implementation

Build the app visually first with mock data, then connect one vertical slice end-to-end:

Goal → Journey → Today's action → Session → Evaluation → Updated Twin → New recommendation

## 26. Hackathon Demo Story

User says: 'I want to become an AI/ML engineer in six months.'

Mentor asks about current level and available time.

SkillTwin creates a visual winding roadmap.

User uploads machine-learning notes.

The app extracts concepts and associates them with the journey.

A short diagnostic finds weak probability fundamentals.

Home immediately changes: 'Fix Probability — 12 min.'

User completes a targeted session.

User enters Teach Mode and explains model evaluation.

AI identifies a precision/recall misconception.

Mentor inserts a short remediation step into the journey.

User passes the follow-up retrieval.

The roadmap updates and the next recommended action changes.

| The demo moment
The strongest moment is not the AI chat. It is when the app visibly changes the roadmap because it learned something new about the user. |
| --- |

## 27. Success Metrics

| Metric | Why it matters |
| --- | --- |
| Goal creation completion | Measures onboarding clarity |
| First recommended action completion | Measures whether guidance converts into action |
| 7-day journey retention | Measures ongoing usefulness |
| Recommendation acceptance rate | Measures trust in mentor decisions |
| Session completion rate | Measures actionability |
| Mastery improvement | Measures learning outcome |
| Delayed retrieval success | Measures retention |
| Resource-to-action conversion | Measures whether uploaded content becomes useful |
| Mentor satisfaction | Measures perceived personalization |

### Qualitative success

The user should be able to say: 'I don't have to figure out what to do next. SkillTwin already knows where I am and gives me the next step.'

## 28. Future Expansion

Multiple simultaneous goals with priority management.

Career-specific journeys tied to job descriptions and skill requirements.

Verified skill portfolios built from evidence rather than course completion.

University competency maps.

Enterprise learning and onboarding.

Project-based learning where real project output becomes evidence.

Mentor voice calls and proactive coaching.

Calendar-aware learning plans.

Cross-goal knowledge reuse: skills learned in one journey can satisfy prerequisites in another.

Long-term learner profiles that evolve across courses, jobs and years.

### Final Architecture — One-Page Reference

| Recommended foundation
Flutter client + FastAPI modular backend + Supabase/PostgreSQL/pgvector + LLM provider + background worker. |
| --- |

SKILLTWIN
 │
 ┌─────────┴─────────┐
 │ FLUTTER │
 │ Home / Mentor │
 │ Journey / Twin │
 │ Library / Sessions│
 └─────────┬─────────┘
 │
 API
 │
 ┌─────────▼─────────┐
 │ FASTAPI │
 │ Mentor / Planner │
 │ Learner Model │
 │ Assessments │
 │ Resources / Voice │
 └──────┬───────┬────┘
 │ │
 ┌─────────▼─┐ ┌▼────────────┐
 │ SUPABASE │ │ AI LAYER │
 │ Auth │ │ LLM │
 │ Postgres │ │ Embeddings │
 │ Storage │ │ RAG │
 │ pgvector │ └─────────────┘
 └───────────┘

Your goal. Your journey. Your mentor.

## Supplied Roadmap UI Wireframe

The uploaded wireframe visually specifies the **Journey** screen. It shows:

- Top greeting and large **Your Learning Journey** heading.
- Current target shown as **AI / ML Engineer** with **42%** overall journey progress.
- A horizontal progress bar using the orange primary action color.
- **Your Roadmap** section with the subtitle **Adaptive path — changes as you learn**.
- A continuous orange winding path connecting six numbered milestones.
- Milestones shown in the reference:
  1. **Python Fundamentals** — Completed
  2. **Mathematics** — Completed
  3. **Machine Learning** — Current focus
  4. **Deep Learning** — Upcoming
  5. **ML Engineering** — Upcoming
  6. **Portfolio / Job Ready** — Upcoming
- Bottom navigation with **Home, Journey, Twin, Library, Profile**, with Journey highlighted.
- Warm off-white/white visual treatment, dark charcoal typography, and orange path/nodes.

This corresponds directly to the technical specification's Signature Roadmap UI section, which states that the roadmap is the user's visual representation of the journey and that node positions alternate left/right to create the winding effect. fileciteturn0file0L200-L204
