using System;
using System.Diagnostics;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Threading; // Added for the delay timer

namespace GeminiCopilotKeyApp
{
    class Program
    {
        // 1. Keyboard Release APIs
        [DllImport("user32.dll", SetLastError = true)]
        static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

        // 2. Window Manipulation APIs
        [DllImport("user32.dll", SetLastError = true)]
        static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

        [DllImport("user32.dll")]
        static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        const uint KEYEVENTF_KEYUP = 0x0002;
        const int SW_MAXIMIZE = 3; // The Windows command to maximize a window
        
        // Virtual Key Codes for Modifier Keys
        const byte VK_LSHIFT = 0xA0;
        const byte VK_RSHIFT = 0xA1;
        const byte VK_LCONTROL = 0xA2;
        const byte VK_RCONTROL = 0xA3;
        const byte VK_LMENU = 0xA4; 
        const byte VK_RMENU = 0xA5; 
        const byte VK_LWIN = 0x5B;
        const byte VK_RWIN = 0x5C;
        const byte VK_SHIFT = 0x10;
        const byte VK_CONTROL = 0x11;
        const byte VK_MENU = 0x12;

        static void Main(string[] args)
        {
            // FORCE KEYBOARD RELEASE
            byte[] keysToRelease = { VK_LWIN, VK_RWIN, VK_SHIFT, VK_LSHIFT, VK_RSHIFT, VK_CONTROL, VK_LCONTROL, VK_RCONTROL, VK_MENU, VK_LMENU, VK_RMENU };
            foreach (byte key in keysToRelease)
            {
                keybd_event(key, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
            }

            // USE THE UNIVERSAL URL METHOD
            string targetUrl = "https://gemini.google.com";
            string appArg = $"--app={targetUrl}";

            string[] browsers = { "msedge.exe", "chrome.exe", "brave.exe" };
            bool launched = false;

            foreach (string browser in browsers)
            {
                try
                {
                    ProcessStartInfo psi = new ProcessStartInfo
                    {
                        FileName = browser,
                        Arguments = appArg,
                        UseShellExecute = true
                    };
                    
                    Process.Start(psi);
                    launched = true;
                    break; 
                }
                catch (Win32Exception)
                {
                    continue;
                }
            }

            if (!launched)
            {
                try
                {
                    ProcessStartInfo fallbackPsi = new ProcessStartInfo
                    {
                        FileName = targetUrl,
                        UseShellExecute = true
                    };
                    Process.Start(fallbackPsi);
                }
                catch (Exception) {}
            }

            // FORCE WINDOW MAXIMIZE
            // FORCE WINDOW MAXIMIZE
            if (launched)
            {
                IntPtr hWnd = IntPtr.Zero;
                
                // The browser takes time to load the page and set the title.
                // We will check every 500 milliseconds (for up to 5 seconds).
                for (int i = 0; i < 10; i++)
                {
                    Thread.Sleep(500); // Wait half a second
                    
                    // Look for the window
                    hWnd = FindWindow(null, "Gemini");
                    
                    // If it didn't find "Gemini", sometimes Chrome names it "Google Gemini"
                    if (hWnd == IntPtr.Zero) 
                    {
                        hWnd = FindWindow(null, "Google Gemini");
                    }
                    
                    // If we found the window, maximize it and stop hunting!
                    if (hWnd != IntPtr.Zero)
                    {
                        ShowWindow(hWnd, SW_MAXIMIZE);
                        break; 
                    }
                }
            }
        }
    }
}