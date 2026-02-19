---
name: issue-refinement
description: "Convert PRDs to refined issue markdown files in the specs/issues folder for autonomous execution. Use when you have an existing PRD and need to convert it to file-based issue/ticket format. Triggers on: convert this prd, refine this into issues, create issues from this."
---

# PRD to Issue Refiner

Converts existing PRDs into well-structured issue markdown files that autonomous agents can execute independently without prior context.

---

## The Job

Take a PRD (markdown file or text) and convert it to as many `[seq]-[priority]-[name].md` issue files in your `specs/issues/` directory as necessary. Each issue must be self-contained and executable by a fresh agent with zero context.

---

## Issue Markdown Format

Each issue MUST be a standalone markdown file that a completely fresh agent (with zero context) can pick up and execute. The format below is REQUIRED:

```markdown
---
title: Short, descriptive title of this specific task
description: One-sentence summary of what this issue accomplishes
status: todo|in-progress|done|cancelled
priority: low|medium|high
created: YYYY-MM-DD
completed: YYYY-MM-DD (only when status=done)
blocks: [issue-id-1, issue-id-2] # List of issues blocked by this one
blocked-by: [issue-id-3] # List of issues that must be completed first
branch: feature/branch-name # Git branch for this work
prd: specs/prds/[name].md # Link to source PRD for full context
estimate: Minutes|Hours|Days|Weeks # Realistic completion time
tags: [feature, bugfix, refactor, etc]
---

# Task: [Exact Task Name]

## Context

**Background**: Explain WHY this task exists and what problem it solves.

**Current State**: Describe the codebase state BEFORE this task (what exists now).

**Desired State**: Describe the codebase state AFTER this task (what should exist).

**Related PRD**: Always read the PRD file referenced in frontmatter (`prd: specs/prds/...`) for full feature context before starting implementation.

**Important Files**: List key files/directories relevant to this task:
- `path/to/file1.ts` - Description of relevance
- `path/to/file2.ts` - Description of relevance

## Objectives

Clear, numbered list of what must be accomplished:
1. Specific objective one
2. Specific objective two
3. Specific objective three

## Acceptance Criteria

Verifiable checklist - a fresh agent must be able to check each item:

- [ ] Specific, testable criterion (e.g., "Add `status` column to `tasks` table with type `'pending' | 'in_progress' | 'done'` and default `'pending'`")
- [ ] Another specific criterion (e.g., "Status dropdown shows exactly three options: Pending, In Progress, Done")
- [ ] Typecheck passes (`npm run typecheck` or equivalent exits with code 0)
- [ ] Tests pass (if applicable: `npm test` or equivalent exits with code 0)
- [ ] Code review completed (hand off to @code-reviewer skill/agent)

**For UI changes, also include:**
- [ ] Verify in browser using agent-browser skill (navigate to [specific URL], confirm [specific behavior])

## Implementation Steps

Detailed, sequential instructions for implementation. Be specific enough that an agent with NO prior context can follow:

1. **Step One Name**
   - Read file `path/to/file.ts`
   - Add/modify the following code: [be specific]
   - Expected outcome: [what should happen]

2. **Step Two Name**
   - Create new file `path/to/new-file.ts`
   - Implement following function: [provide signature/description]
   - Expected outcome: [what should happen]

3. **Run Tests**
   - Execute: `npm test [specific test file]`
   - All tests should pass

4. **Verify Changes**
   - Run typecheck: `npm run typecheck`
   - If UI change: Use agent-browser to navigate to [URL] and verify [behavior]

## Testing & Validation

**Automated Tests**:
- List specific test files to run or create
- Expected test outcomes

**Manual Verification**:
- For UI: Navigate to [URL], perform [action], observe [result]
- For API: Call [endpoint] with [payload], expect [response]

**Performance Checks** (if applicable):
- [Specific metric to check]

**IMPORTANT**: You MUST hand off to @code-reviewer agent after implementation!

## Dependencies

**Must Complete First** (blocked-by):
- `issue-id-1`: [Why this must be done first]

**Blocks These Issues** (blocks):
- `issue-id-2`: [Why this issue blocks that one]

**External Dependencies**:
- Package: [package-name] version [x.x.x] (install with: `npm install ...`)
- API: [external service] (requires: [credential/setup])

## Notes

**Assumptions**:
- List any assumptions about the codebase or environment

**Edge Cases**:
- List edge cases to handle or explicitly not handle

**Future Considerations**:
- Technical debt or follow-up work this creates

## References

**Documentation**:
- [Link to relevant docs]

**Related Issues**:
- `issue-id-x`: [Description of relationship]

**Code Examples**:
- [Link or snippet showing similar pattern in codebase]
```

