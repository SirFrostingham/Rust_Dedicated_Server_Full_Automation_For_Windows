# Installation

1. Run this to get the server running: 

    [!start_dedicated.cmd](Rust_Dedicated_Server_Full_Automation_For_Windows/!start_dedicated.cmd)

    NOTE: The server will post this to the game server log when the server is done loading:
        ```
        Server startup complete
        SteamServer Connected
        ```

2. Run this to automate steam game version checks, where if there's an update
    and there are 0 players online, the server automatically restarts:

    NOTE: Make sure the server is done loading before running this...  (see above ^^)

    [`!StartCheck-RustUpdates-loop.cmd`](Rust_Dedicated_Server_Full_Automation_For_Windows/!StartCheck-RustUpdates-loop.cmd)

3. Automate daily server restarts
    - NOT-recommended... Use Windows Task Scheduler (this thing is a piece of shit)
    - Recommend this process:
        - Run Packaged task runner made by ME
        - Run look for directory called: Runny
        - Run `runny.exe`
            - This leverages settings in scheduler.xml
            - This file can be configured any which direction.

4. Carbon Plugins (server-side)
    - https://carbonmod.gg/owners/modules/what-are-modules
        - Example Admin plugin
            - login to rcon
            - add yourself as admin -ex: `ownerid 76561197970982843`


5. Load Rust game (as a client / player)
    - If connecting to the server for the first time, the server will likely not be listed yet...
    - To connect: Press F1 (for console) -> `client.connect [your_ip_address]:28015`
        - NOTE: If you have a DNS, you can use that: `client.connect [your_dns_name]:28015`
    - Once in-game... If you did step #4 (add yourself as admin): Press F1 (for console) -> `cp`
        - `cp` command loads the admin interface
        - From here you can enable plugins/mods and HIGHLY configure your server.


# Configuration

## If coming from a previously running instance, search for `C:\` and adjust paths accordingly.

## Customization

- Review [!StartServer-RunEXE.cmd](Rust_Dedicated_Server_Full_Automation_For_Windows/!StartServer-RunEXE.cmd) and adjust starter server settings accordingly.
    
    - If you already have a server going, assign your server's identity to the value - ex: `set "IDENTITY=MyCoolServer"`

    - NOTE these IMPORTANT things to keep in-line with whatever instance you may already have...

        - Do a FIND & REPLACE with the settings you want...

            `server.seed 93526673`
            `server.worldsize 3000`

- CRITICAL: If coming from an already existing world, make sure the "[your_server_name]" from path .\live\config\server\[your_server_name]\cfg\server.cfg matches exactly what's defined for `IDENTITY` in [!StartServer-RunEXE.cmd](Rust_Dedicated_Server_Full_Automation_For_Windows/!StartServer-RunEXE.cmd

That should cover most things... There may be more gotchas, but hey... this is FREE game server automation sent out for your enjoyment. So yeah... Enjoy! ;-)
