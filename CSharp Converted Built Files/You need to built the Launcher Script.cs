using System;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;

class DayZServerLauncher
{
    private static int serverPort;         // Server port
    private static int serverCPU;          // CPU count
    private static int restartHours;       // Restart time in hours
    private static string serverLocation;  // Server location
    private static string markerFile;      // Marker file path
    private static string serverName;      // Server name
    private static string serverExecutable; // Server executable path

    static void Main()
    {
        serverLocation = Path.GetDirectoryName(System.Reflection.Assembly.GetEntryAssembly().Location);

        // Check if DayZServer_x64.exe is present in the executable's directory
        serverExecutable = Path.Combine(serverLocation, "DayZServer_x64.exe");
        if (!File.Exists(serverExecutable))
        {
            Console.WriteLine("Error: DayZServer_x64.exe not found in the same directory as this executable.");
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
            return;
        }

        // Check if setup has already been performed by looking for a marker file
        markerFile = Path.Combine(serverLocation, "setup_marker.txt");
        if (File.Exists(markerFile))
        {
            Configuration();
        }
        else
        {
            AskForSetup();
        }
    }

    static void AskForSetup()
    {
        Console.Clear();
        Console.WriteLine("Do you want to perform the initial setup? (Y/N)");
        string setupInput = Console.ReadLine();
        if (setupInput != null && setupInput.Trim().ToUpper() == "Y")
        {
            DayZServerSetup();
            Configuration();
        }
        else if (setupInput != null && setupInput.Trim().ToUpper() == "N")
        {
            Configuration();
        }
        else
        {
            Console.WriteLine("Error: Invalid choice. Please select either 'Y' or 'N'.");
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
            AskForSetup();
        }
    }

    static void DayZServerSetup()
    {
        // Setup process to clean up directories and move configuration files
        Console.Clear();
        Console.WriteLine("Setting up DayZ Server configuration...");

        // Delete existing directories if found
        DeleteIfExists(Path.Combine(serverLocation, "logs"));
        DeleteIfExists(Path.Combine(serverLocation, "profiles"));
        DeleteIfExists(Path.Combine(serverLocation, "keys"));
        DeleteIfExists(Path.Combine(serverLocation, "server_profile"));
        DeleteIfExists(Path.Combine(serverLocation, "config"));

        Console.WriteLine("---");
        Console.WriteLine("Configuration cleanup completed");
        Console.WriteLine("---");
        Console.WriteLine("Press any key to continue...");
        Console.ReadKey();

        // Create necessary directories if not found
        CreateDirectoryIfNotExists(Path.Combine(serverLocation, "logs"));
        CreateDirectoryIfNotExists(Path.Combine(serverLocation, "profiles"));
        CreateDirectoryIfNotExists(Path.Combine(serverLocation, "mods"));
        CreateDirectoryIfNotExists(Path.Combine(serverLocation, "keys"));
        CreateDirectoryIfNotExists(Path.Combine(serverLocation, "server_profile"));

        // Move serverDZ.cfg to server_profile folder
        string sourceConfig = Path.Combine(serverLocation, "serverDZ.cfg");
        string destinationConfig = Path.Combine(serverLocation, "server_profile", "serverDZ.cfg");
        MoveFile(sourceConfig, destinationConfig);

        Console.WriteLine(":");
        Console.WriteLine("Press any key to continue...");
        Console.ReadKey();

        // Setup complete
        Console.Clear();
        Console.WriteLine("Setup complete.");

        // Create a marker file to indicate setup completion
        using (StreamWriter writer = File.CreateText(markerFile))
        {
            writer.WriteLine("Setup complete");
            writer.WriteLine("DO NOT DELETE THIS FILE");
            writer.WriteLine("This file stops you from seeing the setup every time on launch");
            writer.WriteLine("DayZ Server setup completed.");
        }

        Console.WriteLine("Press any key to continue...");
        Console.ReadKey();
    }

