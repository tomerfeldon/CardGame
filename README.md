# CardGame 🃏

משחק קלפים ל-iOS (UIKit) בן שלושה מסכים. צד השחקן (מזרח/מערב) נקבע אוטומטית לפי
מיקום ה-GPS, ולאחר מכן מתנהל משחקון אוטומטי של 10 סבבים שבו הקלף החזק יותר זוכה בנקודה.

נכתב ב-Swift עם Storyboard (Interface Builder), Core Location, ובדיקות יחידה ב-Swift Testing.

---

## 📱 המסכים

| מסך | תיאור |
|------|--------|
| **תפריט (Menu)** | בפעם הראשונה מוצג כפתור **Insert name**; אחרי שמזינים שם הוא נשמר ומוצג **"Hi \<name\>"**. בכל פתיחה נדגם המיקום, מסומן הצד (West/East), וכפתור **START** מופיע רק כשיש גם שם וגם מיקום. |
| **משחק (Game)** | מתחיל אוטומטית, ללא כפתורים. כל 5 שניות הקלפים מתהפכים: הפנים מוצגים ~3 שניות, הקלף החזק זוכה בנקודה, ואז היפוך חזרה לגב. הניקוד והטיימר מתעדכנים בכל סבב. אחרי 10 סבבים → מסך הסיכום. |
| **סיכום (Summary)** | מציג **Winner** ואת הניקוד, עם כפתור **BACK TO MENU** שמחזיר לתפריט הראשי. |

---

## 🎮 חוקי המשחק

- **בחירת צד**: משווים את ה-longitude של השחקן לקו הייחוס `34.817549168324334`.
  ממזרח לקו → צד מזרח (East), אחרת → צד מערב (West).
- **חוזק הקלף** = ערך הקלף: `2..10`, `J=11`, `Q=12`, `K=13`, `A=14` (אס גבוה).
- בכל סבב מוגרלים שני קלפים. הקלף החזק יותר מזכה את בעליו בנקודה.
- **שוויון** בין הקלפים → אף אחד לא מקבל נקודה (מתעלמים).
- **תיקו בסוף המשחק** → הבית (PC) מנצח.
- המשחק לא יכול לפעול ללא **מיקום וגם שם**.

---

## 🏗 ארכיטקטורה

```
CardGame/
├── Models/
│   ├── Card.swift          // קלף בודד: חליפה, ערך, חוזק, שם asset
│   ├── Deck.swift          // מאגר הקלפים + הגרלת שני קלפים
│   └── Side.swift          // enum: west / east
├── Game/
│   └── GameEngine.swift    // לוגיקת המשחק הטהורה (ללא UIKit) — נבדקת ב-unit tests
├── Location/
│   └── LocationService.swift // עטיפת CLLocationManager + בחירת צד לפי longitude
├── ViewControllers/
│   ├── MenuViewController.swift
│   ├── GameViewController.swift
│   └── SummaryViewController.swift
├── Base.lproj/Main.storyboard  // ה-UI: Navigation Controller + 3 סצנות
└── Assets.xcassets/            // 26 קלפים (clubs + diamonds, A–K) + 2 גבי קלף
```

**הפרדת אחריות:** לוגיקת המשחק (`GameEngine`) ובחירת הצד (`LocationService.side(forLongitude:)`)
מופרדות מ-UIKit כדי שיהיו ניתנות לבדיקה באופן עצמאי.

**ניווט:** `UINavigationController` (סרגל מוסתר) → Menu → (segue `toGame`) → Game →
(segue `toSummary`) → Summary → `popToRootViewController` חזרה לתפריט.

---

## 🃏 נכסי הקלפים

- מאגר של **26 קלפים**: תלתן (clubs) A–K ויהלום (diamonds) A–K — שתי החליפות השלמות.
- שני גבי קלף: אדום (`card_back_red`) ושחור (`card_back_black`).
- שמות ה-imagesets בפורמט `<suit>_<rank>` (למשל `clubs_13`, `diamonds_14`),
  כך ש-`Card.assetName` ממפה ישירות לתמונה.

---

## ▶️ בנייה והרצה

**דרישות:** Xcode 16.2+, iOS 18.2+ (סימולטור או מכשיר), אוריינטציית **Landscape**.

```bash
git clone https://github.com/tomerfeldon/CardGame
cd CardGame
git checkout claude/compassionate-hawking-6PDD2
open CardGame.xcodeproj
```

ב-Xcode: בחר סימולטור ולחץ **Run** (`Cmd+R`).

### דימוי מיקום בסימולטור
המשחק זקוק למיקום. בסימולטור:
**Features → Location → Custom Location…**
- `longitude` גדול מ-`34.8175` → צד **מזרח (East)**
- `longitude` קטן מ-`34.8175` → צד **מערב (West)**

> אם לא נבחר מיקום, תוצג הודעה שהמשחק דורש מיקום.

---

## ✅ בדיקות

בדיקות יחידה ל-`GameEngine` ולבחירת הצד נמצאות ב-`CardGameTests/CardGameTests.swift`
(מבוססות Swift Testing). להרצה: **`Cmd+U`** ב-Xcode.

מכוסה: השוואת חוזק וניקוד, דילוג בשוויון, סיום אחרי 10 סבבים, תיקו → PC, ובחירת צד מ-longitude.

---

## 🔐 הרשאות

`NSLocationWhenInUseUsageDescription` מוגדר ב-`Info.plist` — נדרש לקבלת מיקום בזמן השימוש.
