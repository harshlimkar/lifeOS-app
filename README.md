# LifeOS ⚡ — Your Futuristic Self-Improvement Operating System

Welcome to **LifeOS** — a premium, gamified self-improvement dashboard designed to help you track your progress, build atomic habits, and level up your life. Powered by a high-performance **Flutter** frontend and a real-time **Supabase (PostgreSQL)** backend.

---

## 🚀 Key Features

### 1. 🔑 Whitelist Authentication & Admin Suite
- **Password Auth**: Simple, secure email + password authentication.
- **Admin Dashboard**: Accessible only by designated admin (`192421216.simats@saveetha.com`).
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

## ⚙️ Backend SQL Configuration (Supabase Setup)

To get your database working, go to your **Supabase Dashboard → SQL Editor → New Query**, paste the following script, and click **Run**:

```sql
-- ════════════════════════════════════════════════════════════════
-- 1. Whitelist Table (allowed_emails)
-- ════════════════════════════════════════════════════════════════
create table public.allowed_emails (
  id serial primary key,
  email text unique not null,
  added_by text,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS Policies
alter table public.allowed_emails enable row level security;
create policy "Anon can read allowed_emails" on public.allowed_emails for select using (true);
create policy "Admin can read allowed_emails" on public.allowed_emails for select using (auth.email() = '192421216.simats@saveetha.com');
create policy "Admin can insert allowed_emails" on public.allowed_emails for insert with check (auth.email() = '192421216.simats@saveetha.com');
create policy "Admin can delete allowed_emails" on public.allowed_emails for delete using (auth.email() = '192421216.simats@saveetha.com');

-- ════════════════════════════════════════════════════════════════
-- 2. App Versions Table (app_versions)
-- ════════════════════════════════════════════════════════════════
create table public.app_versions (
  id serial primary key,
  version_name text not null,
  version_code integer unique not null,
  release_notes text not null,
  download_url text not null,
  is_force_update boolean default false,
  created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- RLS Policies
alter table public.app_versions enable row level security;
create policy "Anyone can read app_versions" on public.app_versions for select using (true);
create policy "Admin can manage app_versions" on public.app_versions for insert with check (auth.email() = '192421216.simats@saveetha.com');
create policy "Admin can delete app_versions" on public.app_versions for delete using (auth.email() = '192421216.simats@saveetha.com');

-- ════════════════════════════════════════════════════════════════
-- 3. Storage Bucket & Policies (app-releases)
-- ════════════════════════════════════════════════════════════════
-- Make sure to create the bucket named 'app-releases' and set it to PUBLIC first.
-- Run this to allow uploading APKs automatically using your deploy script:
create policy "Allow uploads to app-releases" on storage.objects for insert with check (bucket_id = 'app-releases');
create policy "Allow updates to app-releases" on storage.objects for update using (bucket_id = 'app-releases');
create policy "Allow select from app-releases" on storage.objects for select using (bucket_id = 'app-releases');

-- Adjust bucket file size limit to 100 MB
update storage.buckets set file_size_limit = 104857600 where id = 'app-releases';
```

---

## 🚀 Native Deploy System (`deploy.ps1`)

To compile and upload a new version directly to your cloud bucket, open **PowerShell** in the project directory and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\deploy.ps1
```

Once the script finishes, it will print your public download link:
`https://broidtyxclxtefdlfwad.supabase.co/storage/v1/object/public/app-releases/app-release.apk`

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
