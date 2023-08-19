// Copyright (c) 2023 Peter Bakota
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

class Sound {
    // private
    #sound;

    // ctor
    constructor(src) {
        this.#sound = document.createElement("audio");
        this.#sound.setAttribute("preload", "auto");
        Object.defineProperty(this, 'loop', {
            set: (value) => {
                this.#sound.loop = value;
            }
        });
        this.#sound.src = src;
        document.body.appendChild(this.#sound);
    }

    addEventListener = (event, cb, opts) => {
        this.#sound.addEventListener(event, cb, opts);
    };

    removeEventListener = (event, cb, opts) => {
        this.#sound.removeEventListener(event, cb, opts);
    };

    play = () => {
        this.#sound.play();
    };

    stop = () => {
        this.#sound.pause();
        this.#sound.currentTime = 0;
    };
}

class Loader {
    _files = {};
    _loadCount = 0;
    _fileCount = 0;
    get = (name) => {
        return this._files[name];
    };
    progress = () => {
        return this._loadCount / this._fileCount;
    };
    load = (name, src) => {
        src = src || name;
        // console.log(`Loading asset ${src}.`);
        ++this._fileCount;
        switch (src.split(".").pop()) {
            case "png":
                var img = new Image();
                this._files[name] = img;
                img.addEventListener("load", (e) => {
                    this._loadCount++;
                });
                img.src = src;
                break;
            case 'ogg':
                var aud = new Sound(src);
                this._files[name] = aud;
                aud.addEventListener("loadeddata", (e) => {
                    this._loadCount++;
                });
                break;
            case 'wav':
                var aud = new Audio();
                this._files[name] = aud;
                aud.addEventListener("loadeddata", (e) => {
                    this._loadCount++;
                });
                aud.preload = "auto";
                aud.type = "audio/wav";
                aud.src = src;
                break;
        }
    };
}

class Renderer {
    _canvas = {}; _bcanvas = {};
    _ctx = {}; _bctx = {};
    _scale = 1.0;
    _scaleWidth;
    _scaledHeight;
    _background = 'black';
    _now; _then;

    constructor() {
        this._canvas = document.getElementById('canvas');
        this._ctx = this._canvas.getContext('2d');

        this._bcanvas = document.createElement('canvas');
        this._bctx = this._bcanvas.getContext('2d');

        Object.defineProperty(this, 'width', {
            get: () => {
                return this._bcanvas.width;
            }
        });

        Object.defineProperty(this, 'height', {
            get: () => {
                return this._bcanvas.height;
            }
        });

        Object.defineProperty(this, 'scale', {
            get: () => {
                return this._scale;
            }
        });

        Object.defineProperty(this, 'ctx', {
            get: () => {
                return this._bctx;
            }
        });

        Object.defineProperty(this, 'canvas', {
            get: () => {
                return this._canvas;
            }
        });

        Object.defineProperty(this, 'display', {
            get: () => {
                return this._bcanvas;
            }
        });

        Object.defineProperty(this, 'backbuffer', {
            get: () => {
                return this._bcanvas;
            }
        });

        Object.defineProperty(this, 'delta', {
            get: () => {
                return this._delta;
            }
        });
    }

    flip = () => {
        this._ctx.drawImage(this._bcanvas, 0, 0, this._bcanvas.width, this._bcanvas.height, 0, 0, this._scaledWidth, this._scaledHeight);
    };

    clear = () => {
        if (this._background instanceof Image) {
            this._bctx.drawImage(this._background, 0, 0, this._background.width, this._background.height, 0, 0, this._background.width, this._background.height);
        } else {
            this._bctx.fillStyle = this._background;
            this._bctx.fillRect(0, 0, this._bcanvas.width, this._bcanvas.height);
        }
    }

    options = (width, height, scale) => {
        this._scale = scale;
        this._scaledWidth = this._scale * width;
        this._scaledHeight = this._scale * height;
        this._canvas.width = this._scaledWidth;
        this._canvas.height = this._scaledHeight;

        this._bcanvas.width = width;
        this._bcanvas.height = height;

        this._ctx["imageSmoothingEnabled"] = false;
        ["o", "ms", "moz", "webkit"].forEach((v) => {
            this._ctx[v + "ImageSmoothingEnabled"] = false;
        });
    };

    background = (background) => {
        this._background = background;
    };

    updateDelta = (timestamp) => {
        // this._now = window.performance.now();
        this._now = timestamp;
        this._delta = (this._now - this._then) / 1000;
        if (this._delta > 1.0) this._delta = 1.0;
        this._then = this._now;
    };

    resetDelta = () => {
        this._now = window.performance.now();
        this._then = this._now;
    }
}

class Engine {
    _game; _renderer; _loader; _reqframe; _loaded = false; _running = false; _paused = false;

    constructor(game, renderer, loader) {
        this._game = game;
        this._renderer = renderer;
        this._loader = loader;

        const _vendors = ["o", "ms", "moz", "webkit"];
        for (var i = 0; i < _vendors.length && !window.requestAnimationFrame; ++i) {
            var v = _vendors[i];
            window.requestAnimationFrame = window[v + "RequestAnimationFrame"];
            window.cancelAnimationFrame = window[v + "CancelAnimationFrame"] ||
                window[v + "CancelRequestAnimationFrame"];
        }
    }

