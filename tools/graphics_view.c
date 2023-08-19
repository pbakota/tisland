#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <SDL2/SDL.h>
#include <SDL2/SDL_ttf.h>
#include <unistd.h>

#define ROOM_TABLE_HI (0x3e40-0x1001+2)
#define ROOM_TABLE_LO (0x3e82-0x1001+2)
#define ROOM_DATA (0x6800-0x1001+2)
#define ATTR_DATA (0x7500-0x1001+2)
#define TILE_BITMAP (0x4000-0x1001+2)
#define ROOM_BITMAP (0x6800-0x1001+2)
#define SPRITE_BITMAP (0x6000-0x1001+2)
#define SPRITE_COLOR (0x1510-0x1001+2)
#define PICKABLE_BITMAP (0x1b80-0x1001+2)
#define SPRITE_LUMI (0x1530-0x1001+2)
#define PIRATE_BITMAP (0x1d00-0x1001+2)
#define SWORD_L_BITMAP (0x1900-0x1001+2)
#define SWORD_R_BITMAP (0x1e00-0x1001+2)
#define SWORD_U_BITMAP (0x1b00-0x1001+2)
#define SPRITE_COLORS (0x1510-0x1001+2)
#define PICKABLE_COLORS (0x1b68-0x1001+2)
#define SCORE_BITMAP (0x2380-0x1001+2)
#define SCORE_ATTR (0x2000-0x1001+2)
#define SCORE_DIGITS (0x19a0-0x1001+2)
#define COPYRIGHT_BITMAP (0x7B00-0x1001+2)
#define ROOM_FLAGS (0x1560-0x1001+2)

#define WINDOW_SIZE_X   1600
#define WINDOW_SIZE_Y   900

// Color palette
#include "plus4palette_yape.h"
// Font
//#include "ProggyClean.h"
//#include "Terminal.h"
#include "ibm_vga_8x16.h"

#define ARRAY_SIZE(x) ((int)(sizeof(x)/sizeof(x[0])))

void button_clicked(int button_id,void *userdata);
typedef void (*callback)(int button_id, void *userdata);
struct {
  int x;
  int y;
  int w;
  int h;
  const char* caption;
  int button_id;
  callback cb;
} buttons [] = {
  { .x=400, .y=400, .w=110, .h=26, "Minimap",       4, &button_clicked },
  { .x=400, .y=430, .w=110, .h=26, "Score panel",   5, &button_clicked },
  { .x=400, .y=780, .w=110, .h=26, "Actor & J.L.S", 0, &button_clicked },
  { .x=400, .y=810, .w=110, .h=26, "Pickables",     1, &button_clicked },
  { .x=400, .y=840, .w=110, .h=26, "Pirate",        2, &button_clicked },
  { .x=400, .y=870, .w=110, .h=26, "Sword",         3, &button_clicked },
};
int selected_button=0;
int selected_view=0;

TTF_Font *font;
SDL_Renderer *renderer;
SDL_Window *window;
SDL_Texture *bitmap;

char prg_file[256] = {0};
Uint8 *prg_mem;
Uint32 prg_len;

SDL_Texture* tiles[64] = {0};
SDL_Texture* sprite_frames[64] = {};
Uint16 sprite_addr[64]={};
SDL_Texture* pickable_frames[5] = {};
Uint16 pickable_addr[5] = {};
SDL_Texture* score_panel = NULL;

SDL_Color white_color = { .r = 255, .g = 255, .b = 255 };
SDL_Color black_color = { .r = 0, .g = 0, .b = 0 };
SDL_Color red_color = { .r = 255, .g = 0, .b = 0 };
SDL_Color gray_color = { .r = 128, .g = 128, .b = 128 };

int current_room = 0;
int cursor_x, cursor_y;
int selected_tile = 0;

void usage(const char *p) {
	fprintf(stderr, "usage: %s <prg file>\n", p);
}

void myexit() {

  for(int i=0;i<64;++i){
    SDL_DestroyTexture(tiles[i]);
  }
  for(int i=0;i<19;++i){
    SDL_DestroyTexture(sprite_frames[i]);
  }
  for(int i=0;i<5;++i){
    SDL_DestroyTexture(pickable_frames[i]);
  }
  SDL_DestroyTexture(score_panel);

	if(renderer) {
		SDL_DestroyRenderer(renderer);
	}

	if(window) {
		SDL_DestroyWindow(window);
	}

	TTF_Quit();
	SDL_Quit();
}

