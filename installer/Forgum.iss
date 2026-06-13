; Forgum Inno Setup Script
; Installs the PowerShell module to the user's PowerShell module path
; Compile with Inno Setup 6+ (https://jrsoftware.org/isinfo.php)
;
; One-liner install (silent):
;   & "$env:TEMP\Forgum-v1.0.4-Setup.exe" /VERYSILENT /SUPPRESSMSGBOXES /NORESTART
;
; Winget install:
;   winget install HKDEVS.Forgum

#define MyAppName "Forgum"
#define MyAppVersion "1.0.4"
#define MyAppPublisher "HKDEVS"
#define MyAppURL "https://github.com/harish2222/Forgum"
#define MyAppLicense "MIT"

[Setup]
AppId={#MyAppName}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}/issues
AppUpdatesURL={#MyAppURL}/releases
DefaultDirName={localappdata}\{#MyAppName}
DefaultGroupName={#MyAppName}
LicenseFile=..\LICENSE
OutputDir=..\dist
OutputBaseFilename=Forgum-v{#MyAppVersion}-Setup
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridingOwnedDir
UninstallDisplayName={#MyAppName} {#MyAppVersion}
UninstallDisplayIcon={app}\Forgum.psm1
VersionInfoVersion={#MyAppVersion}.0
VersionInfoDescription={#MyAppName} PowerShell Module Installer
CloseApplications=no
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Files]
; Module files - extracted to temp install dir, then copied to PSModule path
Source: "..\Forgum.psd1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Forgum.psm1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\Private\*"; DestDir: "{app}\Private"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Public\*"; DestDir: "{app}\Public"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\Data\*"; DestDir: "{app}\Data"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\install.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\install.sh"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\setup.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\uninstall.ps1"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"

[Run]
; Run setup.ps1 to configure user profile (skipped in silent/very silent mode)
Filename: "pwsh.exe"; Parameters: "-NoProfile -ExecutionPolicy Bypass -File ""{app}\setup.ps1"" -InstallOnly"; StatusMsg: "Configuring PowerShell profile..."; Flags: runhidden waituntilterminated skipifsilent skipifdoesntexist

[Code]
function GetPSModulePath: String;
var
  PSModulePathEnv: String;
  UserModules: String;
begin
  PSModulePathEnv := GetEnv('PSModulePath');
  UserModules := ExpandConstant('{userdocs}\PowerShell\Modules');
  if DirExists(UserModules) then
    Result := UserModules
  else
    Result := ExpandConstant('{userdocs}\Documents\PowerShell\Modules');
end;

procedure CurStepChanged(CurStep: TSetupStep);
var
  ModuleDir: String;
  SourceDir: String;
begin
  if CurStep = ssPostInstall then
  begin
    ModuleDir := GetPSModulePath + '\Forgum';
    SourceDir := ExpandConstant('{app}');

    if not DirExists(ModuleDir) then
      ForceDirectories(ModuleDir);

    FileCopy(SourceDir + '\Forgum.psd1', ModuleDir + '\Forgum.psd1', False);
    FileCopy(SourceDir + '\Forgum.psm1', ModuleDir + '\Forgum.psm1', False);

    if DirExists(SourceDir + '\Private') then
      CopyDir(SourceDir + '\Private', ModuleDir + '\Private', False);
    if DirExists(SourceDir + '\Public') then
      CopyDir(SourceDir + '\Public', ModuleDir + '\Public', False);
    if DirExists(SourceDir + '\Data') then
      CopyDir(SourceDir + '\Data', ModuleDir + '\Data', False);

    FileCopy(SourceDir + '\LICENSE', ModuleDir + '\LICENSE', False);
    FileCopy(SourceDir + '\README.md', ModuleDir + '\README.md', False);
    FileCopy(SourceDir + '\install.ps1', ModuleDir + '\install.ps1', False);
    FileCopy(SourceDir + '\install.sh', ModuleDir + '\install.sh', False);
    FileCopy(SourceDir + '\setup.ps1', ModuleDir + '\setup.ps1', False);
    FileCopy(SourceDir + '\uninstall.ps1', ModuleDir + '\uninstall.ps1', False);
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
  ModuleDir: String;
begin
  if CurUninstallStep = usPostUninstall then
  begin
    ModuleDir := GetPSModulePath + '\Forgum';
    if DirExists(ModuleDir) then
      DelTree(ModuleDir, True, True, True);
  end;
end;
