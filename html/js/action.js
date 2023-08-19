// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class ActionScene extends Scene {
    // private
    #input;
    #room;
    #current_room;
    #actor;
    #swords;
    #actor_sword; #actor_sword_pos; #actor_sword_range;
    #pirate_sword; #pirate_sword_pos; #pirate_sword_range; #pirate_sword_down_y;

    #actor_next_x; #actor_next_y; #actor_next_r;
    #actor_prev_x; #actor_prev_y; #actor_prev_r;

    #jls_delay; #jls_active; #jls;

    // ctor
    constructor(game) {
        super(game);

        this.#input = this.game.input;
        this.#swords = [
            //left
            new Sprite(this.game.graphics, 0, 384, 32, 32),
            // right
            new Sprite(this.game.graphics, 128, 384, 32, 32),
            // up
            new Sprite(this.game.graphics, 256, 384, 32, 32),
            // down
            new Sprite(this.game.graphics, 288, 384, 32, 32),
        ];
    }

    // Initialize the scene
    init = () => {
        // reset score
        this.game.score = 0;
        this.game.chest_found = false;
        this.#jls_active = false;
        this.#actor = new Actor(this.game);
        this.#jls = new JLS(this.game);

        // actor sprite start position x,y
        this.#actor.x = this.#actor_next_x = this.#actor_prev_x = 208;
        this.#actor.y = this.#actor_next_y = this.#actor_prev_y = 40;
        // start room
        this.#current_room = this.#actor_next_r = this.#actor_prev_r = 0x38;

        this.#room = new Room(this.game);
        this.#room.enter(this.#current_room);

        // sword for actor
        this.#actor_sword = false;
        this.#actor_sword_pos = false;
        this.#actor_sword_range = 0;

        // sword for pirate
        this.#pirate_sword = false;
        this.#pirate_sword_pos = false;
        this.#pirate_sword_range = 0;
    }

    // Unused
    teardown = () => { }

    // Change room
    #change_room = (new_room) => {
        // remove the active actor sword if the room was changed
        this.#actor_sword = false;
        this.#pirate_sword = false;
        this.#room.exit(this.#current_room);
        this.#current_room = new_room;
        this.#room.enter(this.#current_room);

        //Delay until JLS enters the scene
        this.#jls_delay = (this.game.chest_found) ? 1000 : 0;
        this.#jls_active = false;
    }

    // Save the Actor's previous position
    #save_actor_position = () => {
        this.#actor_prev_x = this.#actor_next_x;
        this.#actor_prev_y = this.#actor_next_y;
        this.#actor_prev_r = this.#actor_next_r;
        this.#actor_next_x = this.#actor.x;
        this.#actor_next_y = this.#actor.y;
        this.#actor_next_r = this.#current_room;
    }

    // Restore Actor's previous position
    #restore_actor_position = () => {
        this.#actor.x = this.#actor_next_x = this.#actor_prev_x;
        this.#actor.y = this.#actor_next_y = this.#actor_prev_y;
        this.#actor_next_r = this.#actor_prev_r;
        this.#change_room(this.#actor_prev_r);
    }

    // calculate sword's current hitbox
    #sword_hb = (pos) => { return { x: pos.x, y: pos.y, w: 16, h: 16 }; }

    // Actor died
    // If there is no more HP, exit to title screen
    // otherwise, restore Actor's previous valid position
    #actor_die = () => {
        this.#actor.dec_hp();
        this.game.sfx_00.play();
        if (this.#actor.killed) {
            this.game.setNextScene(Game.TITLE_SCENE);
        } else {
            this.#restore_actor_position();
        }
    }

    // Check if the actor has thrown the sword.
    // If the sword is thrown then move it
    #actor_sword_throw = (dt) => {
        if (this.#input.isDown(Input.KEY_SPACE) && this.#actor.has_sword) {
            // the actor has thrown the sword
            this.#actor_sword = this.#swords[this.#actor.direction];
            var x, y, dx, dy;
            switch (this.#actor.direction) {
                case Actor.LEFT:
                    dx = -Sword.SPEED;
                    dy = 0;
                    x = this.#actor.x - 16;
                    y = this.#actor.y;
                    break;
                case Actor.RIGHT:
                    dx = Sword.SPEED;
                    dy = 0;
                    x = this.#actor.x + 16;
                    y = this.#actor.y;
                    break;
                case Actor.UP:
                    dx = 0;
                    dy = -Sword.SPEED;
                    x = this.#actor.x;
                    y = this.#actor.y - 2;
                    break;
                case Actor.DOWN:
                    dx = 0;
                    dy = Sword.SPEED;
                    x = this.#actor.x;
                    y = this.#actor.y;
                    break;
            }
            this.#actor_sword_pos = { x: x, y: y, dx: dx, dy: dy, d: this.#actor.direction };
            this.#actor_sword_range = 64;
            this.#actor.has_sword = false;
        }

        if (this.#actor_sword) {
            this.#actor_sword_pos.x += dt * this.#actor_sword_pos.dx;
            this.#actor_sword_pos.y += dt * this.#actor_sword_pos.dy;
            const sword_hb = this.#sword_hb(this.#actor_sword_pos);

            // limit the range
            this.#actor_sword_range--;

            const zone = this.game.zone.hit(sword_hb);
            // check if the sword hits the wall or the edge of the playfield or the pirate
            if (this.#room.check_pirate(this.#current_room, sword_hb)) {
                this.#room.kill_pirate(this.#current_room);
                this.#actor_sword = false;
            } else if (this.#actor_sword_range == 0 || zone.includes('wall')
                || this.#actor_sword_pos.x < 2
                || this.#actor_sword_pos.y < 2
                || this.#actor_sword_pos.x > 235
                || this.#actor_sword_pos.y > 180) {
                this.#actor_sword = false;
            }
        }
    }

    // Check if the pirate has thrown the sword.
    // If the sword is thrown then move it
    #pirate_sword_throw = (dt) => {
        if (this.#pirate_sword && (this.#pirate_sword_pos.dx != 0 || this.#pirate_sword_pos.dy != 0)) {
            this.#pirate_sword_pos.x += dt * this.#pirate_sword_pos.dx;
            this.#pirate_sword_pos.y += dt * this.#pirate_sword_pos.dy;
            const sword_hb = this.#sword_hb(this.#pirate_sword_pos);

            // console.log(`X=${this.#pirate_sword_pos.x}, R=${this.#pirate_sword_range}`);

            // limit the range
            if (~~Math.abs(this.#pirate_sword_range - this.#pirate_sword_pos.x) <= 0) {
                this.#pirate_sword_range = 0;
            }

            const zone = this.game.zone.hit(sword_hb);
            if (this.#pirate_sword_range == 0) {
                this.#pirate_sword_pos.dy = Sword.SPEED;
                this.#pirate_sword_pos.dx = 0;
                if (this.#pirate_sword_pos.y > this.#pirate_sword_down_y) {
                    this.game.sfx_03.play();
                    this.#pirate_sword_pos.dy = 0;
                }
            } else if (zone.includes('wall')
                || this.#pirate_sword_pos.x < 2
                || this.#pirate_sword_pos.y < 2
                || this.#pirate_sword_pos.x > 235
                || this.#pirate_sword_pos.y > 180) {
                this.#pirate_sword_range = 0;
            }
        }

        if (!this.#pirate_sword && this.#room.can_pirate_throw_sword(this.#current_room, this.#actor)) {
            var x, y, dx;
            // pirate throws sword
            if (this.#actor.x < this.#room.pirate.x) {
                // fire left
                this.#pirate_sword = this.#swords[Actor.LEFT];
                x = this.#room.pirate.x;
                y = this.#room.pirate.y + 2;
                dx = -Sword.SPEED2;
                this.#pirate_sword_range = x - 48 * 2 - 6;
            } else {
                // fire right
                this.#pirate_sword = this.#swords[Actor.RIGHT];
                x = this.#room.pirate.x;
                y = this.#room.pirate.y + 2;
                dx = Sword.SPEED2;
                this.#pirate_sword_range = x + 48 * 2 + 10;
            }
            this.#pirate_sword_pos = { x: x, y: y, dx: dx, dy: 0, d: this.#actor.direction };
            this.#pirate_sword_down_y = y + 4;

            // console.log(`(start) X=${this.#pirate_sword_pos.x}, R=${this.#pirate_sword_range}`);
        }

        if (this.#pirate_sword) {
            if (Sprite.aabb(this.#actor.hb, this.#sword_hb(this.#pirate_sword_pos))) {
                this.#pirate_sword = false;
                if (!this.game.cheat_is_on && this.#pirate_sword_range != 0) {
                    this.#actor_die();
                } else {
                    this.game.sfx_02.play();
                    this.#room.pirate_throw_sword(this.#current_room);
                    this.#actor.has_sword = true;
                }
            }
        }
    }

    // checking if the actor has collided with something
    #check_actor_collided = () => {
        switch (this.#room.check_hit(this.#current_room, this.#actor)) {
            case 'pirate':
                if (!this.game.cheat_is_on) {
                    this.#actor_die();
                }
                break;
            case 'pickable':
                switch (this.#room.pickup_object(this.#current_room)) {
                    case 'sword':
                        this.#actor.has_sword = true;
                        break;
                    case 'key':
                        this.#room.show_chest();
                        break;
                    case 'barrel':
                    case 'cheese':
                    case 'spade':
                    case 'skull':
                        break;
                }
                break;
            default:
                break;
        }
    }

    // Update scene
    update = (dt) => {
        // Exit to tite scene if Esc key is pressed
        if (this.#input.isPressed(Input.KEY_ESCAPE)) {
            this.game.setNextScene(Game.TITLE_SCENE);
            return;
        }

        if (!this.game.chest_found) {
            this.#actor_sword_throw(dt);
            this.#pirate_sword_throw(dt);
        } else if (!this.#jls_active && this.#jls_delay > 0) {
            this.#jls_delay -= dt * 1000;
            if (this.#jls_delay < 0) {
                // JLS enters the scene
                this.#jls_active = true;
                this.#jls.x = this.#actor_next_x;
                this.#jls.y = this.#actor_next_y;
            }
        }

        if (!this.#actor.halt) {
            // Actor control
            if (this.#input.isDown(Input.KEY_LEFT)) {
                this.#actor.go_left(dt);
            } else if (this.#input.isDown(Input.KEY_RIGHT)) {
                this.#actor.go_right(dt);
            } else if (this.#input.isDown(Input.KEY_UP)) {
                this.#actor.go_up(dt);
            } else if (this.#input.isDown(Input.KEY_DOWN)) {
                this.#actor.go_down(dt);
            } else {
                this.#actor.idle(dt);
            }
        }

        if (this.#actor.win) {
            this.game.setNextScene(Game.TITLE_SCENE);
            return;
        }

        // checking exits
        if (this.#actor.y < 2) {
            // top
            this.#actor.y = 160;
            this.#change_room(this.#current_room - 8);
            this.#save_actor_position();
        } else if (this.#actor.y > 166) {
            // bottom
            this.#actor.y = 4;
            this.#change_room(this.#current_room + 8);
            this.#save_actor_position();
        } else if (this.#actor.x < 2) {
            // left
            this.#actor.x = 224;
            this.#change_room(this.#current_room - 1);
            this.#save_actor_position();
        } else if (this.#actor.x > 230) {
            // right
            this.#actor.x = 4;
            this.#change_room(this.#current_room + 1);
            this.#save_actor_position();
        } else {

            // update room animations
            this.#room.update(dt, this.#current_room);

            // checking if the actor has collided with something
            this.#check_actor_collided();

            // chase the actor ;-)
            if (this.#jls_active && !this.#actor.halt) {
                if (this.#jls.chase(dt, this.#actor)) {
                    // the actor was caught by JLS
                    if (!this.game.cheat_is_on) {
                        this.#actor_die();
                    }
                }
            }
        }
    }

    draw = (ctx) => {
        this.#room.draw(ctx, this.#current_room);

        this.#actor_sword && this.#actor_sword.draw(ctx, this.#actor_sword_pos.x, this.#actor_sword_pos.y);
        this.#pirate_sword && this.#pirate_sword.draw(ctx, this.#pirate_sword_pos.x, this.#pirate_sword_pos.y);

        this.#jls_active && this.#jls.draw(ctx);

        this.#actor.draw(ctx);

        // this.#pirate_sword && Sprite.debug(ctx, this.#sword_hb(this.#pirate_sword_pos));
        //this.#actor_sword && Sprite.debug(ctx, this.#sword_hb(this.#actor_sword_pos));
    }
}

var Sword = {};
Sword.SPEED = 100;
Sword.SPEED2 = 100; // from pirate
Sword.SIZE = 16;