    update = () => {
        if (this._loaded) {
            this._game.update(this._renderer.delta);
        } else {
            this._loaded = this._loader.progress() == 1;
            if (this._loaded) {
                this._game.ready();
            }
        }
    };

    draw = () => {
        if (this._loaded) {
            this._renderer.clear();
            this._game.draw(this._renderer.ctx);
            this._renderer.flip();
        }
    };

    loop = (timestamp) => {
        this._reqframe = window.requestAnimationFrame(this.loop);
        this._renderer.updateDelta(timestamp);

        this.update();
        this.draw();
    };

    #active = () => {
        this._renderer.canvas.removeEventListener('click', this.#active, false);

        this._running = true;
        // this._renderer.resetDelta();

        if (this._paused) {
            this._paused = false;
            if (typeof (this._game) != "undefined")
                this._game.restore();
        }

        this.loop();
    }

    run = () => {
        if (this._running) return;
        this._renderer.canvas.addEventListener('click', this.#active, false);

        this._renderer.clear();
        this._renderer.ctx.fillStyle = "blue";
        this._renderer.ctx.font = "bold 16px Arial";
        this._renderer.ctx.textAlign = 'center';
        this._renderer.ctx.textBaseline = 'middle';
        this._renderer.ctx.fillText("Click to start the game!", (this._renderer.width / 2), (this._renderer.height / 2));
        this._renderer.flip();
    };

    stop = () => {

        window.cancelAnimationFrame(this._reqframe);
        if (typeof (this._game) != "undefined") {
            this._game.pause();
            this._paused = true;
        }

        this._running = false;
    }
}

class Input {
    _keys = {}; _lastk = Input.NO_KEY;
    constructor() {
        window.addEventListener("keydown", (e) => {
            this._keys['k' + e.code] = true;
            this._lastk = e.code;
        });

        window.addEventListener("keyup", (e) => {
            this._keys['k' + e.code] = false;
            this._lastk = Input.NO_KEY;
        });
    }

    isDown = (keyCode) => {
        this._lastk = keyCode;
        return this._keys['k' + keyCode] == true;
    };

    isUp = (keyCode) => {
        this._lastk = Input.NO_KEY;
        return this._keys['k' + keyCode] == false;
    };

    isPressed = (keyCode) => {
        var pressed = (this._keys['k' + keyCode] == true);
        this._keys['k' + keyCode] = false;
        return pressed;
    };

    clear = () => {
        this._keys = {};
        this._lastk = Input.NO_KEY;
    }

    rawKey = () => {
        if (this._lastk == Input.NO_KEY)
            return Input.NO_KEY;

        var pressed = (this._keys['k' + this._lastk]) == true;
        this._keys['k' + this._lastk] = false;
        if (pressed)
            return this._lastk;

        return Input.NO_KEY;
    }
}

// define global key constants
Input.NO_KEY = '';
Input.KEY_LEFT = 'ArrowLeft';
Input.KEY_DOWN = 'ArrowDown';
Input.KEY_RIGHT = 'ArrowRight';
Input.KEY_UP = 'ArrowUp';
Input.KEY_RETURN = 'Enter';
Input.KEY_ESCAPE = 'Escape';
Input.KEY_Y = 'KeyY';
Input.KEY_N = 'KeyN';
Input.KEY_BS = 'Backspace';
Input.KEY_SPACE = 'Space';
Input.KEY_PGDOWN = 'PageDown';
Input.KEY_PGUP = 'PageUp';
Input.KEY_L = 'KeyL';

class Sprite {
    // private
    #ix; #iy; #w; #h; #image;

    // ctor
    constructor(image, ix, iy, w, h) {
        this.#ix = ix;
        this.#iy = iy;
        this.#w = w;
        this.#h = h;
        this.#image = image;

        Object.defineProperty(this, 'width', {
            get: () => { return this.#w; }
        })

        Object.defineProperty(this, 'height', {
            get: () => { return this.#h; }
        })

        Object.defineProperty(this, 'x', {
            get: () => { return this.#ix; }
        })

        Object.defineProperty(this, 'y', {
            get: () => { return this.#iy; }
        })
    }

    draw = (ctx, x, y) => {
        ctx.drawImage(this.#image, this.#ix, this.#iy, this.#w, this.#h, ~~x, ~~y, this.#w, this.#h);
    };
}

// Static methods
Sprite.aabb = (rect1, rect2) => {
    return (
        rect1.x < rect2.x + rect2.w &&
        rect1.x + rect1.w > rect2.x &&
        rect1.y < rect2.y + rect2.h &&
        rect1.h + rect1.y > rect2.y
    );
}

Sprite.debug = (ctx, hb) => {
    ctx.strokeStyle = 'red';
    ctx.lineWidth = 1;
    ctx.beginPath();
    ctx.rect(hb.x, hb.y, hb.w, hb.h);
    ctx.stroke();
}