### Critical Requirements for Fresh Agents

Every issue MUST be written so that an agent starting with ZERO context can:

1. **Understand WHY**: Context section explains the problem and motivation
2. **Know WHAT**: Objectives and acceptance criteria are crystal clear
3. **Know WHERE**: Implementation steps reference specific file paths
4. **Know HOW**: Step-by-step instructions are detailed enough to follow
5. **Know WHEN DONE**: Acceptance criteria are verifiable checkboxes
6. **Get HELP**: References point to PRD and related issues for more context

---

## Story Size: The Number One Rule

**Each issue must be completable in one session (one context window).**

Every issue refinement must ensure that each task can be completed before the agent runs out of context. Because each session starts with no memory of previous work, if the work can't be completed in session, the agent might produce broken code or incomplete implementations.

### Right-sized issues:
- Add a database column and migration
- Add a UI component to an existing page
- Update a server action with new logic
- Add a filter dropdown to a list
- Write tests for a specific function

### Too big (SPLIT THESE):
- "Build the entire dashboard" → Split into: schema, queries, UI components, filters, pagination
- "Add authentication" → Split into: schema, middleware, login UI, logout UI, session handling
- "Refactor the API" → Split into one issue per endpoint or pattern
- "Implement user management" → Split into: user model, CRUD operations, UI forms, permissions

**Rule of thumb:** If you cannot describe the complete implementation in 5-7 detailed steps, it is too big.

**File naming**: `[sequence]-[priority]-[short-description].md`
- Examples: `001-high-add-status-column.md`, `002-medium-status-badge-ui.md`

---

## Issue Ordering: Dependencies First

Issues execute by priority and dependency order. Use `blocked-by` frontmatter field to enforce dependencies. Earlier issues must NOT depend on later ones.

**Correct order:**
1. `001-high-add-status-column.md` - Schema/database changes (migrations)
2. `002-high-status-server-action.md` - Server actions / backend logic
3. `003-medium-status-badge-ui.md` - UI components that use the backend
4. `004-low-status-dashboard-view.md` - Dashboard/summary views that aggregate data

