# CompactGM

Small cascading GM command menus for WoW 3.3.5a / AzerothCore.

## Install

Copy the `CompactGM` folder into `Interface/AddOns` in the WotLK client. At the character screen, enable **CompactGM** (and check **Load out of date AddOns** if it is listed as out of date), then log in.

## Use

- Click the small gear button by the minimap, or type `/cgm`, for global menus.
- Right-click a player through the normal unit/player context menu and choose **Compact GM Tools** for actions on that character.
- Choose **Custom command…** to enter a server command. The addon sends it to the server as a normal GM chat command.
- Open **World & server → Teleport** for `.recall`, saving the current spot, and your saved teleport shortcuts.
- Open **Lookup** from the minimap menu to choose a server lookup category and search term; results remain in chat with no result-count cap added by the addon.
- Ctrl-click an item result from `.lookup item` to add one copy to your inventory.
- Drag the minimap button to move it.

## Teleport list

- **Save current spot on server…** runs `.teleport add <name>` and remembers the name in this addon's local list.
- **Saved spots** shows remembered names; selecting one runs `.teleport <name>`.
- **Add existing server spot to list…** lets you enter a teleport name you already created, then checks it with `.lookup teleport <name>`.
- **Remove from addon's list** removes only the local shortcut. It does not delete the server teleport.
- **Return before last teleport** runs `.recall`.

The server stores actual teleport coordinates in its world database. CompactGM keeps only the shortcut names in `CompactGMDB`; it cannot automatically import the server's complete teleport table. You can search the server using the menu item **Search server teleport names…** and add existing spots to the local list by name.

Playerbots, selfbot fishing, and Dungeon Clear shortcuts are included for the modules in this server checkout. They appear in the global menu; unsupported commands are still governed by your server's GM permissions and module availability.

The fishing start shortcut uses the updated `mod-selfbot-fishing` command: it enables a selfbot if needed, checks Fishing skill and for a Fishing Pole, equips a pole from your bags, then starts the fishing strategy. Stop turns off the selfbot only when fishing enabled it.

## Notes

- This is a client addon; it does not change or rebuild the server.
- Commands are sent as chat text beginning with a dot, matching the AzerothCore command handler.
- The addon avoids a large settings window and stores the minimap button position plus your local teleport shortcut names.
