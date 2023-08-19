## Reverse-engineered Commodore +4 game "Treasure Island" by Greg Duddle published by Mr. Micro Ltd. in 1985.

https://plus4world.powweb.com/software/Treasure_Island

## The game

The repository contains all the reverse-engineered data for the game. Also, there is a new HTML5 re-implementation that can be played in any modern browser. The JS implementation does not use any game engine, everything is in plain "modern" Javascript.

Please take a look at the screen shots from the game:

![Alt text](/screenshots/ti_screenshot_001.png?raw=true "Screenshot1")
![Alt text](/screenshots/ti_screenshot_002.png?raw=true "Screenshot2")
![Alt text](/screenshots/ti_screenshot_003.png?raw=true "Screenshot3")
![Alt text](/screenshots/ti_screenshot_004.png?raw=true "Screenshot4")
![Alt text](/screenshots/ti_screenshot_005.png?raw=true "Screenshot5")


## Graphical tool
The repository also contains a small graphical tool which I used to convert original multicolor graphics
to PNG image file. The graphical tool uses SDL2 library. You can buid & run the tool with

```console
$ make && make run
```

![Alt text](/screenshots/gw_screenshot_001.png?raw=true "Graphical tool")

## Assemble reverse-engineered code

The reverse-engineered assembly code can be assembled to .PRG format with KickAssemble, just by using
the included Makefile

```console
$ make game
```

The make file will assemble the code and run the game in Vice emulator.

To run the original unaltered game you can do that from Makefile as well with

```console
$ make original
```

