<!-- :
@echo off 

SET ENVFILE=.env

for /f "tokens=1-5 delims=|" %%a in ('mshta.exe "%~f0"') do (
    SET "IIQ_VERSION=%%a"
    SET "IIQ_PORT=%%b"
    SET "MYSQL_PORT=%%c"
    SET "USERNAME=%%d"
    SET "PASS=%%e"
)

echo IIQ_VERSION=%IIQ_VERSION% > .env
echo IIQ_PORT=%IIQ_PORT% >> .env
echo MYSQL_PORT=%MYSQL_PORT% >> .env
echo USERNAME is %USERNAME%
echo PASS is %PASS%

docker --version > NUL

IF NOT %ERRORLEVEL% == 0 (
    echo Docker must be installed and running. Please visit https://www.docker.com to download the latest version.
    EXIT /B
) ELSE echo Docker is installed.

docker login -u %USERNAME% -p %PASS% identityiqdocker.azurecr.io
docker compose up

timeout /t 10
-->

<html>
<head>
    <HTA:APPLICATION SCROLL="no" ICON="icons/sp_favicon.ico">
    <title>IdentityIQ Launcher</title>
</head>
<body>

    <script language='javascript' >
        window.resizeTo(800,600);
        function validateForm() {
            var a = document.getElementById("iiqVersion").value;
            var b = document.getElementById("iiqPort").value;
            var c = document.getElementById("mysqlPort").value;
            var d = document.getElementById("username").value;
            var e = document.getElementById("pass").value;
            if ((a == null || a == "") || (b == null || b == "") || (c == null || c == "") || (d == null || d == "")  || (e == null || e == "")) {
                alert("Please fill in all fields");
                return false;
            }
            else {
                pipeText();
            }
        }
        function pipeText() {
            new ActiveXObject("Scripting.FileSystemObject")
            .GetStandardStream(1)
            .WriteLine(
                [ // Array of elements to return joined with the delimiter
                    document.getElementById("iiqVersion").value,
                    document.getElementById("iiqPort").value,
                    document.getElementById("mysqlPort").value,
                    document.getElementById("username").value,
                    document.getElementById("pass").value
                ].join('|')
            );
            window.close();
        }
    </script>
    <style>
        body {
            font-family: Arial, Helvetica, sans-serif;
            color: white;
            margin-top: 0px;
            margin-bottom: 10px;
        }
        h2 {
            font-weight: bold;
        }
        * {box-sizing: border-box;}

        input[type=text], select, textarea {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
            margin-top: 6px;
            margin-bottom: 16px;
            resize: vertical;
        }

        input[type=submit] {
            background-color: #04AA6D;
            color: white;
            padding: 12px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
        }

        input[type=submit]:hover {
            background-color: #45a049;
        }

        .container {
            background-color: #0071ce;
            background-repeat: no-repeat;
            padding: 20px;
        }
    </style>
    <div class="container">
        <form action="/action_page.php">
            <h2>IdentityIQ Details</h2>
            <label for="iiqVersion">Please specify the version and patch number of IIQ (i.e. 8.3p1) you wish to install:</label><br>
            <input style="width: 375px;" type='text' name='iiqVersion' value='8.3p1' required><br>
            <br>
            <label for="iiqPort">Please specify the port for IIQ:</label><br>
            <input style="width: 375px;" type='text' name='iiqPort' value='7070' required><br>
            <br>
            <label for="mysqlPort">Please specify the port for MySQL:</label><br>
            <input style="width: 375px;" type='text' name='mysqlPort' value='3307' required><br>
            <br>
            <label for="username">Enter username:</label><br>
            <input style="width: 375px;" type='text' name='username' value='edgile' required><br>
            <br>
            <label for="pass">Enter password:</label><br>
            <input style="width: 375px;" type='text' name='pass' required><br>
            <br>
            <button onclick='return validateForm()'>Submit</button>
        </form>
    </div>
</body>

</html>