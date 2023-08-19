// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class TitleScene extends Scene {
    // private
    #input;
    #room;
    #copyright;

    // ctor
    constructor(game) {
        super(game);

        this.#input = this.game.input;
        this.#copyright = new Sprite(this.game.graphics, 256, 144, 134, 20);
    }

    init = () => {
        this.#room = new Room(this.game);
        this.game.music_00.play();
        this.game.music_00.loop = true;
    };

    teardown = () => {
        this.game.music_00.stop();
    };

    update = (dt) => {
        if (this.#input.isPressed(Input.KEY_RETURN) || this.#input.isPressed(Input.KEY_SPACE)) {
            this.game.music_03.addEventListener('ended', () => {
                this.game.setNextScene(Game.GAME_SCENE);
            }, { once: true });
            this.game.music_00.stop();
            this.game.music_03.play();
            return;
        } else {
            this.game.enter_cheat();
        }
    };

    draw = (ctx) => {
        this.#room.draw(ctx, 64);
        this.#copyright.draw(ctx, 72, 72);
    };
}