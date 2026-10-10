# Meta AI Co-Pilot Key App

[![Platform](https://img.shields.io/badge/Platform-Windows%2011-0078D6?logo=windows11&logoColor=white)](https://www.microsoft.com/windows)
[![Release](https://img.shields.io/badge/Release-v3.0-blue?logo=github&logoColor=white)](../../releases)
[![Target](https://img.shields.io/badge/Target-Meta%20AI%20(meta.ai)-0866FF?logo=meta&logoColor=white)](https://www.meta.ai)
[![Framework](https://img.shields.io/badge/Framework-.NET%208-512BD4?logo=dotnet&logoColor=white)](https://dotnet.microsoft.com/)
[![Package](https://img.shields.io/badge/Packaging-MSIX%20%2B%20Inno%20Setup-blue)](https://jrsoftware.org/isinfo.php)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

A ultra-lightweight Windows 11 application designed to remap the physical keyboard **Copilot key** to launch **[Meta AI](https://www.meta.ai)** instantly in a clean, maximized, standalone desktop application window.

**Author:** Nimantha  
**Latest Version:** v3.0  

---

## 💡 Why This Transition? (From Gemini to Meta AI)

This project was originally created as the *Gemini Co-Pilot Key App* because Windows 11 strictly restricted the physical Copilot keyboard key to Microsoft-approved apps and blocked direct web URLs.

### What Changed?
1. **Google Launched an Official Dedicated Gemini App for PC:** Google now offers an official, dedicated desktop application for Google Gemini on Windows. Users who want Gemini on their PC can now install and use Google's official app directly.
2. **Meta AI Lacks an Official Dedicated PC App / Key Integration:** While Meta AI is one of the world's most powerful AI assistants, Meta does not currently offer an official native Windows 11 desktop application or Copilot key binding.
3. **The Windows 11 Copilot Key Limitation:** Windows 11 does not let you enter a website URL like `https://www.meta.ai` into the Copilot key remapper in Settings. It strictly requires a packaged Windows Application (`MSIX`) declaring the `com.microsoft.windows.copilotkeyprovider` extension.

### The Solution: Meta AI Co-Pilot Key App
To bridge this gap, this project has evolved into the **Meta AI Co-Pilot Key App**. It transforms your hardware Copilot key into a dedicated, instantaneous hotkey for **Meta AI**—delivering a native-feeling desktop experience with zero background resource usage.

---

## ✨ Features

- **⚡ Instant Meta AI Launch:** Launches [meta.ai](https://www.meta.ai) in milliseconds at the touch of your physical Copilot keyboard key.
- **🖥️ Borderless Standalone Desktop Experience (PWA Mode):** Uses Chromium's `--app=` mode to run Meta AI without browser tabs, address bars, bookmarks, or browser clutter, looking like a native Windows 11 app.
- **🔍 Smart Multi-Browser Support:** Automatically checks for **Microsoft Edge**, **Google Chrome**, and **Brave**. If none are found, it seamlessly falls back to your system default web browser.
- **📐 Automatic Window Hunting & Maximization:** Integrates native Win32 APIs (`FindWindow`, `EnumWindows`, `ShowWindow`) to dynamically locate the launched Meta AI window and maximize it for comfortable interaction.
- **👻 Ghost Architecture (Zero RAM / Zero CPU):** The C# launcher executes and terminates in under a second. There is **no persistent background process**, meaning **0 MB RAM** and **0% CPU** consumption while idle.
- **⌨️ Sticky Modifier Key Fix:** The Windows 11 Copilot key hardware interrupt often causes modifier keys (`Win`, `Shift`, `Ctrl`, `Alt`) to stay virtually stuck. Our launcher automatically executes a low-level `keybd_event` release sequence upon launch to prevent ghost keyboard glitches.
- **📦 1-Click Silent Installer (Inno Setup):** Comes packaged with an Inno Setup installer that silently trusts the local security certificate and installs the MSIX package with one click—no PowerShell commands required.

---

## 🚀 Quick Start / Installation

### Method 1: Single-Click Setup (Recommended)
1. Download the latest release asset: **`MetaAICopilot_Installer.exe`** from the [Releases](../../releases) tab.
2. Double-click **`MetaAICopilot_Installer.exe`** and grant administrator permissions when prompted.
3. The installer will silently register the required security certificate and install the MSIX app package onto your Windows 11 system.

### Method 2: Manual Installation via ZIP
1. Download the release `.zip` archive and extract its contents.
2. Right-click **`Install.bat`** and select **Run as administrator**.
3. The batch script will import `MetaAICopilotKeyApp.pfx` into your local machine's `Root` certificate store and launch the Windows App Installer.
4. Click **Install** on the blue Windows App Installer dialog.

---

## ⚙️ How to Map in Windows 11 Settings

Once installed, map your physical key in just a few seconds:

1. Press <kbd>Win</kbd> + <kbd>I</kbd> to open **Windows Settings**.
2. Navigate to:  
   **Personalization** &gt; **Text input** &gt; **Customize Copilot key on keyboard**.
3. In the dropdown menu, select **Custom**.
4. Choose **Meta AI Co-Pilot Key App** from the list of recognized applications.
5. Press the physical Copilot key on your keyboard. **Meta AI** will open maximized and ready for your prompt!

---

## 🧠 Under The Hood: How It Works

```
[Physical Copilot Key Pressed]
             │
             ▼
[Windows 11 Bouncer Checks AppxManifest.xml]
 └─ Recognized via "com.microsoft.windows.copilotkeyprovider"
             │
             ▼
[MetaAICopilotKeyApp.exe Launched]
 ├─ 1. Release modifier keys via user32.dll (prevents sticky key bug)
 ├─ 2. Search for Edge / Chrome / Brave executable
 ├─ 3. Launch "--app=https://www.meta.ai" in borderless PWA mode
 ├─ 4. Window hunt for "Meta AI" window & maximize (SW_MAXIMIZE)
 └─ 5. Ghost exit (0 MB RAM residual)
```

1. **The Manifest Extension:**  
   Windows 11 only populates the Copilot key custom app dropdown with applications containing the `com.microsoft.windows.copilotkeyprovider` extension in their `AppxManifest.xml`.
2. **Ghost Process (.NET 8):**  
   The application is compiled as a self-contained, single-file Windows executable (`WinExe`). It contains no graphical interface of its own and closes immediately after starting the browser process.
3. **PWA Standalone Mode:**  
   Launching Chromium browsers with `--app=https://www.meta.ai` isolates the Meta AI interface from your standard browsing tabs and sessions.

---

## 🛠️ Building From Source

If you prefer to compile and package the application yourself:

### Prerequisites
- [.NET 8.0 SDK](https://dotnet.microsoft.com/download/dotnet/8.0)
- Windows 10/11 SDK (specifically `makeappx.exe` and `signtool.exe`)
- [Inno Setup 6 or 7](https://jrsoftware.org/isdl.php) (for compiling the single-click setup executable)
- PowerShell 5.1 or PowerShell 7+

### Build Steps
1. Clone the repository:
   ```powershell
   git clone https://github.com/NimanthaShyamin/Gemini-Copilot-Key-App.git
   cd Gemini-Copilot-Key-App/MetaAICopilotKeyApp
   ```
2. Run the automated PowerShell build script:
   ```powershell
   .\build.ps1
   ```
   * The script will:
     * Publish the self-contained .NET 8 application.
     * Copy the manifest and generate asset logos.
     * Generate a self-signed PFX certificate if one does not already exist.
     * Package the MSIX using `makeappx.exe`.
     * Sign the package with `signtool.exe`.
     * If Inno Setup is detected, compile `MetaAICopilot_Installer.exe` into the `Output` directory.

---

## 📋 Release Notes

### Version 3.0 (v3.0)
- **Pivoted to Meta AI:** Re-targeted launcher from Google Gemini to [Meta AI](https://www.meta.ai) following Google's official desktop app release.
- **Enhanced Window Hunting:** Implemented Win32 `EnumWindows` window enumeration with title search to reliably catch and maximize the Meta AI window across different Chromium browsers and title formats.
- **New Meta AI Branding:** Updated all application visual assets, Store logos, tile icons, and executable icons to the Meta AI gradient ring design.
- **Modern Inno Setup Script:** Updated `Inno SetupBuilder.iss` to automatically compile a single-click installer with embedded icon and silent certificate import.
- **Automated Certificate Generation:** Enhanced `build.ps1` to automatically create and export a valid self-signed signing certificate if absent.

---

## 🤝 Contributing & Feedback

Contributions, suggestions, and bug reports are welcome! Feel free to open an issue or submit a pull request.

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
