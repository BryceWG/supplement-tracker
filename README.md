# Supplement Tracker（补剂管家）

这是一个 Flutter 跨平台应用（Android/iOS/Web/Windows/macOS/Linux），用于跟踪营养补剂的库存与花费。

仓库根目录的 `index.html` 是最初的网页原型（用于对齐 UI/交互）；Flutter App 的源码就在仓库根目录（`lib/`、`android/`、`ios/` 等）。

## 快速开始

在仓库根目录运行：

```powershell
flutter pub get
```

启动（任选其一）：

```powershell
flutter run -d windows
# 或
flutter run -d chrome
# 或（连接真机/启动模拟器后）
flutter run
```

## 功能对齐（参考 `index.html`）

- 统计卡片：补剂总数 / 今日花费 / 最短剩余 / 月度总花费
- 补剂列表：进度条（按剩余天数变色）/ 每日花费 / 编辑 / 删除
- 数据分析：月度花费分布（环形图）/ 花费趋势（折线图）
- 提醒：剩余天数 ≤ 14 天时提示库存不足
- 本地持久化：使用 `shared_preferences` 保存数据

## 打包

```powershell
# Android（AAB）
flutter build appbundle --release

# Windows
flutter build windows --release

# Web
flutter build web --release
```