    static void Configuration()
    {
        // Configuration process to prompt for server details
        Console.Clear();
        Console.WriteLine("Configuration:");

        // Check if server.log exists and delete it
        string logFile = Path.Combine(serverLocation, "logs", "server.log");
        if (File.Exists(logFile))
        {
            File.Delete(logFile);
        }

        // Prompt user to enter server details
        Console.Write("Enter server name: ");
        serverName = Console.ReadLine();
        if (string.IsNullOrWhiteSpace(serverName))
        {
            Console.WriteLine("Error: Server name cannot be empty.");
            Console.WriteLine("Press any key to exit...");
            Console.ReadKey();
            return;
        }
        LogToFile(logFile, $"Server name set to: {serverName}");

        // Prompt user to enter server port
        Console.Write("Enter server port (press Enter to use the default port = 2302): ");
        string serverPortInput = Console.ReadLine();
        if (string.IsNullOrWhiteSpace(serverPortInput) || !int.TryParse(serverPortInput, out serverPort))
        {
            serverPort = 2302;
        }
        LogToFile(logFile, $"Server port set to: {serverPort}");

        // Prompt user to enter CPU count
        Console.Write("Enter CPU count (press Enter to use the default CPU count = 2): ");
        string serverCPUInput = Console.ReadLine();
        if (string.IsNullOrWhiteSpace(serverCPUInput) || !int.TryParse(serverCPUInput, out serverCPU))
        {
            serverCPU = 2;
        }
        LogToFile(logFile, $"CPU count set to: {serverCPU}");

        // Prompt user to enter restart time in hours and convert to seconds
        do
        {
            Console.Write("Enter restart time (from 1 to 24 hours): ");
        } while (!int.TryParse(Console.ReadLine(), out restartHours) || restartHours < 1 || restartHours > 24);

        int restartTimeInSeconds = restartHours * 3600; // Convert hours to seconds
        LogToFile(logFile, $"Restart time set to: {restartTimeInSeconds} seconds");

        // Prompt user to enter server location
        Console.Write($"Enter server location (press Enter to use found directory = {serverLocation}): ");
        string serverLocationInput = Console.ReadLine();
        if (!string.IsNullOrWhiteSpace(serverLocationInput) && Directory.Exists(serverLocationInput))
        {
            serverLocation = serverLocationInput;
            LogToFile(logFile, $"Server location set to: {serverLocation}");
        }

        // Proceed with server mods if mods directory exists
        string modsDirectory = Path.Combine(serverLocation, "mods");
        if (Directory.Exists(modsDirectory))
        {
            string[] modFolders = Directory.GetDirectories(modsDirectory);
            if (modFolders.Length > 0)
            {
                ServerMods();
            }
            else
            {
                LogToFile(logFile, "No mods found inside mods folder. Skipping serverMods.");
                Reconfiguration();
            }
        }
        else
        {
            LogToFile(logFile, "Mods folder not found. Skipping serverMods.");
            Reconfiguration();
        }
    }

    static void ServerMods()
    {
        // Server mods configuration to add mods to mods.cfg and .bikey files to keys folder
        Console.Clear();

        Console.WriteLine("Mods found.");

        // Prompt user to add all mods to mods.cfg
        Console.Write("Do you want to add all mods to mods.cfg and all .bikey files to Keys folder? (Y/N): ");
        string addModsInput = Console.ReadLine();
        if (addModsInput != null && addModsInput.Trim().ToUpper() == "Y")
        {
            // Create an empty mods.cfg file
            File.WriteAllText(Path.Combine(serverLocation, "mods.cfg"), "");

            // Loop through each subfolder in the mods directory and write folder names to mods.cfg
            foreach (string modFolder in Directory.GetDirectories(Path.Combine(serverLocation, "mods")))
            {
                string modFolderName = new DirectoryInfo(modFolder).Name;
                File.AppendAllText(Path.Combine(serverLocation, "mods.cfg"), $"{modFolderName}{Environment.NewLine}");
            }

            // Search for .bikey files in nested "mods" folders and copy them to "keys" folder
            foreach (string bikeyFile in Directory.GetFiles(Path.Combine(serverLocation, "mods"), "*.bikey", SearchOption.AllDirectories))
            {
                string bikeyFileName = Path.GetFileName(bikeyFile);
                string destinationBikey = Path.Combine(serverLocation, "keys", bikeyFileName);
                File.Copy(bikeyFile, destinationBikey, true);
            }

            LogToFile(Path.Combine(serverLocation, "logs", "server.log"), "Successfully added all mods to mods.cfg and Keys folder");
        }
        else if (addModsInput != null && addModsInput.Trim().ToUpper() == "N")
        {
            LogToFile(Path.Combine(serverLocation, "logs", "server.log"), "User chose not to add all mods to mods.cfg and Keys folder");
            Reconfiguration();
        }
        else
        {
            Console.WriteLine("Error: Invalid choice. Please enter either Y or N.");
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
            ServerMods();
        }

        Console.WriteLine("Press any key to continue...");
        Console.ReadKey();
        Reconfiguration();
    }

