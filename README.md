![McAfee Remove MacOS](logo.png)

# McAfee Cleaner for Mac

Removes the following McAfee software from macOS and prevents it from being installed again:

* McAfee Threat Prevention for Mac
* McAfee Agent

## Project Goal & Design

Project aims at aiding users in complete removal of enterprise McAfee product from their system. 
Enterprise McAfee version has no option of being uninstalled while it continues to corrupt the system,
occupy significant CPU time, and cause wild crashes by misusing macOS's `logd` daemon.

The script also prevents listed McAfee products from being installed again.

**Tested on**: macOS Catalina 10.15.6

## Usage

Download `mcafee-cleaner.sh` script to your machine and run it with sudo rights:

```shell
sudo ./mcafee-cleaner.sh
```

Alternatively, if you trust the source of this script you can run it directly in the terminal:

```shell
sudo /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/vduseev/mcafee/master/mcafee-cleaner.sh)"
```

## Internals

It's a simple bash script that performs the following actions:

1. Removing McAfee
   1. Stopping McAfee services or daemons via `launchctl`
   1. Removing McAfee services using `launchctl`
   1. Killing all remaining McAfee processes using `pkill`
   1. Removing McAfee user and group from the system using `dscl`
   1. Removing directories where McAfee installs itself
   1. Removing McAfee files, such as configs, logs, and plists
   1. Unloading McAfee kernel extensions using `kextunload`
1. Preventing McAfee from installing itself again
   1. Recreate the directories where McAfee installs itself
   2. Make them immutable


## Disclaimer

This is a personal project not affiliated with any entity whatsoever with which I have been, am now, or will be affiliated.
Use the script on your own risk. No guarantees provided. 

