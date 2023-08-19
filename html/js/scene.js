// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class Scene {
    // private
    #game;

    // ctor
    constructor(game) {
        this.#game = game;

        Object.defineProperty(this, 'game', {
            get: () => {
                return this.#game;
            }
        });
    }

    // virtual methods
    init = () => { };
    teardown = () => { };
    update = (dt) => { };
    draw = (ctx) => { };
}