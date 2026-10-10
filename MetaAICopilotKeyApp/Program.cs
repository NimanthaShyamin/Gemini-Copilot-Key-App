using System;
using System.Diagnostics;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

namespace MetaAICopilotKeyApp
{
    class Program
    {
        // 1. Keyboard Release APIs
        [DllImport("user32.dll", SetLastError = true)]
        static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, UIntPtr dwExtraInfo);

        // 2. Window Manipulation APIs
        [DllImport("user32.dll", SetLastError = true)]
        static extern IntPtr FindWindow(string? lpClassName, string? lpWindowName);

        [DllImport("user32.dll")]
        static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll", SetLastError = true)]
        static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
        static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

        [DllImport("user32.dll")]
        static extern bool IsWindowVisible(IntPtr hWnd);

        delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

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
            // FORCE KEYBOARD RELEASE (Fixes sticky modifier keys when launched by Copilot key)
            byte[] keysToRelease = { VK_LWIN, VK_RWIN, VK_SHIFT, VK_LSHIFT, VK_RSHIFT, VK_CONTROL, VK_LCONTROL, VK_RCONTROL, VK_MENU, VK_LMENU, VK_RMENU };
            foreach (byte key in keysToRelease)
            {
                keybd_event(key, 0, KEYEVENTF_KEYUP, UIntPtr.Zero);
            }

            // TARGET URL: Meta AI
            string targetUrl = "https://www.meta.ai";
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

            // Universal fallback if browser executable not found in PATH
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
                    launched = true;
                }
                catch (Exception) {}
            }

            // FORCE WINDOW MAXIMIZE
            if (launched)
            {
                IntPtr hWnd = IntPtr.Zero;

                // The browser takes time to load the page and set the title.
                // We will check every 500 milliseconds (for up to 6 seconds).
                for (int i = 0; i < 12; i++)
                {
                    Thread.Sleep(500);

                    // 1. Direct title check
                    hWnd = FindWindow(null, "Meta AI");

                    // 2. Fallback window hunting: search any visible window containing "Meta AI"
                    if (hWnd == IntPtr.Zero)
                    {
                        EnumWindows((h, l) =>
                        {
                            if (IsWindowVisible(h))
                            {
                                var sb = new StringBuilder(256);
                                GetWindowText(h, sb, 256);
                                string title = sb.ToString();
                                if (!string.IsNullOrEmpty(title) && title.IndexOf("Meta AI", StringComparison.OrdinalIgnoreCase) >= 0)
                                {
                                    hWnd = h;
                                    return false; // Stop hunting
                                }
                            }
                            return true; // Continue hunting
                        }, IntPtr.Zero);
                    }

                    // If found, maximize and exit
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