// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class Zone {
    // private
    #zones;

    // ctor
    constructor() {
        this.clear();
    }

    clear = () => {
        this.#zones = [];
    }

    add = (zone) => {
        this.#zones.push(zone);
    }

    hit = (rect) => {
        var z = [];
        for (var i = 0; i < this.#zones.length; ++i) {
            const zone = this.#zones[i];
            if (Sprite.aabb({ x: zone.x, y: zone.y, w: zone.w, h: zone.h }, rect)) {
                z.push(zone.t);
            }
        }
        return z;
    }

    debug = (ctx) => {
        ctx.strokeStyle = 'red';
        ctx.lineWidth = 1;
        this.#zones.forEach(zone => {
            ctx.beginPath();
            ctx.rect(zone.x, zone.y, zone.w, zone.h);
            ctx.stroke();
        });
    }
}

Zone.NONE = 'none';
