# TODO: bug audit

Findings from a full read of `lib/`, cross-checked against the backend (`championshiptracker/backend`) models and real staging data (2026-10-06).

Legend: **[verified]** reproduced against staging data or confirmed in config; **[latent]** the code crashes or misbehaves if the backend sends a value it is allowed to send, but current staging data doesn't trigger it yet.

---

## P0: Critical

- [x] **Release builds have no network access** [verified]
  - `android/app/src/main/AndroidManifest.xml` does not declare `android.permission.INTERNET`; only the `debug` and `profile` manifests do. Every API call fails in a release APK built by the new release scripts.
  - Fix: add `<uses-permission android:name="android.permission.INTERNET"/>` to the main manifest, then smoke-test a release build on a device.

- [x] **Live matches are never detected as live** [verified]
  - `lib/enums/matchs.dart`: `MatchStatus.inProgress` maps to `'in_progress'`, but the backend sends `'ongoing'`. Unknown values fall back to `planned`, so a live match shows its kickoff time with no score on the card, "VS" and "Scheduled" in the header, and never appears under the Live filter.
  - The enum is also missing `scheduled`, `cancelled` and `abandoned`, which all silently become `planned`.
  - Fix: mirror the backend `MatchStatus` choices exactly (`planned, scheduled, ongoing, completed, awarded, postponed, cancelled, abandoned`) and update every `MatchStatus.inProgress` usage (`match_card.dart`, `match_header.dart`, `match_screen.dart`). Add a model test that parses each backend value.

## P1: High

- [ ] **Timeline shows shootout kicks and missed penalties as goals** [verified]
  - `lib/helpers/utils.dart` `buildTimelineEvents` only skips goals with status `cancelled`. Goals with `goal_type: pso` and status `missed` / `pending` are rendered as normal goals. Example: `2026-maroc-w-vs-cameroun-w-sf` ended 0-0 (1-3 pens) but the timeline would show 9 "goals" at 118' and 120'.
  - Fix: render only `GoalStatus.valid` non-`pso` goals as goals; show the shootout as its own section (or skip it), and show a missed in-game penalty as its own event type if wanted.

- [ ] **Model parsing crashes on nullable backend fields** [latent]
  - Any of these turns into a `TypeError` inside `fromJson`, which fails the whole request (for a match, the entire Match Center shows "Could not find match details"; for the team list, the whole Teams tab errors):

    | Dart field (non-null) | Backend field (nullable) |
    | --- | --- |
    | `Goal.minute` (`models/goal.dart`) | `Goal.minute` |
    | `DisciplinaryCard.minute` (`models/disciplinary_card.dart`) | `Card.minute` |
    | `Stadium.city`, `.country`, `.capacity` (`models/stadium.dart`) | `Stadium.city/country/capacity` |
    | `Team.coach`, `Team.slug` (`models/team.dart`) | `Team.coach/slug` |
    | `MatchTeam.slug`, `TeamLookup.slug` | `Team.slug` |
    | `PlayerLookup.firstname/lastname/slug`, `GoalPlayer.*`, `PlayerTeam.*` (`models/player.dart`, `goal.dart`, `team.dart`) | `Player.firstname/lastname/slug` |
    | `Player.nationality`, `.dateOfBirth`, `.jerseyNumber`, `.matricule` (`models/player.dart`) | same fields on `Player` |
    | `PlayerTeam.jerseyNumber` | `Player.jersey_number` |

  - `PlayerLookup` is also used by the MOTM models, so one player with a null name breaks the MOTM tab.
  - Fix: make these fields nullable or default them (`?? ''`, `?? 0`, guarded `DateTime.parse`), and add model tests with null fixtures. Where a null `slug` is used for navigation (`/teams/:slug`, `/players/:slug`), disable the tap instead of pushing `/teams/null`.

- [ ] **Matches near midnight land on the wrong day** [verified in code]
  - `MatchService.getMatchsByDay` sends the device's local date, but the backend's `/matchs/day/` filters on the UTC day (`TIME_ZONE = "UTC"`). For a user in UTC+2, a match at 00:30 local (22:30 UTC) shows under the previous day and is missing from the day it is actually played.
  - Fix: either send a `tz` offset / UTC range to the backend, or fetch the neighbouring UTC day(s) and filter client-side by local date.

- [ ] **Match list shows stale results when switching dates quickly** [latent]
  - `lib/screens/matchs/match_screen.dart` `_loadMatchesForDate` has no request ordering. Tapping several dates in a row lets an older, slower response overwrite a newer one, so the list can show matches for a date that is no longer selected.
  - Fix: track a request token / the requested date and ignore responses that don't match the current selection.

- [ ] **Championship screen can hang or throw after dispose**
  - `lib/screens/championships/championship_details.dart` `loadEdition` has no `try/catch` and no `mounted` check. A failed request leaves a spinner forever (plus an unhandled exception); leaving the screen before it loads calls `setState` on a disposed widget.
  - Fix: wrap in `try/catch`, check `mounted`, and show an error state with retry.

## P2: Medium

- [ ] **Scores never refresh on their own**
  - Neither the match list nor Match Center polls or listens for updates (the websocket service is disabled), and there is no pull-to-refresh on either. Live scores stay frozen until the user navigates away and back.
  - Fix: add pull-to-refresh to both, and a periodic refresh (e.g. every 30-60s) while any shown match is live.

