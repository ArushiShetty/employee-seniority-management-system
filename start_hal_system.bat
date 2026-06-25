@echo off
setlocal enabledelayedexpansion
title HAL Seniority System Startup
echo ==================================================
echo HAL Seniority Management System - Startup Script
echo ==================================================

:: Free port 8080 and 8005 if occupied
echo [0/3] Ensuring ports 8080 and 8005 are free...
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8080') do (
    taskkill /f /pid %%a >nul 2>nul
)
for /f "tokens=5" %%a in ('netstat -aon ^| findstr :8005') do (
    taskkill /f /pid %%a >nul 2>nul
)


:: 1. Attempt to detect Java
set "DETECTED_JAVA_HOME="

:: Check for a bundled local JDK first (ideal for 100% offline portability on old systems)
if exist "%~dp0jdk" (
    set "DETECTED_JAVA_HOME=%~dp0jdk"
)

:: Check the default laptop path
if not defined DETECTED_JAVA_HOME (
    if exist "C:\Program Files\Eclipse Adoptium\jdk-8.0.492.9-hotspot" (
        set "DETECTED_JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-8.0.492.9-hotspot"
    )
)

:: If not found, check if system JAVA_HOME env var is set and valid
if not defined DETECTED_JAVA_HOME (
    if defined JAVA_HOME (
        if exist "!JAVA_HOME!\bin\java.exe" (
            set "DETECTED_JAVA_HOME=!JAVA_HOME!"
        )
    )
)

:: If still not found, check other standard directories
if not defined DETECTED_JAVA_HOME (
    for /d %%d in ("C:\Program Files\Eclipse Adoptium\jdk-*") do (
        if exist "%%d\bin\java.exe" set "DETECTED_JAVA_HOME=%%d"
    )
)
if not defined DETECTED_JAVA_HOME (
    for /d %%d in ("C:\Program Files\Java\jdk-*" "C:\Program Files\Java\jre-*") do (
        if exist "%%d\bin\java.exe" set "DETECTED_JAVA_HOME=%%d"
    )
)
if not defined DETECTED_JAVA_HOME (
    for /d %%d in ("C:\Program Files\Java\jdk1.8.*" "C:\Program Files\Java\jre1.8.*") do (
        if exist "%%d\bin\java.exe" set "DETECTED_JAVA_HOME=%%d"
    )
)
if not defined DETECTED_JAVA_HOME (
    for /d %%d in ("C:\Program Files (x86)\Java\jdk-*" "C:\Program Files (x86)\Java\jre-*") do (
        if exist "%%d\bin\java.exe" set "DETECTED_JAVA_HOME=%%d"
    )
)
if not defined DETECTED_JAVA_HOME (
    for /d %%d in ("C:\Program Files\Amazon Corretto\jdk-*" "C:\Program Files\Microsoft\jdk-*" "C:\Program Files\Zulu\zulu-*") do (
        if exist "%%d\bin\java.exe" set "DETECTED_JAVA_HOME=%%d"
    )
)

:: If we found a Java Home, set it for Tomcat
if defined DETECTED_JAVA_HOME (
    set "JAVA_HOME=!DETECTED_JAVA_HOME!"
    echo [INFO] Using Java Home: !JAVA_HOME!
) else (
    echo [WARNING] JAVA_HOME not found. Tomcat will try to start using the system path Java.
)

:: Determine if JDK compiler (javac) is available
set "JAVAC_EXE="
if defined JAVA_HOME (
    if exist "!JAVA_HOME!\bin\javac.exe" (
        set "JAVAC_EXE=!JAVA_HOME!\bin\javac.exe"
    )
)
if not defined JAVAC_EXE (
    where javac >nul 2>nul
    if not errorlevel 1 set "JAVAC_EXE=javac"
)

:: Detect Java version to determine compilation flags (backward compatibility check)
set "COMPILER_FLAGS="
if defined DETECTED_JAVA_HOME (
    "!DETECTED_JAVA_HOME!\bin\java" -version 2>&1 | findstr " 1." >nul
    if not errorlevel 1 (
        set "COMPILER_FLAGS=-source 1.4 -target 1.4"
        echo [INFO] Detected Java 1.x. Compiling targeting Java 1.4.
    ) else (
        set "COMPILER_FLAGS="
        echo [INFO] Detected Java 9 or later. Compiling with default compatibility.
    )
) else (
    java -version 2>&1 | findstr " 1." >nul
    if not errorlevel 1 (
        set "COMPILER_FLAGS=-source 1.4 -target 1.4"
        echo [INFO] Detected Java 1.x on system PATH. Compiling targeting Java 1.4.
    ) else (
        set "COMPILER_FLAGS="
        echo [INFO] Detected Java 9 or later on system PATH. Compiling with default compatibility.
    )
)

:: 2. Compile Java classes (if javac is available)
if defined JAVAC_EXE (
    echo [1/3] Compiling Java classes...
    if not exist "%~dp0WebContent\WEB-INF\classes" mkdir "%~dp0WebContent\WEB-INF\classes"
    if exist "%~dp0java_sources.txt" del "%~dp0java_sources.txt" >nul 2>nul
    
    rem Generate java_sources.txt with forward slashes and quotes
    for /R "%~dp0src" %%f in (*.java) do (
        set "filepath=%%f"
        set "filepath=!filepath:\=/!"
        echo "!filepath!" >> "%~dp0java_sources.txt"
    )
    
    "!JAVAC_EXE!" !COMPILER_FLAGS! -d "%~dp0WebContent\WEB-INF\classes" -classpath "%~dp0tomcat\lib\servlet-api.jar" @"%~dp0java_sources.txt"
    
    if errorlevel 1 (
        echo [ERROR] Compilation failed. Please check errors above.
        if exist "%~dp0java_sources.txt" del "%~dp0java_sources.txt" >nul 2>nul
        pause
        exit /b 1
    )
    if exist "%~dp0java_sources.txt" del "%~dp0java_sources.txt" >nul 2>nul
    echo [SUCCESS] Compilation successful.
) else (
    rem Check if classes exist
    if exist "%~dp0WebContent\WEB-INF\classes\com\hal\hrms\servlet\LoginServlet.class" (
        echo [INFO] JDK compiler javac not found.
        echo [INFO] Running with pre-compiled classes from your laptop.
    ) else (
        echo [ERROR] JDK compiler not found, and no pre-compiled classes exist.
        echo Please ensure Java JDK is installed to run/compile the application.
        pause
        exit /b 1
    )
)

:: 3. Deploy/Copy WebContent to Tomcat webapps/HAL
echo [2/3] Deploying application files to Tomcat...
if not exist "%~dp0WebContent\WEB-INF\classes" mkdir "%~dp0WebContent\WEB-INF\classes"
copy "%~dp0src\db.properties" "%~dp0WebContent\WEB-INF\classes" > nul
if exist "%~dp0tomcat\webapps\HAL" rmdir /s /q "%~dp0tomcat\webapps\HAL"
mkdir "%~dp0tomcat\webapps\HAL"
robocopy "%~dp0WebContent" "%~dp0tomcat\webapps\HAL" /e /r:0 /w:0 /njh /njs /ndl /nc /ns > nul
echo [SUCCESS] Deployment completed.

:: 4. Start Tomcat Server
echo [3/3] Starting Tomcat Server...
echo ==================================================
echo System starting! You can access the portal at:
echo http://localhost:8080/HAL/
echo ==================================================
cd tomcat\bin
call startup.bat
cd ..\..
ping 127.0.0.1 -n 6 >nul
start http://localhost:8080/HAL/
pause
