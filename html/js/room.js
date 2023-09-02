// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class Room {
    // private
    #game;
    #cached;
    #graphics;
    #background_cache;
    #pickable_positions; #pickable_points; #pickable_hb;
    #pirate_positions;
    #pickable;
    #pirates; #pirate; #pirate_t; #pirate_hb;
    #map; #score_digits;
    #gps_target; #gps; #gps_on; #gps_t;

    // ctor
    constructor(game) {
        this.#game = game;
        this.#graphics = this.#game.graphics;
        this.#background_cache = this.#game.renderer.backbuffer.cloneNode(true);
        this.#cached = false;
        this.#game.zone.clear();

        this.#pickable_positions = [
            { x: 0x9, y: 0x5 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0xB, y: 0x5 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 },
            { x: 0x0, y: 0x0 }, { x: 0x5, y: 0x5 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0x3, y: 0x9 }, { x: 0xB, y: 0x9 }, { x: 0x9, y: 0x3 }, { x: 0x0, y: 0x0 },
            { x: 0x9, y: 0x3 }, { x: 0x7, y: 0x5 }, { x: 0x3, y: 0x5 }, { x: 0xD, y: 0x9 }, { x: 0xD, y: 0x3 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 },
            { x: 0x0, y: 0x0 }, { x: 0x3, y: 0x3 }, { x: 0x0, y: 0x0 }, { x: 0xD, y: 0x9 }, { x: 0x0, y: 0x0 }, { x: 0xB, y: 0x5 }, { x: 0x5, y: 0x3 }, { x: 0x0, y: 0x0 },
            { x: 0xD, y: 0x5 }, { x: 0x0, y: 0x0 }, { x: 0x9, y: 0x7 }, { x: 0x0, y: 0x0 }, { x: 0x3, y: 0x7 }, { x: 0x3, y: 0x7 }, { x: 0x3, y: 0x5 }, { x: 0x0, y: 0x0 },
            { x: 0x0, y: 0x0 }, { x: 0x9, y: 0x5 }, { x: 0x7, y: 0x5 }, { x: 0x0, y: 0x0 }, { x: 0x3, y: 0x9 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 },
            { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0xD, y: 0x9 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0x7, y: 0x7 }, { x: 0x3, y: 0x3 }, { x: 0x0, y: 0x0 },
            { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0x3, y: 0x5 }, { x: 0x7, y: 0x5 }, { x: 0x9, y: 0x7 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 }, { x: 0x0, y: 0x0 },
        ];

        this.#pirate_positions = [
            { x: 0xE, y: 0x5 }, { x: 0x3, y: 0x9 }, { x: 0x3, y: 0x9 }, { x: 0x5, y: 0x5 }, { x: 0xE, y: 0x5 }, { x: 0x5, y: 0x9 }, { x: 0x5, y: 0x9 }, { x: 0x5, y: 0x5 },
            { x: 0x7, y: 0x3 }, { x: 0xE, y: 0x9 }, { x: 0x3, y: 0x5 }, { x: 0xE, y: 0x9 }, { x: 0x5, y: 0x3 }, { x: 0x5, y: 0x9 }, { x: 0x7, y: 0x3 }, { x: 0x7, y: 0x7 },
            { x: 0xD, y: 0x1 }, { x: 0x3, y: 0x5 }, { x: 0x9, y: 0x5 }, { x: 0x7, y: 0x9 }, { x: 0x3, y: 0x7 }, { x: 0xE, y: 0x5 }, { x: 0xD, y: 0x9 }, { x: 0x3, y: 0x3 },
            { x: 0x9, y: 0x9 }, { x: 0xB, y: 0x5 }, { x: 0x3, y: 0x3 }, { x: 0x5, y: 0x3 }, { x: 0x3, y: 0x3 }, { x: 0x3, y: 0x9 }, { x: 0x3, y: 0x9 }, { x: 0x3, y: 0x3 },
            { x: 0x0, y: 0x0 }, { x: 0xE, y: 0x3 }, { x: 0xE, y: 0x3 }, { x: 0xE, y: 0x3 }, { x: 0xB, y: 0x3 }, { x: 0xE, y: 0x3 }, { x: 0xD, y: 0xB }, { x: 0x7, y: 0x7 },
            { x: 0xB, y: 0x1 }, { x: 0x9, y: 0x9 }, { x: 0x5, y: 0x3 }, { x: 0xB, y: 0x1 }, { x: 0x3, y: 0x3 }, { x: 0xE, y: 0x9 }, { x: 0x9, y: 0x5 }, { x: 0x3, y: 0x3 },
            { x: 0xE, y: 0x9 }, { x: 0x3, y: 0x3 }, { x: 0x3, y: 0x3 }, { x: 0xB, y: 0xB }, { x: 0xB, y: 0x9 }, { x: 0xE, y: 0x3 }, { x: 0x3, y: 0x7 }, { x: 0x0, y: 0x0 },
            { x: 0x9, y: 0x7 }, { x: 0x9, y: 0x3 }, { x: 0x0, y: 0x0 }, { x: 0x5, y: 0x3 }, { x: 0x0, y: 0x0 }, { x: 0x5, y: 0x7 }, { x: 0xE, y: 0x3 }, { x: 0x3, y: 0x7 },
        ];

        this.#score_digits = [
            new Sprite(this.#graphics, 256 + 0 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 1 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 2 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 3 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 4 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 5 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 6 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 7 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 8 * 8, 136, 8, 8),
            new Sprite(this.#graphics, 256 + 9 * 8, 136, 8, 8),
        ];

        this.#gps = [
            //left
            new Sprite(this.#graphics, 256 + 16 * 0, 164, 16, 16),
            // right
            new Sprite(this.#graphics, 256 + 16 * 1, 164, 16, 16),
            // up
            new Sprite(this.#graphics, 256 + 16 * 2, 164, 16, 16),
            // down
            new Sprite(this.#graphics, 256 + 16 * 3, 164, 16, 16),
        ];

        this.#pickable_points = [
            { p: 0x05, t: 'key' },
            { p: 0x02, t: 'spade' },
            { p: 0x03, t: 'barell' },
            { p: 0x02, t: 'skull' },
            { p: 0x02, t: 'cheese' },
            { p: 0x00, t: 'sword' }
        ];

        Object.defineProperty(this, 'pirate', { get: () => { return { x: this.#pirate_hb.x, y: this.#pirate_hb.y } } });

        // deep copy of the MAP array (is there any better way?)
        this.#map = JSON.parse(JSON.stringify(MAP));
        this.#game.map = this.#map;
    }

    enter = (room) => {
        this.#pickable = false;
        this.#pirates = false;
        this.#cached = false;
        this.#game.zone.clear();
        // Do not activate pickable items and pirate if the actor has found the chest
        if (this.#game.chest_found) return;
        if (this.#map[room].pickable) {
            this.#pickable = this.#map[room].pickable_index == 5
                ? new Sprite(this.#graphics, 128, 384, 32, 32) // sword
                : new Sprite(this.#graphics, this.#map[room].pickable_index * 32, 256, 32, 32);

            const pos = this.#pickable_positions[room];
            this.#pickable_hb = { x: ((pos.x * 16) - 8), y: ((pos.y * 16) - 8), w: 16, h: 16 };
        }
        if (this.#map[room].pirate) {
            this.#pirates = [
                new Sprite(this.#graphics, (this.#map[room].pirate_index * 4 * 32) + 0 * 32, 352, 32, 32),
                new Sprite(this.#graphics, (this.#map[room].pirate_index * 4 * 32) + 1 * 32, 352, 32, 32),
                new Sprite(this.#graphics, (this.#map[room].pirate_index * 4 * 32) + 2 * 32, 352, 32, 32),
                new Sprite(this.#graphics, (this.#map[room].pirate_index * 4 * 32) + 3 * 32, 352, 32, 32),
            ];
            const pos = this.#pirate_positions[room];
            this.#pirate_hb = { x: ((pos.x * 16) - 8), y: ((pos.y * 16) - 8), w: 16, h: 22 };
            this.#pirate = 0;
            this.#pirate_t = 0;
        }

        this.#gps_on = true;
        this.#gps_t = 0;
    }

    #print_score = (ctx) => {
        var s = this.#game.score, d;

        d = ~~(s / 100); s -= d * 100;
        this.#score_digits[d].draw(ctx, 272 + 0 * 8 - 1, 112);

        d = ~~(s / 10); s -= d * 10;
        this.#score_digits[d].draw(ctx, 272 + 1 * 8 - 1, 112);

        d = s;
        this.#score_digits[d].draw(ctx, 272 + 2 * 8 - 1, 112);
    }

    exit = (room) => {

    }

    update = (dt, room) => {
        if (this.#map[room].pirate && this.#pirates) {
            // animate pirate
            this.#pirate_t += dt;
            if (this.#pirate_t > 0.1) {
                this.#pirate_t = 0;
                this.#pirate = (this.#pirate + 1) % 4;
            }
        }

        // this.#gps_t += dt;
        // if (this.#gps_t > 0.0125) {
        //     this.#gps_t = 0;
        //     this.#gps_on = !this.#gps_on;
        // }
    }

    check_hit = (room, actor) => {
        if (this.#map[room].pirate && this.#pirates) {
            if (Sprite.aabb(this.#pirate_hb, actor.hb)) {
                return 'pirate';
            }
        }

        if (this.#map[room].pickable && this.#pickable) {
            if (Sprite.aabb(this.#pickable_hb, actor.hb)) {
                return 'pickable';
            }
        }
        return 'none';
    }

    check_pirate = (room, hb) => this.#map[room].pirate && Sprite.aabb(this.#pirate_hb, hb);

    can_pirate_throw_sword = (room, actor) => {
        return ((this.#map[room].pirate && this.#map[room].throw) && ((actor.x > this.#pirate_hb.x) && (Math.abs(this.#pirate_hb.x + 10 - actor.x) < 64) ||
            (Math.abs(this.#pirate_hb.x - actor.x) < 64)) && (Math.abs(actor.y - this.#pirate_hb.y) < 10));
    }

    pirate_throw_sword = (room) => {
        this.#map[room].throw = false;
    }

    kill_pirate = (room) => {
        this.#map[room].pirate = false;
        this.#game.add_to_score(1);
        this.#game.sfx_01.play();
    }

    pickup_object = (room) => {
        this.#map[room].pickable = false;
        const item = this.#pickable_points[this.#map[room].pickable_index];
        this.#game.add_to_score(item.p);
        this.#game.sfx_00.play();
        return item.t;
    }

    show_chest = () => {
        // Show treasure chest on map
        this.#map[0].tiles[37] = 0x16;
    }

    open_the_gate = () => {
        // Open the gate to ship
        this.#map[32].tiles[28] = 0x00;
    }

    // check if the gate to the ship is open
    is_gate_open = () => this.#map[32].tiles[28] == 0x00;

    find_path = (room, actor) => {
        // find room's global position
        const rx = ~~(room % 8) * 8;
        const ry = ~~(room / 8) * 6;

        // find actor's global position
        const sx = rx + ~~(actor.x / 32);
        const sy = ry + ~~(actor.y / 32);

        // first find the path to the nearest pickable object ...
        const result = new PriorityQueue((a, b) => b.length > a.length);
        for (let r = 0; r < 64; ++r) {
            // the room has pickable ?
            if (this.#map[r].pickable) {
                const p = this.#map[r].pickable_index;
                // skip swords .. for now
                if (p == 5) continue;
                const px = (this.#pickable_positions[r].x * 16) - 8, py = (this.#pickable_positions[r].y * 16) - 8;
                const tx = ~~(px / 32), ty = ~~(py / 32);
                // calculate pickable global position
                const ex = ~~(r % 8) * 8 + tx;
                const ey = ~~(r / 8) * 6 + ty;
                // find the nearest path
                const path = Util.path_finding(this.#map, sx, sy, ex, ey);
                if (path.length != 0) { // ignore if path could not be found (this should not happen!)
                    result.push(path);
                }
            }
        }

        let path;
        if (result.isEmpty()) {
            if (!this.#game.chest_found) {
                // ... if there is no pickable left, try the chest
                path = Util.path_finding(this.#map, sx, sy, 6, 4);
            } else if (this.is_gate_open()) {
                // .. or try the gate to the ship if chest has been found
                path = Util.path_finding(this.#map, sx, sy, 5, 27);
            } else {
                this.#gps_target = false; //we should not get here!
                return;
            }
        } else {
            path = result.pop();
        }

        for (let i = 0; i < path.length; ++i) {
            // find the tile which is on the edge of the room
            const tx = path[i].x, ty = path[i].y;
            // console.log(`tx=${tx}, ty=${ty}`);
            if (tx < rx || tx >= rx + 8 || ty < ry || ty >= ry + 6) {
                if (i > 0) {
                    const cx = path[i - 1].x;
                    const cy = path[i - 1].y;
                    // calculate room-tile position
                    const x = cx % 8, y = cy % 6;
                    let d;
                    if (cx > tx)
                        d = Actor.LEFT;
                    else if (cx < tx)
                        d = Actor.RIGHT;
                    else if (cy > ty)
                        d = Actor.UP;
                    else if (cy < ty)
                        d = Actor.DOWN;

                    // console.log(`cx=${cx}, cy=${cy}, x=${x}, y=${y}, d=${d}`);
                    this.#gps_target = { x: x, y: y, d: d };
                    return;

                } else {
                    // we are in the same room where the pickable is
                }
            }
        }
        this.#gps_target = false;
    }

    draw = (ctx, room) => {
        if (this.#cached) {
            // render cached background
            ctx.drawImage(this.#background_cache, 0, 0);
        } else {
            // render room tiles
            for (var y = 0; y < 6; ++y) {
                for (var x = 0; x < 8; ++x) {
                    const t = this.#map[room].tiles[y * 8 + x];
                    const ty = ~~(t / 8) * 32, tx = ~~(t % 8) * 32;
                    ctx.drawImage(this.#graphics, tx, ty, 32, 32, x * 32, y * 32, 32, 32);
                    if (t != 0) {
                        var name = 'wall'
                        if (t == 0x16) {
                            name = 'chest';
                        }
                        this.#game.zone.add({ t: name, x: x * 32, y: y * 32, w: 32, h: 32 });
                    }
                }
            }

            if (room == 32) {
                // the gate is open?
                if (this.#map[32].tiles[28] == 0) {
                    // add hit zone
                    this.#game.zone.add({ t: 'ship', x: 3 * 32, y: 3 * 32, w: 32, h: 32 });
                }
            }

            // draw score panel
            ctx.drawImage(this.#graphics, 256, 0, 64, 136, 256, 16, 64, 136);

            // cache the rendered screen
            this.#background_cache.getContext("2d", { alpha: false }).drawImage(this.#game.renderer.backbuffer, 0, 0);
            this.#cached = true;
        }

        if (this.#gps_target && this.#gps_on) {
            this.#gps[this.#gps_target.d].draw(ctx, this.#gps_target.x * 32 + 8, this.#gps_target.y * 32 + 8);
        }

        (this.#map[room].pickable && this.#pickable) && this.#pickable.draw(ctx, this.#pickable_hb.x, this.#pickable_hb.y);
        (this.#map[room].pirate && this.#pirates) && this.#pirates[this.#pirate].draw(ctx, this.#pirate_hb.x, this.#pirate_hb.y);

        this.#print_score(ctx);

        //this.#map[room].pirate && Sprite.debug(ctx, this.#pirate_hb);

        //this.#game.zone.debug(ctx);
    }
}