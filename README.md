# 🦁 Scoreboards

## The Tactical Pulse of Camerounian Football

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Framework-Flutter-02569B?logo=flutter)](https://flutter.dev)

**Scoreboards Mobile** is an open-source tactical interface dedicated to the high-definition tracking of Camerounian football. From **Elite One** and **Elite Two** to the **Guinness Super League**, this Apps provides intelligence where mainstream apps often fail to provide coverage.

---

## Mission Scope

This project aims to solve the "Data Gap" in local football. While international apps focus on European leagues, Scoreboards Mobile is built for the fans, scouts, and analysts of the 237 ecosystem.

### Focused Coverage

* **Elite One & Two**: Live scores, standings, and detailed lineups for every matchday.
* **National Team Hub**: Comprehensive data on the **Indomitable Lions** (Senior, U23, and Women's selections).
* **Local Intelligence**: Manual verification of venues (from Japoma to Roumdé Adjia) and match officials.
* **Sentinel-Driven Data**: Accuracy ensured by local operatives (Sentinels) who are physically present at the pitches.

## 🛠️ Tech Stack

* **Framework**: Flutter (Dart)
* **State**: Riverpod
* **HTTP**: dio
* **Navigation**: go_router

* **Design System**: "Command Center" (High-contrast Navy & Brand Green)

## 🧭 Architecture

The code is organised by feature, like the Sentinel reporter app:

```text
lib/
  main.dart        startup: config, notifications, providers, first route
  app.dart         the MaterialApp
  core/            what every feature uses
    api/           errors (ApiException) and paging helpers
    providers.dart dio and shared_preferences
    router.dart    every route (Routes) and the router
    config.dart    .env values (API, website)
    device/        this install's anonymous device on the backend
    notifications/ push (Firebase) and local notifications
    theme.dart, links.dart, app_shell.dart, crash_reporting.dart
  features/        one folder per part of the app
    scores/ match/ motm/ competitions/ teams/ players/ blogs/
    favorites/ settings/
  shared/          models and widgets used by several features
```

Inside a feature, each layer has one job:

* **Repository** (`*_repository.dart`): talks to the API with `dio` and
  returns models. No widgets, no state.
* **Providers or controller** (`*_providers.dart`, `*_controller.dart`):
  the screen's data, with Riverpod. A `FutureProvider` loads something; a
  `Notifier` holds state that changes (favorites, paging, votes).
* **Screen and widgets**: show the providers' values (`ref.watch`) and
  call controllers on taps (`ref.read(...).method()`).

Screens never call the API directly, and navigate with `Routes` (for
example `context.push(Routes.match(slug))`), never with hand-written paths.

### Adding a feature

1. Create `lib/features/<name>/` with a repository and its provider.
2. Add providers for what the screen shows, then the screen.
3. Add its path to `Routes` and a `GoRoute` in `core/router.dart`.
4. Test the repository with the fake backend in `test/helpers/fake_http.dart`,
   and the screen with `pumpScreen` from `test/helpers/harness.dart`.

## 🚀 Deployment Protocol

### Prerequisites

* Flutter SDK (Latest Stable)

* Android Studio / Xcode
* A valid uplink to the Scoreboards API

### Local Setup

1. **Clone the repository:**

   ```bash
   git clone https://github.com/GMWA/scoreboards.git
   ```

### Install dependencies

```bash
flutter pub get
```

### Configure Tactical Variables

Create a .env file:

```bash
API_BASE_URL=<api base endpoint>
WEB_SOCKET_BASE_URL=<web socket endpoint>
DEBUG_MODE=true
```

## Launch Application

```bash
flutter run
```

### Release Builds

```bash
./scripts/build_apk.sh         # Android APK
./scripts/build_appbundle.sh   # Android App Bundle (Play Store)
./scripts/build_ios.sh         # iOS (macOS + Xcode required)
```

Each script checks that a real `.env` is present before building.

## Join the Sentinels

Are you at the stadium in Douala, Yaoundé, or Garoua? We need you. Scoreboards is only as powerful as the intelligence we receive. Check our [CONTRIBUTING.md](./CONTRIBUTING.md) to help us map the future of Camerounian football data.