int textout(int x, int y, const SDL_Color textColor, const char *fmt, ...)
{
	char buffer[256];
	va_list va;

	va_start(va, fmt);

	vsnprintf(buffer, sizeof(buffer), fmt, va);

	va_end(va);

	SDL_Surface* textSurface = TTF_RenderText_Solid(font, buffer, textColor);
  SDL_Texture *texture = SDL_CreateTextureFromSurface(renderer, textSurface);

	int texW, texH;
	SDL_QueryTexture(texture, NULL, NULL, &texW, &texH);
	SDL_Rect r = {x, y, texW, texH};
	SDL_RenderCopy(renderer, texture, 0, &r);

	SDL_FreeSurface(textSurface);
}

int init_sdl() {
	if(SDL_Init(SDL_INIT_VIDEO | SDL_INIT_EVENTS) == -1) {
		fprintf(stderr, "[E] Failed to initialize SDL: %s\n", SDL_GetError());
		return -1;
	}

	if( TTF_Init() == -1 )
	{
		printf( "SDL_ttf could not initialize! SDL_ttf Error: %s\n", TTF_GetError() );
		return -1;
	}

	atexit(myexit);
	if((window = SDL_CreateWindow("graphics_view", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WINDOW_SIZE_X, WINDOW_SIZE_Y, 0)) == NULL)
	{
		fprintf(stderr, "[E] Failed to create window: %s\n", SDL_GetError());
		return -1;
	}

	if((renderer = SDL_CreateRenderer(window, -1, SDL_RENDERER_SOFTWARE)) == NULL)
	{
		fprintf(stderr, "[E] Failed to create renderer: %s\n", SDL_GetError());
		return -1;
	}


	font = TTF_OpenFontRW(SDL_RWFromConstMem(ibm_vga_8x16_ttf, ibm_vga_8x16_ttf_len), 1, 16.4f);
	if( font == NULL )
    {
    printf( "Failed to load font! SDL_ttf Error: %s\n", TTF_GetError() );
		return -1;
	}

	return 0;
}

void clear_surface(SDL_Surface* surface){
  SDL_FillRect(surface, NULL, 0x000000);
}

#define COLOR_01(attr,lumi) (lumi&0x07)<<4|((attr&0xf0)>>4)
#define COLOR_02(attr,lumi) (lumi&0x70)|(attr&0x0f)

void convert_byte(Uint8 byte, Uint8 row[], Uint8 color_01, Uint8 color_02){
  #define FF15_COLOR 0x00
  #define FF16_COLOR 0x71
  Uint8 color;
  /* convert 1 byte */
  for(int p=0;p<8;p+=2){
    /* parsing pixels from left-to-right */
    int bit_pattern = (byte&0xc0)>>6;
    switch(bit_pattern){
      case 0x00: /* Bits 4..6 of TED Register # $15 Bits 0..3 of TED Register # $15 */
        color = FF15_COLOR;
        break;
      case 0x01: /* Bits 0..2 of LUMINANCE table Bits 4..7 of COLOR table */
        color = color_01;
        break;
      case 0x02: /* Bits 4..6 of LUMINANCE table Bits 0..3 of COLOR table */
        color = color_02;
        break;
      case 0x03: /* Bits 4..6 of TED Register # $16  Bits 0..3 of TED Register # $16 */
        color = FF16_COLOR;
        break;
    }
    byte <<= 2;
    /* multicolor pixel is double sized */
    row[p+0] = color;
    row[p+1] = color;
  }
  #undef FF15_COLOR
  #undef FF16_COLOR
}

