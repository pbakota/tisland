// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class Menu {
    // private
    #game; #input;
    #font;
    #origin_x; #origin_y;
    #selected;

    // ctor
    constructor(game) {
        this.#game = game;
        this.#input = this.#game.input;
        this.#font = new Font(this.#game);

        this.#origin_x = 32;
        this.#origin_y = 36;
        this.#selected = 0;
    }

    init = () => {
        this.#selected = 0;
    }

    handle = (dt) => {
        if (this.#input.isPressed(Input.KEY_RETURN) || this.#input.isPressed(Input.KEY_SPACE)) {
            // menu select
            switch (this.#selected) {
                case 0:
                    this.#game.superhero_jim = !this.#game.superhero_jim;
                    break;
                case 1:
                    this.#game.inteligent_jls = !this.#game.inteligent_jls;
                    break;
                case 2:
                    this.#game.use_gps_navigation = !this.#game.use_gps_navigation;
                    break;
                case 4:
                    return true;
            }
        }

        if (this.#input.isPressed(Input.KEY_ESCAPE)) {
            return true;
        }

        if (this.#input.isPressed(Input.KEY_UP)) {
            if (this.#selected > 0) {
                this.#selected --;
                if (this.#selected == 3) {
                    this.#selected = 2;
                }
            }
        } else if (this.#input.isPressed(Input.KEY_DOWN)) {
            if (this.#selected < 4) {
                this.#selected++;
                if (this.#selected == 3) {
                    this.#selected = 4;
                }
            }
        }

        return false;
    }

    #draw_window = (ctx, x, y, w, h, bcolor) => {
        ctx.save();
        ctx.fillStyle = bcolor;
        ctx.fillRect(x, y, w, h);
        ctx.fillStyle = "black";
        ctx.fillRect(x + 4, y + 4, w - 8, h - 8);
        ctx.restore();
    }

    draw = (ctx) => {
        ctx.save();
        this.#draw_window(ctx, this.#origin_x, this.#origin_y, 256, 128, 'green');

        this.#font.print(ctx, this.#origin_x + (256 - 10 * 8) / 2, this.#origin_y + 16, "game menu");

        this.#font.print(ctx, this.#origin_x + 20, this.#origin_y + 48 + 0 * 9, "superhero jim");
        this.#font.print(ctx, this.#origin_x + 200, this.#origin_y + 48 + 0 * 9, (this.#game.superhero_jim ? "yes" : "no"));
        this.#font.print(ctx, this.#origin_x + 20, this.#origin_y + 48 + 1 * 9, "inteligent j.l.s");
        this.#font.print(ctx, this.#origin_x + 200, this.#origin_y + 48 + 1 * 9, (this.#game.inteligent_jls ? "yes" : "no"));
        this.#font.print(ctx, this.#origin_x + 20, this.#origin_y + 48 + 2 * 9, "use gps navigation");
        this.#font.print(ctx, this.#origin_x + 200, this.#origin_y + 48 + 2 * 9, (this.#game.use_gps_navigation ? "yes" : "no"));

        this.#font.print(ctx, this.#origin_x + 20, this.#origin_y + 48 + 4 * 9, "back to game");

        this.#font.print(ctx, this.#origin_x + 10, this.#origin_y + 48 + this.#selected * 9, ">");
        ctx.restore();
    }
}