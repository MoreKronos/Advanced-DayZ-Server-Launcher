import os
import shutil
import sys

# Get the directory of the script
script_dir = os.path.dirname(os.path.realpath(__file__))

# Ensure the keys folder exists
keys_dir = os.path.join(script_dir, "keys")
if not os.path.exists(keys_dir):
    os.makedirs(keys_dir)

# Clear the screen
os.system('cls' if os.name == 'nt' else 'clear')

# Prompt user to add all mods to mods.cfg
print("Mods found.\n")
print("In your launcher.bat script, you will find a line like this: \"-mod=@mod1;@mod2;@mod3\"")
print("Replace \"-mod=\" with the contents of mods.cfg.\n")

add_mods = input("Do you want this script to setup everything required for mods? (Y/N): ")

# Clear all text in the mods.cfg file
open(os.path.join(script_dir, "mods.cfg"), 'w').close()

# Validate user input
while True:
    if add_mods.upper() == 'Y':
        # Search for .bikey files in nested "put-mods-here" folders and copy them to keys folder
        print("\nCopying .bikey files to keys folder...")
        for root, _, files in os.walk(os.path.join(script_dir, "put-mods-here")):
            for file in files:
                if file.endswith('.bikey'):
                    print(f"Copying {file} to keys folder...")
                    shutil.copy2(os.path.join(root, file), keys_dir)
        
        # Loop through each subfolder in put-mods-here and construct the mods variable
        for folder in os.listdir(os.path.join(script_dir, "put-mods-here")):
            if os.path.isdir(os.path.join(script_dir, "put-mods-here", folder)):
                # Write folder names to mods.cfg
                with open(os.path.join(script_dir, "mods.cfg"), 'a') as mods_file:
                    mods_file.write(folder + '\n')
                
                # Move mod folders to the server's root directory
                print(f"Moving folder {folder} to server root...")
                shutil.move(os.path.join(script_dir, "put-mods-here", folder), script_dir)

        # Create marker file to prevent mods setup prompt on next launch
        with open(os.path.join(script_dir, "setup_mods_marker.txt"), 'w') as marker_file:
            marker_file.write("This file prevents the mods setup prompt from appearing on the next launch.")

        break

    elif add_mods.upper() == 'N':
        add_mods = input("Do you want this script to setup everything required for mods? (Y/N): ")
    
    else:
        print("Error: Invalid choice. Please enter either Y or N.\n")
        add_mods = input("Do you want this script to setup everything required for mods? (Y/N): ")

# Display mods written to mods.cfg (optional)
print("\nMods written to mods.cfg:")
with open(os.path.join(script_dir, "mods.cfg"), 'r') as mods_file:
    print(mods_file.read())

print("\nMods and .bikey files processed successfully.")
print("Setup complete.\n")

# Pause at the end of the script and exit
input("Press Enter to continue...")
sys.exit()  # Add this line to exit the script after user input
