# HAL HR Seniority System - Detailed Requirements

This document outlines the detailed requirements for the HAL HR Seniority System, capturing Hindustan Aeronautics Limited (HAL) organizational structure, seniority calculation rules, and data grid layout requirements.

---

## 1. HAL Organizational Structure

To support all of HAL's operations across India, the system incorporates the following complexes, divisions, and offices:

### Complexes & Divisions

1. **Bangalore Complex (BC)**
   - Aircraft Division, Bengaluru
   - Engine Division, Bengaluru
   - Overhaul Division, Bengaluru
   - Foundry & Forge Division, Bengaluru
   - Industrial & Marine Gas Turbine (IMGT) Division
   - Aerospace Division, Bengaluru
   - Facilities Department, Bengaluru
   - Airport Services Centre, Bengaluru

2. **Helicopter Complex (HC)**
   - Helicopter Division, Bengaluru
   - Helicopter Factory, Tumakuru
   - Barrackpore Division, West Bengal

3. **MiG Complex (MC)**
   - Aircraft Division, Nasik (Ozar, Maharashtra)
   - Engine Division, Koraput (Sunabeda, Odisha)

4. **Accessories Complex (AC)**
   - Transport Aircraft Division, Kanpur (Uttar Pradesh)
   - Accessories Division, Lucknow (Uttar Pradesh)
   - Avionics Division, Hyderabad (Telangana)
   - Avionics Division, Korwa (Uttar Pradesh)

5. **Design Complex (R&D Centres)**
   - Aircraft Research & Design Centre (AERDC), Bengaluru
   - Mission & Combat System Research & Design Centre (MCMRDC), Bengaluru
   - Rotary Wing Research & Design Centre (RWRDC), Bengaluru
   - Aerospace System Design Centre (ARDC)
   - Strategic Electronics Research & Development Centre (SLRDC), Hyderabad
   - Koraput Engine Design Centre (KEDC)
   - Lucknow Accessories Design Centre (LADC)

---

## 2. Disciplines (Departments)

The system supports the full spectrum of HAL executive disciplines:

- **Technical / Engineering**:
  - Aerospace / Aeronautical Engineering
  - Mechanical Engineering
  - Electrical Engineering
  - Electronics & Communication / Avionics
  - Computer Science / Information Technology
  - Production / Manufacturing / Industrial Engineering
  - Metallurgy / Materials Science
  - Civil Engineering
  - Quality Assurance / Quality Control
  - Flight Operations (Test Pilots, Flight Test Engineers)
- **Non-Technical / Services**:
  - Human Resources (HR) / Personnel & Administration
  - Finance & Accounts (F&A)
  - Materials Management / Purchase / Logistics
  - Marketing & Business Development
  - Commercial & Contracts
  - Legal & Corporate Affairs
  - Security & Fire Services
  - Medical / Health Services
  - Public Relations (PR)

---

## 3. Grades & Designation Hierarchy

The application defines 10 executive grades using Roman numerals (I to X) with corresponding designations:

| Grade | Roman Numeral | Designation |
|:---:|:---:|---|
| Grade 1 | **I** | Assistant Engineer / Assistant Officer |
| Grade 2 | **II** | Engineer / Officer |
| Grade 3 | **III** | Deputy Manager |
| Grade 4 | **IV** | Manager |
| Grade 5 | **V** | Senior Manager |
| Grade 6 | **VI** | Chief Manager |
| Grade 7 | **VII** | Deputy General Manager (DGM) |
| Grade 8 | **VIII** | Additional General Manager (AGM) |
| Grade 9 | **IX** | General Manager (GM) |
| Grade 10 | **X** | Executive Director (ED) |

---

## 4. Seniority Grid Layout (21 Logical Columns)

The data table must display the following 21 logical columns. Under "Seniority in Grades", the column splits into 10 sub-columns (I to X), bringing the total layout to 30 columns.

1. **Sl No.** - Dynamic serial number of the visible records.
2. **Div/Office** - Division or office handling the employee's posting.
3. **Complex** - Left empty (retained for future manual inputs by HR).
4. **PB No** - Personnel Book Number (Unique Employee ID).
5. **Name (S/Shri)** - Prefix "S/Shri" (or appropriate title) followed by employee name.
6. **Discipline** - Field of specialization (Technical, IT, HR, Finance, etc.).
7. **Present Designation** - Current role abbreviation (e.g. CM, AGM, GM, ED).
8. **Present Grade** - Present grade in Roman numerals (I to X).
9. **Gender** - Male / Female / Other.
10. **Ex DT/MT** - Appointed as Design Trainee (DT) or Management Trainee (MT).
11. **Ex-Servicemen** - Veteran indicator (Y/N).
12. **PHP** - Physically Handicapped Person indicator (Y/N).
13. **SC/ST/OBC/Gen** - Social Category.
14. **DOB** - Date of Birth (dd-MMM-yyyy format).
15. **Super Annuation** - Date of retirement. Irrespective of birth date, retirement occurs at age 60 on:
    - The last day of the *previous* month if born on the 1st of the month.
    - The last day of the *birth* month if born on any other day (2nd to 31st).
16. **Date of Joining** - Date of first entry into HAL.
17. **Date of Absorption** - Date of permanent post-trainee absorption (empty for direct entries).
18. **Date of Seniority in Present Grade** - Effective promotion/appointment date for current grade.
19. **Sen in all grades (I,II,...,X)** - 10 columns representing promotion dates for each grade (I to X).
20. **Educational Qualification** - Academic qualifications (e.g. BE, B.Tech, MBA, CA).
21. **Remarks** - Custom administrative comments.

---

## 5. Seniority Calculation & Sorting Engine

The sorted order of the table must strictly follow these rules (senior-most listed first):

1. **Present Grade** (Grade X down to I).
2. **Promotion Date back-trace**: Within a grade, compare promotion dates in the present grade (earlier is senior). If tied, compare promotion dates in the next lower grade (Grade X-1 down to I). If any date is null (not yet promoted to that grade), it is placed after the valid dates.
3. **Date of Joining (DOJ)**: Earlier date is senior.
4. **Date of Birth (DOB)**: Older employee (earlier date of birth) is senior.
5. **Tie-Breaker**: Personnel Book (PB) Number in ascending order.

---

## 6. Dynamic Excel-Like Filters & Scale (20k to 50k Records)

### Excel-like Dropdown Filters
- Each column header includes a dropdown filter listing all unique values present in that column.
- HR operators can click any dropdown to filter records (multi-select checkbox or quick search inside the dropdown).
- Multiple active filters combine cumulatively (AND logic).
- When filtering, **all 30 columns** (including the 10 grade columns) always remain visible.

### Scaling & Performance Strategy (20,000 - 50,000 Rows)
To handle up to 50k records in the browser without UI lag or freeze:
1. **In-Memory Data Processing**: Perform sorting and filtering on a clean, in-memory array representation of the dataset.
2. **Pagination**: Render only the current page (e.g. 50, 100, or 200 rows per page) in the DOM. This reduces DOM nodes from 1,500,000 (50,000 rows × 30 columns) to a highly responsive 3,000 (100 rows × 30 columns).
3. **Dynamic Pagination UI**: Include controls for Page Size, Previous/Next page, and direct page jumping.
4. **Debounced Filtering**: Apply filters after a minor delay (100–250ms) to ensure smooth input response.
