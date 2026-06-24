#!/bin/bash
# ====================================================================
# HAL Seniority Management System - Startup Script for Ubuntu/Linux
# ====================================================================

echo "=================================================="
echo "HAL Seniority Management System - Ubuntu Startup"
echo "=================================================="

# 1. Detect Java
if [ -n "$JAVA_HOME" ] && [ -x "$JAVA_HOME/bin/javac" ]; then
    echo "[INFO] Using JAVA_HOME: $JAVA_HOME"
    JAVAC="$JAVA_HOME/bin/javac"
else
    if command -v javac >/dev/null 2>&1; then
        echo "[INFO] Using system default javac."
        JAVAC="javac"
    else
        echo "[WARNING] Java Compiler (javac) not found."
        echo "If you already compiled classes, we will skip compilation."
        JAVAC=""
    fi
fi

# 2. Compile Java classes (if javac is available)
if [ -n "$JAVAC" ]; then
    echo "[1/3] Compiling Java classes..."
    mkdir -p WebContent/WEB-INF/classes
    
    # Generate list of Java sources
    find src -name "*.java" > java_sources.txt
    
    # Compile
    $JAVAC -d WebContent/WEB-INF/classes -classpath tomcat/lib/servlet-api.jar @java_sources.txt
    
    if [ $? -eq 0 ]; then
        echo "[SUCCESS] Compilation successful."
        rm -f java_sources.txt
        # Copy properties configuration file to classpath
        cp src/db.properties WebContent/WEB-INF/classes/
    else
        echo "[ERROR] Compilation failed. Please check errors above."
        rm -f java_sources.txt
        exit 1
    fi
else
    if [ -f "WebContent/WEB-INF/classes/com/hal/hrms/servlet/LoginServlet.class" ]; then
        echo "[INFO] Running with existing pre-compiled classes."
    else
        echo "[ERROR] Java Compiler (javac) not found and no pre-compiled classes exist."
        echo "Please install JDK (e.g. sudo apt install default-jdk) to compile and run."
        exit 1
    fi
fi

# 3. Deploy/Copy WebContent to Tomcat webapps/HAL
echo "[2/3] Deploying application files to Tomcat..."
rm -rf tomcat/webapps/HAL
mkdir -p tomcat/webapps/HAL
cp -r WebContent/* tomcat/webapps/HAL/
echo "[SUCCESS] Deployment completed."

# 4. Start Tomcat Server
echo "[3/3] Starting Tomcat Server..."
echo "=================================================="
echo "System starting! Automatically launching portal..."
echo "=================================================="

# Make scripts executable
chmod +x tomcat/bin/*.sh

cd tomcat/bin
./startup.sh
cd ../..

echo "[INFO] Tomcat started in the background."
echo "Open your browser and navigate to: http://localhost:8080/HAL/"

# Attempt to open browser if graphical session is active
if [ -n "$DISPLAY" ]; then
    sleep 3
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open http://localhost:8080/HAL/
    elif command -v gnome-open >/dev/null 2>&1; then
        gnome-open http://localhost:8080/HAL/
    fi
fi
