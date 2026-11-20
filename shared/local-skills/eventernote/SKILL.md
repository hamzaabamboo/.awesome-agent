---
name: eventernote
description: Add, edit or mark attendance on events in the user's Eventernote account (HamP_punipuni). Use when the user says "add to eventernote", gives a show/live/schedule URL to log, or asks to fix an Eventernote event, performer or venue.
---

# Eventernote

Every fact you write to Eventernote is **fact-checked** against a source, every entity is checked for an existing entry before you create it, and every write is **minimal**: one deliberate create or save per real change, so the shared database never gets duplicates, junk, or retries.

## Browser setup

Prefix every agent-browser command with both env vars. If you leave out `AGENT_BROWSER_HEADED=1` even once, the browser relaunches headless and the login is lost:

```bash
export AGENT_BROWSER_ARGS="--use-mock-keychain,--password-store=basic" AGENT_BROWSER_HEADED=1
agent-browser --session eventernote-login auth login eventernote   # vault profile; never ask the user to log in
```

- Wrap each command in `timeout 60`, because ad-heavy pages make `wait` hang.
- Confirm you are logged in: the page body contains `HamP_punipuni`.
- Close the session when you finish.

## Steps

### 1. Collect facts

Read the source the user gave in full, including its subpages: schedule, cast, access, flyer. Build a fact sheet with one source URL per field:

- title
- date, 開場 and 開演 times (and 終演 if stated)
- venue
- performers per performance (cast groups, roles)
- tickets
- synopsis

When the source omits a field (venue, readings), take it from a second independent source: CoRich, a ticket site, the agency page, the troupe blog. Copy text verbatim. A field with no source stays blank.

The user's explicit corrections (for example "終演 is 21:00") override the sheet; record them as user-supplied.

Done when every field has either a source URL, a user statement, or BLANK. Mark a field PROVISIONAL when the source calls it 仮, 予定, 未定 or subject to change.

### Provisional marking

Mark a PROVISIONAL or BLANK fact the way existing Eventernote events do:

| Case | Mark it like this | Example event |
|---|---|---|
| Official title is tentative | Append `(仮)` to the title, using the source's own bracket width | 495226 `BUDOKAN(仮)`, 497510 `LIVE 2027（仮）` |
| No title announced yet | `「タイトル未定」` in the title | 500426 |
| Times not announced | Leave the time fields blank and write `時間未定` in the description | 497510, 494510 |
| Venue not announced, or only an area | Leave the place empty, or use the area placeholder venue, and write `会場未定` or `<area> 予定` in the description | 495217, 494510 |
| Lineup tentative | Head the list `出演者（予定）` and copy the official `※出演者は…変更となる場合がございます` line | 494510, 500426 |
| Lineup changed | Prefix the title `【出演者変更】` and update the performers | 488965 |
| Cancelled | Prefix the title `【中止】`; keep the event | 251586 |

- An end time you estimated: write it as a 目安 in the description. The site already labels every 終演 time a 目安.
- Each provisional mark comes off in one edit once the official announcement confirms the value.

### 2. Check for existing entries

Do this before any write. Search every way listed below, not just one:

- **Event**: run all three searches. If any hit is the same show, date and 組/公演 slot, it EXISTS: go to step 6 to update it rather than creating a new one.
  - Keyword search on title fragments: `/events/search?keyword=…`
  - Date listing: `/events/search?year=Y&month=M&day=D&limit=200`
  - The venue page: `/places/<id>`
- **Venue**: search `/places/search?keyword=…` with several fragments (e.g. `BONBON`), then confirm the name and address.
- **Performers**:
  - Exact-name search: `/actors/search?keyword=<name>`.
  - In the logged-in page, also run a fuzzy search through `/api/actors/search?keyword=` (full name, surname, given name) to catch variant spellings.
  - A fuzzy hit counts only if it is the same person (same agency or works); a shared kanji is not enough.

Done when every event, venue and performer is either EXISTS (with an ID) or MISSING (all searches run).

### 3. Plan the writes

List every write you intend to make (creates, edits, attendance), with a count. Show it to the user when it includes new performers or anything beyond what they asked for.

