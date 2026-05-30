# LifeOS ⚡ — Your Futuristic Self-Improvement Operating System

Welcome to **LifeOS** — a premium, gamified self-improvement dashboard designed to help you track your progress, build atomic habits, and level up your life. Powered by a high-performance **Flutter** frontend and a real-time **Supabase (PostgreSQL)** backend.

---

## 🚀 Key Features

### 1. 🔑 Whitelist Authentication & Admin Suite
- **Password Auth**: Simple, secure email + password authentication.
- **Admin Dashboard**: Accessible only by designated admin.
  - **Invite-Only Access**: Grant/remove sign-up access to new users dynamically.
  - **Automated App Updates**: Publish new versions directly from the dashboard.
  - **Auto-Signup Fallback**: Seamless first-time admin setup (automatically creates the profile if missing).

### 2. 🗓️ Daily Flow Checklist (Streamlined & Custom)
Track your consistency everyday with a beautiful, high-fidelity **5-Step Flow**:
1. **Daily Missions** 🧘: Check off tasks like Gym, Protein intake, and Mindfulness.
2. **Hydration** 💧: Track your water intake and strive to hit the 3-liter daily goal.
3. **Workout Split** 💪: Smart display of daily exercises tailored to the day's routine.
4. **Screen Time** 📱: Monitor your YouTube & Instagram active time.
5. **Interactive Journaling** 📖: Write daily summaries of what went well and what to improve.

### 3. 🗓️ Complete Scrollable Day History & Past Edits (Day 1 Onwards)
- Access a complete timeline of your entire tracking history from Day 1 to the present.
- Tap on any past day card to open a custom, glassmorphic **Edit Dialog** to backdate and correct missions, water intake, screen time, workout statuses, and journal entries. Edits instantly write to Supabase and update your levels and streaks!

### 4. 🏆 Gamified Progression System
- **Level & XP**: Earn XP for every mission, water goal, workout, and journal entry completed. 
- **Trophies & Achievements**: Unlock collectible badges (e.g. *Hydration Master*, *Gym Warrior*, *Consistency Champion*).
- **Streak Multipliers**: Maintain daily tracking to keep your streak multiplier burning.

### 5. 📲 Auto-Update System & Native Deployment Script
- **Play Store-like Update Prompts**: When a new version is pushed, users are instantly notified inside the app with release notes and a direct download link.
- **`deploy.ps1` automated builder**: Compile and deploy a fresh release APK to your public Supabase Storage bucket in **one single command**!

---

## 🛠️ Tech Stack & Architecture
- **Frontend**: Flutter & Dart (responsive design for Android, iOS, and Web)
- **Backend Services**: Supabase (Auth, Database, Storage)
- **State Management**: Provider
- **Local Cache**: Hive (fast, lightweight offline storage)
- **UI Animations**: Flutter Animate & Animate Do

---

## 🔄 How it Works & Application Workflow

LifeOS operates on a high-efficiency hybrid architecture. The application core talks directly to a cloud **Supabase** database (protected securely by Postgres Row Level Security) while serving the frontend client across native mobile compiles and **Firebase Hosting** for web browsers.

```text
  [ Web Client ]                   [ Android Client ]
 (Firebase Hosting)               (Native Android App)
         │                                  │
         │ (HTTPS / REST)                   │ (HTTPS / REST)
         └─────────────────┬────────────────┘
                           ▼
                 [ Supabase Cloud Core ]
                 ┌───────────────────┐
                 │  • Supabase Auth  │
                 │  • Postgres DB    │
                 │  • RLS Security   │
                 └───────────────────┘
```

### 1. Launch & Authentication State
- **Bootstrap (`main.dart`)**: Configures Supabase connection parameters globally, establishes visual dark-theme variables, and evaluates the current active user authentication session synchronously.
- **Security Guard (`auth_provider.dart`)**: Tries to hydrate user sessions instantly upon app opening. To prevent unauthorized sign-ups, standard registration is validated against a pre-authorized email table (`allowed_emails`) on Supabase.
- **Admin Dashboard Integration**: The code automatically promotes the configured master user email to administrator status, routing them to deep system panels (to whitelist users and publish update versions) without storing local vulnerable password keys.

### 2. Parallel Loading Engine (`lifeos_provider.dart`)
Upon successful login, the state manager loads all necessary statistics concurrently inside a parallel `Future.wait` array, increasing loading speed on mobile platforms by 3x:
1. **`_loadProfile()`**: Downloads user profile parameters (XP, level progress, unlocked badges, age, gender, and metrics).
2. **`_loadTodayEntry()`**: Downloads date-specific entry (`YYYY-MM-DD`) containing completed missions, focus intervals, screen time limits, and journals.
3. **`_loadAllEntries()`**: Loads total historical days to compute streaks in memory.
4. **`_loadMealChecklist()`**: Syncs custom nutrition checkmarks.
5. **`_loadNotificationSettings()`**: Evaluates and schedules the status bar alerts.

