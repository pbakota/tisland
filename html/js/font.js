// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT


"use strict";

class Font {
    // private
    #game; #graphics; #font;

    // ctor
    constructor(game) {
        this.#game = game;
        this.#graphics = this.#game.graphics;
        this.#font = [];

        this.#font[' '] = new Sprite(this.#graphics, 160 + 0 * 8, 256, 8, 8);
        this.#font['A'] = new Sprite(this.#graphics, 160 + 1 * 8, 256, 8, 8);
        this.#font['B'] = new Sprite(this.#graphics, 160 + 2 * 8, 256, 8, 8);
        this.#font['C'] = new Sprite(this.#graphics, 160 + 3 * 8, 256, 8, 8);
        this.#font['D'] = new Sprite(this.#graphics, 160 + 4 * 8, 256, 8, 8);
        this.#font['E'] = new Sprite(this.#graphics, 160 + 5 * 8, 256, 8, 8);
        this.#font['F'] = new Sprite(this.#graphics, 160 + 6 * 8, 256, 8, 8);
        this.#font['G'] = new Sprite(this.#graphics, 160 + 7 * 8, 256, 8, 8);
        this.#font['H'] = new Sprite(this.#graphics, 160 + 8 * 8, 256, 8, 8);
        this.#font['I'] = new Sprite(this.#graphics, 160 + 9 * 8, 256, 8, 8);
        this.#font['J'] = new Sprite(this.#graphics, 160 + 10 * 8, 256, 8, 8);
        this.#font['K'] = new Sprite(this.#graphics, 160 + 11 * 8, 256, 8, 8);
        this.#font['L'] = new Sprite(this.#graphics, 160 + 12 * 8, 256, 8, 8);
        this.#font['M'] = new Sprite(this.#graphics, 160 + 13 * 8, 256, 8, 8);
        this.#font['N'] = new Sprite(this.#graphics, 160 + 14 * 8, 256, 8, 8);
        this.#font['O'] = new Sprite(this.#graphics, 160 + 15 * 8, 256, 8, 8);
        this.#font['P'] = new Sprite(this.#graphics, 160 + 16 * 8, 256, 8, 8);
        this.#font['Q'] = new Sprite(this.#graphics, 160 + 17 * 8, 256, 8, 8);
        this.#font['R'] = new Sprite(this.#graphics, 160 + 18 * 8, 256, 8, 8);
        this.#font['S'] = new Sprite(this.#graphics, 160 + 19 * 8, 256, 8, 8);
        this.#font['T'] = new Sprite(this.#graphics, 160 + 20 * 8, 256, 8, 8);
        this.#font['U'] = new Sprite(this.#graphics, 160 + 21 * 8, 256, 8, 8);
        this.#font['V'] = new Sprite(this.#graphics, 160 + 22 * 8, 256, 8, 8);
        this.#font['W'] = new Sprite(this.#graphics, 160 + 23 * 8, 256, 8, 8);
        this.#font['X'] = new Sprite(this.#graphics, 160 + 24 * 8, 256, 8, 8);
        this.#font['Y'] = new Sprite(this.#graphics, 160 + 25 * 8, 256, 8, 8);
        this.#font['Z'] = new Sprite(this.#graphics, 160 + 26 * 8, 256, 8, 8);
        this.#font[':'] = new Sprite(this.#graphics, 160 + 27 * 8, 256, 8, 8);
        this.#font['0'] = new Sprite(this.#graphics, 160 + 28 * 8, 256, 8, 8);
        this.#font['1'] = new Sprite(this.#graphics, 160 + 29 * 8, 256, 8, 8);
        this.#font['2'] = new Sprite(this.#graphics, 160 + 30 * 8, 256, 8, 8);
        this.#font['3'] = new Sprite(this.#graphics, 160 + 31 * 8, 256, 8, 8);
        this.#font['4'] = new Sprite(this.#graphics, 160 + 32 * 8, 256, 8, 8);
        this.#font['5'] = new Sprite(this.#graphics, 160 + 33 * 8, 256, 8, 8);
        this.#font['6'] = new Sprite(this.#graphics, 160 + 34 * 8, 256, 8, 8);
        this.#font['7'] = new Sprite(this.#graphics, 160 + 35 * 8, 256, 8, 8);
        this.#font['8'] = new Sprite(this.#graphics, 160 + 36 * 8, 256, 8, 8);
        this.#font['9'] = new Sprite(this.#graphics, 160 + 37 * 8, 256, 8, 8);
        this.#font['^'] = new Sprite(this.#graphics, 160 + 38 * 8, 256, 8, 8);
        this.#font['>'] = new Sprite(this.#graphics, 160 + 39 * 8, 256, 8, 8);
        this.#font['/'] = new Sprite(this.#graphics, 160 + 40 * 8, 256, 8, 8);
        this.#font['.'] = new Sprite(this.#graphics, 160 + 41 * 8, 256, 8, 8);
        this.#font['!'] = new Sprite(this.#graphics, 160 + 42 * 8, 256, 8, 8);
        this.#font[','] = new Sprite(this.#graphics, 160 + 43 * 8, 256, 8, 8);
    }

    print = (ctx, x, y, txt) => {
        txt = txt.toUpperCase();
        for (let i = 0; i < txt.length; ++i) {
            const c = txt.charAt(i);
            if (this.#font[c]) {
                this.#font[c].draw(ctx, x + i * 8, y);
            } else {
                console.log(`undefined ${c}`);
            }
        }

        ctx.globalCompositeOperation = "source-in";
        ctx.fillStyle = '#ffff00';
        // ctx.fillRect(x, y, x + 8 * txt.length, 8);

        ctx.globalCompositeOperation = "source-over";
    }
}