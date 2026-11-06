@echo off
chcp 65001 >nul
title Hidrat Mobil Uygulama Sunucusu
start http://localhost:8080
node "%~dp0server.js"
pause