void convert_score_panel(SDL_Surface* surface){
  clear_surface(surface);
  Uint8* byte_ptr = prg_mem+SCORE_BITMAP;
  Uint8* attr_ptr = prg_mem+SCORE_ATTR;
  if(SDL_MUSTLOCK(surface)){
    SDL_LockSurface(surface);
  }
  Uint8 *bitmap = surface->pixels;
  long pitch = surface->pitch;
  for(int y=0;y<17;++y){
    for(int x=0;x<8;++x){
      Uint8 *row = bitmap+y*8*pitch+x*8;
      Uint8 lumi = 0x74, attr = *attr_ptr++;
      for(int l=0;l<8;++l,row += pitch){
        Uint8 byte = *byte_ptr++;
        convert_byte(byte, row, COLOR_01(attr, lumi), COLOR_02(attr, lumi));
      }
    }
    byte_ptr += 320-8*8;
  }
  bitmap = surface->pixels+17*8*pitch;
  Uint8* digits_ptr = prg_mem+SCORE_DIGITS;
  for(int x=0;x<10;++x){
    Uint8 *row = bitmap+x*8;
    Uint8 lumi = 0x74, attr = 0x07;
    for(int l=0;l<8;++l,row += pitch){
      Uint8 byte = *digits_ptr++;
      convert_byte(byte, row, COLOR_01(attr, lumi), COLOR_02(attr, lumi));
    }
  }
  if(SDL_MUSTLOCK(surface)){
    SDL_UnlockSurface(surface);
  }
  score_panel = SDL_CreateTextureFromSurface(renderer, surface);
  assert(score_panel != NULL);
}

void convert_tiles(SDL_Surface* tile_surface){
  clear_surface(tile_surface);
  for(int tile=0;tile<64;++tile){
    Uint8* tile_ptr = prg_mem+TILE_BITMAP+(tile*128);
    Uint8* attr_ptr = prg_mem+ATTR_DATA+(tile*16);
    if(SDL_MUSTLOCK(tile_surface)){
      SDL_LockSurface(tile_surface);
    }
    Uint8 *bitmap = tile_surface->pixels;
    long pitch = tile_surface->pitch;
    for(int y=0;y<4;++y){
      for(int x=0;x<4;++x){
        Uint8 *row = bitmap+y*8*tile_surface->pitch+x*8;
        Uint8 color, lumi = 0x74, attr = *attr_ptr++;
        for(int l=0;l<8;++l,row += pitch){
          Uint8 byte = *tile_ptr++;
          convert_byte(byte, row, COLOR_01(attr, lumi),COLOR_02(attr, lumi));
        }
      }
    }
    if(SDL_MUSTLOCK(tile_surface)){
      SDL_UnlockSurface(tile_surface);
    }
    tiles[tile] = SDL_CreateTextureFromSurface(renderer, tile_surface);
    assert(tiles[tile] != NULL);
  }
}

void convert_drawable(SDL_Surface* sprite_surface, SDL_Texture** frames, 
  Uint8* sprite_ptr, int hsize, int nsprites, Uint8* attr_ptr, Uint8 lumi){
  
  clear_surface(sprite_surface);
  int rows = hsize == 64 ? 21 : 13; /* 21 = regular sprites, 13 = sword */
  for(int sprite=0;sprite<nsprites;++sprite){
    Uint8 *data_ptr = sprite_ptr+(sprite*hsize);
    if(SDL_MUSTLOCK(sprite_surface)){
      SDL_LockSurface(sprite_surface);
    }
    Uint8 *bitmap = sprite_surface->pixels;
    Uint8 attr=attr_ptr?*attr_ptr++: 0x62;
    long pitch = sprite_surface->pitch;
    for(int y=0;y<rows;++y){
      Uint8 *row = bitmap+y*sprite_surface->pitch;
      Uint8 color;
      for(int l=0;l<3;++l,row += 8){
        Uint8 byte = *data_ptr++;
        convert_byte(byte, row, COLOR_01(attr, lumi), COLOR_02(attr, lumi));
      }
    }
    if(SDL_MUSTLOCK(sprite_surface)){
      SDL_UnlockSurface(sprite_surface);
    }
    frames[sprite] = SDL_CreateTextureFromSurface(renderer, sprite_surface);
    assert(frames[sprite] != NULL);
  }
}

