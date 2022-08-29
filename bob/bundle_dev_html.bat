if not defined in_subprocess (cmd /k set in_subprocess=y ^& %0 %*) & exit )
cd ../
java -jar bob/bob.jar --settings bob/settings/dev_game.project_settings --archive  --texture-compression true --with-symbols --variant debug --platform=js-web --bo bob/releases/dev/web -brhtml bob/releases/dev/web/report.html clean resolve build bundle 

xcopy /s /y ".\bob\releases\dev\web\CryptoNeon Hex Dev" "C:\Users\user\Desktop\firebase\public"

C:

cd "C:\Users\user\Desktop\firebase"
firebase deploy