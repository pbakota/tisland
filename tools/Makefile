CFLAGS=$(shell pkg-config sdl2 --cflags) $(shell pkg-config SDL2_ttf --cflags)
LIBS=$(shell pkg-config sdl2 --libs) $(shell pkg-config SDL2_ttf --libs)
#FONT=ProggyClean
#FONT=Terminal
FONT=ibm_vga_8x16

all: graphics_view

graphics_view : graphics_view.c $(FONT).h
	clang -g $(CFLAGS) graphics_view.c -o graphics_view $(LIBS)

$(FONT).h : $(FONT).ttf
	xxd -i $(FONT).ttf $(FONT).h

clean:
	rm -f graphics_view
	rm -f $(FONT).h

run:
	./graphics_view ../original/treasure_island.prg

game:
	kickass ../tisland.asm -o ../tisland.prg -vicesymbols && \
	~/Applications/vice36/bin/xplus4 -moncommands ../tisland.vs ../tisland.prg

original:
	~/Applications/vice36/bin/xplus4 ../original/treasure_island.prg

