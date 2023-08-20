// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class TitleScene extends Scene {
    // private
    #input; #room; #font;
    #copyright;
    #menu_visible; #menu;

    // ctor
    constructor(game) {
        super(game);

        this.#input = this.game.input;
        this.#copyright = new Sprite(this.game.graphics, 256, 144, 134, 20);
        this.#font = new Font(this.game);
        this.#menu = new Menu(this.game);
    }

    init = () => {
        this.#room = new Room(this.game);
        this.game.music_00.play();
        this.game.music_00.loop = true;

        this.#menu_visible = false;
    };

    teardown = () => {
        this.game.music_00.stop();
    };

    update = (dt) => {
        if (this.#menu_visible) {
            if (this.#menu.handle(dt)) {
                this.#menu_visible = false;
            }
            return;
        }

        if (this.#input.isPressed(Input.KEY_RETURN) || this.#input.isPressed(Input.KEY_SPACE)) {
            this.game.music_03.addEventListener('ended', () => {
                this.game.setNextScene(Game.GAME_SCENE);
            }, { once: true });
            this.game.music_00.stop();
            this.game.music_03.play();
            return;
        } else if (this.#input.isPressed(Input.KEY_M)) {
            this.#menu_visible = true;
            this.#menu.init();
        }
    };

    draw = (ctx) => {
        this.#room.draw(ctx, 64);
        this.#copyright.draw(ctx, 72, 72);

        if (this.#menu_visible) {
            this.#menu.draw(ctx);
        } else {
            this.#font.print(ctx, (256-18*8)/2, 192, "press .m. for menu");
        }
    };
}