- [ ] **Standings and match list refetch on every rebuild**
  - `lib/widgets/championships/standing_table.dart` and `match_list.dart` are `StatelessWidget`s that create their `Future` inside `build()`. Any parent rebuild (tab switches, favorite toggles) refires the request and flashes the spinner.
  - Fix: make them `StatefulWidget`s and create the future once in `initState` (as `player_stats.dart` already does).

- [ ] **Edition year dropdown in the Teams tab does nothing**
  - `lib/widgets/championships/championship_team_list.dart`: the years are hardcoded (`[2024, 2025, 2026]`) and `_selectedEdition` is never passed to the request (`getTeamsByEdition(widget.editionId)`), so changing it just refetches the same list.
  - Fix: remove the dropdown, or populate it from the championship's real editions and load the selected one.

- [ ] **Settings toggles have no effect**
  - `lib/screens/settings/settings_screen.dart` persists `dark_mode` and the `notif_*` prefs, but nothing in the app reads them: the theme is hardcoded to dark in `main.dart`, and the notification service is disabled and never checks these flags.
  - Fix: wire them up, or hide them until the features exist so users aren't misled.

- [ ] **Postponed/cancelled matches show a 0-0 score**
  - `lib/widgets/ui/match_card.dart` and `match_header.dart` show the score for every status except `planned`, so postponed, cancelled and (once the enum is fixed) scheduled matches display "0 - 0".
  - Fix: only show a score for `ongoing`, `completed` and `awarded`; show a status label otherwise.

- [ ] **Pagination may follow `http://` links in release builds** [verified on staging, impact to confirm]
  - Staging returns `"next": "http://api.staging..."` (and `http://` image URLs) even though the API base is `https`. `fetchPaginated` follows `next` as-is, so page 2+ goes over cleartext HTTP, which Android/iOS can block in release builds.
  - Fix (backend): set `SECURE_PROXY_SSL_HEADER` / `USE_X_FORWARDED_HOST` so Django builds `https` URLs. Defensive fix (app): rewrite `next` to the base URL's scheme in `fetchPaginated`.

- [ ] **Notification permission is never requested on Android 13+**
  - `POST_NOTIFICATIONS` is declared but never requested at runtime, so local notifications will be silently dropped once the background service is re-enabled.
  - Fix: call `requestNotificationsPermission()` (flutter_local_notifications) when the user turns notifications on.

- [ ] **Websocket reconnect loops can multiply connections**
  - `lib/ws/notification_ws.dart` and `lib/ws/websocket_manager.dart` reconnect from both `onError` and `onDone`. An error is usually followed by a close, so each failure schedules two reconnects, and the number of open sockets grows over time. Retry delay is also fixed (2-3s) with no backoff.
  - Fix: reconnect from a single place, guard with an "already reconnecting" flag, and use exponential backoff. Do this before flipping `kEnableBackgroundNotificationService` back on.

- [ ] **Two concurrent first-launch calls can register two devices**
  - `DeviceService.getOrRegisterDevice` has no in-flight guard. If two callers hit it before the first registration finishes (e.g. UI and background isolate), two device IDs are created and only the last is stored; anything tied to the other one (like a MOTM vote) is orphaned.
  - Fix: cache the in-flight `Future` and return it to concurrent callers.

## P3: Low / cleanup

- [ ] **Teams pull-to-refresh ends instantly and drops the search filter**: `lib/screens/teams/team_screen.dart` `_refreshTeams` doesn't await the request, and the reload resets `_filteredTeams` to all teams while the search box still has text. Same no-await refresh in `championship_screen.dart`.
- [ ] **Lineups tab only shows starters**: `_LineupsTab` filters on `isStarting`, so substitutes never appear.
- [ ] **Second yellow shows as a yellow card**: timeline ignores `DisciplinaryCard.isSecondYellow`.
- [ ] **Links in articles don't open**: `blog_details_screen.dart` renders `Html(...)` without `onLinkTap`.
- [ ] **Bottom nav highlights "Scores" on detail pages**: `app_layout.dart` `_selectedIndex` returns 0 for `/matchs/details/*` and `/players/*`, even when reached from Leagues or Teams.
- [ ] **Date strip can duplicate or skip a day around DST**: `match_screen.dart` builds the range with `now.subtract(Duration(days: n))`; use calendar arithmetic (`DateTime(y, m, d - n)`) instead.
- [ ] **Notifications can overwrite each other**: `LocalNotificationService.show` uses seconds-since-epoch as the ID, so two notifications in the same second replace each other.
- [ ] **Copy-pasted / misleading error messages**: `MatchService.getMatchById` and `getLiveMatches` say "Can't get standings."
- [ ] **Service API oddities**: `ChampionshipService.getChampionshipsByEdition` ignores its `edition` argument; `getEditionById` builds a URL without a trailing slash (forces a Django redirect); `getChampionshipById` takes a `String` id.
- [ ] **Dead code**: `MatchesTabScreen` and `PlayerListScreen` aren't routed; `_connectWebSocket` / `_reconnect` / `_channel` in `background_service.dart` are unused; `urls['MATCHS']['SUBTITUTIONS']` (typo) is unused.
- [ ] **`main()` calls `dotenv.load` before `WidgetsFlutterBinding.ensureInitialized()`**: works today, but loading an asset before the binding is initialized is fragile; swap the two lines.
- [ ] **Test gaps**: no model tests with null fields, unknown enum values, or a shootout match; no widget tests for Match Center tabs.
