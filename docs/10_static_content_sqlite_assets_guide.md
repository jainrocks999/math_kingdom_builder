# Static Content, SQLite, and Asset Images Guide

This guide is for the current `math_kingdom_builder` app, where a lot of home screen content is still hardcoded in UI files like [lib/features/home/home_screen.dart](/Users/forebear/Desktop/Flutter/math_kingdom_builder/lib/features/home/home_screen.dart:1).

The goal is simple:

- make the app feel more real and content-driven
- reduce hardcoded home data inside widgets
- use asset images in a clean, scalable way
- use SQLite only where it actually helps

---

## 1. Current Situation in This Project

Right now the project already uses:

- `hive` for local structured app data
- `shared_preferences` for tiny key-value state
- `assets/images/...` for local images

Examples from the current codebase:

- Home cards and quests are hardcoded in [lib/features/home/home_screen.dart](/Users/forebear/Desktop/Flutter/math_kingdom_builder/lib/features/home/home_screen.dart:39)
- Child profiles are stored with Hive in [lib/core/services/child_profile_service.dart](/Users/forebear/Desktop/Flutter/math_kingdom_builder/lib/core/services/child_profile_service.dart:1)
- Reward progress is stored in `SharedPreferences` in [lib/core/services/reward_progress_service.dart](/Users/forebear/Desktop/Flutter/math_kingdom_builder/lib/core/services/reward_progress_service.dart:1)

So the project is **not empty on local storage**. It already has a working offline base.

---

## 2. Best Recommendation for This App

For this app, the most proper setup is a **hybrid approach**:

- keep UI-only constants in Dart
- move home content and lesson catalog to local JSON assets
- keep user progress/profile/kingdom state in Hive
- add SQLite only if you need filtering, joins, search, ordering, or large structured content

That means:

### Use Dart constants for

- colors
- typography
- route names
- very small UI config

### Use asset JSON for

- home featured cards
- quest list
- lesson metadata
- sticker catalog
- onboarding text/content

### Use Hive for

- child profiles
- unlocked progress
- kingdom state
- session data

### Use SQLite for

- large lesson bank
- question bank
- category-wise content
- filtered queries like "give me all counting lessons for level 2"
- admin-style local content tables

If your main problem is: "home static data zyada hardcoded hai", then **JSON assets first** is the better step than jumping directly to SQLite.

---

## 3. When SQLite Is Worth It

SQLite is useful if you want data like this:

| Need | SQLite fit? |
|------|-------------|
| 4 home cards only | No |
| 6-20 quest cards | Usually no |
| 500 lessons/questions | Yes |
| Search/sort/filter by level, skill, topic | Yes |
| Parent report history | Yes |
| Simple local settings | No |

### Practical rule

If data is mostly:

- fixed
- bundled with app
- small
- read-only

then use `assets/data/*.json`.

If data is:

- relational
- large
- query-heavy
- updated often in app logic

then use SQLite.

---

## 4. Best Structure for "Real Feeling" Home Content

Instead of this pattern:

```dart
static const List<_HomeActionData> _featuredActions = [ ... ];
static const List<_QuestData> _quests = [ ... ];
```

move the content into local data files.

### Recommended folder structure

```text
assets/
  data/
    home/
      featured_actions.json
      quests.json
    lessons/
      counting_lessons.json
      tracing_lessons.json
    rewards/
      sticker_catalog.json
  images/
    home/
    quests/
    rewards/
    characters/
    counting_objects/
```

And in `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/data/
    - assets/data/home/
    - assets/data/lessons/
    - assets/data/rewards/
    - assets/images/
    - assets/images/home/
    - assets/images/quests/
    - assets/images/rewards/
    - assets/images/characters/
    - assets/images/counting_objects/
```

This makes the app feel more production-like because UI becomes data-driven.

---

## 5. Recommended Home Data Format

### `assets/data/home/featured_actions.json`

```json
[
  {
    "id": "start_learning",
    "title": "Start Learning",
    "subtitle": "Number magic & playful counting",
    "route": "/start-learning",
    "iconKey": "play_arrow_rounded",
    "image": "assets/images/home/start_learning.png",
    "accentColor": "#FF6B35"
  },
  {
    "id": "kingdom_map",
    "title": "Kingdom Map",
    "subtitle": "Visit the castle & unlock places",
    "route": "/kingdom",
    "iconKey": "castle_rounded",
    "image": "assets/images/home/kingdom_map.png",
    "accentColor": "#CDB4FF"
  }
]
```

### `assets/data/home/quests.json`

