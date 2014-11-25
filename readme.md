Shadows of Deception
================================================================================

**Shadows of Deception (SoD)** is an RPG-ish add-on campaign for the game
[Battle for Wesnoth] [1].

This campaign is an indirect prequel to *Invasion from the Unknown* and *After
the Storm*, both created by [shadowm/shikadilord] [2].

A shadow lengthens across the land; a faceless evil plots to overthrow the
Empire. No one holds all the pieces. The fate of a kingdom rests in the hands of
a despairing few, but will they be able to tell friend from foe?

Nine years later, and the land is rife with unrest. With the throne of Wesnoth
held in the grasp of a madman, a small force attempts to right the mistake made
almost a decade before.

**(Intermediate level, two separate episodes planned, one with 6 scenarios
playable so far)**

**NOTE:** Some scenarios of this campaign work significantly differently from
normal Wesnoth gameplay. It is especially important to pay close attention to
the mission objectives and not necessarily try to kill every single enemy,
especially on shrouded maps, or in places where enemies seem to respawn
continuously.

[1]: <https://www.wesnoth.org>
[2]: <https://github.com/shikadilord>

Installing Shadows of Deception
--------------------------------------------------------------------------------

Requirements:

 * *The Batttle For Wesnoth* version 1.12 and later or 1.11.11 and later
   versions of the 1.11 series.
 * *8680’s Lua Pack*, a resource pack containing several functions made use of
   by SoD. Refer to the *Installing lp8* section below for instructions on
   installing the pack.
 * *SoD Music* (optional), a music pack containing additional music played in
   some scenarios.

Released versions of SoD should be installed from Wesnoth’s official add-ons
servers using the main client. Players who know how to use [Git] [3] and are
interested in testing the latest (unstable, buggy) version of SoD may clone the
Git repository, which is to be found [on GitHub] [4], into Wesnoth’s
`<user data>/data/add-ons/` directory. See [this page] [5] on the Wesnoth.org
wiki for information on locating your user data directory.

A game screen resolution of **800x600 or greater** is recommended. Some
sequences make use of floating labels, halos, and standing unit animations, so
you might want to make sure these options are enabled under **Preferences** →
**Display**.

[3]: <http://www.git-scm.com>
[4]: <https://github.com/Vultraz/NX-RPG>
[5]: <http://wiki.wesnoth.org/EditingWesnoth#The_user_data_directory>

Installing lp8
--------------------------------------------------------------------------------

Shadows of Deception requires another Wesnoth add-on, 8680’s Lua Pack
(internally referred to as “lp8”). It may be found [on GitHub] [6] and on the
official Wesnoth add-ons server.

A copy of lp8 is included with released versions of SoD available on the add-ons
server. However, players who install SoD via Git must install lp8 manually.
If you install SoD via Git, you should either:

* Install lp8 externally to SoD:
  * Install lp8 via Wesnoth’s add-ons manager, or…
  * Clone lp8’s Git repository, and create a symbolic link to its
    `8680s_Lua_Pack` directory in the same directory into which you cloned SoD’s
    Git repository (the link should also be named `8680s_Lua_Pack`).
* Install lp8 internally to SoD:
  * Clone lp8’s Git repository into SoD’s `lua/lp8` directory, as `wesnoth-lp8`,
    or…
  * Clone lp8’s Git repository, and make `lua/lp8/wesnoth-lp8` a symbolic link
    to it.

You can have lp8 installed both externally and internally if you want, but you
can’t have an external lp8 installed via both the add-ons manager and Git, or an
internal lp8 installed with both a clone and a symbolic link in `lua/lp8`.

[6]: <https://github.com/8573/wesnoth-lp8>

Reporting issues
--------------------------------------------------------------------------------

If you encounter any bugs or other problems, you may report them at our [issue
tracker on GitHub] [7] or the dedicated [development topic] [8] on the
Wesnoth.org forums.

[7]: <https://github.com/Vultraz/NX-RPG/issues>
[8]: <http://r.wesnoth.org/t35544>

Contacting the author
--------------------------------------------------------------------------------

You may contact the author of this campaign via forum PM to vultraz on the
[Wesnoth.org forums][9] or the IRC channel ##vultcave on chat.freenode.net.

[9]: <http://forums.wesnoth.org/>

<!-- vim: textwidth=80 -->
