# Flutter 应用启动脚本
# 自动清理缓存并运行应用，减少错误信息显示

Write-Host "正在清理构建缓存..." -ForegroundColor Yellow
flutter clean | Out-Null

Write-Host "正在运行应用..." -ForegroundColor Green
flutter run -d 10AEAB44PX000TN
