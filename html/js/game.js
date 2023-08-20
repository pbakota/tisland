// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

"use strict";

class Game
{
    _engine; _renderer; _loader; _graphics; _input; _screen; _screenCtx; _scene; _nextScene;
    _titleScene; _actionScene; _current_room; _active_item; _player; _room; _current_house; _hud;
    _zone; _game_over; _game_cheat_is_on; _cheat_char_index; _cheat_text; _game_success;
    _snapshot_char_index; _snapshot_text; _snapshot; _player_start_x; _player_start_y; _player_face; _game_level;
    _zone; _music_00; _music_01; _music_02; _music_03; _sfx_00; _sfx_01; _sfx_02; _sfx_03; #score; #chest_found;
    #game_superhero_jim; #game_inteligent_jls; #game_use_gps_navigation;

    constructor() {

        this._loader = new Loader();
        this._renderer = new Renderer();
        this._input = new Input();
        this._zone = new Zone();

        this._renderer.options(320, 200, 4);
        this._engine = new Engine(this, this._renderer, this._loader);

        this._screen = document.createElement('canvas');
        this._screen.width = 320;
        this._screen.height = 200;

        this._game_over = false;
        this._game_success = false;

        this.#game_superhero_jim = false;
        this.#game_inteligent_jls = false;
        this.#game_use_gps_navigation = false;
    }

    run = () => {
        this._engine.run();
        console.log('Loading assets.');
        this._loader.load('graphics', 'assets/treasure_island_atlas.png');
        this._loader.load('music_00', 'assets/music_00.ogg');
        this._loader.load('music_01', 'assets/music_01.ogg');
        this._loader.load('music_02', 'assets/music_02.ogg');
        this._loader.load('music_03', 'assets/music_03.ogg');
        this._loader.load('sfx_00', 'assets/sfx_00.ogg');
        this._loader.load('sfx_01', 'assets/sfx_01.ogg');
        this._loader.load('sfx_02', 'assets/sfx_02.ogg');
        this._loader.load('sfx_03', 'assets/sfx_03.ogg');

        Object.defineProperty(this, 'music_00', { get: () => this._music_00 });
        Object.defineProperty(this, 'music_01', { get: () => this._music_01 });
        Object.defineProperty(this, 'music_02', { get: () => this._music_02 });
        Object.defineProperty(this, 'music_03', { get: () => this._music_03 });
        Object.defineProperty(this, 'sfx_00', { get: () => this._sfx_00 });
        Object.defineProperty(this, 'sfx_01', { get: () => this._sfx_01 });
        Object.defineProperty(this, 'sfx_02', { get: () => this._sfx_02 });
        Object.defineProperty(this, 'sfx_03', { get: () => this._sfx_03 });

        Object.defineProperty(this, 'graphics', {
            get: () => { return this._graphics; }
        });
        Object.defineProperty(this, 'renderer', {
            get: () => { return this._renderer; }
        });
        Object.defineProperty(this, 'input', {
            get: () => { return this._input; }
        });
        Object.defineProperty(this, 'cheat_is_on', {
            get: () => { return this._game_cheat_is_on; }
        });
        Object.defineProperty(this, 'superhero_jim', {
            get: () => { return this.#game_superhero_jim; },
            set: (value) => { this.#game_superhero_jim = value; },
        });
        Object.defineProperty(this, 'inteligent_jls', {
            get: () => { return this.#game_inteligent_jls; },
            set: (value) => { this.#game_inteligent_jls = value; },
        });
        Object.defineProperty(this, 'use_gps_navigation', {
            get: () => { return this.#game_use_gps_navigation; },
            set: (value) => { this.#game_use_gps_navigation = value; },
        });
        Object.defineProperty(this, 'snapshot_is_on', {
            get: () => { return this._game_snapshot_is_on; }
        });
        Object.defineProperty(this, 'zone', {
            get: () => { return this._zone; }
        });
        Object.defineProperty(this, 'score', {
            get: () => { return this.#score; },
            set: (value) => { this.#score = value; },
        });
        Object.defineProperty(this, 'chest_found', {
            get: () => { return this.#chest_found; },
            set: (value) => { this.#chest_found = value; },
        });

        this._cheat_char_index = 0;
        this._cheat_text = [
            'KeyA',
            'KeyB',
            'KeyR',
            'KeyA',
            'KeyK',
            'KeyA',
            'KeyD',
            'KeyA',
            'KeyB',
            'KeyR',
            'KeyA'
        ];

        this._snapshot_char_index = 0;
        this._snapshot_text = [
            'KeyS',
            'KeyN',
            'KeyA',
            'KeyP',
            'KeyS',
            'KeyH',
            'KeyO',
            'KeyT'
        ];

        this._game_snapshot_is_on = false;
        this._game_cheat_is_on = false;

        this._snapshot = {};
    };

    add_to_score = (points) => {
        this.#score += points;
        if (this.#score > 999) {
            this.#score = 999;
        }
    }

    save_player_position = () => {
        this._player_start_x = this._player.x;
        this._player_start_y = this._player.y;
        this._player_start_face = this._player.face;
    }

    save_snapshot = (room) => {
        console.log('saving snapshot');
        this._snapshot = {
        };
    }

    load_snapshot = () => {
        console.log('loading snapshot');
        if(this._snapshot != {}) {
        }
    }

    enter_cheat = () => {
        var c = this._input.rawKey();
        if(c != Input.NO_KEY) {
            // console.log(`c=${c}, next_char=${this._cheat_text[this._cheat_char_index]}`);
            if(c == this._cheat_text[this._cheat_char_index]) {
                this._cheat_char_index ++;
                if(this._cheat_char_index == this._cheat_text.length) {
                    this._game_cheat_is_on = true;
                    console.log('cheats are enabled');
                }
            }
            if(c == this._snapshot_text[this._snapshot_char_index]) {
                this._snapshot_char_index ++;
                if(this._snapshot_char_index == this._snapshot_text.length) {
                    this._game_snapshot_is_on = true;
                    console.log('snapshots are enabled');
                }
            }
        }
    }

    ready = () => {
        console.log('Game ready.');
        this._graphics = this._loader.get('graphics');
        this._music_00 = this._loader.get('music_00');
        this._music_01 = this._loader.get('music_01');
        this._music_02 = this._loader.get('music_02');
        this._music_03 = this._loader.get('music_03');

        this._sfx_00 = this._loader.get('sfx_00');
        this._sfx_01 = this._loader.get('sfx_01');
        this._sfx_02 = this._loader.get('sfx_02');
        this._sfx_03 = this._loader.get('sfx_03');

        this.#score = 0;

        this._actionScene = new ActionScene(this);
        this._nextScene = this._titleScene = new TitleScene(this);
    };

    setNextScene = (scene) => {
        switch (scene) {
            case Game.GAME_SCENE:
                this._nextScene = this._actionScene;
                break;
            case Game.TITLE_SCENE:
                this._nextScene = this._titleScene;
        }
    };

    set_game_success = () => {
        this._game_success = true;
        this.set_game_over();
    };

    update = (dt) => {
        if (this._nextScene) {
            if(this._scene)
                this._scene.teardown();

            this._scene = this._nextScene;
            this._nextScene = false;

            this._scene.init();
        }

        if (this._scene) {
            this._scene.update(dt);
        }
    };

    draw = (ctx) => {
        if (this._scene) {
            this._scene.draw(ctx);
        }
    };

    pause = () => {

    };

    restore = () => {

    };
}

Game.TITLE_SCENE = 0;
Game.GAME_SCENE  = 1;
