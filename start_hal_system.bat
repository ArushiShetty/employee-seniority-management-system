@echo off
setlocal enabledelayedexpansion
title HAL Seniority System Startup
echo ==================================================
echo HAL Seniority Management System - Startup Script
echo ==================================================

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
    if not exist "WebContent\WEB-INF\classes" mkdir "WebContent\WEB-INF\classes"
    if exist java_sources.txt del java_sources.txt
    
    rem Generate java_sources.txt with forward slashes and quotes
    for /R src %%f in (*.java) do (
        set "filepath=%%f"
        set "filepath=!filepath:\=/!"
        echo "!filepath!" >> java_sources.txt
    )
    
    "!JAVAC_EXE!" !COMPILER_FLAGS! -d WebContent\WEB-INF\classes -classpath "tomcat\lib\servlet-api.jar" @java_sources.txt
    
    if errorlevel 1 (
        echo [ERROR] Compilation failed. Please check errors above.
        if exist java_sources.txt del java_sources.txt
        pause
        exit /b 1
    )
    if exist java_sources.txt del java_sources.txt
    echo [SUCCESS] Compilation successful.
) else (
    rem Check if classes exist
    if exist "WebContent\WEB-INF\classes\com\hal\hrms\servlet\LoginServlet.class" (
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
if exist "tomcat\webapps\HAL" rmdir /s /q "tomcat\webapps\HAL"
mkdir "tomcat\webapps\HAL"
xcopy /s /e /y /q WebContent\* tomcat\webapps\HAL\ > nul
echo [SUCCESS] Deployment completed.

:: 4. Start Tomcat Server
echo [3/3] Starting Tomcat Server...
echo ==================================================
echo System starting! Automatically launching portal in your browser...
echo ==================================================
cd tomcat\bin
call startup.bat
cd ..\..
ping 127.0.0.1 -n 6 >nul
start http://localhost:8080/HAL/
pause
