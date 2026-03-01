#define MyAppName "补剂管家"
#ifndef MyAppVersion
  #define MyAppVersion "0.0.0"
#endif
#define MyAppPublisher "Supplement Tracker"
#define MyAppExeName "supplement_tracker.exe"
#define BuildDir GetEnv("BUILD_DIR")

[Setup]
AppId={{9B8D31F5-3B4E-4B3A-9B54-3BDB2C4C8C9F}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
OutputBaseFilename=supplement-tracker-setup-{#MyAppVersion}-windows
Compression=lzma2
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64
MinVersion=10.0
SetupIconFile=..\..\windows\runner\resources\app_icon.ico
UninstallDisplayIcon={app}\{#MyAppExeName}
SetupLogging=yes

#define _PF86 GetEnv("ProgramFiles(x86)")
#define _PF GetEnv("ProgramFiles")
#define _InnoLangCN_1 AddBackslash(_PF86) + "Inno Setup 6\Languages\ChineseSimplified.isl"
#define _InnoLangCN_2 AddBackslash(_PF) + "Inno Setup 6\Languages\ChineseSimplified.isl"

[Languages]
#if FileExists(_InnoLangCN_1) || FileExists(_InnoLangCN_2)
Name: "chinesesimp"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"
#else
; Some minimal Inno Setup installs (e.g. CI) may not include extra languages.
; Fall back to the default language file so packaging never fails.
Name: "english"; MessagesFile: "compiler:Default.isl"
#endif

[Tasks]
Name: "desktopicon"; Description: "创建桌面图标"; GroupDescription: "附加任务"; Flags: unchecked

[Files]
Source: "{#BuildDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "运行 {#MyAppName}"; Flags: nowait postinstall skipifsilent
