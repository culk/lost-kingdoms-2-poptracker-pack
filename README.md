# Lost Kingdoms II AP Tracker

A [PopTracker](https://github.com/black-sliver/PopTracker/) Pack for Lost Kingdoms II to be used for the multiworld randomizer [Archipelago](https://archipelago.gg/). The Lost Kingdoms II AP world can be found at https://github.com/cokeman5/LK2Archipelago.

![Screenshot](images/docs/screenshot.png)

## Getting Started

Download the most recent .zip file from the **Releases** and either drag it to the PopTracker window or place it in your `poptracker/packs` directory. For more details and instructions on how to connect the tracker to an Archipelago server see [PopTracker](https://github.com/black-sliver/PopTracker/).

## Features

- Automatically reads player options from the AP server slot data.
- Autotracking for found key items and checked locations.
- Manual tracking for randomized level connections.
- Displays locations that are reachable in logic (green) and out of logic (yellow).
- Highlighting of hinted item locations.

### Planned Features

- Support for autotracking randomized level connections.
- Auto map tab switching based on players location.

## Compatibility

| AP World Version | PopTracker Pack Version |
|------------------|-------------------------|
| v0.1.07          | v0.1.0+                 |

## Randomized Levels Manual Instructions

![Randomize levels manual setting enabled](images/docs/manual_connections_enabled.png)

This pack supports manual tracking of level connections since pack version v0.3.0 when the "randomize levels" option is enabled. The "Connections" map tab displays current connections, reachable level exits, and is the place to add new connections. A "connection" is a link between a single exit and a single level to inform the pack's logic that reaching the exit will unlock the connected level. Exits are displayed as color coded diamonds above the level on the map: green if the exit is reachable, red if the exit is unreachable, and grey if it is already connected to a level. Levels are displayed as diamonds below the level on the map: blue if unconnected and grey if connected.

To add a connection, select a level or exit and then select its connected level or exit.

### Steps:
1. To select a level or exit, hover over the diamond location icon and then left click on the item icon in the hover window.

![An exit manually selected by left clicking its item icon](images/docs/manual_connections_step_1.png)

2. The item icon will update with a yellow butterfly to indicate it is currently selected.
3. With a level or exit already selected, select its connected level or exit to create the connection.

![A level connected to an exit](images/docs/manual_connections_step_3.png)

4. Connected locations will update their location color to grey and their item icon will state where they are connected.

Each exit can only be connected to a single level and each level can only be connected to a single exit. To remove a connection, right click on the level or exit item icon for an already connected location. To deselect a level or exit, left click on the selected level or exit.


## Credits

- Pack created with the help of [pack builder](https://github.com/StripesOO7/poptracker-pack-builder).