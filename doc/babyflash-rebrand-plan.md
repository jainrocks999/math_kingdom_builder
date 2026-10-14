# Baby Flash Cards Rebrand Plan (iOS)

**Source app:** Math Kingdom (`com.forebear.mathkingdombuilder`, Team `NX75C8SF7P`), jo already App Store par live hai
**Target:** EFlashApps / Baby Flash Cards (https://babyflashcards.com, "Eflashapp ®, LLC") ka Apple Developer account
**Approach:** App transfer nahi hoga. Same codebase ko rebrand karke client ke account ke app record par fresh binary upload hogi.

---

## 0. Pehle ye samjho: rejection ka asli risk kya hai

| Apple Guideline | Kya hai | Humare case me risk |
|---|---|---|
| **4.3(a) Spam / Duplicate** | Same app (ya bahut similar binary/UI) do alag developer accounts se live ho | **Sabse bada risk.** Math Kingdom tumhare account par live hai. Same UI, same screens, same assets ke saath doosre account se submit kiya to 4.3 rejection almost pakka hai. Repeat hone par Apple dono accounts ko flag kar sakta hai. |
| **4.1 Copycat** | Kisi doosre ke brand/app ki nakal | Kam risk, kyunki brand (Baby Flash Cards) client ka hai aur unke hi account se upload ho raha hai. |
| **5.2.1 / 5.2.2 IP** | Third-party brand/content bina permission | Client se written authorization lo (logo, naam, characters, music use karne ki permission) aur apne paas rakho. |
| **1.3 Kids Category + 5.1.4** | Kids apps me ads/tracking ke strict rules | AdMob already child-directed configured hai. Client ka apna AdMob account aur IDs lagenge. |

### Rule of thumb
Apple reviewer ko dono apps side-by-side dikhein to **pehli nazar me alag app lagni chahiye**: naam, icon, colors, mascot, theme, home layout, screenshots, sounds, aur kam se kam **1–2 unique features**. Sirf logo aur naam badalna **kaafi nahi hai**.

### Do options (client ke saath decide karo)
1. **Option A (sabse safe):** Math Kingdom ko apne account se *Remove from Sale* kar do, phir Baby Flash version submit karo. Duplicate ka sawaal hi khatam ho jata hai.
2. **Option B:** Dono apps live rakhni hain, to is document ka **poora** differentiation plan follow karo (sections 2–5). Ye zaroori hai, optional nahi.

---

## 1. Client se kya chahiye (start karne se pehle)

- [ ] Apple Developer account me tumhara **App Manager / Developer role** (App Store Connect → Users and Access). Transfer nahi, sirf access.
- [ ] Client ki **Team ID** (Membership page se).
- [ ] Kaunsa app record use karna hai, ye decide karo:
  - **(i) Unka existing app record update karna hai** (jaise "123 Numbers Flash Cards 4 Kids"): to **bundle ID exactly wahi** hona chahiye jo us app ka hai, aur version number us app ke current version se **bada** hona chahiye.
  - **(ii) Naya app record banana hai:** naya bundle ID register karna hoga (suggestion niche diya hai).
- [ ] Brand assets: high-res logo (SVG/PNG), brand colors, font (agar koi hai), mascot/characters (agar hain), jingles/music jo use kar sakte hain.
- [ ] Written permission (email bhi chalega) ki unka brand aur assets is app me use ho sakte hain.
- [ ] Client ka **AdMob account** (App ID + Banner + Interstitial unit IDs), ya ads hatane ka decision.
- [ ] Privacy policy URL (https://babyflashcards.com/privacy-policy.html), jisme is app ka naam aur AdMob ka mention update ho.
- [ ] Support URL aur email (eflashapps@gmail.com).

---

## 2. Identity changes (naam, package, bundle ID, sab)

### 2.1 App name (App Store + device)
**Final (client approval pending):**

| Where | Value |
|---|---|
| App Store name | `eFlashApps: Math Fun` (20 chars) |
| Home screen name (`CFBundleDisplayName`) | `Math Fun` |
| Subtitle | `Count, Trace, Add & Subtract` |

Agar ye naam App Store par available na ho, to ye backups try karo: `Math Flash Cards 4 Kids`, `Baby Flash Cards: Math Fun`.

> "Kingdom", "Builder", "Castle" jaise words **kahin bhi** nahi aane chahiye: na naam, na subtitle, na keywords, na app ke andar.

### 2.2 Files to change

| What | File | Current | New (example) |
|---|---|---|---|
| Dart package name | [pubspec.yaml](../pubspec.yaml) `name:` | `math_kingdom_builder` | `eflash_math_fun` |
| All Dart imports | `lib/**` (`package:math_kingdom_builder/...`) | ~sab files | find-replace to `package:eflash_math_fun/...` |
| Description | [pubspec.yaml](../pubspec.yaml) | "A new Flutter project." | "Baby Flash Cards Math for kids" |
| Version | [pubspec.yaml](../pubspec.yaml) `version:` | `1.0.4+6` | New record: `1.0.0+1`. Existing record update: unke current version se bada (jaise current `3.2` hai to `4.0.0+1`). |
| iOS Bundle ID | [ios/Runner.xcodeproj/project.pbxproj](../ios/Runner.xcodeproj/project.pbxproj) (3 Runner configs + 3 RunnerTests) | `com.forebear.mathkingdombuilder` | Client ka existing ID, ya naya `com.eflashapps.mathfun` |
| Team ID | same pbxproj, `DEVELOPMENT_TEAM` (3 jagah) | `NX75C8SF7P` | Client ki Team ID |
| Display name | [ios/Runner/Info.plist](../ios/Runner/Info.plist) `CFBundleDisplayName`, `CFBundleName` | `Math Kingdom` | `Math Fun` |
| AdMob App ID | [ios/Runner/Info.plist](../ios/Runner/Info.plist) `GADApplicationIdentifier` | `ca-app-pub-6121378252341914~...` | Client ka AdMob App ID |
| Ad unit IDs | [lib/ads/ad_units_ids.dart](../lib/ads/ad_units_ids.dart) | Forebear ke IDs | Client ke IDs (test IDs as-is rehne do) |
| Method channel | [lib/core/services/device_orientation_service.dart:15](../lib/core/services/device_orientation_service.dart#L15) + [ios/Runner/AppDelegate.swift](../ios/Runner/AppDelegate.swift) | `com.forebear.mathkingdombuilder/device` | `com.eflashapps.mathfun/device` (dono jagah same) |
| Hive box names | [lib/main.dart:28-33](../lib/main.dart#L28-L33) | `profiles`, `kingdoms`, `progress` | `bf_profiles`, `bf_cards`, `bf_progress` (aur `KingdomState` model rename, section 4.14 dekho) |
| App icon | [pubspec.yaml](../pubspec.yaml) `flutter_launcher_icons` + `assets/logo/` | `math_kingdom_app_logo_ios.png` | Naya 1024×1024 icon, Baby Flash Cards style ka, bina transparency ke. Phir `dart run flutter_launcher_icons`. |
| Launch screen | `ios/Runner/Assets.xcassets/LaunchImage.imageset` + `Base.lproj/LaunchScreen.storyboard` | Math Kingdom | Baby Flash Cards logo on brand color |
| Translations | [assets/translations/en.json](../assets/translations/en.json), `hi.json` | "Math Kingdom" ~15+ jagah, "kingdom/castle/bear" bahut jagah | Poora copy rewrite (section 4) |
| Privacy policy | [docs/privacy_policy.md](../docs/privacy_policy.md) | Math Kingdom / Forebear Productions | eFlashApps: Math Fun / Eflashapp, LLC (client ki site par host hoga) |
| Docs / README | `README.md`, `doc/` | Math Kingdom | Update karo, ya build se pehle repo se hata do. Ye binary me nahi jaate, isliye low priority. |

**Android (optional, sirf agar baad me Play Store bhi chahiye):** `android/app/build.gradle.kts` (`namespace`, `applicationId`), `MainActivity.kt` ka package aur folder path, `res/values/strings.xml` `app_name`, aur `AndroidManifest.xml` me AdMob ID.

### 2.3 Quick find-check (rebrand ke baad ye command khali output de)
```bash
grep -rniE "kingdom|forebear|castle|mathkingdom" lib ios/Runner assets/translations assets/data pubspec.yaml
```

### 2.4 Build hygiene
- `flutter clean`, purane `build/` aur `ios/Pods` delete karo, phir `pod install`.
- Purana **provisioning profile / certificate use mat karo**. Client ke team ke certs se sign karo (Xcode → Automatically manage signing → client ki team).
- `ios/Runner/PrivacyInfo.xcprivacy` (privacy manifest) add karo: AdMob, shared_preferences aur path_provider ke required-reason APIs declare karne ke liye.
- Info.plist me Google ki list wale `SKAdNetworkItems` add karo (AdMob ke liye).

---

## 3. Visual identity (global design system)

Ye sabse important section hai **4.3 se bachne ke liye**.

| Element | Abhi (Math Kingdom) | Naya (Baby Flash Cards) |
|---|---|---|
| Theme concept | Candy castle / kingdom building | **Flash cards**: cards flip hote hain, card deck collect hote hain, card table/playroom background |
| Primary color | Orange `#FF6B35` | Client ke logo se (jaise blue/green family) |
| Secondary | Teal `#4ECDC4` | Brand se derived |
| Background | Cream `#FFF9F0` + `backround.png` sky/castle | Naya illustrated background (playroom / soft pattern) |
| Font | Fredoka | Alag rounded font, jaise **Baloo 2**, **Nunito** ya **Quicksand** |
| Card style | 3D pressed bottom shadow | **Flash-card style**: white card, colored border, slight tilt, flip animation |
| Mascot | Bear (`idle`, `waw`, `clapping`) | Client ka character, ya naya mascot (jaise owl / bunny / smiling flash card). **Bear poori tarah hatao.** |
| Celebration | Bear clapping + confetti | Naya mascot + card-shower / stars animation |
| Music & SFX | `home_music`, `start_counting`, `celebration`, `correct`, `wrong_soft` | Naye tracks (client ke YouTube/music library me nursery-style jingles hain, unhe use karo) |
| Splash video | `splash_video.mp4` | Naya Baby Flash Cards logo animation |
| Icons/emoji | 🏰 castle, 🗺️ map | 🃏 cards, 🎈 etc. |

**Files:** [lib/core/constants/app_colors.dart](../lib/core/constants/app_colors.dart) (saare tokens + "Kingdom zone colors" ka rename), [lib/core/constants/app_typography.dart](../lib/core/constants/app_typography.dart), `pubspec.yaml` fonts section, `assets/images/**`, `assets/audio/**`, `assets/videos/`, `assets/animations/mascot.riv`.

**Shared widgets jo rename aur redesign karne hain:**
- `lib/shared/widgets/celebration_bear.dart` → `celebration_mascot.dart`
- `lib/shared/widgets/mascot_widget.dart` → naya character
- `lib/shared/widgets/bouncing_game_button.dart` → flash-card style button
- `lib/shared/widgets/kid_loading_view.dart`, `kid_oops_view.dart` → naya mascot + copy
- `lib/shared/widgets/celebration_overlay.dart`, `activity_completion_card.dart` → card-flip reveal
- `lib/shared/widgets/adaptive_hub_scaffold.dart` → naya background aur header

---

## 4. Screen-by-screen plan

Har screen ke liye: **Naam/Copy**, **UI**, **Assets**, aur **Functional difference** (4.3 se bachne ke liye).

### 4.1 Splash (`/`, [lib/splash_screen.dart](../lib/splash_screen.dart), `lib/data/models/splash_screen.dart`)
- **Copy:** "Math Kingdom" → "eFlashApps: Math Fun". Tagline: "Learn numbers with flash cards!"
- **UI:** Castle/kingdom video hatao. Naya: Baby Flash Cards logo, aur ek card deck jo shuffle hokar logo reveal kare.
- **Assets:** naya `splash_video.mp4` (ya Lottie/Rive animation), naya logo.
- **Diff:** Splash ki duration aur transition bhi alag rakho.

### 4.2 Onboarding (`/onboarding`, [lib/onboarding_screen.dart](../lib/onboarding_screen.dart))
- **Copy:** Abhi teen slides hain: "Build Your Dream Kingdom", "Math Made Fun", "Collect Bright Rewards". Nayi slides:
  1. "Flip, Listen & Learn" (flash cards)
  2. "Count, Trace & Play"
  3. "Collect Your Card Deck"
- **UI:** Teen ki jagah 2 ya 4 slides rakho, aur layout alag (jaise card-swipe carousel). "Enter the home castle" jaise CTA hatao.
- **Assets:** `assets/images/onboarding/first|second|third.png` ki jagah naye illustrations.
- **Diff:** Onboarding me **child name + age picker** ka step add karo (profile service already hai, `ChildProfileService`). Isse flow alag dikhega.

### 4.3 Home (`/home`, [lib/features/home/home_screen.dart](../lib/features/home/home_screen.dart), `assets/data/home/featured_actions.json`, `quests.json`)
- **Copy:** "Math Kingdom ✨ / grow your candy castle" → "Hi {name}! Pick a card deck 🃏". "Choose a Quest 🗺️" → "Today's Cards".
- **Featured actions** (`featured_actions.json`):
  | Old | New |
  |---|---|
  | Start Learning 🎮 | Number Flash Cards 🃏 |
  | Kingdom Map 🏰 | My Card Collection / Learning Path |
  | Sticker Album ⭐ | Reward Cards ⭐ |
  | Parent Zone 🔐 | Grown-ups 👨‍👩‍👧 |
- **UI:** 2×2 grid ki jagah **horizontal swipeable deck**, ya 3+1 layout. Daily challenge banner ko "Card of the Day" bana do (ek bada flip card).
- **Assets:** JSON me `imagePath` bear/onboarding images ki jagah naye images; `colorHex` values brand palette se.
- **Diff:** "Card of the Day" feature: ek random number card jo flip karne par number + object + voice bataye.

### 4.4 Start Learning hub (`/start-learning`, `lib/features/StartLearning/*`)
- **Copy:** "Start Learning! All math adventures in one place" → "Number Decks". "Wake up the number bear" → "Flip the cards and hear the numbers".
- **UI:** List/grid of activity cards ko **deck stack** look do (har activity ek card-deck jiska top card dikhe).
- **Diff:** Activities ko 3 levels me group karo: **Baby (1–5)**, **Toddler (1–10)**, **Preschool (1–20 + operations)**. Ye age-based grouping Math Kingdom me nahi hai.

### 4.5 Learn Numbers (`/learn-numbers`, `lib/features/learn_numbers/learn_numbers_screen.dart`)
- **Ye app ka hero feature banega**, kyunki Baby Flash Cards ka signature format flash cards hai.
- **UI:** Swipe-and-listen ko **real flash card** bana do: front par number, tap karke flip, back par object picture + word ("3, three apples"). Card ka design client ke "123 Numbers Flash Cards" style jaisa.
- **Diff:** Auto-play mode (cards khud flip hon + voice), aur ek "Hindi/Spanish voice" toggle. Client ki apps 11 languages me hain, aur yahan `easy_localization` + TTS already hai.

### 4.6 Trace Numbers (`/tracing`, `lib/features/number_tracing/trace_numbers_screen.dart`)
- **Copy:** Kingdom/bear wale lines hatao.
- **UI:** Tracing canvas ko flash card ke andar dikhao (card ke border ke andar); stroke color aur guide-dots brand colors me.
- **Diff:** Trace complete hone par card flip ho aur picture reveal ho (jaise 2 trace kiya to 2 ducks).

### 4.7 Count Objects (`/count-objects`, `lib/features/count_objects/*`, `counting_themes.dart`)
- **Assets:** `assets/images/contingobjects/` (`candy`, `apple`, `car`, `ballun`, `start`) **replace karo**. Client ke flash card illustrations (animals, fruits, vehicles) use karo. Unke paas ye library already hogi, aur isse visual difference sabse zyada aayega.
- **UI:** Counting themes rename karo; answer buttons flash-card style.
- **Diff:** Har object tap karne par voice count kare ("one… two… three…").

### 4.8 Find Correct Number (`/find-number`, `lib/features/number_recognition/number_recognition_screen.dart`)
- **Copy:** "pick the magical number" → "Find the card that says…". Is file me "kingdom" ka reference hai, use hatao.
- **UI:** Options ko face-down cards bana do; tap karne par flip ho (memory-game feel).

### 4.9 Match Numbers (`/matching`, `lib/features/matching/match_numbers_screen.dart`)
- **UI:** Line-drawing/drag matching ko **"Snap" card game** style me karo (number card ko picture card par drop karo).
- **Diff:** Timer-free "pair" mode add karo.

### 4.10 Mini Quiz (`/mini-quiz`, `lib/features/mini_quiz/mini_quiz_screen.dart`)
- **Copy:** "brain challenge / streak glowing" → "Flash Quiz".
- **UI:** Question card center me, answers 2×2 cards. Progress dots ki jagah stacked cards jo kam hote jayein.

### 4.11 Math Operations hub (`/math-operations`, `lib/features/math_operations/math_operations_screen.dart`, `operation_preview_screen.dart`, `math_operation_theme.dart`)
- **Copy:** "Math Operations / Math Ops / Math Bridge" → "Plus & Minus Cards" (aur "Times & Share Cards").
- **UI:** `math_operation_theme.dart` ke colors aur icons badlo; preview screen ko card-flip tutorial bana do.

### 4.12 Addition / Subtraction / Multiplication / Division (`addition_screen.dart`, `subtraction_screen.dart`, `multiplication_screen.dart`, `division_screen.dart`, `math_operation_widgets.dart`)
- **Copy:** "fill the bowl" jaise metaphors badlo (jaise "put cards in the basket").
- **UI:** Bowl/group visuals ko naye objects aur card layout se replace karo.
- **Diff (recommended):** Baby Flash Cards ka audience toddler/preschool hai, isliye **Multiplication & Division ko default "Preschool+" level ke peeche lock** karo, ya v1 me hata do. Isse feature-set Math Kingdom se alag ho jayega.

### 4.13 Sequencing (`/sequencing`) & Patterns (`/patterns`)
- **Copy:** "missing number trail" → "Put the cards in order". "Spot the repeating shape pattern" → "What card comes next?"
- **UI:** Shapes ko card faces me dikhao; drag-to-slot cards.

### 4.14 Kingdom Map (`/kingdom`, `lib/features/kingdom/**`, 8 files + `lib/data/models/kingdom_state.dart`)
- **Ye screen Math Kingdom ki identity hai, isse POORA replace karna hai.** Isko reskin karna kaafi nahi hai.
- **Naya concept: "My Card Collection" / "Learning Path"**
  - Castle zones (garden, meadow, castle, bridge, pathway, stairs) ki jagah **card albums** honge (Animals deck, Fruits deck, Vehicles deck…), jo stars se unlock hon.
  - `kingdom_map_canvas.dart` (map drawing) ki jagah grid of decks, ya ek simple path jisme card stops hon.
- **Code rename:** `kingdom_screen.dart` → `collection_screen.dart`, `KingdomService` → `CollectionService`, `KingdomState` → `CollectionState` (Hive adapter typeId change, aur box `kingdoms` → `bf_collection`), `kingdom_zone_data.dart` → `deck_data.dart`. Route `/kingdom` → `/collection` ([lib/core/router/app_router.dart](../lib/core/router/app_router.dart)).
- **Copy:** `en.json` ka poora `kingdom` block ("My Kingdom", "Loading your kingdom…", "kingdom clouds", etc.) rewrite karo.
- **Colors:** `AppColors` me `gardenGreen`, `castleGray`, `bridgeBlue`… rename karke deck colors bana do.

### 4.15 Rewards / Stickers (`/stickers`, `lib/features/rewards/rewards_screen.dart`, `lib/core/services/reward_progress_service.dart`)
- **Copy:** "Golden Kingdom Cup", "First kingdom trophy", "{progress}/{goal} kingdom rewards" → "Golden Card", "First Deck Complete", "{progress}/{goal} reward cards".
- **UI:** Sticker album ko **trading-card binder** jaisa banao (har reward ek shiny card).
- **Assets:** Naye reward card images.

### 4.16 Parent Dashboard (`/parent-dashboard`, `lib/features/parent_dashboard/parent_dashboard_screen.dart`)
- **Copy:** "Parent Zone" → "Grown-ups Corner". Baaki text neutral hai, theek hai.
- **UI:** Brand colors (`parentAccent` etc.). PIN gate same rakh sakte ho (ye standard Kids-category parental gate hai).
- **Add:** "More apps from Baby Flash Cards" section, jo parental gate ke **peeche** ho (Kids category me external links sirf parental gate ke peeche allowed hain). Isme client ki doosri apps aur website link.
- **Add:** "About" section: © Eflashapp, LLC, privacy policy link, support email.

### 4.17 Settings (`/settings`, `lib/features/settings/settings_screen.dart`)
- **Copy:** `voice_preview_message` "Math Kingdom is ready for today's adventure" → "Math Fun is ready to play!" "Coming Next" placeholder text hata do (reviewer ko unfinished lagta hai).
- **Diff:** Language list me client ki popular languages (Spanish, Hindi, etc.) add karo, ya kam se kam ek extra language `assets/translations/` me.

### 4.18 Ads (`lib/ads/*`, `lib/shared/widgets/bottom_banner_layout.dart`)
- Client ke AdMob IDs lagao (section 2.2).
- Banner position/frequency Math Kingdom se alag rakho (jaise interstitial sirf activity complete hone par, aur max 1 per 3 activities).
- Client ki site par "Why do we have ads" page hai; uska link Grown-ups Corner me de do.

### 4.19 Global audio (`lib/core/constants/app_sounds.dart`, `lib/core/router/screen_music_observer.dart`, `lib/core/services/audio_service.dart`, `lib/core/utils/celebration_service.dart`)
- Saare sound paths naye files par point karo. In files me "kingdom" naming bhi hai, use rename karo.
- TTS praise phrases ("Math Hero", "kingdom") ko naye phrases se replace karo ("Super star!", "You flipped it!").

---

## 5. App Store Connect listing (client ke account me)

| Field | Kya karna hai |
|---|---|
| Name | Section 2.1 se |
| Subtitle | "Numbers, Counting & Tracing", Math Kingdom se alag wording |
| Category | Education, aur **Kids (Ages 5 & Under)** (client ke audience ke hisaab se) |
| Keywords | Naye. "kingdom", "castle" na ho. Apne keywords me doosre brands ke naam mat daalo. |
| Description | Fresh likho, Math Kingdom ka text copy mat karo. Flash-card concept highlight karo. |
| Screenshots | **Naye** banao (naya UI, naye frames, brand colors). Math Kingdom ke screenshot frames reuse mat karo. |
| App Preview video | Optional, naye UI se |
| Icon | Naya Baby Flash Cards style |
| Privacy Policy URL | babyflashcards.com/privacy-policy.html (is app ke naam ke saath updated) |
| Support URL | babyflashcards.com |
| Copyright | `2026 Eflashapp, LLC` |
| App Privacy (nutrition label) | AdMob ke hisaab se fill karo (Device ID / advertising data; child-directed) |
| Age rating | Questionnaire dobara bharo |
| Review notes | Saaf likho: "Educational number app by Baby Flash Cards (EFlashApps). Parental gate: [kaise kholna hai, PIN setup steps]." |

---

## 6. Recommended order of work

1. **Identity** (section 2): pubspec, bundle ID, team, display name, channels, AdMob IDs. Build chalao aur device par check karo.
2. **Design system** (section 3): colors, font, mascot, backgrounds, sounds.
3. **Kingdom Map → Card Collection** (4.14): sabse bada kaam, aur sabse zyada differentiation deta hai.
4. **Learn Numbers flash-card mode** (4.5) + **Home redesign** (4.3).
5. Baaki screens ka reskin + copy (4.6–4.19).
6. `en.json` / `hi.json` ka poora copy pass.
7. Grep check (2.3), app icon, launch screen, privacy manifest.
8. Screenshots + listing (section 5).
9. TestFlight (client ke account se), internal testing, phir submit.

---

## 7. Pre-submission checklist

- [ ] `grep -rniE "kingdom|forebear|castle|mathkingdom"` sab jagah khali hai
- [ ] Bear images aur Fredoka font poori tarah hat gaye
- [ ] Bundle ID aur Team ID client ke hain; signing client ke certificate se
- [ ] Version number sahi (existing record ho to usse bada)
- [ ] AdMob IDs client ke; release build me test IDs nahi (`kDebugMode` check already hai)
- [ ] Naya icon, launch screen aur splash
- [ ] `PrivacyInfo.xcprivacy` aur `SKAdNetworkItems` added
- [ ] Parental gate har external link, "More apps" aur ad-settings ke aage hai
- [ ] Koi "Coming soon" ya placeholder screen visible nahi (`placeholder_screen.dart` routes check karo)
- [ ] Screenshots naye UI ke hain
- [ ] Client ki written brand permission tumhare paas hai
- [ ] Option A ya B decide ho gaya (Math Kingdom remove from sale, ya full differentiation)

---

## 8. Agar fir bhi 4.3 rejection aaye

- Resolution Center me politely jawab do ki ye app Baby Flash Cards brand ke under, unke content aur flash-card format ke saath hai. Unique features list karo (flash-card mode, card collection, age levels, multi-language).
- Phir bhi reject ho to Option A (Math Kingdom remove from sale) sabse fast fix hai.
- Same binary ko baar-baar resubmit **mat** karo; har resubmission me real changes hone chahiye.
