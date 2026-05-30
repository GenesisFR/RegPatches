# RegPatches

A collection of registry patches to allow launchers, tools and addons to locate the installation path of a game.

The following games are supported:

- Beyond Good and Evil
- Dungeon Siege 1 (with Legends of Aranna)
- Dungeon Siege 2 (with Broken World)

# Limitations

Not all of the available options will work on older systems, for example Controlled Folder Access is not relevant before Windows 10.

I left all of them available at the selection menu on Windows otherwise it would be a nightmare to display just the ones that are supported for each version of Windows.

# Issues fixed

## A PRM.PRM file is required for this application

<img width="578" height="157" alt="geomatica error" src="https://github.com/user-attachments/assets/5f0ba2be-73d4-4a58-81bd-379c4837fec8" />

If you get this error after making a choice in the selection menu, uninstall Geomatica as it seems to interfere with batch files.

## The scripts don't work on Windows 2000/XP

They rely on some commands like `bitsadmin`, `choice`, `curl` and `mklink`, which are not available by default on Windows 2000/XP.

- `bitsadmin` can be obtained by installing the [Support Tools for Windows XP](https://www.majorgeeks.com/files/details/microsoft_windows_xp_service_pack_2_support_tools.html), however I couldn't get the command to work (probably due to an outdated/unsupported protocol), so the script will offer to open this repository instead when trying to update if both `bitsadmin` and `curl` failed or aren't installed.
- `choice` is included in this repository as it's hard to find online. Download it and place it next to the script.
- `curl` v7.80 can be obtained from the [Wayback Machine](https://web.archive.org/web/20211208160135/https://curl.se/windows). Download it and place both `curl.exe` and `curl-ca-bundle.crt` next to the script.
- `mklink` doesn't exist, therefore [junction](https://learn.microsoft.com/en-us/sysinternals/downloads/junction) (a tool from Sysinternals) is used instead.