void convert_sprites(SDL_Surface* surface){
  Uint8* sprite_ptr = prg_mem+SPRITE_BITMAP;
  Uint8 sprite_colors[] = {
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
    0x82,0x82,0x62,0x62,
  };
  convert_drawable(surface, sprite_frames, sprite_ptr, 64, 32, sprite_colors, 0x64);
  for(int i=0;i<32;++i){
    sprite_addr[i] = (SPRITE_BITMAP+0x1001-2)+(i*64);
  }
  Uint8 *pirate_ptr = prg_mem+PIRATE_BITMAP;
  Uint8 pirate_colors[] = {
    0x52, 0x62, 0x72, 0x42
  };
  convert_drawable(surface, &sprite_frames[32], pirate_ptr, 64, 4, pirate_colors, 0x73);
  for(int i=0;i<4;++i){
    sprite_addr[32+i] = (PIRATE_BITMAP+0x1001-2)+(i*64);
  }
  Uint8 *l_sword_ptr = prg_mem+SWORD_L_BITMAP;
  convert_drawable(surface, &sprite_frames[32+4], l_sword_ptr, 39, 4, NULL, 0x64);
  for(int i=0;i<4;++i){
    sprite_addr[32+4+i] = (SWORD_L_BITMAP+0x1001-2)+(i*39);
  }
  Uint8 *r_sword_ptr = prg_mem+SWORD_R_BITMAP;
  convert_drawable(surface, &sprite_frames[32+4+4], r_sword_ptr, 39, 4, NULL, 0x64);
  for(int i=0;i<4;++i){
    sprite_addr[32+4+4+i] = (SWORD_R_BITMAP+0x1001-2)+(i*39);
  }
  Uint8 *u_sword_ptr = prg_mem+SWORD_U_BITMAP;
  convert_drawable(surface, &sprite_frames[32+4+4+4], u_sword_ptr, 39, 2, NULL, 0x64);
  for(int i=0;i<2;++i){
    sprite_addr[32+4+4+4+i] = (SWORD_U_BITMAP+0x1001-2)+(i*39);
  }
}

void convert_pickables(SDL_Surface* surface){
  Uint8* pickable_ptr = prg_mem+PICKABLE_BITMAP;
  Uint8* pickable_colors = prg_mem+PICKABLE_COLORS;
  convert_drawable(surface, pickable_frames, pickable_ptr, 64, 5, pickable_colors, 0x64); 
  for(int i=0;i<5;++i){
    pickable_addr[i] = (PICKABLE_BITMAP+0x1001-2)+(i*64);
  }
}

void convert_tiles_and_sprites(){
  /* create indexed colors surface */
  SDL_Surface *surface = SDL_CreateRGBSurfaceWithFormat(0,32,32,8,SDL_PIXELFORMAT_INDEX8);
  assert(surface != NULL);

  /* Set palette */
  SDL_Color colors[128];
  for(int c=0;c<128;++c){
    int r = (plus4_color_palette[c]&0xff0000)>>16;
    int g = (plus4_color_palette[c]&0x00ff00)>>8;
    int b = (plus4_color_palette[c]&0x0000ff);
    colors[c].r = r;
    colors[c].g = g;
    colors[c].b = b;
  }
  SDL_SetPaletteColors(surface->format->palette, colors, 0, 128);

  convert_tiles(surface);
  convert_sprites(surface);
  convert_pickables(surface);

  SDL_FreeSurface(surface);
  
  /* create indexed colors surface */
  SDL_Surface *panel_surface = SDL_CreateRGBSurfaceWithFormat(0,64+2*8,168,8,SDL_PIXELFORMAT_INDEX8);
  assert(surface != NULL);

  SDL_SetPaletteColors(panel_surface->format->palette, colors, 0, 128);
  convert_score_panel(panel_surface);
  SDL_FreeSurface(panel_surface);
}

void clear_window() {
	// Clear screen
	SDL_SetRenderDrawColor(renderer, 0,0,0,SDL_ALPHA_OPAQUE);
	SDL_RenderClear(renderer);
}

Uint16 get_room_ptr(int room_nr){
  Uint8 room_ptr_lo = *(prg_mem+ROOM_TABLE_LO+(room_nr%16));
  Uint8 room_ptr_hi = *(prg_mem+ROOM_TABLE_HI+room_nr);
  Uint16 room_ptr = (((int)room_ptr_hi) << 8)|((int)(room_ptr_lo));
  return room_ptr;
}

void draw_rect(const SDL_Color *color, int x, int y, int w, int h){
	SDL_SetRenderDrawColor(renderer, color->r,color->g,color->b, SDL_ALPHA_OPAQUE);
  SDL_RenderDrawLine(renderer, x, y, x + w, y);
  SDL_RenderDrawLine(renderer, x + w, y, x + w, y + h);
  SDL_RenderDrawLine(renderer, x + w, y + h, x, y + h);
  SDL_RenderDrawLine(renderer, x, y + h, x, y);
}

void button_clicked(int button_id, void* userdata){
  switch(button_id){
    case 0:
    case 1:
    case 2:
    case 3:
      selected_button = button_id;
    break;
    case 4:
    case 5:
      selected_view = button_id-4;
      break;
  }
}

