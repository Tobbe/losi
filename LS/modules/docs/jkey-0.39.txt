_____________________________________________________
Notes for 0.39 (modded version by thegeek)
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
This version adds the following bangs:
!jKeyAdd
!jKeyRemove
!jKeyDisableAll
!jKeyEnableAll

The Add and Remove bangs use the exact same syntax as an ordinary hotkey line, and the disableall and enableall bangs are pretty self-explanatory;P
In the process of adding the mods I also restructured the code a little bit (split some of the functions into smaller ones).
In addition you can now use hex values as keys:
*Hotkey win 0x53 !recycle
The hexvalues are the exact same as in vk104.txt, so you can get them with scankey.exe

_____________________________________________________
Notes for 0.38 (or a small history, as you wish ;) )
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
When I installed Omar's LSInstaller 3.x, the jkey module started to
show me a strage message - 'Invalid <hotkey> - x. Error in definition'.
This message was not shown each time but randomly on a !Recycle.
Never used this module before, so it annoyed me, but I didn't want
to switch to the hotkey.dll module, because it doesn't work with the
multimedia keys :(
Today I spent some time and found that this message is showing because
jugg used VkKeyScan function, that relies on the current input
language. Litestep has the own process's keyboard layout, and sometimes
I switched it (LSXCommand forever! ;) ). But there is no Latin 'X' or
'W' letters in Cyrilic alphabet, so VkKeyScan failed.
I added only two lines of code (now it calls the VkKeyScanEx function
with U.S. English keyboard layout after VkKeyScan failed) and everything
works fine for me :)
Probably it will help somebody else :)



_______________________________
jkey.dll 0.37 Released 5-20-02
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Modded by: hollow (Eric Moore, hollow1@subdimension.com)
Originally by: Jugg

Modified and released as 0.38
by Sergey Gagarin a.k.a. Seg@ (mailto: inform-sega@freemail.ru)

_______________________________
New in 0.37:
¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯¯
Added modkey choice ".none", allowing single key hotkeys.  Mostly usefull for mapping to
extra keys found on enhanced keyboards.  You can specify "h" as a hotkey, but that would
make using the keyboard a little difficult. As far as i can tell, you cannot have custom
keyboard software installed to do this, scankey seems to return "FF" for all extra keys
then.  I do not know whether this is universally true, but on both computers I tried it
was.

_______________________________

Included below is the jkey 0.36 readme.


==================================================
===================================================
== jKey.dll - nice hotkeys ========================
===================================================
===================================================
====== Written by: ================================
================== Chris Rempel (jugg) ============
===================================================
================== http://jugg.logicpd.com/ =======
================== jugg@dylern.com ================
===================================================
===================================================
= Version: 0.36 = Release Date: 01.06.12 ==========
===================================================
===================================================

-=ToC=-
I. Introduction
II. Installation
III. Information
 A} Commands
 B} Changes
 C} Notes
IV. Tips & Tricks
V. Disclaimer


=====================
== I. Introduction ==
=====================
===================================================

jKey.dll is Hotkey manager for Win32 Shells. jKey
is based off the idea of LiteStep's Hotkey.dll, but
offers more features and configuration options with
less overhead.

======================
== II. Installation ==
======================
===================================================

Extract "jKey.dll" to your LiteStep directory
(c:\litestep\). Open up your step.rc (LiteStep
configuration file) and find the section where all
of your "LoadModule" lines are located. Remove any
"LoadModule" lines that are loading "hotkey.dll".
Now, add a new line that looks like this:

LoadModule c:\litestep\jkey.dll

Of course, adjust the path as necessary. Save your
step.rc and issue the LiteStep Recycle command
(!Recycle).

NOTE: If you are migrating from LiteSteps hotkey
module, and do not want to have to update all of
your "*Hotkey" lines, make sure to set the command
"jKeyUseHotkeyDef" in your configuration file. If
you don't, you have to change all instances of
"*Hotkey" to "*jKey" in your configuration file.


======================
== III. Information ==
======================
===================================================
= A} Commands =
===============

jKeyVKTable "vk104.txt"
  - Sets the Virtual Key code lookup table text
    file that jKey will reference for special key
    specifiers.

  - Accepts any valid formatted test file that
    contains a Virtual Keycode lookup table.

    Text file format:
    - One entry per line in the following format.

      <keyname> , <hexvalue>

      The <keyname> is a string value representing
      the virtual key code (<hexvalue>). <keyname>
      is used in the *jKey definition in place of
      <hotkey>.

      The <hexvalue> is the Virtual Key Code,
      represented in Hexidecimal format.

  - Defaults to: no default

jKeyLWinKey "!Popup"
  - Sets the command to be executed when the
    LEFT WinKey is pressed by itself.

    *Note: Command will be executed after the time
           specified by "jKeyLWinKeyTimeout"
           setting.

    *Note: "jKeyLWinKey" does not execute anything
           by default and so, must be set for it to
           execute anything.

  - Accepts any !Bang command or Executable.

  - Defaults to: no default


jKeyRWinKey "!Popup"
  - Sets the command to be executed when the
    RIGHT WinKey is pressed by itself.

    *Note: Command will be executed after the time
           specified by "jKeyRWinKeyTimeout"
           setting.

    *Note: "jKeyRWinKey" does not execute anything
           by default and so, must be set for it to
           execute anything.

  - Accepts any !Bang command or Executable.

  - Defaults to: no default