```json
[
  {
    "id": "counting",
    "label": "Counting",
    "route": "/count-objects",
    "description": "Count objects and numbers 1-20",
    "stars": 3,
    "image": "assets/images/quests/counting.png",
    "locked": false
  },
  {
    "id": "tracing",
    "label": "Tracing",
    "route": "/tracing",
    "description": "Trace and write numbers beautifully",
    "stars": 2,
    "image": "assets/images/quests/tracing.png",
    "locked": false
  }
]
```

Benefits:

- easier to edit content without touching UI logic
- same UI can render many cards
- image path and text stay together
- later the same data can come from SQLite or API

---

## 6. How to Use Asset Images Properly

To make image usage feel clean and real:

### Naming

Use meaningful names:

- `assets/images/home/start_learning.png`
- `assets/images/quests/counting.png`
- `assets/images/quests/tracing.png`
- `assets/images/rewards/star_badge.png`

Avoid names like:

- `img1.png`
- `final_home_new2.png`
- `background_latest.png`

### Group by feature

Do not keep everything in one folder. Group by purpose:

- `home/`
- `quests/`
- `characters/`
- `counting_objects/`
- `rewards/`

### Store the path in content data

Instead of hardcoding image paths in widget files, store them in JSON or DB:

```dart
Image.asset(item.image, fit: BoxFit.cover)
```

### Keep a fallback

If any image is missing, show a placeholder:

```dart
Image.asset(
  item.image,
  errorBuilder: (_, __, ___) => const Icon(Icons.image_outlined),
)
```

### Use consistent art style

For a kids app, "real and proper" mostly means visual consistency:

- same illustration style
- same color warmth
- same shadow depth
- same corner radius language
- same export quality

If one image is flat vector and another is realistic photo, the app starts feeling unpolished.

---

## 7. Where SQLite Should Fit in This Repo

If you decide to add SQLite, use it for content tables, not for everything.

### Good SQLite tables for this app

```sql
home_sections
quests
lessons
lesson_items
question_bank
reward_catalog
```

### Not necessary in SQLite right now

- colors
- static routes
- tiny feature toggles
- one-time onboarding flag
- a few hardcoded buttons

---

## 8. Suggested SQLite Package Setup

If you want to add SQLite later, use:

```yaml
dependencies:
  sqflite: ^2.3.3+1
  path: ^1.9.0
```

### Suggested files

```text
lib/
  data/
    local/
      app_database.dart
      tables/
        quest_table.dart
        lesson_table.dart
    models/
      home_action_model.dart
      quest_model.dart
    repositories/
      home_content_repository.dart
      lesson_repository.dart
```

### Example database responsibility

- `app_database.dart`: open DB, create tables, migrations
- repository: read/write/query content
- UI: only render models

---

## 9. Recommended Flow: JSON First, SQLite Later

This is the most practical migration plan for your current app.

### Phase 1

Move hardcoded home data out of [lib/features/home/home_screen.dart](/Users/forebear/Desktop/Flutter/math_kingdom_builder/lib/features/home/home_screen.dart:39) into JSON assets.

### Phase 2

Create models:

- `HomeActionModel`
- `QuestModel`

Load them using `rootBundle.loadString(...)`.

### Phase 3

Keep progress and profile data in existing Hive services.

### Phase 4

Only add SQLite when:

- lesson bank becomes large
- you need local querying
- parent dashboard needs proper history/report tables

This avoids unnecessary complexity.

---

## 10. Best Architecture for This Project

### Recommended now

```text
UI config            -> Dart constants
Home content         -> JSON assets
Quest content        -> JSON assets
Lesson catalog       -> JSON assets or SQLite
Profile data         -> Hive
Kingdom state        -> Hive
Tiny flags/settings  -> SharedPreferences
```

### Recommended later if app grows

```text
Bundled content      -> SQLite seeded from assets
User progress        -> Hive or SQLite
Reports/history      -> SQLite
Settings             -> SharedPreferences
```

---

## 11. What I Would Do in This App

If I were cleaning this project properly, I would do this:

1. keep `Hive` as is for profile and kingdom data
2. move home screen static lists into `assets/data/home/*.json`
3. create typed models for home cards and quests
4. organize images feature-wise under `assets/images/...`
5. use SQLite only for lesson/question catalogs if content grows

This gives you a proper, scalable setup without making the project heavy too early.

---

## 12. Final Decision

For your current app, the best answer is:

- **Do not use SQLite just for a few static home cards**
- **Use JSON assets to remove hardcoded home data**
- **Use asset image paths inside JSON/models**
- **Keep Hive for user-side saved data**
- **Add SQLite only when content becomes large and query-based**

That will feel more real, more maintainable, and more production-ready.
