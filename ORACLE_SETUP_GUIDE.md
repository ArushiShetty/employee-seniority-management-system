# HAL HR Seniority System - Oracle Database Setup Guide (Simple Language)

This guide walks you through connecting this application to HAL's real Oracle database. Follow these steps when you arrive at their office.

---

## STEP 1: Ask the HAL IT Admin for these Details
Find the database administrator or IT officer and ask them to fill out this list. Write down their answers:

1. **Database Server IP Address**: ________________________
   *(Usually looks like `10.x.x.x` or `172.x.x.x`. If it's on the same computer you are running the app on, it will be `localhost`.)*
   
2. **Oracle Port**: ________________________
   *(Standard port is `1521`.)*
   
3. **Oracle SID or Service Name**: ________________________
   *(This is the database database identifier, e.g. `XE`, `ORCL`, or `HALPROD`.)*
   
4. **Database Username**: ________________________
   *(The user credentials to access the tables.)*
   
5. **Database Password**: ________________________
   
6. **Their Table Names & Column Names**:
   Ask them: *"What are the table names for active employees and promotion histories? Also, what are the names of the columns (like ID, Name, Date of Joining, Date of Birth) in those tables?"*

---

## STEP 2: Find the Oracle JDBC Driver (The Connection File)
Java needs a file called the **Oracle JDBC Driver** to talk to Oracle. It is a file that ends with `.jar` (usually called `ojdbc14.jar`, `ojdbc6.jar`, or `ojdbc8.jar`). 

You must locate this file on their computers:
1. **Search the computer**: Open Windows Explorer, click on **This PC**, and search for `ojdbc` in the top-right search box.
2. **Ask the Admin**: If you can't find it, ask the IT admin: *"Where is the Oracle JDBC Driver ojdbc.jar file stored on this system?"*
3. **Once you find the file**:
   * Copy the `ojdbcXX.jar` file.
   * Paste it into the **`c:\HAL Internship\tomcat\lib\`** folder.

---

## STEP 3: Configure the Mappings in Notepad
Now, update the settings in the application to match the details you gathered:

1. Open the file **`c:\HAL Internship\src\db.properties`** in Notepad.
2. Edit the following fields:
   * **`db.url`**: Change it to match their IP, Port, and SID:
     ```properties
     db.url=jdbc:oracle:thin:@IP_ADDRESS:PORT:SID
     ```
     *Example: If the IP is `10.20.30.40`, Port is `1521`, and SID is `HALDB`, you change it to:*
     `db.url=jdbc:oracle:thin:@10.20.30.40:1521:HALDB`
   * **`db.username`**: Type the username they gave you.
   * **`db.password`**: Type the password they gave you.
3. Look at the **Table Names** and **Column Mapping** sections in that file. If the admin said their columns have different names, change the names after the `=` sign.
   * *Example: If they name the full name column `EMP_NAME` instead of `employee_name`, change:*
     `col.emp.name=employee_name` to `col.emp.name=EMP_NAME`
4. **Save and close** the file.

---

## STEP 4: Compile and Start the Application
1. Double-click the file **`start_hal_system.bat`** in your project folder.
2. The window will open, automatically compile the Java files using the new mappings, copy them to the Tomcat server, and start the system.
3. Open the browser and go to `http://localhost:8080/HAL/`. The app will now fetch and display the live database records.
