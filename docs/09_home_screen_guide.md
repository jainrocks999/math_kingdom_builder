# Home Screen Guide

Ye document `HomeScreen` ke liye practical reference hai. Iska goal simple hai:

- `home screen` abhi project me kis state me hai
- final UI me kaun kaun se sections hone chahiye
- `image`, `mascot`, `svg`, aur dusre assets exact kis folder se aayenge
- naye home assets kahan rakhne chahiye aur Flutter me kaise use karne chahiye

Primary implementation file:
- `lib/features/home/home_screen.dart`

Related docs:
- `docs/02_assets_and_resources.md`
- `docs/03_ui_design_system.md`
- `docs/design/screen_design_reference.md`

## 1. Current Home Screen Me Kya Hai

Current `HomeScreen` ek clean placeholder navigation screen hai.

Isme abhi:
- top welcome card hai
- ek primary button hai jo `Number Recognition` screen kholta hai
- neeche grid cards hain jo different routes open karte hain
- cards me abhi `Icons.*` use ho rahe hain, custom images nahi

Iska matlab:
- screen functional hai
- routing ready hai
- visual assets integration abhi baaki hai

## 2. Final Home Screen Ka Recommended Structure

Home screen ko child-friendly landing page ki tarah treat karna chahiye, dashboard ki tarah nahi.

Recommended layout:

### 2.1 Top Background / Hero Area

Ye section first impression banata hai.

Isme ho sakta hai:
- soft illustrated background
- welcome text
- child ka name
- short motivational line

Recommended asset:
- `assets/images/home/home_background.png`

Temporary fallback:
- `assets/images/backround.png`

Note:
- project me current file ka naam `backround.png` hai, `background.png` nahi
- agar is file ko use karna hai to same spelling hi use karni padegi

### 2.2 Mascot Area

Home screen ke center ya top-right me mascot hona chahiye.

Best source:
- `assets/animations/mascot.riv`

Use case:
- greeting state
- idle state
- talking state

Ye static PNG se better rahega kyunki project me `rive` dependency already available hai.

### 2.3 Primary CTA

Main child action:
- `Continue Learning`

Iske paas arrow icon ya visual accent ho sakta hai.

Existing SVG option:
- `assets/images/svg/ArrowRight.svg`

### 2.4 Secondary Action Cards

Ye 2 ya 3 focused options hone chahiye:
- `Kingdom`
- `Sticker Album`
- `Parents`

Current code me bahut saare route cards hain. Final child-facing home ke liye cards limited rakhna better hai, warna 3-5 saal ke user ke liye choice overload ho sakta hai.

### 2.5 Progress Preview

Small preview card dikh sakta hai:
- aaj ka lesson
- earned stickers
- unlocked kingdom part

Iske liye alag illustration useful rahegi.

Recommended assets:
- `assets/images/home/progress_badge.png`
- `assets/images/home/kingdom_preview.png`

## 3. Home Screen Me Images Kahan Se Aayengi

Neeche exact mapping di gayi hai.

| UI Part | Asset Type | Current Source | Final Recommended Source |
|---|---|---|---|
| Full screen/hero background | PNG | `assets/images/backround.png` | `assets/images/home/home_background.png` |
| Mascot | Rive animation | `assets/animations/mascot.riv` | same file use kar sakte hain |
| CTA arrow | SVG | `assets/images/svg/ArrowRight.svg` | same file use kar sakte hain |
| Continue card illustration | PNG/SVG | `assets/images/onboarding/first.png` ko temporary reuse kar sakte hain | `assets/images/home/continue_learning.png` |
| Kingdom preview | PNG | `assets/images/onboarding/second.png` ko temporary reuse kar sakte hain | `assets/images/home/kingdom_preview.png` |
| Sticker card art | PNG | `assets/images/onboarding/third.png` ko temporary reuse kar sakte hain | `assets/images/home/sticker_album.png` |
| Parent gate icon | PNG/SVG | abhi available nahi | `assets/images/home/parent_gate_icon.svg` |

## 4. Current Project Me Kaunse Assets Already Available Hain

Ye files abhi repo me mil rahi hain:

- `assets/animations/mascot.riv`
- `assets/fonts/Fredoka-VariableFont_wdth,wght.ttf`
- `assets/videos/splash_video.mp4`
- `assets/images/backround.png`
- `assets/images/svg/ArrowRight.svg`
- `assets/images/onboarding/first.png`
- `assets/images/onboarding/second.png`
- `assets/images/onboarding/third.png`

### 4.1 Directly Useful For Home Screen

- `assets/images/backround.png`
- `assets/animations/mascot.riv`
- `assets/images/svg/ArrowRight.svg`

Ye teen assets home screen me bina extra editing ke use kiye ja sakte hain.

### 4.2 Temporarily Reusable For Home Screen

- `assets/images/onboarding/first.png`
- `assets/images/onboarding/second.png`
- `assets/images/onboarding/third.png`

