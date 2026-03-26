using System;
using System.Diagnostics;
using System.ComponentModel;

namespace GeminiCopilotKeyApp
{
    class Program
    {
        static void Main(string[] args)
        {
            string targetUrl = "https://gemini.google.com";
            string appArg = $"--app={targetUrl}";

            // List of Chromium-based browsers that support the --app argument
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
                        UseShellExecute = true,
                        WindowStyle = ProcessWindowStyle.Normal
                    };
                    
                    Process.Start(psi);
                    launched = true;
                    break; // Successfully launched, break out of the loop
                }
                catch (Win32Exception)
                {
                    // Browser executable not found in PATH/App Paths. Try the next one.
                    continue;
                }
            }

            // Smart Fallback
            if (!launched)
            {
                try
                {
                    // Letting UseShellExecute = true with a URL opens the default system browser
                    ProcessStartInfo fallbackPsi = new ProcessStartInfo
                    {
                        FileName = targetUrl,
                        UseShellExecute = true
                    };
                    Process.Start(fallbackPsi);
                }
                catch (Exception)
                {
                    // Since this is a silent background app, we intentionally swallow exceptions 
                    // here so no crash dialogs appear to the user.
                }
            }
        }
    }
}
