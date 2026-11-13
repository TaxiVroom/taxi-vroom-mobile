---
name: build-memory
description: Maintains the versioned .aimemory/ knowledge base of this repo, with hot architecture, prefs and hypotheses and an on-demand long-term graph. Use when exploring the codebase, starting non-trivial work, finishing a feature, or updating durable repo understanding and build preferences.
---

# Build Memory

Per-repo memory in `.aimemory/`, committed with the code. Dense line format. Destructive compression on fluff. Graph links over pasted code. The lifecycle (when to read, when to write) is in the `lifecycleStart` and `lifecycleEnd` lines of `.aimemory/INDEX.md`.

## Context budget (~256K)

| Slice | Cap | ~tokens @ 256K | Holds |
|-------|-----|----------------|-------|
| Memory in context | ≤15% | ≤~30K | Hot loaded + LTM fetched this request |
| Active work | ≥85% | ≥~170K | Code, tools, dialogue, diffs |

1. Keep hot memory lean (<30K tokens). 1 token is about 4 characters: the 5 hot files together stay under ~120 KB.
2. Fetch LTM on demand per task. Never load the full graph eagerly.
3. Compress `done.md` at the end of every feature: one short `#L` line per change.

## Layout

```
.aimemory/
  INDEX.md      # hub, always read first
  arch.md       # confirmed hot structure/build graph
  hyp.md        # hypotheses + concept models (revisable)
  done.md       # recent prior work
  prefs.md      # feature-building prefs (always hot)
  ltm/
    CATALOG.md  # id|tags|one-liner|pathRefs
    edges.md    # LTM graph edges
    n/<id>.md   # durable cold node payloads
```

| Shard | Meaning |
|-------|---------|
| `arch` | Confirmed, frequently useful |
| `hyp` | Soft working models, rewritten when wrong |
| `done` | Recent outcomes |
| `prefs` | How to build features here, never LTM |
| `ltm` | Cold/overflow durable graph, never bulk-load |

## Boot and retrieve

1. Read `.aimemory/INDEX.md`.
2. Load hot shards under the 15% cap.
3. If the task matches LTM tags/paths and the memory slice has room: scan `ltm/CATALOG.md`, then fetch matching `ltm/n/<id>.md` + relevant `ltm/edges.md` lines, highest match first. Stop at the cap.
4. Never read all of `ltm/n/`.
5. After work: update hot, promote when near the cap or when knowledge is cold, revise `hyp` freely.

## Formats

### INDEX.md

```markdown
# aimemory
arch: confirmed hot modules/build
hyp: working hypotheses + concepts (revisable)
done: recent outcomes
prefs: feature workflow
ltm: durable cold graph, see ltm/CATALOG.md (do not bulk-load)
entry: <main entry paths> | <layer flow>
```

### arch.md (confirmed)

```text
#N id|kind|path|note
AuthSvc|svc|src/services/auth.ts|JWT

#E from>rel>to
loginMut>calls>AuthSvc

#B key=value
stack=TS+TypeGraphQL+TypeORM+Apollo
build=yarn build

# stub for LTM overflow
#N moneyFlow|@ltm|ltm:moneyFlow|Invoice→Ledger→Payout
```

### hyp.md (revisable)

```text
#H id|status|claim|evidence
batchPricing|open|pricing in repo not resolver|thin resolver; not fully traced
authzCache|wrong|roles cached per request|fresh load each call

#C id|model|links
requestLifecycle|Apollo→authChecker→resolver→repo|#N:AuthSvc
```

`#H` status: `open` | `likely` | `wrong`. There is no `confirmed` status.

- Confirm → move into `arch` (`#N`/`#E`/`#B`) and remove from `hyp`.
- Falsify → mark `wrong` with what is true instead. Keep it while it prevents a likely repeat of the mistake, drop it on the next compaction otherwise.
- `#C`: rewrite the whole line when the model changes. No conflicting versions.
- Never promote `hyp` → `ltm` directly. Path: `hyp` → `arch` → (cold) → `ltm`.

### done.md

```text
#L YYYY-MM-DD|topic|paths|outcome
2026-08-04|billing mutation|resolvers/billing,repos/billing|shipped+e2e

#S older summaries
2026-07|* auth hardening; repo pattern stabilized
```

Keep recent `#L`, fold older ones into `#S`, then into LTM history/topic nodes.

### prefs.md

```text
#P id|rule
feat|resolver thin→repo/service logic→e2e matrix
auth|@Authorized on every Query/Mutation
```

Prefix a non-negotiable rule with `HARD:`.

### ltm/CATALOG.md

```text
#K id|tags|sum|refs
moneyFlow|billing,ledger,payout|Invoice→Ledger→Payout|src/repos/ledger
```

Every `#K` line has its `ltm/n/<id>.md` file. Removing one removes the other.

### ltm/edges.md

```text
#E from>rel>to
moneyFlow>dependsOn>authLifecycle
moneyFlow>implements>#N:Invoice
```

### ltm/n/\<id\>.md

```text
# id: moneyFlow
# tags: billing,ledger,payout
# sum: Invoice→Ledger→Payout

#N id|kind|path|note
LedgerRepo|repo|src/repositories/ledger.ts|postings

#E from>rel>to
Invoice>postsTo>LedgerRepo

#F durable facts
payouts require settled ledger rows
```

Same line language as hot arch: promotion is cut/paste + link update.

## Promote / demote

**Hot → LTM** when:

1. Loading hot (+ needed LTM) would exceed the 15% cap → move the least relevant confirmed subgraphs to `ltm/n/<id>.md`, leave `@ltm` stubs, update catalog + edges.
2. Confirmed knowledge is rarely needed: prefer LTM so hot stays high-signal.
3. Old `done` `#S` still useful → LTM topic/history nodes.
4. Explicit "durable but not hot".

**Never LTM:** `open`/`wrong` hyp, prefs, INDEX entry points, debug fluff.

**LTM → hot:** merge into `arch` if repeatedly needed and under the cap, else stub + fetch.

**Correct LTM** on code conflict: overwrite the node, fix edges, update the catalog sum.

## When to write

| Shard | Update when |
|-------|-------------|
| `arch` | Confirmed structure/build facts from exploration |
| `hyp` | Forming or revising a working model |
| `done` | Meaningful completed change |
| `prefs` | User states or corrects a build preference |
| `ltm` | Promote/demote, correct cold facts, deep rare subsystem |
| `CATALOG` | Node add/remove/retag/summary change |
| `INDEX` | Entry points or shard purpose change |

- A decision with a spec stays in the spec: memory only points to it. Never copy it.
- A decision without a spec gets one line, with its reason and the rejected option: `chosen; rejected: X (why)`. A rejected option is not a failed attempt: never compress it away.

## Compression

- Facts over narrative. Merge duplicate ids in place.
- Links (`@ltm:id`, `#E`) over duplicated subgraphs.
- Drop superfluous content: exact diffs, failed attempts, chat noise.
- On conflict with code: overwrite `arch`/LTM, rewrite `hyp`.
- Never store secrets or tokens.