void draw_button(int x, int y, int w, int h, int selected, const char* caption){
  draw_rect(&gray_color,x,y,w,h);
  textout(x+4, y+4, selected ? white_color : gray_color, caption);
}

void draw_tile(Uint8 tile_nr, int x, int y, int size){
  SDL_Rect d = { x,y,size,size };
  SDL_RenderCopy(renderer, tiles[tile_nr], NULL, &d);
}

void draw_drawable(SDL_Texture** frames, Uint8 sprite_nr, int x, int y, int size){
  SDL_Rect d = { x,y,size,size };
  SDL_RenderCopy(renderer, frames[sprite_nr], NULL, &d);
}

void draw_room(int room_nr){
  Uint16 room_ptr = get_room_ptr(room_nr);
  textout(0, 6*64+8, white_color, "Room: %02d ($%02x) addr: $%04x", room_nr, room_nr, room_ptr);

  for(int y=0;y<6;++y){
    for(int x=0;x<8;++x){
      int tile = (int)*((prg_mem+room_ptr++)-0x1001+2);
      draw_tile(tile, 64*x, 64*y, 64); 
    }
  }
}

void draw_score_panel(){
  SDL_Rect d = { 520, 0, (64+2*8)*2, 336};
  SDL_RenderCopy(renderer, score_panel, NULL, &d);
}

void draw_minimap(){
  const int zoom = 16;
  for(int room_nr=0;room_nr<64;++room_nr){
    Uint16 room_ptr = get_room_ptr(room_nr);
    int startx = (room_nr%8)*8*zoom, starty=(room_nr/8)*6*zoom;

    Uint16 p = room_ptr;
    for(int y=0;y<6;++y){
      for(int x=0;x<8;++x){
        int tile = (int)*((prg_mem+p++)-0x1001+2);
        draw_tile(tile, 520 + startx + zoom*x, starty + zoom*y, zoom); 
      }
    }
  }

	SDL_SetRenderDrawColor(renderer, 255,0,0, SDL_ALPHA_OPAQUE);
  int tx = 520 + (current_room%8)*8*zoom, ty=(current_room/8)*6*zoom;

  draw_rect(&red_color, tx, ty, 8*zoom, 6*zoom);
}

void draw_tiles(){
  for(int y=0;y<8;++y){
    for(int x=0;x<8;++x){
      draw_tile(y*8+x,49*x,450+49*y,48);
    }
  }
  if(selected_tile!=-1){
    int x = selected_tile%8, y = selected_tile/8;
    draw_rect(&red_color, x*49,450+y*49,48,48); 
    int addr = (TILE_BITMAP+0x1001-2)+(selected_tile*128);
    textout(0, 848, white_color, "Selected tile: $%02x (%2d) addr: $%04x", 
      selected_tile, selected_tile, addr);
  }
}

void draw_pickables(){
  for(int y=0;y<1;++y){
    for(int x=0;x<5;++x){
      int tx=520+64*x, ty=780+49*y;
      draw_drawable(pickable_frames,y*5+x,tx,ty,48);
      textout(tx, ty+36, white_color, "$%04x", pickable_addr[y*5+x]);
    }
  }
}

void draw_sprites(){
  for(int y=0;y<2;++y){
    for(int x=0;x<16;++x){
      int tx=520+64*x, ty=780+64*y;
      draw_drawable(sprite_frames, y*16+x,tx,ty,48);
      textout(tx, ty+36, white_color, "$%04x", sprite_addr[y*16+x]);
    }
  }
}

void draw_pirate(){
  for(int y=0;y<1;++y){ 
    for(int x=0;x<4;++x){
      int tx=520+64*x, ty=780+49*y;
      draw_drawable(&sprite_frames[32], y*4+x,tx,ty,48);
      textout(tx, ty+36, white_color, "$%04x", sprite_addr[32+y*4+x]);
    }
  }
}

void draw_sword(){
  for(int y=0;y<1;++y){ 
    for(int x=0;x<8+2;++x){
      int tx=520+64*x, ty=780+49*y;
      draw_drawable(&sprite_frames[32+4], y*4+x,tx,ty,48);
      textout(tx, ty+36, white_color, "$%04x", sprite_addr[32+4+y*4+x]);
    }
  }
}

