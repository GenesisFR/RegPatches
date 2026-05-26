# RegPatches

A collection of registry patches to allow launchers, tools and addons to locate the installation path of a game.

The following games are supported:

- Beyond Good and Evil
- Dungeon Siege 1 (with Legends of Aranna)
- Dungeon Siege 2 (with Broken World)

# Issues fixed

## A PRM.PRM file is required for this application

If you get this [error](https://prnt.sc/116q0db) after making a choice in the selection menu, uninstall Geomatica as it seems to interfere with batch files.

## The scripts don't work on Windows XP

The scripts rely on some commands like `choice` and `bitsadmin`. Making them work without them would require a lot of additional code and would be prone to errors.

If they're missing from your system, you can add them by installing the [Support Tools](https://www.majorgeeks.com/files/details/microsoft_windows_xp_service_pack_2_support_tools.html) for Windows XP.
