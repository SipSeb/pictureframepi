# A picture frame on Raspberry Pi

## Goal of the project

Even though, it looks like the time for picture frames is over, I still like the concept. We have thousands of pictures on our phones and hard drives, and most of those pictures never make their way out of our devices. With a picture frame, showing our favorite pictures, we can re-live some of our favorite moments, can be with our dearest friends and family. The frame surprises us with a new picture every couple of minutes.

There are ready-to-buy solutions on the market. However, I did not find one product giving me the flexibility I wanted. My requirements were:

* online-ready
* no cloud - at least not some closed vendor cloud
* fetch new pictures from a regular mail box
* store the pictures locally on the frame after downloading
* have a way to manage the files on the frame
* lightweight, if possible without an X setup or Kodi or whatever (fb to the rescue!)

So if you want to share some memories or your life with Grandma or your parents, this project might be for you.

## Requirements

* You need a pre-installed Raspberry Pi. The ruby IMAP module needs at least Bullseye, otherwise you might get SSL errors when connecting.
* Best to have your ssh key installed, so you don't need to supply the password.
* Mails are fetched via IMAP, so IMAP access to a mailbox is necessary.
* Ansible is needed for installation. No special modules needed.

### Gmail considerations

There is no Google authentication procedure built in. So if you want to use this with Gmail, there are two ways:

1. Enable support for "less secure apps". This works only, if you haven't enabled 2 factor authentication.
2. If 2 factor authentication is enabled, you need to generate an app password. This is done in the account settings, in the 2FA submenu.

## Installation
1. Copy `examples/inventory` to the main project folder and enter the target machine.
2. Copy `examples/pictureframepi.yml` to the `group_vars` folder and configure your frame. Parameters are explained in the example file.
3. There is a sample welcome picture included, which gets displayed while the slideshow is being generated. You can customize it by replacing the `welcome.jpg` file in the base directory.
4. Then run ansible: `ansible -i inventory setup_frame.yml`

## Important files on the raspberry pi
* A lot of stuff is configurable. All data (pictures), however, is placed inside the pi user's home dir.
* The pictures that get downloaded from IMAP, are placed inside `/home/pi/Pictures`.
* The slideshow works with a copy of those files, placed inside `/home/pi/Slideshow`.

## System update

* I tried updating the system from Buster to Bullseye with an `apt dist-upgrade`, but that resulted in a totally broken system. So I suggest to just reinstall it.
* Backup the folders `/home/pi/Pictures` and `/home/pi/Slideshow`.
* Do a fresh install of the system, configure networking and everything.
* Restore the two folders. If you want to keep timestamps and use `scp` for transferring the files, the `-p` option is your friend.
* Then re-run the pipeline. The slideshow is set up again.