jKeyLWinKeyTimeout 750
  - Sets the delay from the time the LEFT WinKey is
    pressed to the time the command specified by
    "jKeyLWinKey" is executed.

  - Accepts any positive integer in milliseconds.

    *Note: Anything less the 400 will probably will
           cause things to behave erratically.

  - Defaults to: 750


jKeyRWinKeyTimeout 750
  - Sets the delay from the time the RIGHT WinKey
    is pressed to the time the command specified by
    "jKeyRWinKey" is executed.

  - Accepts any positive integer in milliseconds.

    *Note: Anything less the 400 will probably will
           cause things to behave erratically.

  - Defaults to: 750


jKeyNoWarn
  - If Set no warning will be issued when a hotkey
    fails to register correctly.

  - boolean value: true if set, otherwise false.


jKeyUseHotkeyDef
  - If Set the "*Hotkey" definition syntax will be
    used instead of the native "*jKey" definition.
    (See explanation of "*jKey")

  - boolean value: true if set, otherwise false.


*jKey
  - parameters: <modkey> <hotkey> <command>

    <modkey> can be one or more of the following
             seperated by a plus (+) sign. Spaces
             are not allowed.

      CTRL, SHIFT, WIN, ALT

    <hotkey> can be any alpha numeric key or an
             identifier listed in the
             "jKeyVKTable" lookup file if one is
             being used.

    <command> can be any !Bang command or
              executable that is to be executed
              when the specified key combination
              is pressed.

  - Multiple settings of this command are
    allowed and the maximum number is limited by
    system memory.

  - It is used to define the Hotkeys and the
    commands to be executed when the hotkey
    sequence is pressed.

    *Note: You can substitute "*Hotkey" for "*jKey"
           if you set the following command in your
           configuration file: "jKeyUseHotkeyDef"
     


===================================================
= B} Changes =
==============
(+)Added
(-)Removed
(*)Changed
(!)Fixed
(^)MiscNote

- 0.36 -
--------
  ! Fixed lower case hotkeys from not working.
  ! Fixed non alpha-numeric keys from not working.
  
  * Changed warning boxes again.

- 0.35 -
--------
  * Changed the warning boxes that are displayed
    when a hotkey fails to register. They are
    cleaner and more informative now.

  * Changed hotkey identifiers to unique values so
    now jkey will never conflict with other hotkeys
    defined by other programs.

  ^ General code cleanup. Things should be working
    better.

- 0.34 -
--------

  ^ Private debug test build (do not use if you
    happen to come upon it somewhere).

- 0.33 -
--------
  ! Fixed memory leak on recycle
  ! Fixed "jKeyVKTable" from not excepting quotes
    around a file name. Now must use quotes when
    specifying a long file name.

- 0.32 -
--------
  ! Fixed recycle bug where Window Class wasn't
    wasn't being unregistered correctly.
  ! Fixed problem with Hotkey error box, that kept
    it from showing the name of the Hotkey that
    failed, if that hotkey wasn't listed in the
    virtual key table.

  ^ I built this version under Win2k. I normally
    build under Win98se. It shouldn't change
    anything, but you never know.

- 0.31 -
--------
  + Added "jKeyVKTable"

  - Removed "jKeyCtrlEscKey"
  - Removed built in special virtual key lookup
    table. Now it is accessed through "jKeyVKTable"

  * Changed a bit of the internal code workings.

  ! Fixed potential to not unregister a hotkey
    when exiting.
  ! Fixed no warning boxes showing up when a hotkey
    was not registered correctly. Now they do.

- 0.30 -
--------
  + Initial release.
  + Supports configuration of individual WinKeys
    and Ctrl+Esc sequence.
  + Supports standard LiteStep Hotkey syntax.
  + Supports MS "APPS" key (odd key to the right of
    the right WinKey).



===================================================
= C} Notes =
============

Enjoy


=====================
= IV. Tips & Tricks =
=====================
===================================================
Check out the "jKeyVKTable" setting. You can
specify a custom Virtual Key code lookup table to
allow access to the custom keys on your keyboard.
So you could set up your new fancy Internet enabled
keyboard to execute custom hotkeys.

Just read the rest of this file and you should be
fine.  This module does not behave like the
hotkey.dll module with it default settings. You
must enable certain aspects of it to gain the same
functionality. Like I said. Read the rest of this
file.



=================
= V. Disclaimer =
=================
===================================================

Copyright (C) 2000-2001, Chris Rempel

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT  WARRANTY
OF ANY KIND, EXPRESS OR  IMPLIED, INCLUDING BUT NOT
LIMITED  TO  THE   WARRANTIES  OF  MERCHANTABILITY,
FITNESS  FOR   A   PARTICULAR   PURPOSE   AND  NON-
INFRINGEMENT.  IN  NO  EVENT  SHALL THE  AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,  DAMAGES
OR  OTHER  LIABILITY,   WHETHER  IN  AN  ACTION  OF
CONTRACT,  TORT OR OTHERWISE,  ARISING FROM, OUT OF
OR IN CONNECTION  WITH  THE  SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
