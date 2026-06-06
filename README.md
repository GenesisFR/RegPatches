# RegPatches

A collection of registry patches to allow launchers, tools and addons to locate the installation path of a game.

# Supported games

- Beyond Good and Evil
- Dungeon Siege 1 (with Legends of Aranna)
- Dungeon Siege 2 (with Broken World)

# Supported operating systems

- Linux* (via Proton/Wine)
- Windows 2000**/ XP** / Server 2003**
- Windows Vista* / Windows Server 2008*
- Windows 7* / Windows Server 2008 R2*
- Windows 8* / Windows Server 2012*
- Windows 8.1* / Windows Server 2012 R2*
- Windows 10 / Windows Server 2016/2019/2022
- Windows 11

\* Requires `curl` to allow all features to work.  
\** Requires `choice`, `curl` and `junction` to allow all features to work.

# Requirements

**Mandatory**

- `choice` for user input (included since Windows Vista and in Wine)

**Optional**

- `bitsadmin` for downloading files, as a fallback (included since Windows Vista)
- [curl](https://curl.se/windows) for downloading files (included since Windows 10 1803)
- `mklink` for making directory junctions (included since Windows Vista)
- **Powershell 2.0+** for downloading files, as a fallback (included since Windows 7)

# Issues fixed

## A PRM.PRM file is required for this application

<img width="578" height="157" alt="geomatica error" src="https://github.com/user-attachments/assets/5f0ba2be-73d4-4a58-81bd-379c4837fec8" />

If you get this error after making a choice in the selection menu, uninstall Geomatica as it seems to interfere with batch files.

## The scripts don't work on Windows 2000/XP/Server 2003

They rely on some commands like `bitsadmin`, `choice`, `curl` and `mklink`, which are not available by default on these versions of Windows:

- `bitsadmin` can be obtained by installing the [Support Tools for Windows XP](https://www.majorgeeks.com/files/details/microsoft_windows_xp_service_pack_2_support_tools.html), however I couldn't get the command to work (probably due to an outdated/unsupported protocol), so you should install `curl` instead (see below).
- `choice` can be obtained from [here](https://www.allbootdisks.com/disk_contents/dos.html) (under `MS-DOS 6.21`). If you don't trust downloading programs from unofficial sources, you can also run the reg patch with the `-c #` (where `#` is a number) command-line argument, which will bypass the selection menu and execute the corresponding option.
- `curl` v7.80 can be obtained from the [Wayback Machine](https://web.archive.org/web/20211208160135/https://curl.se/windows).
- `mklink` doesn't exist, therefore [junction](https://learn.microsoft.com/en-us/sysinternals/downloads/junction) (a tool from Sysinternals) is used instead.

They're also available from the [XP](https://github.com/GenesisFR/RegPatches/tree/master/XP) folder, for your convenience. Download and place them next to the script (for `curl`, `curl-ca-bundle.crt` must be present as well).