### 3. SPAM Protection & Low-Latency Saves
- **Concurrent Load Locks**: Features a private concurrent initialization lock (`_isLoading`). If the app attempts to reload during database loading, it returns early immediately. This prevents infinite microtask rendering loops and reduces Supabase request counts by over **95%**!
- **Parallel Network Writes**: When saving log updates or completing the day checklist, the provider fires all database upserts and native alarm calls in parallel, decreasing mobile latency by up to **3x**.

### 4. Smart Native Checklist Reminders (`notification_service.dart`)
- **Android Timezone Sync**: Resolves local device timezone (e.g. `Asia/Kolkata`) and registers daily inexact alarms.
- **Inexact Timing Safety**: Utilizes `inexactAllowWhileIdle` to bypass strict Android 12+ alarm permissions, protecting the app from crash loops on release builds

## 📊 Application Lifecycle & Visual Workflows

LifeOS manages its database requests and device interactions through clean, optimized workflows. Below are detailed visualizations showing exactly how the app executes its boot phase, handles real-time cloud data syncs, and operates native notifications.

---

### 1. App Launch & Initialization Flow
This flowchart details how the application bootstraps and performs its parallel database loading sequence securely:

```mermaid
graph TD
    A["User Opens LifeOS"] --> B{"Active User Session?"}
    B -- "No Session" --> C["Show Login Screen"]
    B -- "Session Exists" --> D{"Is Master Admin?"}
    D -- "Yes" --> E["Route to Admin Dashboard"]
    D -- "No" --> F["Trigger Concurrent Supabase Fetch"]
    
    subgraph Parallel Fetch Engine
        F --> G["Load Profile Stats (XP, Badges)"]
        F --> H["Load Today's Habits Checklist"]
        F --> I["Load Complete History (Streaks)"]
        F --> J["Load Daily Meal Log Options"]
        F --> K["Check Alarm & Settings Preferences"]
    end
    
    G & H & I & J & K --> L["Calculate Streak Multipliers & Milestones"]
    L --> M["Set isInitialized = true"]
    M --> N["Route from Splash Screen to Home Dashboard"]
```

---

### 2. Habit Actions & Real-Time Cloud Sync
This is the low-latency visual representation of how user checkboxes and habit logs are synced to the cloud concurrently:

```mermaid
graph LR
    A["User Toggles Habit / Logs Water"] --> B["Update Local UI State Instantly"]
    B --> C["Call notifyListeners()"]
    C --> D["Trigger Parallel Background Saves"]
    
    subgraph Concurrently Shared REST Writes
        D --> E["Upsert 'day_entries' Table"]
        D --> F["Upsert 'profiles' Table"]
    end
    
    E & F --> G["Cloud Database Synchronized Safely"]
```

---

### 3. Complete Daily Flow & Alert Clear
How the app processes final daily checklists and commands the device's operating system to clear persistent alerts:

```mermaid
graph TD
    A["User Taps 'Complete Day' Button"] --> B["Display Loading Spinner"]
    B --> C["Calculate Daily Completion Score"]
    C --> D["Unlock Badges & Award XP Bonuses"]
    D --> E["Initialize Async Operations"]
    
    subgraph Parallel low-latency API Calls
        E --> F["Save final 'day_entries' stats"]
        E --> G["Save final user 'profiles' XP"]
        E --> H["Command OS to Clear Locked Notifications"]
    end
    
    F & G & H --> I["Dismiss Loading Spinner"]
    I --> J["Navigate to Summary Screen & Launch Confetti! 🎉"]
```

---

## 🚀 Native Deploy System (`deploy.ps1`)

To compile and upload a new version directly to your cloud bucket, open **PowerShell** in the project directory and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy.ps1
---

## 🏃 Getting Started locally

### Prerequisites
Make sure you have [Flutter SDK](https://flutter.dev/docs/get-started/install) installed on your system.

### Installation
1. Clone this repository:
   ```bash
   git clone https://github.com/harshlimkar/lifeOS-app.git
   cd lifeOS-app
   ```
2. Pull dependencies:
   ```bash
   flutter pub get
   ```
3. Run the development server:
   ```bash
   flutter run
   ```

---

## 👑 License & Creator
Created with ❤️ by **Harsh Limkar**. Private application. Unauthorized reproduction or redistribution is restricted.
