# CompactGM

CompactGM is a lightweight World of Warcraft 3.3.5a client addon for sending common AzerothCore GM, lookup, Playerbot, and server commands through compact cascading menus. It does not change the server or grant permissions; every command still runs through the logged-in character's normal server permissions.

## Install

1. Copy the `CompactGM` folder into the 3.3.5a client's `Interface/AddOns` directory.
2. At the character screen, enable **CompactGM**. If the client marks it out of date, enable **Load out of date AddOns**.
3. Log in and use `/cgm` or click the small gear button near the minimap.

## Menus

The minimap button and `/cgm` open the global menu:

- **Lookup** — search items, item sets, quests, creatures, game objects, spells, skills, areas, maps, factions, and events. Results are printed in chat. Ctrl-click a supported item result to add one copy to your inventory; this uses the server's `.additem` command and requires permission.
- **GM mode** — send `.gm on`, `.gm off`, `.gm fly`, or `.gm visible`.
- **Playerbots** — start selfbot fishing, check its status, or stop it. These entries require the companion `mod-selfbot-fishing` server module described below.
- **Dungeon Clear** — check status, enable, pause, skip the current step, disable, or list bosses. These entries require the matching server module and permission.
- **World & server** — use recall and teleport shortcuts, show server information, list commands, or enter a teleport/other command.
- **Custom command…** — enter a server command to send as chat text.

Right-click a player through the client's normal unit context menu and choose **Compact GM Tools** for targeted actions. The target menu includes player information and common moderation/character actions; server permissions still apply. Some actions ask for a target name or command argument.

## Selfbot fishing

The Playerbots menu has **Start selfbot fishing**, **Fishing: status**, and **Fishing: stop**. Starting uses `.sbfish start` from `mod-selfbot-fishing`. That server command checks that the character knows Fishing and has a Fishing Pole in their bags, enables a selfbot if necessary, equips the pole, and activates Playerbots' existing `master fishing` strategy. It does not choose a fishing route or override Playerbots pool/path selection.

Stopping removes the fishing and pending bobber-use strategies. If the start command enabled the selfbot, stop turns it off; if the character was already a selfbot, it leaves that bot active. When the session began with another main-hand item, the server module attempts to restore it if the pole is still equipped and the original item remains in inventory.

The local server also uses a small Playerbots source patch to keep the selfbot dismounted during fishing and delay autonomous remounting. That patch is documented and supplied separately in the `mod-selfbot-fishing` repository. CompactGM itself does not apply the patch.

## Teleport shortcuts

The **World & server → Teleport** menu provides:

- **Return before last teleport** — sends `.recall`.
- **Save current spot on server…** — asks for a name, sends `.teleport add <name>`, and adds the name to CompactGM's local shortcut list.
- **Saved spots** — sends `.teleport <name>` for a remembered shortcut.
- **Add existing server spot to list…** — asks for an existing teleport name, adds it to the local list, and sends `.lookup teleport <name>` so the server can show matching entries. The name list is local; this lookup does not import the server's teleport table automatically.
- **Remove from addon's list** — forgets a local shortcut only. It does not delete the server teleport.
- **Search server teleport names…** — sends `.lookup teleport <search text>`; use the displayed name with **Add existing server spot to list…** if you want a local shortcut.

The server stores teleport locations and coordinates. CompactGM stores only shortcut names in the client's `CompactGMDB` SavedVariables. The local list does not synchronize with the server or other clients.

## Moving the minimap button

Drag the gear button to reposition it around the minimap. Its position is saved by the client.

## Compatibility and scope

- Client addon for WoW 3.3.5a; the `.toc` interface version is `30300`.
- Commands are sent as dot-prefixed chat text to the server.
- Features supplied by optional server modules appear in the menu even if the module is unavailable; in that case the server will reject the command.
- This addon does not modify server source, database tables, or permissions.

## Compatibility and provenance

CompactGM is an unofficial client addon for WoW 3.3.5a. Its Playerbots, selfbot fishing, and Dungeon Clear menu entries send commands to optional server modules; Yu'Lon is not required to install or run the addon. These shortcuts were developed for a Yu'Lon-managed AzerothCore WotLK server using `mod-playerbots/azerothcore-wotlk` commit `32fd3472aa74961c91cb9bc942ee3e0a44b36779` and `mod-playerbots/mod-playerbots` commit `ecc4a537a3b43056e412fae63fb4a4271849b472`. The core and Playerbots revisions are compatibility references, not bundled source code.

This project is not affiliated with or endorsed by AzerothCore, the Playerbots project, Yu'Lon, Blizzard Entertainment, or World of Warcraft.

No license has been selected for this addon yet. Choose a license before making the repository public if you want others to have explicit permission to reuse or modify it.
