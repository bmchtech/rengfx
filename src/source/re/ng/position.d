module re.ng.position;
static import raylib;

import re.ecs.component;

class Position : Component {
    public raylib.Vector2 vec;

    this(float x, float y) {
        vec = raylib.Vector2(x, y);
    }
}