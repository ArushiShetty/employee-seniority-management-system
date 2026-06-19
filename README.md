# Hindustan Aeronautics Limited (HAL)
## Overhaul Division, Bangalore - HR Seniority Management System

An enterprise portal developed for the Human Resources department of the HAL Overhaul Division. This system automates the complex computation of employee seniority rankings using official legacy rules, featuring a premium custom HAL-branded dashboard.

---

## 🚀 One-Click Execution

To start the portal on any Windows machine:
1. Open the project directory.
2. Double-click the **`start_hal_system.bat`** script.
3. Once the server starts, open your browser and navigate to:
   👉 **[http://localhost:8080/HAL/](http://localhost:8080/HAL/)**

### 🔑 Credentials
* **Administrator Role (Full Read/Write/Delete Access):**
  * **Username:** `admin`
  * **Password:** `admin123`
* **HR Operator Role (Read & Registry Addition Access):**
  * **Username:** `operator`
  * **Password:** `hal123`

---

## ⚡ Key Features

1. **Dynamic Seniority Engine:** Automatically computes seniority rankings in real-time based on the multi-tiered fallback rules.
2. **Interactive Career Timeline Modals:** Clicking any employee's name displays a chronological vertical timeline of their entire career at HAL, detailing designations, department shifts, promotion order numbers, and position codes.
3. **Dynamic Column Hiding:** The table headers dynamically hide columns for grades that have no promotion data in the currently filtered list, keeping the screen compact and uncluttered.
4. **Offline Demo Fallback Mode:** If the connection to the secure Oracle database server is not available, the system automatically runs in **Demo Mode**, seeding an in-memory database with over 100 mockup profiles.
5. **HAL Custom Branded Interface:** Designed around the official HAL palette, featuring the Indian flag tricolor bar, custom SVG globe logos with jet trajectories, and subtle LCA Tejas fighter jet watermark backgrounds.
6. **One-Click CSV Export & PDF Printing:** Generate official reports instantly for board meetings or audits.

---

## 📐 Seniority Rule Hierarchy

The system calculates rankings dynamically using the following hierarchical criteria:
1. **Grade Weight:** Employees in higher grades are senior (Grade 10 is highest, Grade 1 is lowest).
2. **Current Grade Promotion Date:** The employee with the earlier promotion date to their current grade is senior.
3. **Historical Promotion Dates (Backwards):** If current promotion dates are identical, the system compares previous promotion dates grade-by-grade backwards (Grade 9, Grade 8, down to Grade 1).
4. **Date of Joining (DOJ):** If all promotion dates are identical, the employee with the earlier Date of Joining is senior.
5. **Date of Birth (DOB):** If DOJ is also identical, the older employee is senior (older by age).
6. **Employee ID:** Tie-breaker (lexicographical order).

---

## 📱 Offline Sharing & Presentations (HAL Campus)

Since secure campus zones often restrict internet, Wi-Fi, and USB storage, you can present this system to evaluators and mentors using these portable methods:

### Method A: Standalone Mock App (Offline Phone/Tablet)
1. In the project root, locate the standalone file **`index.html`**.
2. Email or message this file to your phone/tablet *before* entering secure zones.
3. Save the file to your device's files/downloads and open it.
4. **It works 100% offline.** All CSS, Javascript logic (including the 7-tier seniority calculator), and mockup data are embedded inside this single file. No server or network required!

### Method B: Print-out Dossier
* Use the **"Print Report"** button on the live portal to print high-resolution reports of the **Seniority Rankings**, **Employee Directory**, and **Career Timelines** to keep a clean physical binder.

### Method C: Optical Media (CD-R/DVD-R)
* Burn the `index.html` or the entire project folder to a CD-R. Optical drives are frequently whitelisted on secure HAL terminals where USB ports are disabled.
