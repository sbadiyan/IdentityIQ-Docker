<!-- :
@echo off 
setlocal EnableDelayedExpansion

set "ERROR="

:open-form
for /f "tokens=1-7 delims=|" %%a in ('mshta.exe "%~f0" "%ERROR%"') do (
    set "IIQ_VERSION=%%a"
    set "IIQ_PORT=%%b"
    set "MYSQL_PORT=%%c"
    set "USERNAME=%%d"
    set "PASS=%%e"
    set "USE_DEMO_DATA=%%f"
    set "BUTTON_CLICKED=%%g"
)

echo IIQ_VERSION=%IIQ_VERSION% > .env
if "%IIQ_VERSION:p=%" neq "%IIQ_VERSION%" (
    for /f "tokens=1,2 delims=p" %%a in ("%IIQ_VERSION%") do (
        set "IIQ_BASE=%%a"
        set "IIQ_PATCH=p%%b"
    )
) else (
    set "IIQ_BASE=%IIQ_VERSION%"
    set "IIQ_PATCH="
)
echo IIQ_BASE=!IIQ_BASE!>> .env
echo IIQ_PATCH=!IIQ_PATCH!>> .env
echo IIQ_PORT=%IIQ_PORT% >> .env
echo MYSQL_PORT=%MYSQL_PORT% >>  .env
echo USE_DEMO_DATA=%USE_DEMO_DATA% >> .env
if "%BUTTON_CLICKED%" == "cancel" (
    exit /B
)

if [%ERROR%] == [] (
    wsl --update
    docker --version > nul 2>&1
    if not %ERRORLEVEL% == 0 (
        echo Docker must be installed and running. Please visit https://www.docker.com to download the latest version.
        exit /B
    ) else echo Docker is installed.
)

docker stats --no-stream > nul 2>&1
if not %ERRORLEVEL% == 0 (
    powershell -Command "start 'C:\Program Files\Docker\Docker\Docker Desktop.exe'"
)

:wait-for-docker
docker stats --no-stream > nul 2>&1
if not %ERRORLEVEL% == 0 (
    echo Waiting for Docker to launch...
    timeout /t 6 /nobreak > nul
    goto :wait-for-docker 
)

netstat -o -n -a | find "LISTENING" | find ":%IIQ_PORT% " > nul
if "%ERRORLEVEL%" equ "0" (
  echo The port you selected for IIQ is already in use on your machine. Please enter a different port.
  set "ERROR=IIQ"
  goto :open-form
)

netstat -o -n -a | find "LISTENING" | find ":%MYSQL_PORT% " > nul
if "%ERRORLEVEL%" equ "0" (
    echo The port you selected for MySQL is already in use on your machine. Please enter a different port.
    set "ERROR=MYSQL"
    goto :open-form
)

docker login -u %USERNAME% -p %PASS% identityiqdocker.azurecr.io > nul 2>&1
if not %ERRORLEVEL% == 0 (
    echo Invalid username or password. Please try again.
    set "ERROR=PASS"
    goto :open-form
)

echo Login succeeded
mkdir IIQ-%IIQ_VERSION%
copy .env %~dp0\IIQ-%IIQ_VERSION%
copy docker-compose.yml %~dp0\IIQ-%IIQ_VERSION%
cd IIQ-%IIQ_VERSION%
docker compose up

timeout /t 30
-->

<html>
<head>
    <HTA:APPLICATION id="myform" SysMenu="no" scroll="no" icon="sp_favicon.ico" singleInstance="yes" reseize="no">
    <title>IdentityIQ Launcher</title>
    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            color: white;
            background-color: #0033a1;
            margin-top: 0px;
            margin-bottom: 10px;
            overflow: auto;
        }
        h1 {
            font-weight: bold;
        }
        * {
            box-sizing: border-box;
        }
        label {
            font-weight: bold;
        }
        input, select, textarea {
            line-height: 20px;
            height: 25px;
            width: 100%;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            margin-top: 6px;
            margin-bottom: 6px;
            resize: vertical;
        }

        .button {
            background-color: #cc27b0;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            margin-left: 6px;
            font-weight: bold;
        }

        .submit {
            margin-left: 18px;
        }

        .container {
            padding: 10px;
        }
    </style>
