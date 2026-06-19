# HAL HR Seniority Management System

A web-based seniority ranking portal built for the HR department at HAL Overhaul Division.

## 🚀 How to Run the App

1. Double-click the **`start_hal_system.bat`** file in the project folder.
2. Open your browser and go to: **`http://localhost:8080/HAL/`**

### Login Credentials
* **Admin:** Username: `admin` | Password: `admin123`
* **Operator:** Username: `operator` | Password: `hal123`

---

## 📐 Seniority Rule Hierarchy

Seniority is calculated dynamically using the following fallback order:
1. **Grade Weight** (Grade 10 is highest down to Grade 1)
2. **Current Promotion Date** (Earlier date is senior)
3. **Historical Promotion Dates** (Compared grade-by-grade backwards)
4. **Date of Joining (DOJ)** (Earlier date is senior)
5. **Date of Birth (DOB)** (Older employee is senior)
6. **Employee ID** (Tie-breaker)

---

## 📱 How to Demo Offline (Without Laptop/Wi-Fi/USB)

If you need to show the app to your mentor on their computer or a phone/tablet offline:
1. Copy the standalone **`index.html`** file in the root folder to your phone or tablet.
2. Open **`index.html`** in any web browser. 
3. It runs 100% offline with full features, styling, and mockup data without requiring a server or database.