void draw_editor() {
  clear_window();

  draw_room(current_room);
  draw_tiles();

  switch(selected_view){
    case 0:
      draw_minimap();
      break;
    case 1:
      draw_score_panel();
      break;
  }

  switch(selected_button){
    case 0:
      draw_sprites();
      break;
    case 1:
      draw_pickables();
      break;
    case 2:
      draw_pirate();
      break;
    case 3:
      draw_sword();
      break;
  }

  for(int i=0;i<ARRAY_SIZE(buttons);++i){
    int selected;
    switch(buttons[i].button_id){
      case 0:
      case 1:
      case 2:
      case 3:
        selected = (selected_button == buttons[i].button_id);
      break;
      case 4:
      case 5:
        selected = (selected_view == buttons[i].button_id-4);
        break;
    }
    draw_button(
      buttons[i].x, 
      buttons[i].y, 
      buttons[i].w, 
      buttons[i].h, 
      selected,
      buttons[i].caption
    );
  }

  if(cursor_x != -1) {
    SDL_SetRenderDrawColor(renderer, 255,0,0, SDL_ALPHA_OPAQUE);
    int cx = cursor_x*64, cy=cursor_y*64;
    draw_rect(&red_color, cx, cy, 64, 64);

    int off = cursor_y*8+cursor_x;
    Uint16 room_ptr = get_room_ptr(current_room);
    int tile = (int)*((prg_mem+room_ptr+off)-0x1001+2);
    textout(0, 420, white_color, "cx:%2d, cy:%2d, offset: $%02x (%2d) tile: $%02x (%2d)",
      cursor_x, cursor_y,off,off,tile,tile);
  }
}

void dump_rooms(){
  for(int room_nr=0;room_nr<64;++room_nr){
    Uint8 room_ptr_lo = *(prg_mem+ROOM_TABLE_LO+(room_nr%16));
    Uint8 room_ptr_hi = *(prg_mem+ROOM_TABLE_HI+room_nr);
    Uint16 room_ptr = (((int)room_ptr_hi) << 8)|((int)(room_ptr_lo));

    printf("Room %02d ptr: 0x%04x\n", room_nr, room_ptr);
    for(int y=0;y<6;++y){
      for(int x=0;x<8;++x){
        printf("%02x ",(int)*((prg_mem+room_ptr++)-0x1001+2));
      }
      printf("\n");
    }
  }
}

void select_room_tile(int mouseX, int mouseY){
  int cx = mouseX/64, cy = mouseY/64;
  cursor_x = cx;
  cursor_y = cy;
}

void select_tile(int mouseX, int mouseY){
  int x = mouseX/49, y = (mouseY-450)/49;
  selected_tile = y*8+x;
}

void select_minimap_room(int mouseX, int mouseY){
  if(selected_view!=0) return;
  int x = (mouseX-520)/(8*16), y = mouseY/(6*16);
  current_room = y*8+x;
}

int valid_room_view_position(Sint32 mouseX, Sint32 mouseY) {
	return
		(mouseX >= 0 && mouseY >= 0) &&
		(mouseX < 512 && mouseY < 384);
}

int valid_tile_view_position(Sint32 mouseX, Sint32 mouseY) {
	return
		(mouseX >= 0 && mouseY >= 450) &&
		(mouseX < 392 && mouseY < 842);
}

int valid_minimap_position(Sint32 mouseX, Sint32 mouseY) {
	return
		(mouseX >= 520 && mouseY >= 0) &&
		(mouseX < 1544 && mouseY < 768);
}

void handle_buttons(Sint32 mouseX, Sint32 mouseY){
  for(int i=0;i<ARRAY_SIZE(buttons);++i){
    SDL_Rect r = { buttons[i].x, buttons[i].y, buttons[i].w, buttons[i].h };
    SDL_Point p = { mouseX, mouseY };
    if(SDL_PointInRect(&p, &r)){
      buttons[i].cb(buttons[i].button_id,NULL);
      break;
    }
  }
}

