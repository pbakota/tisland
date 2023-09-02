"use strict";

// inspired by https://stackoverflow.com/questions/42919469/efficient-way-to-implement-priority-queue-in-javascript (gyre answer)
class PriorityQueue {
    // private
    #heap;
    #comparator;
    // ctor
    constructor(comparator = (a, b) => a > b) {
        this.#heap = [];
        this.#comparator = comparator;
    }
    size = () => this.#heap.length;
    isEmpty = () => this.size() == 0;
    peek = () => this.#heap[0];
    push = (...values) => {
        values.forEach(value => {
            this.#heap.push(value);
            this.#siftUp();
        });
        return this.size();
    }
    pop = () => {
        const poppedValue = this.peek();
        const bottom = this.size() - 1;
        if (bottom > 0) {
            this.#swap(0, bottom);
        }
        this.#heap.pop();
        this.#siftDown();
        return poppedValue;
    }
    replace = (value) => {
        const replacedValue = this.peek();
        this.#heap[0] = value;
        this.#siftDown();
        return replacedValue;
    }
    #parent = i => ((i + 1) >>> 1) - 1;
    #left = i => (i << 1) + 1;
    #right = i => (i + 1) << 1;
    #greater = (i, j) => this.#comparator(this.#heap[i], this.#heap[j]);
    #swap = (i, j) => {
        [this.#heap[i], this.#heap[j]] = [this.#heap[j], this.#heap[i]];
    }
    #siftUp = () => {
        let node = this.size() - 1;
        while (node > 0 && this.#greater(node, this.#parent(node))) {
            this.#swap(node, this.#parent(node));
            node = this.#parent(node);
        }
    }
    #siftDown = () => {
        let node = 0;
        while (
            (this.#left(node) < this.size() && this.#greater(this.#left(node), node)) ||
            (this.#right(node) < this.size() && this.#greater(this.#right(node), node))
        ) {
            let maxChild = (this.#right(node) < this.size() && this.#greater(this.#right(node), this.#left(node))) ? this.#right(node) : this.#left(node);
            this.#swap(node, maxChild);
            node = maxChild;
        }
    }
}


var Util = {}


Util.path_finding = (rooms, start_x, start_y, end_x, end_y) => {
    class Node {
        // public
        x; y; p_x; p_y; f; g; h;
        // ctor
        constructor(x, y, p_x, p_y, f, g, h) {
            this.x = x;
            this.y = y;
            this.p_x = p_x;
            this.p_y = p_y;
            this.f = f;
            this.g = g;
            this.h = h;
        }
    }

    const is_valid = (x, y) => {
        if (x < 0 || y < 0 || x >= 8 * 8 || y >= 6 * 8) {
            return false;
        }
        // calculate the room-tile position on the map
        let r = ~~(y / 6) * 8 + ~~(x / 8);
        let tx = x % 8, ty = y % 6;

        return (rooms[r].tiles[ty * 8 + tx] == 0); // must be empty tile
    }

    const is_destination = (x, y, dx, dy) => x == dx && y == dy;

    const calculate_h = (x, y, dx, dy) => Math.sqrt((x - dx) * (x - dx) + (y - dy) * (y - dy));

    if (!is_valid(end_x, end_y) || is_destination(start_x, start_y, end_x, end_y)) {
        return [];
    }

    let closed = new Array(48);
    for (let y = 0; y < 6 * 8; ++y) {
        closed[y] = new Array(64);
        for (let x = 0; x < 8 * 8; ++x) {
            closed[y][x] = false;
        }
    }

    let map = new Array(48);
    for (let y = 0; y < 6 * 8; ++y) {
        map[y] = new Array(64);
        for (let x = 0; x < 8 * 8; ++x) {
            map[y][x] = new Node(x, y, -1, -1, Number.MAX_VALUE, Number.MAX_VALUE, Number.MAX_VALUE);
        }
    }

    const x = start_x;
    const y = start_y;

    map[y][x].f = 0;
    map[y][x].g = 0;
    map[y][x].h = 0;

    map[y][x].p_x = x;
    map[y][x].p_y = y;

    let open = new PriorityQueue((a, b) => b.h > a.h);
    open.push(map[y][x]);

    let destination_found = false;
    while (!open.isEmpty() && !destination_found) {
        let node;
        do {
            node = open.pop();
        } while (!is_valid(node.x, node.y));

        const x = node.x;
        const y = node.y;

        closed[y][x] = true;
        for (let ny = -1; ny <= 1 && !destination_found; ++ny) {
            for (let nx = -1; nx <= 1; ++nx) {

                // skip diagonals
                if ((nx == -1 && ny == -1)
                    || (nx == 1 && ny == -1)
                    || (nx == -1 && ny == 1)
                    || (nx == 1 && ny == 1)) continue;

                const new_x = x + nx;
                const new_y = y + ny;

                if (is_valid(new_x, new_y)) {
                    if (is_destination(new_x, new_y, end_x, end_y)) {
                        map[new_y][new_x].p_x = x;
                        map[new_y][new_x].p_y = y;
                        destination_found = true;

                        // goto exit;
                        break;
                    } else if (!closed[new_y][new_x]) {
                        const gn = node.g + 1.0;
                        const hn = calculate_h(new_x, new_y, end_x, end_y);
                        const fn = gn + hn;
                        if (map[new_y][new_x].f == Number.MAX_VALUE || map[new_y][new_x].f > fn) {
                            map[new_y][new_x].g = gn;
                            map[new_y][new_x].h = hn;
                            map[new_y][new_x].f = fn;

                            map[new_y][new_x].p_x = x;
                            map[new_y][new_x].p_y = y;

                            open.push(map[new_y][new_x]);
                        }
                    }
                }
            }
        }
    }

    if (!destination_found) return [];

    const make_path = (map, x, y) => {
        let path = [];
        while (!(map[y][x].p_x == x && map[y][x].p_y == y && map[y][x].x != -1 && map[y][x].y != -1)) {
            path.push(map[y][x]);
            const tx = map[y][x].p_x;
            const ty = map[y][x].p_y;
            x = tx;
            y = ty;
        }
        path.push(map[y][x]);
        return path.reverse();
    }

    return make_path(map, end_x, end_y);
}

// Linear interpolation
Util.lerp = (start, end, t) => start * (1 - t) + end * t;

// Draw path for debugging purpose
Util.path_debug = (ctx, path) => {
    ctx.save();
    ctx.lineWidth = 3;
    for (let i = 0; i < path.length; ++i) {
        ctx.strokeStyle = (i == 0 ? 'white' : 'green');
        ctx.beginPath();
        ctx.rect(32 * (path[i].x % 8), 32 * (path[i].y % 6), 32, 32);
        ctx.stroke();
    }
    ctx.restore();
}