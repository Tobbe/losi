/*
   This is a part of the Niver's Settings IPC LiteStep Module SDK

   Copyright (C) 2003 Niversoft 
   http//niversoft.dyndns.org
   info@niversoft.dyndns.org

   This program is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public License
   as published by the Free Software Foundation; either version 2
   of the License, or (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
*/

//-------------------------------------------------------------------------------------

This module implements a IPC model to get settings and info from
a running litestep instance, to provide this data to an external
application. This module can help non-litestep appilication developpers
to integrate their application with litestep.

Litestep Integration:
   Copy bin/settingsipc.dll in your litestep folder
   Add
      LoadModule $LitestepDir$settingsipc.dll
   to step.rc or personal.rc to be sure that the IPC server is loaded


External Application integration:
   see include/settingsipc_client.h for interface

   Use provided static functions to get settings info from the running
   instance of litestep:

   call settingsipc_client::IsServerPresent() to know if the server module
      is loaded in litestep AND if litestep is running

   call settingsipc_client::GetRC????() to obtain settings values

   call settingsipc_client::GetLitestepWnd() to obtain LiteStep Window Hwndle (HWND)

   More functions can be added. To do so, get the source code of the client and
   the server, add an enumeration member and the implementation in the client and
   the server. When doing so, don't forget to modify the NAME defined in
   settingsipcdefs.h for EACH modification of the functions.


Known Application that uses settingsipc:
   - Winamp advanced tray controls 1.7.0.5+, by Niversoft
   - Winamp3 advanced tray controls 2.1.5+, by Niversoft