void make_atlas_bitmap(){
  const int atlas_width=512, atlas_height=416, size=32;
  SDL_RendererInfo info;
  SDL_GetRendererInfo(renderer, &info);
  assert(info.flags&SDL_RENDERER_TARGETTEXTURE!=0);

  SDL_Texture* atlas = SDL_CreateTexture(renderer, SDL_PIXELFORMAT_RGBX8888, 
    SDL_TEXTUREACCESS_STATIC|SDL_TEXTUREACCESS_TARGET, atlas_width, atlas_height);
  assert(atlas != NULL);

  assert(SDL_SetRenderTarget(renderer, atlas)==0);

  /* render content */

  /* tiles */
  for(int y=0;y<8;++y){
    for(int x=0;x<8;++x){
      draw_tile(y*8+x,size*x,size*y,size);
    }
  }

  /* score panel */
  SDL_Rect d = { 256, 0, 64+2*8, 168};
  SDL_RenderCopy(renderer, score_panel, NULL, &d);

  /* pickables */
  for(int x=0;x<5;++x){
    int tx=size*x, ty=256;
    draw_drawable(pickable_frames,x,tx,ty,size);
  }

  /* sprites */
  for(int y=0;y<2;++y){
    for(int x=0;x<16;++x){
      int tx=size*x, ty=256+size+size*y;
      draw_drawable(sprite_frames, y*16+x,tx,ty,size);
    }
  }

  /* pirates */
  for(int x=0;x<4;++x){
    int tx=size*x, ty=256+3*size;
    draw_drawable(&sprite_frames[32], x,tx,ty,size);
  }

  /* sword */
  for(int x=0;x<8+2;++x){
    int tx=size*x, ty=256+4*size;
    draw_drawable(&sprite_frames[32+4], x,tx,ty,size);
  }

  SDL_Surface* surface = SDL_CreateRGBSurfaceWithFormat(0, atlas_width, atlas_height, 
    32, SDL_PIXELFORMAT_RGBX8888);
  assert(surface != NULL);

  if(SDL_MUSTLOCK(surface)){
    SDL_LockSurface(surface);
  }
  SDL_RenderReadPixels(renderer, NULL, surface->format->format, surface->pixels, surface->pitch);
  if(SDL_MUSTLOCK(surface)){
    SDL_UnlockSurface(surface);
  }
  
  assert(SDL_SetRenderTarget(renderer, NULL)==0);

  SDL_SaveBMP(surface, "treasure_island_atlas.bmp");
  SDL_DestroyTexture(atlas);
  SDL_FreeSurface(surface);
  
  printf("Atlas has been saved!\n");
}

void generate_room_json(){
  FILE *fp;
  if(!(fp = fopen("room.js","wb"))) return;
  fprintf(fp,"\"use strict\";\n");
  fprintf(fp,"var MAP=[\n");
  Uint16 room_ptr = ROOM_DATA;
  Uint16 flags_ptr = ROOM_FLAGS;
  for(int room_nr=0;room_nr<=64;++room_nr){
    fprintf(fp,"//Room %02d addr: 0x%04x\n", room_nr, room_ptr+0x1001-2);
    fprintf(fp,"{\"tiles\": [\n");
    for(int y=0;y<6;++y){
      for(int x=0;x<8;++x){
        fprintf(fp,"0x%02x, ",(int)*((prg_mem+room_ptr++)));
      }
      fprintf(fp,"\n");
    }
    fprintf(fp,"],\n");
    Uint8 flags = (Uint8)*((prg_mem+flags_ptr++));
    fprintf(fp,"//flags=$%02x\n", flags);
    fprintf(fp,"\"pirate\":%s,\n",((flags&0x80)?"true":"false"));
    fprintf(fp,"\"throw\":%s,\n",((flags&0x40)?"true":"false"));
    fprintf(fp,"\"pirate_index\":%d,\n",(flags&0x30>>4));
    fprintf(fp,"\"pickable\":%s,\n",((flags&0x08)?"true":"false"));
    fprintf(fp,"\"pickable_index\":%d,\n",(flags&0x07));
    fprintf(fp,"},\n");
  }
  fprintf(fp,"];\n");

  fclose(fp);
  printf("Map data generated!\n");
}

