// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class Actor {
    // private
    #game;
    #graphics;
    #actor_left;
    #actor_right;
    #actor_down;
    #actor_up;
    #actor_x; #actor_y;
    #direction;
    #actor_sword;
    #f; #t; #actor_hp; #actor_killed;
    #halt; #win;

    // ctor
    constructor(game) {
        this.#game = game;
        this.#graphics = this.#game.graphics;
        this.#actor_right = [
            new Sprite(this.#graphics, 0, 288, 28, 28),
            new Sprite(this.#graphics, 32 + 4, 288, 28, 28),
            // + sword
            new Sprite(this.#graphics, 128 + 32 + 2, 288, 28, 28),
            new Sprite(this.#graphics, 128, 288, 28, 28),
        ];
        this.#actor_left = [
            new Sprite(this.#graphics, 256, 288, 28, 28),
            new Sprite(this.#graphics, 256 + 32 + 2, 288, 28, 28),
            // + sword
            new Sprite(this.#graphics, 384, 288, 28, 28),
            new Sprite(this.#graphics, 384 + 32 + 2, 288, 28, 28),
        ];
        this.#actor_down = [
            new Sprite(this.#graphics, 0, 320, 28, 28),
            new Sprite(this.#graphics, 0 + 32, 320, 28, 28),
            // + sword
            new Sprite(this.#graphics, 128, 320, 28, 28),
            new Sprite(this.#graphics, 128 + 32, 320, 28, 28),
        ];
        this.#actor_up = [
            new Sprite(this.#graphics, 256, 320, 28, 28),
            new Sprite(this.#graphics, 256 + 32, 320, 28, 28),
            // + sword
            new Sprite(this.#graphics, 384, 320, 28, 28),
            new Sprite(this.#graphics, 384 + 32, 320, 28, 28),
        ];
        this.#direction = Actor.RIGHT;
        this.#actor_sword = 0; // +2 if actor has the sword
        this.#f = 0;
        this.#t = 0;
        this.#actor_hp = 5;
        this.#actor_killed = false;

        Object.defineProperty(this, 'x', {
            get: () => { return this.#actor_x; },
            set: (value) => { this.#actor_x = value; }
        });
        Object.defineProperty(this, 'y', {
            get: () => { return this.#actor_y; },
            set: (value) => { this.#actor_y = value; }
        });
        Object.defineProperty(this, 'killed', {
            get: () => { return this.#actor_killed; },
            set: (value) => { this.#actor_killed = value; }
        });
        Object.defineProperty(this, 'direction', {
            get: () => { return this.#direction; }
        });
        Object.defineProperty(this, 'has_sword', {
            get: () => { return this.#actor_sword == 2; },
            set: (value) => { this.#actor_sword = value ? 2 : 0; }
        });
        Object.defineProperty(this, 'hb', {
            get: () => { return this.#hitbox(); }
        });
        Object.defineProperty(this, 'halt', {
            get: () => { return this.#halt; }
        });
        Object.defineProperty(this, 'win', {
            get: () => { return this.#win; }
        });
        Object.defineProperty(this, 'hp', {
            get: () => { return this.#actor_hp; }
        });
        this.#halt = false;
        this.#win = false;
    }

    // calculate actor's current hitbox
    #hitbox = () => { return { x: this.#actor_x, y: this.#actor_y, w: 18, h: 20 - 2 }; }

    dec_hp = () => {
        this.#actor_hp --;
        if (this.#actor_hp == 0) {
            this.#actor_hp = 0;
            this.#actor_killed = true;
        }
    }

    idle = (dt) => {
    }

    go_left = (dt) => {
        this.#direction = Actor.LEFT;
        this.#t += dt;
        if (this.#t > 0.030) {
            this.#t = 0;
            this.#f = (this.#f + 1) % 2;
        }
        const old = this.#actor_x
        this.#actor_x -= dt * Actor.SPEED;
        const zones = this.#game.zone.hit(this.#hitbox());
        if (zones.includes('wall')||(this.#game.chest_found && zones.includes('chest'))) {
            this.#actor_x = old;
            this.#f = 0;
        }

        if (zones.includes('ship')) {
            // the actor win!
            this.#halt = true;
            this.#game.add_to_score(5 + this.#actor_hp);
            this.#game.music_02.addEventListener('ended', () => {
                this.#game.music_03.addEventListener('ended', () => {
                    this.#win = true;
                }, { once: true });
                this.#game.music_03.play();
            }, { once: true });
            this.#game.music_02.play();
        } else if (!this.#game.chest_found && zones.includes('chest')) {
            // chest found!
            this.#halt = true;
            this.#game.music_01.addEventListener('ended', () => {
                this.#game.music_03.addEventListener('ended', () => {
                    this.#halt = false;
                    this.#game.chest_found = true;
                    this.#game.add_to_score(5);
                    this.#actor_sword = 0; // remove sword
                }, { once: true });
                this.#game.music_03.play();
            }, { once: true });
            this.#game.music_01.play();
        }
    }

    go_right = (dt) => {
        this.#direction = Actor.RIGHT;
        this.#t += dt;
        if (this.#t > 0.030) {
            this.#t = 0;
            this.#f = (this.#f + 1) % 2;
        }
        const old = this.#actor_x;
        this.#actor_x += dt * Actor.SPEED;
        const zones = this.#game.zone.hit(this.#hitbox());
        if (zones.includes('wall')) {
            this.#actor_x = old;
            this.#f = 0;
        }
    }

    go_up = (dt) => {
        this.#direction = Actor.UP;
        this.#t += dt;
        if (this.#t > 0.065) {
            this.#t = 0;
            this.#f = (this.#f + 1) % 2;
        }
        const old = this.#actor_y;
        this.#actor_y -= dt * Actor.SPEED;
        const zones = this.#game.zone.hit(this.#hitbox());
        if (zones.includes('wall')) {
            this.#actor_y = old;
            this.#f = 0;
        }
    }

    go_down = (dt) => {
        this.#direction = Actor.DOWN;
        this.#t += dt;
        if (this.#t > 0.065) {
            this.#t = 0;
            this.#f = (this.#f + 1) % 2;
        }
        const old = this.#actor_y;
        this.#actor_y += dt * Actor.SPEED;
        const zones = this.#game.zone.hit(this.#hitbox());
        if (zones.includes('wall')) {
            this.#actor_y = old;
            this.#f = 0;
        }
    }

    draw = (ctx) => {
        switch (this.#direction) {
            case Actor.LEFT:
                this.#actor_left[this.#f + this.#actor_sword].draw(ctx, ~~(this.#actor_x - 2 * this.#f), this.#actor_y);
                break;
            case Actor.RIGHT:
                this.#actor_right[this.#f + this.#actor_sword].draw(ctx, ~~(this.#actor_x - this.#actor_sword * (1 - this.#f)), this.#actor_y);
                break;
            case Actor.UP:
                this.#actor_up[this.#f + this.#actor_sword].draw(ctx, this.#actor_x, this.#actor_y);
                break;
            case Actor.DOWN:
                this.#actor_down[this.#f + this.#actor_sword].draw(ctx, this.#actor_x, this.#actor_y);
                break;
        }

        // Sprite.debug(ctx, this.#hitbox());
    }
}

Actor.LEFT = 0;
Actor.RIGHT = 1;
Actor.UP = 2;
Actor.DOWN = 3;

Actor.SPEED = 100;