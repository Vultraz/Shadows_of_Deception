Shadows of Deception
================================================================================

An RPG-ish add-on for the game [Battle for Wesnoth] [1].

[1]: <https://www.wesnoth.org>


Installing Shadows of Deception
--------------------------------------------------------------------------------
Released versions of Shadows of Deception should be installed from Battle for Wesnoth’s
official add-ons servers, via Battle for Wesnoth’s built-in add-ons manager,
which can be accessed via the “Add-ons Manager” button in the main menu.

Players who know how to use [Git] [2] and are interested in testing the latest
(unstable, buggy) version of Shadows_of_Deception may clone our Git repository, which is to
be found [on GitHub] [3], into Battle for Wesnoth’s
“[userdata][4]/data/add-ons/” directory.

[2]: <http://www.git-scm.com>
[3]: <https://github.com/Vultraz/Shadows_of_Deception>
[4]: <http://wiki.wesnoth.org/EditingWesnoth#Where_is_my_user_data_directory.3F>


Installing lp8
--------------------------------------------------------------------------------
Shadows of Deception requires another Battle for Wesnoth add-on, 8680’s Lua Pack
(internally referred to as “lp8”).

A copy of lp8 is included with the released versions of Shadows of Deception that are made
available on Battle for Wesnoth’s official add-ons servers.

Players who install Shadows_of_Deception via Git must install lp8 manually. If you install
Shadows of Deception via Git, you should either:

* Install lp8 externally to Shadows of Deception:
  * Install lp8 via Battle for Wesnoth’s add-ons manager, or…
  * Clone lp8’s Git repository (which is also [on GitHub] [5]), and create a
    symbolic link to its `8680s_Lua_Pack` directory in the same directory into
    which you cloned Shadows of Deception’s Git repository (the link should also be named
    `8680s_Lua_Pack`).
* Install lp8 internally to Shadows_of_Deception:
  * Clone lp8’s Git repository into Shadows of Deception’s `lua/lp8` directory, as
    `wesnoth-lp8`, or…
  * Clone lp8’s Git repository, and make `lua/lp8/wesnoth-lp8` a symbolic link
    to it.

You can have lp8 installed both externally and internally if you want, but you
can’t have an external lp8 installed via both the add-ons manager and Git, or
an internal lp8 installed with both a clone and a symbolic link in `lua/lp8`.

[5]: <https://github.com/8573/wesnoth-lp8>


Reporting issues
--------------------------------------------------------------------------------
If you encounter any bugs or other problems, you may report them at our [issue
tracker on GitHub] [6].

[6]: <https://github.com/Vultraz/Shadows_of_Deception/issues>
