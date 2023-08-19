all: game

game:
	kickass tisland.asm -o tisland.prg -vicesymbols && \
	~/Applications/vice36/bin/xplus4 -moncommands tisland.vs tisland.prg

original:
	~/Applications/vice36/bin/xplus4 original/treasure_island.prg

