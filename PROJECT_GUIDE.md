# 📚 Class Attendance Tracker - Project Report & Guide

## 1. Project Overview
**Title:** Class Attendance Tracker
**Version:** v1.2.1
**Type:** Progressive Web Application (PWA)
**Objective:** A mobile-first, offline-capable tool for teachers to track student attendance without physical paper.

---

## 2. Technology Stack & Tools Used

### Core Technologies
*   **HTML5**: Structure and semantic layout.
*   **CSS3**: Custom styling with CSS Variables (Dark Mode support) and Glassmorphism effects.
*   **Vanilla JavaScript (ES6+)**: Core logic, DOM manipulation, and state management (no heavy frameworks like React/Angular were used to keep it lightweight).

### Advanced Features (PWA)
*   **Service Workers (`sw.js`)**: Enables offline functionality and caching.
*   **Web Manifest (`manifest.json`)**: Allows the app to be installed on home screens.
*   **LocalStorage API**: Saves data on the user's device so nothing is lost.

### Tools & Utilities
*   **Git**: Version control (tracking changes).
*   **Node.js**: Used for syntax checking and running the local development server (`npx serve`).
*   **PowerShell**: Used for automation scripts (`update-pwa.ps1`).
*   **Libraries**:
    *   `jspdf`: Generating PDF reports.
    *   `xlsx`: Exporting data to Excel.

---

## 3. Development Process (Step-by-Step)

### Phase 1: Prototyping
*   Started with a **Single File Architecture** (`index.html`) containing HTML, CSS, and JS.
*   This allowed for rapid prototyping and easy sharing during the initial phase.

### Phase 2: Refactoring (Code Quality)
*   **Separation of Concerns**: The large file (5,000+ lines) was split into:
    *   `index.html` (Structure)
    *   `styles.css` (Presentation)
    *   `app.js` (Logic)
*   This improved maintainability and readability.

### Phase 3: Feature Implementation
*   Added **"About Modal"** and Version Control.
*   Implemented **Data Export** (PDF/Excel) and WhatsApp sharing.
*   Added **Conflict Resolution** for data safety.

### Phase 4: Optimization & Release
*   Cleaned up code (deduplication, whitespace).
*   Configured **Service Worker** for offline caching (v1.2.1).
*   Created usage scripts for easy updates.

---

## 4. How to Host Publicly (Free)

Since this is a static web app, you can host it for free in minutes.

### Option A: GitHub Pages (Recommended)
1.  Push your latest code to GitHub (already done).
2.  Go to your Repository **Settings** -> **Pages**.
3.  Under **Branch**, select `main` and save.
4.  GitHub will give you a public URL (e.g., `https://yourname.github.io/attendance-tracker`).

### Option B: Vercel / Netlify
1.  Create an account on [Vercel](https://vercel.com) or [Netlify](https://netlify.com).
2.  Import your GitHub repository.
3.  Click **Deploy**. It automatically detects the static files and gives you a global link (e.g., `appname.vercel.app`).

---

## 5. How to Publish to Google Play Store

Since this is a PWA, you don't rewrite it in Java/Kotlin. You wrap it using **TWA (Trusted Web Activity)**.

### Method 1: PWABuilder (Easiest)
1.  Host your app publicly (see Step 4).
2.  Go to [PWABuilder.com](https://www.pwabuilder.com).
3.  Enter your live URL.
4.  Click **"Package for Store"**.
5.  It will generate an **AAB/APK file** and a "Signing Key".
6.  Upload these files to the **Google Play Console** ($25 one-time developer fee required).

### Method 2: Bubblewrap CLI (Advanced)
1.  Install Bubblewrap: `npm install -g @bubblewrap/cli`.
2.  Run `bubblewrap init --manifest https://your-site.com/manifest.json`.
3.  Answer the questions (App name, package ID).
4.  Run `bubblewrap build`.
5.  It generates the Android build directly on your machine.

---

## 6. Future Improvements (Roadmap)
*   **Cloud Sync**: Connect to a Firebase/Supabase database for multi-device sync.
*   **Authentication**: Add teacher login (Google/Email).
*   **Dashboard**: A desktop view for principals/admins.
