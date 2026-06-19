@echo off
title HAL Seniority System Startup
echo ==================================================
echo HAL Seniority Management System - Startup Script
echo ==================================================

:: 1. Attempt to detect Java
set "DETECTED_JAVA_HOME="

:: Check the default laptop path
if exist "C:\Program Files\Eclipse Adoptium\jdk-8.0.492.9-hotspot" (
    set "DETECTED_JAVA_HOME=C:\Program Files\Eclipse Adoptium\jdk-8.0.492.9-hotspot"
)

:: If not found, check if system JAVA_HOME env var is set and valid
if "%DETECTED_JAVA_HOME%"=="" (
    if not "%JAVA_HOME%"=="" (
        if exist "%JAVA_HOME%\bin\java.exe" (
            set "DETECTED_JAVA_HOME=%JAVA_HOME%"
        )
    )
)

:: If still not found, check other standard directories
if "%DETECTED_JAVA_HOME%"=="" (
    for /d %%d in ("C:\Program Files\Eclipse Adoptium\jdk-*") do (
        if exist "%%d\bin\java.exe" set "DETECTED_JAVA_HOME=%%d"
    )
)
if "%DETECTED_JAVA_HOME%"=="" (
    for /d %%d in ("C:\Program Files\Java\jdk1.8.*" "C:\Program Files\Java\jre1.8.*") do (
        if exist "%%d\bin\java.exe" set "DETECTED_JAVA_HOME=%%d"
    )
)

:: If we found a Java Home, set it for Tomcat
if not "%DETECTED_JAVA_HOME%"=="" (
    set "JAVA_HOME=%DETECTED_JAVA_HOME%"
    echo [INFO] Using Java Home: %JAVA_HOME%
) else (
    echo [WARNING] JAVA_HOME not found. Tomcat will try to start using the system path Java.
)

:: Determine if JDK compiler (javac) is available
set "JAVAC_EXE="
if not "%JAVA_HOME%"=="" (
    if exist "%JAVA_HOME%\bin\javac.exe" (
        set "JAVAC_EXE=%JAVA_HOME%\bin\javac.exe"
    )
)
if "%JAVAC_EXE%"=="" (
    where javac >nul 2>nul
    if %ERRORLEVEL% EQU 0 set "JAVAC_EXE=javac"
)

:: 2. Compile Java classes (if javac is available)
if not "%JAVAC_EXE%"=="" (
    echo [1/3] Compiling Java classes targeting Java 1.4...
    if not exist "WebContent\WEB-INF\classes" mkdir "WebContent\WEB-INF\classes"
    dir /s /b src\*.java > java_sources.txt
    "%JAVAC_EXE%" -source 1.4 -target 1.4 -d WebContent\WEB-INF\classes -classpath "tomcat\lib\servlet-api.jar" @java_sources.txt
    del java_sources.txt
    
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] Compilation failed. Please check errors above.
        pause
        exit /b %ERRORLEVEL%
    )
    echo [SUCCESS] Compilation successful!
) else (
    :: Check if classes exist
    if exist "WebContent\WEB-INF\classes\com\hal\hrms\servlet\LoginServlet.class" (
        echo [INFO] JDK compiler (javac) not found.
        echo [INFO] Running with pre-compiled classes from your laptop.
    ) else (
        echo [ERROR] JDK compiler not found, and no pre-compiled classes exist!
        echo Please ensure Java JDK is installed to run/compile the application.
        pause
        exit /b 1
    )
)

:: 3. Deploy/Copy WebContent to Tomcat webapps/HAL
echo [2/3] Deploying application files to Tomcat...
if exist "tomcat\webapps\HAL" rmdir /s /q "tomcat\webapps\HAL"
mkdir "tomcat\webapps\HAL"
xcopy /s /e /y /q WebContent\* tomcat\webapps\HAL\ > nul
echo [SUCCESS] Deployment completed!

:: 4. Start Tomcat Server
echo [3/3] Starting Tomcat Server...
echo ==================================================
echo System starting! You can access the portal at:
echo http://localhost:8080/HAL/
echo ==================================================
cd tomcat\bin
call startup.bat
cd ..\..
pause
