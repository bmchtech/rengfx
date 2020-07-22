module re.ecs.entity;

import std.array;
import re.ecs.component;

class Entity {
    public Appender!(Component[]) components;
    public bool alive;

    public void initialize() {
        alive = true;
        components.clear();
    }

    public void destroy() {
        alive = false;
    }
}