    static void Reconfiguration()
    {
        // Reconfiguration prompt to allow user to reconfigure settings
        Console.Clear();

        Console.WriteLine("Do you want to reconfigure the settings? (Y/N)");
        string reconfigureInput = Console.ReadLine();
        if (reconfigureInput != null && reconfigureInput.Trim().ToUpper() == "Y")
        {
            Configuration();
        }
        else if (reconfigureInput != null && reconfigureInput.Trim().ToUpper() == "N")
        {
            Console.WriteLine("User chose not to reconfigure settings.");
            StartServerPrompt();
        }
        else
        {
            Console.WriteLine("Error: Invalid choice. Please select either 'Y' or 'N'.");
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
            Reconfiguration();
        }
    }

    static void StartServerPrompt()
    {
        // Server start prompt to confirm server startup
        Console.Clear();

        Console.WriteLine("Are you sure you want to start DayZ Server? (Y/N)");
        string confirmInput = Console.ReadLine();
        if (confirmInput != null && confirmInput.Trim().ToUpper() == "Y")
        {
            StartServer();
        }
        else if (confirmInput != null && confirmInput.Trim().ToUpper() == "N")
        {
            Console.WriteLine("User chose to abort server startup.");
            return;
        }
        else
        {
            Console.WriteLine("Error: Invalid choice. Please select either 'Y' or 'N'.");
            Console.WriteLine("Press any key to continue...");
            Console.ReadKey();
            StartServerPrompt();
        }
    }

    static void StartServer()
    {
        // Start the DayZ server process with configured parameters
        Console.Clear();
        Console.WriteLine("Starting DayZ Server...");

        // Ensure serverExecutable is properly set
        string serverExecutable = Path.Combine(serverLocation, "DayZServer_x64.exe");

        // Example command to start DayZ server
        // Adjust the command line arguments based on your server configuration
        string arguments = $"-config=server_profile\\serverDZ.cfg -port={serverPort} -cpuCount={serverCPU} -name=\"{serverName}\" -dologs -filePatching -adminlog";

        Console.WriteLine($"Server command: {serverExecutable} {arguments}");

        try
        {
            // Start the server process
            ProcessStartInfo startInfo = new ProcessStartInfo();
            startInfo.FileName = serverExecutable; // Set the executable file name
            startInfo.Arguments = arguments;       // Pass the command line arguments
            startInfo.UseShellExecute = false;
            startInfo.RedirectStandardOutput = true;
            startInfo.RedirectStandardError = true;
            startInfo.CreateNoWindow = true;

            using (Process process = Process.Start(startInfo))
            {
                process.WaitForExit();
                Console.WriteLine("DayZ Server process exited.");
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error starting DayZ Server: {ex.Message}");
        }

        Console.WriteLine("Press any key to exit...");
        Console.ReadKey();
    }

    static void DeleteIfExists(string path)
    {
        // Delete directory if it exists
        if (Directory.Exists(path))
        {
            Directory.Delete(path, true);
        }
    }

    static void CreateDirectoryIfNotExists(string path)
    {
        // Create directory if it does not exist
        if (!Directory.Exists(path))
        {
            Directory.CreateDirectory(path);
        }
    }

    static void MoveFile(string sourceFile, string destFile)
    {
        // Move file from source to destination
        if (File.Exists(sourceFile))
        {
            File.Move(sourceFile, destFile);
        }
    }

    static void LogToFile(string logFile, string message)
    {
        // Log message to a file
        using (StreamWriter writer = File.AppendText(logFile))
        {
            writer.WriteLine($"{DateTime.Now} - {message}");
        }
    }
}
