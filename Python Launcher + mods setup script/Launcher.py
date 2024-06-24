import os
import shutil
import time
import subprocess
from datetime import datetime

def log_message(log_file, message):
    with open(log_file, 'a') as log:
        log.write(f"[{datetime.now()}] {message}\n")

def delete_if_exists(path):
    if os.path.exists(path):
        os.remove(path)

def remove_dir_if_exists(path):
    if os.path.exists(path):
        shutil.rmtree(path)

def create_dir_if_not_exists(path):
    if not os.path.exists(path):
        os.makedirs(path)

def move_file(src, dst):
    if os.path.exists(src):
        shutil.move(src, dst)

def main():
    script_dir = os.path.dirname(os.path.abspath(__file__))
    server_location = script_dir
    log_file = os.path.join(server_location, "logs", "server.log")
    setup_log_file = os.path.join(server_location, "logs", "setup.log")
    marker_file = os.path.join(server_location, "setup_marker.txt")
    server_exe = os.path.join(server_location, "DayZServer_x64.exe")

    delete_if_exists(log_file)

    if not os.path.exists(server_exe):
        print("Error: DayZServer_x64.exe not found in the same directory as this script.")
        input("Press any key to exit...")
        return

    if os.path.exists(marker_file):
        configure_server(server_location, log_file)
    else:
        if input("Would you like this script to set up your DayZ server? (Y/N): ").strip().lower() == 'y':
            setup_server(server_location, setup_log_file)
        else:
            log_message(setup_log_file, "User chose to decline setup")
            create_marker_file(marker_file, setup_log_file)
            configure_server(server_location, log_file)

def setup_server(server_location, setup_log_file):
    print("Setting up DayZ Server configuration...")
    remove_dir_if_exists(os.path.join(server_location, "logs"))
    remove_dir_if_exists(os.path.join(server_location, "profiles"))
    remove_dir_if_exists(os.path.join(server_location, "keys"))
    remove_dir_if_exists(os.path.join(server_location, "server_profile"))
    remove_dir_if_exists(os.path.join(server_location, "config"))

    create_dir_if_not_exists(os.path.join(server_location, "logs"))
    log_message(setup_log_file, "Created logs folder")

    create_dir_if_not_exists(os.path.join(server_location, "profiles"))
    log_message(setup_log_file, "Created profiles folder")

    create_dir_if_not_exists(os.path.join(server_location, "mods"))
    log_message(setup_log_file, "Created mods folder")

    create_dir_if_not_exists(os.path.join(server_location, "keys"))
    log_message(setup_log_file, "Created keys folder")

    create_dir_if_not_exists(os.path.join(server_location, "server_profile"))
    log_message(setup_log_file, "Created server_profile folder")

    move_file(os.path.join(server_location, "serverDZ.cfg"), os.path.join(server_location, "server_profile", "serverDZ.cfg"))
    log_message(setup_log_file, "Moved serverDZ.cfg to server_profile")

    create_marker_file(os.path.join(server_location, "setup_marker.txt"), setup_log_file)
    configure_server(server_location, os.path.join(server_location, "logs", "server.log"))

def create_marker_file(marker_file, setup_log_file):
    with open(marker_file, 'w') as marker:
        marker.write(f"[{datetime.now()}] Setup complete\n")
        marker.write("DO NOT DELETE THIS FILE\n")
        marker.write("This file stops you from seeing the setup every time on launch\n")
    log_message(setup_log_file, "Setup complete")

