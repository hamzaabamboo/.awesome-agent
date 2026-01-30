# Repo Setup

You are setting up this repository for agentic coding with Gemini and Claude (Universal Setup).

## Step 0: Check Existing Setup & Context

First, check what's already configured in this repo:

```bash
ls -la GEMINI.md CLAUDE.md .cursorrules 2>/dev/null
ls -la .gemini/ .claude/ 2>/dev/null
ls -la docs/ specs/ 2>/dev/null
cat .gemini/settings.json .claude/settings.json 2>/dev/null
```

**If things are already set up**, ask the user:
- "I see you already have [X] configured. Would you like me to:
  - Add missing pieces only?
  - Replace/update existing config?
  - Skip certain parts?"

**If you don't have enough context** about the project:
- Check for package.json, pyproject.toml, Cargo.toml, go.mod to detect project type
- Read any existing GEMINI.md, CLAUDE.md or .cursorrules
- If still unclear, say: "Tell me more about this project and what you're trying to build here. Or if you'd like, we can plan the project first before setting up—would you prefer that?"

## Step 1: Interview the User

Ask about these if not already clear from context:

1. **Project basics:**
   - What type of project? (web app, API, CLI, library, monorepo)
   - Primary language/framework?
   - New repo or existing codebase?
   - If monorepo: what packages/apps?

2. **Tooling preferences:**
   - Ralph for autonomous development loops?
   - Code quality tools? (knip, jscpd)
   - If frontend: ESLint rules for component discipline?

3. **Project specifics:**
   - Non-standard patterns or architecture?
   - Testing strategy? (interface tests > unit tests)
   - Database/ORM? (Prisma for JS/TS, SQLAlchemy for Python)
   - Existing GEMINI.md/CLAUDE.md to migrate?

## Step 2: Create CLAUDE.md and Symlink GEMINI.md

**ONE SOURCE OF TRUTH**: Generate the master configuration as `CLAUDE.md`, then symlink `GEMINI.md` to it. This ensures both agents see the exact same conventions.

1. Generate a concise `CLAUDE.md` (<300 lines).
2. Run `ln -sf CLAUDE.md GEMINI.md` to create the alias.

Include all relevant sections in `CLAUDE.md`:

```markdown
# Project Name

[1-2 sentence description]

## 🎯 Quick Reference

- **Dev**: `npm run dev` / `bun run dev` (Check PORT! e.g. 3000 vs 5173)
- **Test**: `npm test` / `bun test`
- **Build**: `npm run build` / `bun run build`
- **Lint**: `npm run lint` / `bun run lint`

## 📚 Documentation Hub

See `docs/` for detailed guides:
- [PROJECT_STATUS.md](docs/PROJECT_STATUS.md) - Current state, tracking, blockers
- [QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md) - Cheatsheets, critical commands
- [TECH_STACK.md](docs/TECH_STACK.md) - Architecture decisions
- [DEVELOPMENT_GUIDE.md](docs/DEVELOPMENT_GUIDE.md) - Patterns and standards

## 🏗️ Directory Structure

[Tree of main directories with brief descriptions]

## 🛠️ Tech Stack

- Framework: [e.g., Next.js 15, FastAPI, Elysia]
- Database: [e.g., Postgres + Prisma, SQLite + SQLAlchemy]
- Key deps: [list major ones]

## 📏 Conventions

- **Strict Types**: No `any`. Define interfaces/types for everything.
- [File naming patterns]
- [Component/module patterns]
- [State management approach]
- Keep file/function names discrete and unique
- Add comments only on code that's referenced elsewhere (Chesterton's fence)

## 🚫 What NOT to Do

- NEVER edit .env or environment files
- NEVER run destructive git ops (reset --hard, rm -rf) unless explicitly instructed
- NEVER add eslint-disable comments - fix the actual issue
- NEVER create abstractions I didn't ask for
- NEVER silence linter errors
- NEVER commit broken code - run tests first

## 🧘 Philosophy

This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into technical debt that slows the whole team down.

You are not just writing code. You are shaping the future of this project. The patterns you establish will be copied. The corners you cut will be cut again.

Fight entropy. Leave the codebase better than you found it.

## 🧪 Testing

[Strategy and commands - prefer interface tests over unit tests]

## 📝 Commit Rules

Run `/commit` after completing tasks. Update `docs/PROJECT_STATUS.md` on completion.

## 💡 Context Tips

- One chat = one task
- Reference docs/*.md for subsystem docs
```

### Domain-Specific Additions

**For Vike + Elysia (Bun) stacks:**
```markdown
## Vike/Elysia Conventions
- **Bun**: Use `bun` for all scripts.
- **Port**: Dev server runs on port 3000 (usually). Verify in `package.json`.
- **RPC**: Use Telefunc or Elysia Eden for type-safe backend communication.
- **Islands**: Minimal client-side JS. Use `.client.tsx` explicitly if needed.
```

**For backends, add:**
```markdown
## Backend Conventions
- Use an ORM for schema-as-context (Prisma, SQLAlchemy, Drizzle)
- Invest in realistic seed data so agents can self-verify
- Generate API docs and Postman workspaces for easy testing
```

**For Python backends, also add:**
```markdown
## Python Conventions
- SQLAlchemy models in `models/`, Pydantic schemas in `schemas/`
- Async everywhere (aiosqlite, httpx)
- Type hints required on all functions
```

**For JavaScript/TypeScript frontends, add:**
```markdown
## Frontend Conventions
- Leaf components are presentational (no business logic)
- Business logic lives in parent components
- Design tokens only (no custom colors/spacing values)
- Responsiveness matters - remind the agent from the start
- Create styling reference docs and configure tailwind.config with main colors/spacing
- Install Vercel's React best practices skill and frontend-design plugin
```

**For monorepos, add:**
```markdown
## Monorepo Rules
- Agents are worse at monorepos - be extra explicit
- Always be explicit about which package you're working in
- Use full paths from repo root
- Check package.json in the specific package for scripts
```

## Step 3: Create Directory Structure

Implement a robust documentation hub:

```bash
mkdir -p docs specs scripts .gemini .claude
```

Create these essential files:
- `docs/PROJECT_STATUS.md` - Active tracking of features and blockers
- `docs/QUICK_REFERENCE.md` - Commands and critical snippets
- `docs/TECH_STACK.md` - Architecture details
- `docs/DEVELOPMENT_GUIDE.md` - Standards and patterns
- `docs/schema.sql` - DB schema if applicable
- `specs/requirements.md` - Project requirements

## Step 4: Set Up Tooling (If Requested)

### Code Quality Tools (knip + jscpd)

```bash
# knip - find dead code and unused exports
npm install -D knip
npx knip init

# jscpd - find code duplication
npm install -D jscpd
```

Add to `package.json`:
```json
{
  
```