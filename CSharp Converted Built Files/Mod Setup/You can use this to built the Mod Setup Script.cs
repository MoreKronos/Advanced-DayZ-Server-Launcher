using System;
using System.IO;
using System.Linq;

class Program
{
    static void Main(string[] args)
    {
        // Set server location to the directory of this script
        string scriptDir = AppDomain.CurrentDomain.BaseDirectory;

        // Initialize mods variable
        string mods = "";

        // Ensure the keys folder exists
        string keysDir = Path.Combine(scriptDir, "keys");
        if (!Directory.Exists(keysDir))
        {
            Directory.CreateDirectory(keysDir);
        }

        // Clear screen
        Console.Clear();

        // Prompt user to add all mods to mods.cfg
        Console.WriteLine("Mods found.");
        bool addMods = PromptUserForModSetup();

        // Clear all text in the mods.cfg file
        string modsCfgPath = Path.Combine(scriptDir, "mods.cfg");
        File.WriteAllText(modsCfgPath, string.Empty);

        if (addMods)
        {
            // Search for .bikey files in nested "put-mods-here" folders and copy them to "keys"
            Console.WriteLine("Copying .bikey files to keys folder...");
            foreach (string bikeyFile in Directory.GetFiles(Path.Combine(scriptDir, "put-mods-here"), "*.bikey", SearchOption.AllDirectories))
            {
                Console.WriteLine($"Copying {Path.GetFileName(bikeyFile)} to keys folder...");
                File.Copy(bikeyFile, Path.Combine(keysDir, Path.GetFileName(bikeyFile)), overwrite: true);
            }

            // Loop through each subfolder in put-mods-here and construct the mods variable
            foreach (string modDir in Directory.GetDirectories(Path.Combine(scriptDir, "put-mods-here")))
            {
                string modName = Path.GetFileName(modDir);

                // Write folder names to mods.cfg
                File.AppendAllText(modsCfgPath, modName + Environment.NewLine);

                // Move mod folders to the server's root directory
                Console.WriteLine($"Moving folder {modName} to server root...");
                Directory.Move(modDir, Path.Combine(scriptDir, modName));
            }

            // Create a marker file to prevent the setup prompt from appearing on the next launch
            File.WriteAllText(Path.Combine(scriptDir, "setup_mods_marker.txt"), "This file prevents the mods setup prompt from appearing on the next launch.");

        }
        else
        {
            Main(args); // Re-run the prompt if the user chooses 'N'
        }

        // Display mods variable for verification (optional)
        Console.WriteLine();
        Console.WriteLine("Mods written to mods.cfg:");
        Console.WriteLine(File.ReadAllText(modsCfgPath));

        Console.WriteLine();
        Console.WriteLine("Mods and .bikey files processed successfully.");
        Console.WriteLine("Setup complete.");
        Console.WriteLine();

        // Pause at the end of the script and exit
        Console.WriteLine("Press any key to continue.");
        Console.ReadKey();
    }

    static bool PromptUserForModSetup()
    {
        while (true)
        {
            Console.WriteLine();
            Console.WriteLine("In your launcher.bat script, you will find a line like this: \"-mod=@mod1;@mod2;@mod3\"");
            Console.WriteLine("Replace \"-mod=\" with the contents of mods.cfg.");
            Console.WriteLine();
            Console.Write("Do you want this script to setup everything required for mods? (Y/N): ");

            string input = Console.ReadLine().Trim().ToUpper();
            if (input == "Y") return true;
            if (input == "N") return false;

            // Invalid choice handling
            Console.WriteLine("Error: Invalid choice. Please enter either Y or N.");
            System.Threading.Thread.Sleep(5000); // Pause for 5 seconds
        }
    }
}
