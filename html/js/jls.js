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
    #f; #t; #up_down; #left_right;

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
        this.#direction = this.#chase_direction= Actor.RIGHT;
        this.#jls_x = 0;
        this.#jls_y = 0;
        this.#f = 0;
        this.#t = 0;
        this.#up_down = false;
        this.#left_right = false;
    }

    chase = (dt, actor) => {
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

        // change direction
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

        if (Sprite.aabb(this.#hitbox(), actor.hb)) {
            return true;
        }

        return false;
    }

    // calculate jls's current hitbox
    #hitbox = () => { return { x: this.#jls_x, y: this.#jls_y, w: 16, h: 16 }; }

    #go_left = (dt) => {
        this.#t += dt;
        if (this.#t > 0.030) {
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
        if (this.#t > 0.030) {
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
    }
}

JLS.SPEED = 70;
