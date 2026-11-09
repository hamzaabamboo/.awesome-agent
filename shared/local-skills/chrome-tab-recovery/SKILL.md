---
name: chrome-tab-recovery
description: Recover the tabs Chrome had open before a crash, reboot, or bad restore on macOS. Use when the user says tabs are lost, Chrome restore failed, Cmd+Shift+T does not bring them back, or asks to recover open tabs.
---

# Chrome tab recovery (macOS)

Goal: the tabs that were OPEN at the crash, not browsing history. The user rejects history lists; use history only as a labeled last-minutes supplement.

## Where state lives
- `~/Library/Application Support/Google/Chrome/<Profile>/Sessions/`
  - `Session_<n>`: window and tab state (the real open-tab list, includes closed-tab commands).
  - `Tabs_<n>`: per-tab navigation state; cannot tell open from closed tabs. Treat as weak evidence.
- Chrome deletes the previous `Session_` files on restart, so the live dir usually holds only post-restart files. Check timestamps against the crash time.
- Check which profiles exist (`Default`, `Profile N`) and which browser the user actually used; inspect Firefox `sessionstore-backups/` and Safari only if Chrome has nothing.

## Order of work
1. `ls -lT` the Sessions dir and note the crash time from `ps` start times and `Session_` mtimes.
2. Copy files before reading (Chrome has them open); work in the scratchpad.
3. Look for older copies, newest first:
   - Time Machine volume (`/Volumes/Time Machine/<stamp>*/Macintosh HD - Data/Users/<user>/Library/Application Support/Google/Chrome/<Profile>/Sessions/`). Interrupted and `.inprogress` backups count.
   - `tmutil listlocalsnapshots /`. Mounting a snapshot may fail with "Resource busy".
4. Parse with `scripts/snss.py <file>` (tab-separated: pinned, title, url). `Session_` files give the open tabs; closed tabs are excluded.
5. Union tabs from the newest `Session_` copies across backups; long-lived tabs often survive only in older copies. Dedupe by URL.
6. Only if still short, add pages from `History` (copy the sqlite file; filter `visits` by time) and label them as history.

## Delivering
- Open recovered URLs in Chrome with `open -a "Google Chrome" <urls>`; this is allowed only because the user asked to open them this turn. Skip `chrome://` URLs (cannot be opened from the CLI).
- Say plainly what each source is and what is unverified (open vs closed). Never claim a list is "the tabs at crash" unless it came from a `Session_` file written near the crash.
- Do not close or restart the user's Chrome or touch their live Sessions files.

## Pitfalls seen
- A `Tabs_` file from before the crash looked authoritative but contained tabs the user had already closed.
- Regex-splitting parser output on `|` breaks on titles containing `|`; split from the right.
- Local `Sync Data` LevelDB is snappy-compressed and mostly other devices; not useful.