**Wrong order:**
1. `001-high-status-ui-component.md` - UI component (blocked: depends on schema that doesn't exist yet)
2. `002-high-add-status-column.md` - Schema change

**Use frontmatter to enforce**:
```yaml
# In 003-medium-status-badge-ui.md
blocked-by: [001-high-add-status-column, 002-high-status-server-action]
```

---

## Acceptance Criteria: Must Be Verifiable by Fresh Agent

Each criterion must be something a fresh agent (with no context) can CHECK programmatically or manually verify. NO vague criteria.

### Good criteria (verifiable):
- "Add `status` column to `tasks` table in `schema.prisma` with type `String` and `@default('pending')`"
- "Run migration: `npx prisma migrate dev --name add-task-status`"
- "Status dropdown in `components/StatusFilter.tsx` renders exactly 3 options: 'All', 'Active', 'Completed'"
- "Clicking delete button triggers confirmation dialog with text 'Are you sure?'"
- "Navigate to `/tasks` in browser, verify status badge appears on each task card"
- "Run `npm run typecheck`, exit code is 0"
- "Run `npm test tasks.test.ts`, all tests pass"

### Bad criteria (vague, unverifiable):
- "Works correctly" ← Too vague, what does "correctly" mean?
- "User can do X easily" ← Subjective, can't be verified
- "Good UX" ← Subjective, unmeasurable
- "Handles edge cases" ← Which edge cases? How to verify?
- "Task is complete" ← Circular, not specific

### Always include in EVERY issue:
```markdown
- [ ] Typecheck passes: Run `[specific typecheck command]`, exit code 0
- [ ] Code review completed: Hand off to @code-reviewer
```

### For issues with testable logic:
```markdown
- [ ] Tests pass: Run `[specific test command]`, all tests pass
- [ ] Coverage maintained: Run `[coverage command]`, coverage >= [X]%
```

### For issues that change UI:
```markdown
- [ ] Visual verification: Use agent-browser to navigate to `[specific URL]`, perform `[specific action]`, confirm `[specific observable result]`
```

Frontend issues are NOT complete until visually verified with specific navigation and interaction steps.

---

## Conversion Rules: PRD → Issue Files

When converting a PRD to issue markdown files:

1. **One issue per file**: Each focused task becomes `specs/issues/[seq]-[priority]-[name].md`
2. **Sequential naming**: Use 001, 002, 003... for sequence
3. **Priority in filename**: Include priority level (high, medium, low) in filename
4. **Dependency order**: Number files in dependency order (foundations first)
5. **All start as todo**: Every new issue has `status: todo` in frontmatter
6. **Link to PRD**: Every issue must have `prd: specs/prds/[name].md` in frontmatter
7. **Branch strategy**: Related issues share same branch, or use separate branches - specify in frontmatter
8. **Typecheck required**: Every issue must include "Typecheck passes" in acceptance criteria
9. **Self-contained**: Each issue must be completable by a fresh agent with zero context
10. **Verifiable Acceptance Criteria**: Each issue must have a clear set of criteria that can be verified prior to acceptance

### Directory Structure
```
specs/
├── prds/
│   └── 001-task-status-feature.md       # Source PRD
└── issues/
    ├── 001-high-add-status-column.md    # Issue 1
    ├── 002-high-status-server-action.md # Issue 2
    ├── 003-medium-status-badge-ui.md    # Issue 3
    └── 004-low-status-filter.md         # Issue 4
```

---

## Splitting Large PRDs

If a PRD describes a large feature, split it into multiple small, focused issues. Each issue should be completable in one session.

**Original PRD Section:**
> "Add user notification system with real-time updates, email notifications, and preferences management"

**Split into Multiple Issues:**

1. `001-high-notifications-table.md` - Add notifications table to database schema
2. `002-high-notification-service.md` - Create notification service for creating/sending notifications
3. `003-high-notification-api.md` - Create API endpoints for fetching notifications
4. `004-medium-notification-bell-icon.md` - Add notification bell icon to header
5. `005-medium-notification-dropdown.md` - Create notification dropdown panel UI
6. `006-low-mark-as-read.md` - Add mark-as-read functionality
7. `007-low-notification-preferences.md` - Add notification preferences page
8. `008-low-email-integration.md` - Integrate email notification sending

Each issue:
- Has clear dependencies via `blocked-by` frontmatter
- Is independently completable
- Has verifiable acceptance criteria
- Contains enough context for a fresh agent

---

## Example Conversion

**Input PRD** (`specs/prds/001-task-status-feature.md`):
```markdown
---
title: Task Status Feature
description: Add ability to mark tasks with different statuses to track progress
status: in-progress
priority: high
created: 2026-01-19
tags: [feature, task-management, status-tracking]
---

# Task Status Feature

Add ability to mark tasks with different statuses so users can track progress.

## Requirements
- Toggle between pending/in-progress/done on task list
- Filter list by status
- Show status badge on each task
- Persist status in database

## Technical Notes
- Uses Prisma schema
- Frontend is Next.js with TypeScript
- Task list is at `/tasks` route
```

**Output Issue Files** (`specs/issues/`):

### File: `001-high-add-status-column.md`
```markdown
---
title: Add status field to tasks database schema
description: Add status column to tasks table to store task progress state
status: todo
priority: high
created: 2026-01-19
blocks: [002-high-status-server-action, 003-medium-status-badge-ui]
blocked-by: []
branch: feature/task-status
prd: specs/prds/001-task-status-feature.md
estimate: 30 Minutes
tags: [database, migration, schema]
---

# Task: Add Status Column to Tasks Table

## Context

**Background**: Users need to track task progress with statuses (pending, in-progress, done). Currently, the tasks table has no status field.

**Current State**: Tasks table in `prisma/schema.prisma` contains only id, title, description, createdAt fields.

**Desired State**: Tasks table includes a `status` enum field with values pending/in_progress/done, defaulting to 'pending'.

**Related PRD**: Read `specs/prds/001-task-status-feature.md` for full feature context.

**Important Files**:
- `prisma/schema.prisma` - Database schema definition
- `prisma/migrations/` - Migration files directory

## Objectives

1. Add status enum to Prisma schema
2. Add status field to Task model with appropriate default
3. Generate and apply database migration
4. Verify migration applied successfully

## Acceptance Criteria

- [ ] Enum `TaskStatus` added to `schema.prisma` with values: PENDING, IN_PROGRESS, DONE
- [ ] `status` field added to `Task` model with type `TaskStatus` and `@default(PENDING)`
- [ ] Migration generated: Run `npx prisma migrate dev --name add_task_status`
- [ ] Migration applied successfully: Database updated, no errors in console
- [ ] Typecheck passes: Run `npm run typecheck`, exit code 0
- [ ] Code review completed: Hand off to @code-reviewer

## Implementation Steps

1. **Open Prisma Schema**
   - Read file `prisma/schema.prisma`
   - Locate the `Task` model definition

2. **Add TaskStatus Enum**
   - Add before Task model:
   
       enum TaskStatus {
         PENDING
         IN_PROGRESS
         DONE
       }

3. **Add Status Field to Task Model**
   - Inside Task model, add:
   
       status TaskStatus @default(PENDING)

4. **Generate Migration**
   - Run: `npx prisma migrate dev --name add_task_status`
   - Expected: Migration file created in `prisma/migrations/`
   - Expected: Database updated, console shows "Migration applied"

5. **Verify Migration**
   - Check database to confirm status column exists
   - Run: `npx prisma studio` and inspect tasks table

## Testing & Validation

**Automated Tests**:
- Run typecheck: `npm run typecheck` (should pass)

**Manual Verification**:
- Open Prisma Studio: `npx prisma studio`
- Navigate to Task model
- Confirm `status` field exists with enum values

**IMPORTANT**: Hand off to @code-reviewer after implementation!

## Dependencies

**Must Complete First** (blocked-by): None

**Blocks These Issues** (blocks):
- `002-high-status-server-action`: Server actions need schema in place
- `003-medium-status-badge-ui`: UI needs backend support

**External Dependencies**: None

## Notes

**Assumptions**:
- Using Prisma as ORM
- PostgreSQL or compatible database

**Edge Cases**:
- Existing tasks will default to PENDING after migration

**Future Considerations**:
- May need additional statuses in future (ARCHIVED, CANCELLED)

## References

**Documentation**:
- Prisma Enums: https://www.prisma.io/docs/concepts/components/prisma-schema/data-model#defining-enums

**Related Issues**: None yet

**Code Examples**: See other enum definitions in `schema.prisma`
```

### File: `002-high-status-server-action.md`
```markdown
---
title: Create server action to update task status
description: Add server action to handle task status updates from UI
status: todo
priority: high
created: 2026-01-19
blocks: [003-medium-status-badge-ui]
blocked-by: [001-high-add-status-column]
branch: feature/task-status
prd: specs/prds/001.task-status-feature.md
estimate: 1 Hour
tags: [backend, server-action, api]
---

# Task: Create Task Status Update Server Action

## Context

**Background**: After adding status to database schema, we need a server action for UI components to update task status.

**Current State**: No server action exists to update task status. Database schema now has status field (from issue 001).

**Desired State**: Server action `updateTaskStatus` exists in `app/actions/tasks.ts` that safely updates task status.

**Related PRD**: Read `specs/prds/task-status-feature.md` for full feature context.

**Important Files**:
- `app/actions/tasks.ts` - Server actions for task operations
- `prisma/schema.prisma` - Reference for TaskStatus enum values

## Objectives

1. Create `updateTaskStatus` server action
2. Add validation for status values
3. Handle errors appropriately
4. Return updated task or error

## Acceptance Criteria

- [ ] Function `updateTaskStatus(taskId: string, status: TaskStatus)` exists in `app/actions/tasks.ts`
- [ ] Function validates taskId is valid UUID
- [ ] Function validates status is valid TaskStatus enum value
- [ ] Function updates task in database using Prisma client
- [ ] Function returns `{success: true, task: Task}` on success or `{success: false, error: string}` on failure
- [ ] Typecheck passes: Run `npm run typecheck`, exit code 0
- [ ] Tests pass: Run `npm test app/actions/tasks.test.ts`, all pass
- [ ] Code review completed: Hand off to @code-reviewer

## Implementation Steps

1. **Open Server Actions File**
   - Read `app/actions/tasks.ts`
   - Identify location for new action

2. **Import Required Types**

       import { TaskStatus } from '@prisma/client';
       import { prisma } from '@/lib/prisma';

3. **Create Update Function**

       export async function updateTaskStatus(taskId: string, status: TaskStatus) {
         'use server';
         
         try {
           // Validate inputs
           if (!taskId) throw new Error('Task ID required');
           if (!Object.values(TaskStatus).includes(status)) {
             throw new Error('Invalid status value');
           }
           
           // Update in database
           const task = await prisma.task.update({
             where: { id: taskId },
             data: { status },
           });
           
           return { success: true, task };
         } catch (error) {
           console.error('Failed to update task status:', error);
           return { 
             success: false, 
             error: error instanceof Error ? error.message : 'Unknown error' 
           };
         }
       }

4. **Create Test File**
   - Create `app/actions/tasks.test.ts` if it doesn't exist
   - Add tests for success case, invalid ID, invalid status

5. **Run Tests and Typecheck**
   - Run: `npm test app/actions/tasks.test.ts`
   - Run: `npm run typecheck`

## Testing & Validation

**Automated Tests**:
- Test file: `app/actions/tasks.test.ts`
- Test cases: valid update, invalid taskId, invalid status, database error

**Manual Verification**:
- Import and call function from Node REPL
- Verify database update using Prisma Studio

**IMPORTANT**: Hand off to @code-reviewer after implementation!

## Dependencies

**Must Complete First** (blocked-by):
- `001-high-add-status-column`: Schema must exist first

**Blocks These Issues** (blocks):
- `003-medium-status-badge-ui`: UI needs this action to work

**External Dependencies**: None

## Notes

**Assumptions**:
- Using Next.js server actions
- Prisma client initialized at `@/lib/prisma`

**Edge Cases**:
- Handle case where taskId doesn't exist (Prisma throws error)
- Handle invalid status enum values

**Future Considerations**:
- May need permissions checking (who can update status?)
- May need audit logging for status changes

## References

**Documentation**:
- Next.js Server Actions: https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions

**Related Issues**:
- `001-high-add-status-column`: Provides the schema

**Code Examples**: See other server actions in `app/actions/tasks.ts`
```

---

**Note**: Additional issues 003 and 004 would follow the same detailed pattern shown above.

---

## Checklist Before Creating Issues

Before writing issue markdown files, verify:

- [ ] **PRD reviewed**: Fully understand the feature requirements and context
- [ ] **Issues are small**: Each issue is completable in one session (5-7 implementation steps max)
- [ ] **Dependencies mapped**: Used `blocked-by` and `blocks` frontmatter to establish order
- [ ] **Dependency order**: Issues numbered so foundations come first (schema → backend → UI)
- [ ] **Self-contained**: Each issue has enough context for a fresh agent with zero prior knowledge
- [ ] **Specific file paths**: Implementation steps reference exact files (not "the component file")
- [ ] **Verifiable criteria**: Every acceptance criterion can be checked (not vague like "works well")
- [ ] **Typecheck required**: Every issue includes "Typecheck passes: Run `[command]`, exit code 0"
- [ ] **UI verification**: UI issues include "Visual verification: Navigate to `[URL]`, perform `[action]`, confirm `[result]`"
- [ ] **Code review**: Every issue includes "Code review completed: Hand off to @code-reviewer"
- [ ] **PRD linked**: Every issue has `prd: specs/prds/[name].md` in frontmatter
- [ ] **Proper naming**: Files named `[seq]-[priority]-[descriptive-name].md` (e.g., `001-high-add-status-column.md`)
- [ ] **No forward dependencies**: No issue depends on a later-numbered issue

---

## Common Mistakes to Avoid

### ❌ Vague Context
```markdown
## Context
We need to add status tracking.
```

### ✅ Specific Context
```markdown
## Context
**Background**: Users need to track task progress. Currently tasks have no status field.
**Current State**: Tasks table in `prisma/schema.prisma` has id, title, description.
**Desired State**: Tasks table includes status enum (pending/in_progress/done).
**Related PRD**: Read `specs/prds/task-status-feature.md` for full context.
```

---

### ❌ Vague Implementation Steps
```markdown
1. Update the schema
2. Add the component
3. Test it
```

### ✅ Specific Implementation Steps
```markdown
1. **Update Prisma Schema**
   - Open `prisma/schema.prisma`
   - Add enum before Task model: `enum TaskStatus { PENDING IN_PROGRESS DONE }`
   - Add to Task model: `status TaskStatus @default(PENDING)`
   - Run: `npx prisma migrate dev --name add_task_status`
```

---

### ❌ Unverifiable Acceptance Criteria
```markdown
- [ ] Feature works well
- [ ] Users can update status easily
- [ ] Good UX
```

### ✅ Verifiable Acceptance Criteria
```markdown
- [ ] Status enum added to `schema.prisma` with values PENDING, IN_PROGRESS, DONE
- [ ] Migration applied: Run `npx prisma migrate dev`, no errors
- [ ] Typecheck passes: Run `npm run typecheck`, exit code 0
- [ ] Visual verification: Navigate to `/tasks`, click status dropdown, see 3 options
```

---

### ❌ Missing File Paths
```markdown
Update the component to show status.
```

### ✅ Specific File Paths
```markdown
Update `app/components/TaskCard.tsx` to display status badge using the `task.status` field.
```

---

### ❌ Dependencies Not Specified
```markdown
# Issue 003: Add status UI
# (Agent doesn't know this needs schema and server action first)
```

### ✅ Dependencies Clearly Specified
```markdown
---
blocked-by: [001-high-add-status-column, 002-high-status-server-action]
---
# Issue 003: Add status UI
## Context
**Dependencies**: This requires the status column (001) and server action (002) to be completed first.
```

---

## Workflow Summary

1. **Read the PRD**: Understand full feature scope and requirements
2. **Identify atomic tasks**: Break down into smallest completable units
3. **Map dependencies**: Determine which tasks must complete before others
4. **Number by dependency order**: Foundations first (schema → backend → UI)
5. **Write first issue**: Use full markdown format with all sections
6. **Verify fresh-agent-ready**: Could someone with zero context complete this?
7. **Repeat for remaining issues**: Maintain consistency and detail
8. **Final review**: Run through checklist above
9. **Create issue files**: Write to `specs/issues/[seq]-[priority]-[name].md`

Remember: **Each issue must be completable by a fresh agent with zero context!**
