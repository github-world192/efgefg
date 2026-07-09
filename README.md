# 超級單字 App

一個準備上架 Google Play 的台灣英文單字學習應用程式，使用 Flutter 開發，支援多平台（Android、iOS、Web、Windows、macOS、Linux）。

本專案基於台灣學校英文單字分級系統，幫助使用者根據自己的程度學習英文單字。

## ✨ 特色功能

- 📚 **分級學習系統**：7 個英文程度級別（基礎到專業）
- 💾 **智慧離線快取**：自動儲存已載入的單字，離線也能複習
- 🔎 **即時單字搜尋**：可快速篩選目標單字
- ⭐ **收藏清單**：一鍵收藏常錯或常用單字，支援僅看收藏
- 📈 **學習進度條**：自動標記已學習單字並顯示完成比例
- 🎨 **現代化 UI 設計**：Material Design 3，優雅簡潔
- 🔄 **自動同步**：優先使用快取資料快速啟動，背景自動更新最新內容
- 📱 **跨平台支援**：Android、iOS、Web、桌面平台全支援
- 🌐 **線上單字庫**：資料來源自 GitHub，持續更新

## 🛠️ 技術棧

- **Flutter/Dart**：跨平台 UI 框架
- **SharedPreferences**：本地資料快取
- **HTTP**：網路資料獲取
- **Material Design 3**：現代化設計語言

### 多平台支援

- **Android**：Kotlin + Gradle
- **iOS/macOS**：Swift + Xcode
- **Windows/Linux**：C++ + CMake
- **Web**：Progressive Web App (PWA)

## 📦 安裝與執行

### 前置需求

1. 安裝 [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. 確保 Flutter 環境正常：
   ```bash
   flutter doctor
   ```

### 下載專案

```bash
git clone https://github.com/github-world192/vocabpass.git
cd vocabpass
```

### 安裝依賴

```bash
flutter pub get
```

### 執行應用程式

#### 在 Chrome 上運行（最快，適合開發）
```bash
flutter run -d chrome
```

#### 在 Android 模擬器/實體機上運行
```bash
flutter run
```

#### 查看所有可用設備
```bash
flutter devices
```

## 🧪 測試

執行測試：
```bash
flutter test
```

## 📱 應用程式結構

```
lib/
├── main.dart                      # 應用程式入口 & 級別選擇畫面
└── vocabulary_list_screen.dart    # 單字列表 & 單字詳細頁面
```

### 主要功能

1. **級別選擇畫面**（LevelSelectionScreen）
   - 7 個英文級別選項
   - 彩色卡片設計，清楚的難度標示

2. **單字列表畫面**（VocabularyListScreen）
   - 顯示該級別的所有單字及定義
   - 即時搜尋與收藏篩選
   - 收藏功能（本機持久化）
   - 已學習進度追蹤與進度條
   - 智慧快取系統（優先載入快取，背景更新）
   - 離線模式指示器
   - 重新載入功能

3. **單字詳細頁面**（BigWordPage）
   - 大字體顯示單字
   - 清楚的定義說明
   - 美觀的卡片設計

## 🔧 Package 資訊

- **Package Name**: `com.vocabpass.app`
- **App Name**: 超級單字
- **Version**: 1.0.0+1

## 🌐 資料來源

單字資料來自：[TaiwanSchoolEnglishVocabulary](https://github.com/AppPeterPan/TaiwanSchoolEnglishVocabulary)

## 🚀 部署

### Android

```bash
flutter build apk --release
```

生成的 APK 位於：`build/app/outputs/flutter-apk/app-release.apk`

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🤝 貢獻方式

歡迎 issue、PR 與討論！

1. Fork 本倉庫
2. 建立分支 (`git checkout -b feature/your-feature`)
3. 提交更改 (`git commit -am 'Add some feature'`)
4. 推送到分支 (`git push origin feature/your-feature`)
5. 發送 Pull Request

## 📄 授權

本專案為開源專案，歡迎使用和修改。

## 📧 聯絡方式

如有問題或建議，請開啟 [issue](https://github.com/github-world192/vocabpass/issues)。