Inhe temporary illustration cards ke liye use kar sakte ho:

- `first.png` -> continue learning card
- `second.png` -> kingdom preview card
- `third.png` -> sticker album ya rewards card

Important:
- ye images originally onboarding ke liye bani hain
- agar inka aspect ratio ya style home layout se match na kare to crop ya contain fit use karna padega
- production-quality home screen ke liye dedicated `home` assets better rahenge

### 4.3 Available But Not For Home Screen UI

- `assets/videos/splash_video.mp4`
- `assets/fonts/Fredoka-VariableFont_wdth,wght.ttf`

Ye project ke available assets hain, lekin home screen visuals me direct illustration ke roop me use nahi honge.

## 5. Recommended Asset Folder For Home Screen

Home-specific files ko alag folder me rakhna best hoga:

```text
assets/images/home/
├── home_background.png
├── continue_learning.png
├── kingdom_preview.png
├── sticker_album.png
├── progress_badge.png
└── parent_gate_icon.svg
```

Is structure ka fayda:
- home assets ek jagah milenge
- future maintenance easy hogi
- onboarding aur home assets mix nahi honge

## 6. `pubspec.yaml` Se Asset Kaise Pickup Hoga

Current `pubspec.yaml` me ye already declared hai:

```yaml
flutter:
  assets:
    - assets/animations/
    - assets/audio/
    - assets/images/
    - assets/images/onboarding/
    - assets/images/svg/
    - assets/videos/
```

Important point:
- `assets/images/` already include hai
- isliye agar aap `assets/images/home/` ke andar files rakhoge, Flutter unhe detect kar lega
- alag se `assets/images/home/` add karna mandatory nahi hai

Phir bhi clarity ke liye optionally add kar sakte ho:

```yaml
- assets/images/home/
```

## 7. Flutter Code Me Ye Assets Kaise Use Honge

### PNG image

```dart
Image.asset(
  'assets/images/home/home_background.png',
  fit: BoxFit.cover,
)
```

### SVG image

```dart
SvgPicture.asset(
  'assets/images/svg/ArrowRight.svg',
)
```

### Rive mascot

```dart
RiveAnimation.asset(
  'assets/animations/mascot.riv',
  fit: BoxFit.contain,
)
```

### Temporary onboarding image as home card art

```dart
Image.asset(
  'assets/images/onboarding/first.png',
  fit: BoxFit.contain,
)
```

## 8. Home Screen Ke Liye Practical Implementation Suggestion

`lib/features/home/home_screen.dart` ko future me roughly is structure me convert kiya ja sakta hai:

1. background image
2. greeting text
3. mascot animation
4. primary `Continue Learning` button
5. do ya teen large cards:
   - Kingdom
   - Sticker Album
   - Parent Area
6. optional progress strip

Current grid me saare routes dikhane ke bajay:
- child-facing screen par limited cards rakho
- baaki routes dev/testing ke liye alag debug menu me rakh sakte ho

## 9. Agar Designer Ya Asset Creator Ko Brief Dena Ho

Unhe ye requirements do:

- style cute aur preschool-friendly ho
- warm cream background palette use ho
- colors `AppColors` ke around match hon
- illustrations overly detailed na hon
- buttons aur cards large hon
- mascot owl friendly aur expressive ho
- export format:
  - backgrounds: PNG
  - icons/simple shapes: SVG
  - mascot animation: Rive

## 10. Missing Assets Checklist

Ye home screen ko polish karne ke liye abhi create/source karne padenge:

- `assets/images/home/home_background.png`
- `assets/images/home/continue_learning.png`
- `assets/images/home/kingdom_preview.png`
- `assets/images/home/sticker_album.png`
- `assets/images/home/progress_badge.png`
- `assets/images/home/parent_gate_icon.svg`

Note:
- `continue_learning.png`, `kingdom_preview.png`, aur `sticker_album.png` ke liye onboarding images temporary fallback ke roop me use ho sakti hain
- `progress_badge.png` aur `parent_gate_icon.svg` ka abhi koi direct fallback available nahi hai

## 11. Final Recommendation

Agar abhi immediately home screen ko visuals ke saath improve karna ho to best starting combination ye hai:

- background: `assets/images/backround.png`
- mascot: `assets/animations/mascot.riv`
- CTA icon: `assets/images/svg/ArrowRight.svg`
- continue card art: `assets/images/onboarding/first.png`
- kingdom card art: `assets/images/onboarding/second.png`
- sticker/reward card art: `assets/images/onboarding/third.png`

Abhi ke current assets ke basis par home screen ka workable visual version bina naye files ke ban sakta hai. Bas dedicated `parent gate` icon aur `progress badge` assets abhi missing hain.

Uske baad dedicated home assets `assets/images/home/` me add karo.

Ye approach safe bhi hai aur incremental bhi:
- existing files ka use ho jayega
- future structure clean rahega
- implementation aur asset management dono simple rahenge