int loop_sdl() {
	clear_window();
  draw_editor();
	SDL_RenderPresent(renderer);

	SDL_Event event;
	Uint8 button = 0;
  int redraw = 0;

	int exitloop = 0;
	do {
		if(!SDL_WaitEvent(&event)) {
			fprintf(stderr, "[E] Wait event error: %s\n", SDL_GetError());
			return -1;
		}

		switch(event.type) {
			case SDL_QUIT:
				exitloop=1;
				break;
			case SDL_WINDOWEVENT:
				//printf("event:%d\n",event.window.event);
				switch(event.window.event) {
					case SDL_WINDOWEVENT_EXPOSED:
					case SDL_WINDOWEVENT_MOVED:
						SDL_RenderPresent(renderer);
						break;
				}
				break;
			case SDL_MOUSEBUTTONDOWN:
				{
					button = event.button.button;
					Sint32 mouseX = event.button.x;
					Sint32 mouseY = event.button.y;

					switch(button) {
						case SDL_BUTTON_LEFT:
              if(valid_room_view_position(mouseX, mouseY)){
                select_room_tile(mouseX, mouseY);
              } else {
                cursor_x = cursor_y = -1;
              }
              if(valid_tile_view_position(mouseX, mouseY)){
                select_tile(mouseX, mouseY);
              } else {
                selected_tile = -1;
              }
              if(valid_minimap_position(mouseX, mouseY)){
                select_minimap_room(mouseX, mouseY);
              }
              handle_buttons(mouseX, mouseY);
              redraw = 1;
							break;
						case SDL_BUTTON_RIGHT:
							break;
					}
				}
				break;
			case SDL_MOUSEBUTTONUP:
				button = 0;
				break;
			case SDL_MOUSEMOTION:
				{
					Sint32 mouseX = event.motion.x;
					Sint32 mouseY = event.motion.y;

					switch(button) {
						case SDL_BUTTON_LEFT:
							break;
						case SDL_BUTTON_RIGHT:
							break;
					}
				}
				break;
			case SDL_KEYDOWN:
				{
					//u32 shift = event.key.keysym.mod  & KMOD_SHIFT;
					switch(event.key.keysym.sym) {
            case SDLK_PERIOD:
              break;
            case SDLK_COMMA:
              break;
						case SDLK_ESCAPE:   // exit
							exitloop=1;
							break;
						case SDLK_F1:   // show help
							break;
						case SDLK_F2:   // load sprite
							break;
						case SDLK_F3:   // save sprite
							break;
						case SDLK_LEFT:
              if((current_room%8)-1<0){
                current_room = (current_room&0xf8)+7;
              } else {
                current_room --;
              }
              redraw = 1;
              break;
						case SDLK_RIGHT:
              if((current_room%8)+1>7){
                current_room = current_room-(current_room%8);
              } else {
                current_room ++;
              }
              redraw = 1;
							break;
						case SDLK_UP:
              if((current_room-8)<0){
                 current_room = (64-8)+(current_room%8);
              } else {
                current_room -= 8;
              }
              redraw = 1;
							break;
						case SDLK_DOWN:
              if(current_room+8>63){
                current_room = current_room%8;
              } else {
                current_room += 8;
              }
              redraw = 1;
							break;
						case SDLK_F11:
              generate_room_json();
							break;
						case SDLK_F12:
              make_atlas_bitmap();
							break;
					}
				}
				break;
		}

    if(redraw){
      draw_editor();
      SDL_RenderPresent(renderer);
      redraw = 0;
    }

	} while(!exitloop);

	return 0;
}

void read_prg_file(const char* pfile){
  FILE *fp;
  if(!(fp=fopen(pfile,"rb"))){
    fprintf(stderr, "[ERROR] Prg file could not be opened!\n");
    exit(1);
  }

  fseek(fp, 0, SEEK_END);
  prg_len = (Uint32)ftell(fp);
  fseek(fp, 0, SEEK_SET);
  prg_mem = (Uint8*)malloc(prg_len);
  fread(prg_mem, 1, prg_len, fp);

  fprintf(stderr, "[INFO]: Loaded \"%s\" (size=%d bytes)\n", pfile, prg_len);
  fclose(fp);
}

int main(int ac, char **av) {

	int i;
	char *ptr;

	for(i=1; i<ac;++i) {
		ptr = av[i];
		if(*ptr == '-') {
			ptr += 2;
			switch(ptr[-1]) {
				case 'h':
					usage(av[0]);
					return 0;
				default:
					fprintf(stderr, "[E] Unknown option '%c'\n", ptr[-1]);
					return 1;
			}
		} else {
			strcpy(prg_file, ptr);
		}
	}

	if(i > ac) {
		fprintf(stderr, "[E] Missing parameter!\n");
		usage(av[0]);
		return 1;
	}

	if(!prg_file) {
		fprintf(stderr, "[E] Treasure Island prg image is not provided\n");
		usage(av[0]);
		return 1;
	}

	if(-1 == init_sdl()) {
		return 1;
	}

  read_prg_file(prg_file);
  convert_tiles_and_sprites();
#if 0
  dump_rooms();
#endif

	loop_sdl();

	return 0;
}
// vim: ts=2 sts=2 sw=2 et ai

