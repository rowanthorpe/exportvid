What is Exportvid?
==================

Exportvid is a batch-script which exports most video files to a chosen platform/format, using ffmpeg - http://www.ffmpeg.org - which should be installed separately, and be able to be found in the %PATH%).
This project is under the GNU Affero General Public License version 3 or greater (http://www.gnu.org/licenses/agpl.html).

Installation & Usage:
=====================

* If not using the auto-installer, unzip the exportvid package and open its "bin" directory.

* Drag-n-drop any video file onto the exportvid.cmd file. By default this will transcode to a high-quality format suitable for uploading to vimeo, and will create a similarly named file in the same directory as the input, with the extension ".mp4". For changing default drag-n-drop behaviour, edit "exportvid.cmd" and follow the comments near the top.

* If you want to properly "install" this tool, then copy the exportvid folder to somewhere like: "C:\Program Files (x86)\exportvid" (probably needing admin permissions), then right-click-and-drag the "exportvid.cmd" onto the desktop, clicking "create a shortcut" when given the option. Then you can drag the files onto that shortcut in the same fashion as above.

* exportvid.cmd can of course be used from scripts. Enter "[path-to]\exportvid.cmd -h" at a command prompt for usage message.

Motivations
===========

I wanted to be able to quickly and effectively prepare high-quality video for certain platforms (particularly mobile and online) from any arbitrary Windoze machine I might happen to be stuck on at the time, without having to install various complex transcoding applications, for what is essentially a simple task of scripting input to ffmpeg.

Web site:
=========

 http://sourceforge.net/projects/exportvid
 
Please make bug reports, feature requests, nagging, and whatever to:

   Rowan Thorpe <rowan _at_ rowanthorpe [dot] com>

...but please understand that this is designed to a be a very small, simple and convenient drag-n-drop tool (& easy/quick to read, therefore easy to trust), so I am highly unlikely to implement many more "features" than it already has. I am most interested in bug reports, security patches and improved ffmpeg settings for video quality. If you want to make a bigger snazzier version of this feel free to start your own project with those different (yet valid) goals, or use one of the myriad large transcoding projects out there...