</head>
<body>
    <div class="container">
        <form id="form">
            <h1>IdentityIQ Launcher Form</h1>
            <label for="iiqVersion">Please specify the version and patch number of IIQ (e.g. 8.3p1) you wish to install:</label><br>
            <input style="width: 375px;" type="text" name="iiqVersion" value="8.3p2" required><br>
            <br>
            <label for="useDemoData">Would you like to include demo data with your install (Yes or No)?</label><br>
            <input style="width: 375px;" type="text" name="useDemoData" value="Yes" required><br>
            <br>
            <label for="iiqPort">Please specify the port for IIQ:</label><br>
            <input style="width: 375px;" type="text" name="iiqPort" value="7070" required><br>
            <br>
            <label for="mysqlPort">Please specify the port for MySQL:</label><br>
            <input style="width: 375px;" type="text" name="mysqlPort" value="3307" required><br>
            <br>
            <label for="username">Enter username:</label><br>
            <input style="width: 375px;" type="text" name="username" value="edgile" required><br>
            <br>
            <label for="pass">Enter password:</label><br>
            <input style="width: 375px;" type="password" name="pass" required><br>
            <br>
            <button class="button cancel" onclick="return validateForm('cancel');">Cancel</button>
            <button class="button submit" onclick="return validateForm('submit');">Submit</button>
        </form>
    </div>
    <script language='javascript' >
        onload = function() {
            var cmdline = document.getElementById("myform").commandLine;
            var args = cmdline.split(" ");
            var error = args[1].substring(1, args[1].length - 1);
            var form = document.getElementById("form");
            var width = form.offsetWidth;
            var height = form.offsetHeight;
            window.resizeTo(screen.width * .33, screen.height *.67);
            window.moveTo((screen.width - 800) / 2, (screen.height - (height + 100)) / 2);

            window.focus();
            if (error === "PASS") {
                alert("Invalid username or password. Please try again.");
            }
            else if (error === "IIQ") {
                alert("The port you selected for IIQ is already in use on your machine. Please enter a different port.");
            }
            else if (error === "MYSQL") {
                alert("The port you selected for MySQL is already in use on your machine. Please enter a different port.");
            }
        };
        function parseCommandline(cmdline) {
            var rx = /"[^"]+"\s*?|\S+\s*?/g;
            var args = [];
            var match;
            while (match = rx.exec(cmdline)) {
                if (match[0].charAt(0) === '"') {
                    args.push(match[0].substring(1, match[0].length - 1));
                } else {
                    args.push(match[0]);
                }
            }
            return args;
        }
        function validateForm(button) {
            var a = document.getElementById("iiqVersion").value;
            var b = document.getElementById("iiqPort").value;
            var c = document.getElementById("mysqlPort").value;
            var d = document.getElementById("username").value;
            var e = document.getElementById("pass").value;
            var f = document.getElementById("useDemoData").value;
            if (((a === null || a === "") || (b === null || b === "") || (c === null || c === "") || (d === null || d === "")  || (e === null || e === "") || (f === null || f === "")) && button === "submit") {
                alert("Please fill in all fields");
                return false;
            }
            else if (button === "cancel") {
                a = "a"; b="b"; c="c"; d="d"; e="e"; f="f";        //can't return empty values to the batch script, they will be ignored
            }
            pipeText(a, b, c, d, e, f, button);
        }
        function pipeText(a, b, c, d, e, f, button) {
            var values = [a,b,c,d,e,f,button].join('|');
            new ActiveXObject("Scripting.FileSystemObject")
            .GetStandardStream(1)
            .WriteLine(values);
            window.close();
        }
    </script>
</body>

</html>