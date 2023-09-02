// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class JLS {
    // private
    #game; #graphics;
    #jls_left;
    #jls_right;
    #jls_down;
    #jls_up;
    #jls_x; #jls_y;
    #direction; #chase_direction;
    #f; #t; #up_down; #path; #target_offset; #old_sx; #old_sy;

    // ctor
    constructor(game) {
        this.#game = game;
        this.#game = game;
        this.#graphics = this.#game.graphics;
        this.#jls_right = [
            new Sprite(this.#graphics, 64, 288, 24, 24),
            new Sprite(this.#graphics, 64 + 32 + 2, 288, 24, 24),
        ];
        this.#jls_left = [
            new Sprite(this.#graphics, 192, 288, 24, 24),
            new Sprite(this.#graphics, 192 + 32 + 2, 288, 24, 24),
        ];
        this.#jls_down = [
            new Sprite(this.#graphics, 320, 288, 24, 24),
            new Sprite(this.#graphics, 320 + 32, 288, 24, 24),
        ];
        this.#jls_up = [
            new Sprite(this.#graphics, 448, 288, 24, 24),
            new Sprite(this.#graphics, 448 + 32, 288, 24, 24),
        ];
        Object.defineProperty(this, 'x', {
            get: () => { return this.#jls_x; },
            set: (value) => { this.#jls_x = value; }
        });
        Object.defineProperty(this, 'y', {
            get: () => { return this.#jls_y; },
            set: (value) => { this.#jls_y = value; }
        });
        this.#direction = this.#chase_direction = Actor.RIGHT;
        this.#jls_x = 0;
        this.#jls_y = 0;
        this.#f = 0;
        this.#t = 0;
        this.#up_down = false;
        this.#path = false;
    }

    init = (room, actor, x, y) => {
        console.log('jls_init');
        this.#jls_x = ~~(x / 32) * 32 + 8;
        this.#jls_y = ~~(y / 32) * 32 + 8;
        this.#old_sx = 0; this.#old_sy = 0;
        if (this.#game.inteligent_jls) {
            this.#target_offset = 0;
            this.#find_new_path(room, actor)
        }
    }

    #find_jls_tile = (rx, ry) => {
        const hb = this.#hitbox();
        return [rx + ~~(((hb.x + hb.w / 2) & 0xffe0) / 32), ry + ~~(((hb.y + hb.h / 2) & 0xffe0) / 32)];
    }

    #find_new_path = (room, actor) => {
        // find room's global position
        const rx = ~~(room % 8) * 8;
        const ry = ~~(room / 8) * 6;

        // find jls's global position
        const [sx, sy] = this.#find_jls_tile(rx, ry);

        // find actor's global position
        const ex = rx + ~~((actor.x + (actor.hb.w / 2)) / 32);
        const ey = ry + ~~((actor.y + (actor.hb.h / 2)) / 32);

        this.#path = false;

        const path = Util.path_finding(this.#game.map, sx, sy, ex, ey);
        if (path.length == 0) return false; // this should never be true, because this means the actor is on unwalkable tile.

        this.#path = path;
    }

    chase = (dt, room, actor) => {
        if (this.#game.inteligent_jls) {

            if (this.#path) {
                const tx = this.#path[0].x % 8;
                const ty = this.#path[0].y % 6;

                if (this.#old_sx == tx && this.#old_sy == ty) {
                    // inside the same tile, go to next tile
                    this.#target_offset = 1;
                } else {
                    // move inside the same tile
                    this.#old_sx = tx; this.#old_sy = ty;
                    this.#target_offset = 0;
                }

                const sx = 32 * (this.#path[this.#target_offset].x % 8) + 4;
                const sy = 32 * (this.#path[this.#target_offset].y % 6) + 4;

                if (sx - this.#jls_x > 5) {
                    this.#chase_direction = Actor.RIGHT;
                } else if (sx - this.#jls_x < -5) {
                    this.#chase_direction = Actor.LEFT;
                } else {
                    if (sy - this.#jls_y > 5) {
                        this.#chase_direction = Actor.DOWN;
                    } else if (sy - this.#jls_y < -5) {
                        this.#chase_direction = Actor.UP;
                    } else {
                        this.#find_new_path(room, actor)
                    }
                }
            } else {
                this.#find_new_path(room, actor);
            }

        } else {
            // change chase direction if applicable
            if (actor.x - this.#jls_x > 5)
                this.#chase_direction = Actor.RIGHT;
            else if (actor.x - this.#jls_x < -5)
                this.#chase_direction = Actor.LEFT;
            else {
                this.#up_down = true;
            }

            if (this.#up_down) {
                if (actor.y - this.#jls_y > 5)
                    this.#chase_direction = Actor.DOWN;
                else if (actor.y - this.#jls_y < -5)
                    this.#chase_direction = Actor.UP;
            }
        }

        switch (this.#chase_direction) {
            case Actor.LEFT:
                this.#go_left(dt);
                break;
            case Actor.RIGHT:
                this.#go_right(dt);
                break;
            case Actor.UP:
                this.#go_up(dt);
                break;
            case Actor.DOWN:
                this.#go_down(dt);
                break;
        }

        if (Sprite.aabb(this.#hitbox(), actor.hb)) {
            return true;
        }

        return false;
    }

    // calculate jls's current hitbox
    #hitbox = () => { return { x: this.#jls_x, y: this.#jls_y, w: 16, h: 16 }; }

    #go_left = (dt) => {
        this.#t += dt;
        if (this.#t > 0.060) {
            this.#t = 0;
            this.#f = (this.#f + 1) % 2;
        }
        const old = this.#jls_x;
        this.#jls_x -= dt * JLS.SPEED;
        const zones = this.#game.zone.hit(this.#hitbox());
        if (zones.includes('wall')) {
            this.#jls_x = old;
            this.#up_down = true;
            this.#f = 0;
        } else {
            this.#direction = Actor.LEFT;
            this.#up_down = false;
        }
    }

    #go_right = (dt) => {
        this.#t += dt;
        if (this.#t > 0.060) {
            this.#t = 0;
            this.#f = (this.#f + 1) % 2;
        }
        const old = this.#jls_x;
        this.#jls_x += dt * JLS.SPEED;
        const zones = this.#game.zone.hit(this.#hitbox());
        if (zones.includes('wall')) {
            this.#jls_x = old;
            this.#up_down = true;
            this.#f = 0;
        } else {
            this.#direction = Actor.RIGHT;
            this.#up_down = false;
        }
    }

    #go_up = (dt) => {
        this.#t += dt;
        if (this.#t > 0.065) {
            this.#t = 0;
            this.#f = (this.#f + 1) % 2;
        }
        var old = this.#jls_y;
        this.#jls_y -= dt * JLS.SPEED;
        const zones = this.#game.zone.hit(this.#hitbox());
        if (zones.includes('wall')) {
            this.#jls_y = old;
            this.#up_down = false;
            this.#f = 0;
        } else {
            this.#direction = Actor.UP;
        }
    }

    #go_down = (dt) => {
        this.#t += dt;
        if (this.#t > 0.065) {
            this.#t = 0;
            this.#f = (this.#f + 1) % 2;
        }
        var old = this.#jls_y;
        this.#jls_y += dt * JLS.SPEED;
        const zones = this.#game.zone.hit(this.#hitbox());
        if (zones.includes('wall')) {
            this.#jls_y = old;
            this.#up_down = false;
            this.#f = 0;
        } else {
            this.#direction = Actor.DOWN;
        }
    }

    draw = (ctx) => {

        switch (this.#direction) {
            case Actor.LEFT:
                this.#jls_left[this.#f].draw(ctx, ~~(this.#jls_x - 2 * this.#f), this.#jls_y);
                break;
            case Actor.RIGHT:
                this.#jls_right[this.#f].draw(ctx, ~~(this.#jls_x + 2 * (1 - this.#f)), this.#jls_y);
                break;
            case Actor.UP:
                this.#jls_up[this.#f].draw(ctx, this.#jls_x, this.#jls_y);
                break;
            case Actor.DOWN:
                this.#jls_down[this.#f].draw(ctx, this.#jls_x, this.#jls_y);
                break;
        }

        // Sprite.debug(ctx, this.#hitbox());

        // if (this.#path) {
        //     Util.path_debug(ctx, path);
        // }

    }
}

JLS.SPEED = 70;