- Group all changes to one event into a single edit save.
- Edits to any user's event are allowed when every changed field is sourced; that is how the shared listing stays current.
- Delete an event only when the user names that exact one.

### 4. Register missing performers

`/actors/add` requires a name, a hiragana よみがな and 性別 (`sex` 1=女性, 2=男性, 3=混合).

- Register a performer only when both the reading and the sex are evidenced. Evidence is a self-introduction with furigana, agency romaji (convert it to hiragana and say so), or an agency men/women category URL.
- Leave out performers with no evidence, list them for the user, and keep them in the description text.
- Re-run the exact-name search immediately before each create.
- Register in bulk with in-page `fetch`: GET `/actors/add`, then POST `/actors/add/confirm`, then POST the confirm form to `/actors/add/complete`. After each one, read the new ID back from the search.

### 5. Create the event

Use the real form in the browser: open `/events/add`, set the fields through the DOM, then call `form.submit()`. A raw `fetch` POST to `/events/add/complete` returns 500.

- **Title**: `<劇団/主催> 第N回公演 <作品名> M/D<組>`. Follow how earlier runs by the same organiser are titled.
- **Fields**:
  - `date[year|month|day]`, `open_time[hour|minute]`, `start_time[hour|minute]`.
  - `end_time[hour|minute]`: when a start time is set, the server rejects an empty end time with `Incorrect time value … end_time`. Fill it in, and if the end time is your estimate, say so in the description. When no times are known, leave all three fields blank.
  - `place_id` is set after triggering `$('#prefecture_id').change()` and waiting for the option to load.
  - Add performers with the page's `addActor(id, name)`.
  - `link` is the official URL.
- **Description**, using only facts from the sheet:
  - title
  - that performance's date, 開演 time and 組
  - the 開場 note
  - 公演期間 and 会場
  - 【あらすじ】 verbatim
  - 【出演】 the full cast with roles, including performers with no actor entry
  - 【チケット】
  - 公式サイト
  - every PROVISIONAL or BLANK field, marked as in the provisional-marking table
- **Confirm page**: it can display performer names wrongly for brand-new actor IDs. Trust the hidden `actor_ids` field, then verify on the live page.

Done when the complete page shows `イベントの登録が完了しました` and you have the new `/events/<id>`.

### 6. Update an existing event

Use this step when an event EXISTS (step 2), or when new official info arrives for an event: a title, times, venue, lineup, a cancellation, or a confirmation of something marked provisional.

1. **Diff.** `curl` the live `/events/<id>` page and compare each field against the new fact sheet:
   - title, date and times
   - venue
   - performers
   - link and description

   Every difference needs a source. Only the differences get written; matching fields stay untouched.
2. **Plan.** List the field-level changes per event, for example:
   - `終演 - → 21:00`
   - `title: drop (仮)`
   - `+3 performers`
   - `【中止】 prefix`

   New performers go through step 4 first.
3. **Apply in one save per event.**
   - Open `/events/<id>/edit` and wait until `#places_list` holds the saved `place_id`. If you change anything before that, the venue is wiped.
   - Change only the planned fields: `event_name`, `date[…]`, `*_time[…]`, `place_id` (via `$('#prefecture_id').change()`), `link`, `description`.
   - Performers: `addActor(id, name)` adds one; `removeActor(id)` removes only the ones the source dropped. Read `#actor_ids` back before saving.
   - Update the description in place:
     - Rewrite the affected lines.
     - Remove the provisional marks the new info resolves.
     - Add a line for each new provisional fact.
     - Keep everything else as it was, including other users' text.
   - Call `form.submit()` once and wait for `/events/<id>/`.
4. **Recheck.** `curl` the public page and confirm every planned change landed and nothing else moved.

Done when the live page matches the updated fact sheet and the event's edit history shows exactly one new save from HamP_punipuni per event.

### 7. Mark attendance

On the event page, run `addNote('<id>')`.

Done when, after a reload, `.note-edit-area` is visible and `.note-delete-btn` links to `deleteNote('<noteId>')`.

### 8. Verify

`curl` each public event page and compare against the fact sheet:

- date and times
- venue
- performer list
- description

Report a table with the event links, what was created or changed (with counts and field-level diffs for edits), what was skipped and why, and which values were derived, user-supplied or still provisional. Then close the browser session.