def configure_server(server_location, log_file):
    server_name = input("Enter server name: ").strip()
    while not server_name:
        print("Error: Server name cannot be empty.")
        time.sleep(5)
        server_name = input("Enter server name: ").strip()

    log_message(log_file, f"Server name set to: {server_name}")

    server_port = input("Enter server port (press Enter to use the default port = 2302): ").strip() or "2302"
    log_message(log_file, f"Server port set to: {server_port}")

    server_cpu = input("Enter CPU count (press Enter to use the default CPU count = 2): ").strip() or "2"
    log_message(log_file, f"CPU count set to: {server_cpu}")

    restart_hours = input("Enter restart time (from 1 to 24 hours): ").strip()
    while not (restart_hours.isdigit() and 1 <= int(restart_hours) <= 24):
        print("Error: Invalid restart time format or out of range. Please enter a value from 1 to 24 hours.")
        time.sleep(5)
        restart_hours = input("Enter restart time (from 1 to 24 hours): ").strip()

    restart_hours = int(restart_hours)
    server_restart_log = f"{restart_hours} hour" if restart_hours == 1 else f"{restart_hours} hours"
    log_message(log_file, f"Restart time set to: {server_restart_log}")

    user_location_input = input(f"Enter server location (press Enter to use found directory = {server_location}): ").strip()
    if user_location_input:
        if os.path.exists(user_location_input):
            server_location = user_location_input
            log_message(log_file, f"Server location set to: {server_location}")
        else:
            print(f"Error: Directory '{user_location_input}' not found. Please enter a valid directory.")
            time.sleep(5)
            configure_server(server_location, log_file)
            return
    else:
        log_message(log_file, f"Server location set to: {server_location}")

    mods_dir = os.path.join(server_location, "mods")
    if os.path.exists(mods_dir) and any(os.path.isdir(os.path.join(mods_dir, i)) for i in os.listdir(mods_dir)):
        configure_mods(server_location, log_file)
    else:
        log_message(log_file, "No mods found inside mods folder. Skipping serverMods.")

    if input("Do you want to reconfigure the settings? (Y/N): ").strip().lower() == 'y':
        configure_server(server_location, log_file)
    else:
        log_message(log_file, "User chose not to reconfigure settings.")
        start_server_prompt(server_location, server_name, server_port, server_cpu, restart_hours, log_file)

def configure_mods(server_location, log_file):
    mods_cfg = os.path.join(server_location, "mods.cfg")
    open(mods_cfg, 'w').close()  # Clear the file

    if input("Do you want to add all mods to mods.cfg and all .bikey files to Keys folder? (Y/N): ").strip().lower() == 'y':
        mods_dir = os.path.join(server_location, "mods")
        with open(mods_cfg, 'w') as mods_file:
            for item in os.listdir(mods_dir):
                if os.path.isdir(os.path.join(mods_dir, item)):
                    mods_file.write(item + "\n")

        log_message(log_file, "Successfully added all mods to mods.cfg and Keys folder")
        copy_files(mods_dir, os.path.join(server_location, "keys"))
    else:
        log_message(log_file, "User chose not to add all mods to mods.cfg and Keys folder")

def start_server_prompt(server_location, server_name, server_port, server_cpu, restart_hours, log_file):
    if input(f"Are you sure you want to start {server_name} Dayz Server? (Y/N): ").strip().lower() == 'y':
        log_message(log_file, "User chose to start the server.")
        start_server(server_location, server_name, server_port, server_cpu, restart_hours, log_file)
    else:
        log_message(log_file, "User chose to abort server startup.")
        exit_launcher(log_file)

def start_server(server_location, server_name, server_port, server_cpu, restart_hours, log_file):
    print(f"Starting {server_name} DayZ server...")
    log_message(log_file, f"{server_name} Server started")

    mods_cfg = os.path.join(server_location, "mods.cfg")
    if os.path.exists(mods_cfg):
        with open(mods_cfg) as mods_file:
            print("Mods currently loaded:")
            print("------------------------")
            print(mods_file.read())
    else:
        print("No mods found/enabled.")
    print("------------------------")

    subprocess.run(["taskkill", "/f", "/im", "DayZServer_x64.exe"], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)

    subprocess.run([
        "start", "DayZ Server", "/min", "DayZServer_x64.exe",
        f"-profiles=profiles", f"-mod={mods_cfg}", f"-config=server_profile/serverDZ.cfg",
        f"-port={server_port}", f"-cpuCount={server_cpu}", "-dologs", "-adminlog", "-netlog", "-freezecheck"
    ], shell=True)

    time.sleep(restart_hours * 3600)

    subprocess.run(["taskkill", "/im", "DayZServer_x64.exe", "/F"], stdout=subprocess.DEVNULL, stderr=subprocess.STDOUT)
    log_message(log_file, "DayZ Server stopped")
    start_server(server_location, server_name, server_port, server_cpu, restart_hours, log_file)

def exit_launcher(log_file):
    log_message(log_file, "Exiting launcher")
    print("Exiting launcher...")
    time.sleep(3)
    exit()

if __name__ == "__main__":
    main()
