# Gemini Co-Pilot Key App

A lightweight, background Windows application designed to remap the physical Windows 11 Copilot key to launch Google Gemini instead of Microsoft Copilot.

**Author:** Nimantha
**Created:** March 26, 2026

> **Context & Timestamp Note:** > This application was custom-built in March 2026. At the time of creation, Windows 11 heavily restricted the physical Copilot keyboard key, only allowing it to open specific Microsoft-approved applications. This project was engineered as a workaround to give users the freedom to launch Google Gemini. If Microsoft releases an official update in the future that allows native web-links or unapproved apps to be mapped to this key, this workaround may no longer be necessary—but for now, it bridges the gap!

## 💡 Why I Created This
I wanted the physical Copilot key on my keyboard to open my preferred AI assistant, Google Gemini. Because Windows Settings does not allow you to simply map the key to a website URL or a standard shortcut, I needed to build a fully packaged, recognized Windows Application (MSIX) to trick the operating system into allowing the switch.

## ⚙️ The Logic: How It Works
This project uses a combination of C# .NET, Windows App SDK packaging, and automated PowerShell scripts to achieve its goal.

1. **The Ghost Application (.NET 8 C#):**
   The core of the app is a minimal, invisible background process. It does not load a graphical interface or a console window. Its only job is to execute a launch command and immediately close itself so it uses zero background RAM.

2. **Smart PWA Fallback Launcher:**
   Windows does not have a universal command to open a website as a standalone App (PWA). To make Gemini look and feel like a native Windows app, the C# code runs a "Smart Fallback" loop:
   * It first searches the computer for Edge, Chrome, and Brave.
   * If it finds one, it launches Gemini using the `--app=https://gemini.google.com` argument to hide browser toolbars and tabs.
   * If no compatible browser is found, it safely falls back to opening a standard web tab, ensuring the app never crashes.

3. **Bypassing the Windows Bouncer (XML Manifest):**
   To make Windows 11 show this app in the "Text Input > Copilot Key" settings menu, the app must be packaged as an MSIX with a very specific secret ID. The `AppxManifest.xml` file is injected with the `com.microsoft.windows.copilotkeyprovider` extension, which acts as a VIP pass to get onto the official Windows Settings list.

4. **Automated Deployment:**
   Because MSIX apps must be digitally signed to be installed, the repository includes a `build.ps1` script to dynamically locate Windows SDK tools, compile the C# code, generate dummy assets, pack the MSIX, and sign it with a local certificate. A secondary `Install.bat` script is used to securely bypass PowerShell execution policies and install the certificate to the user's Trusted Root vault in one click.

## 🚀 Installation
1. Download the latest release `.zip` file.
2. Extract the folder.
3. Run `Install.bat` as Administrator to automatically trust the local certificate and launch the MSIX installer.
4. Go to **Windows Settings > Personalization > Text input > Customize Copilot key** and select "Gemini Co-Pilot Key App" from the dropdown.
