module re.ecs.entity;

import std.array;
import std.algorithm.iteration;
import std.algorithm.searching;
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

    public T add_component(T)(T component) {
        components ~= component;
        component.entity = this;
        return component;
    }

    public bool has_component(T)() {
        return components.any!(x => x is T);
    }

    public T get_component(T)() {
        auto i = components.data.countUntil!(x => is(x : T));
        return cast(T) components.data[i];
    }

    public T[] get_components(T)() {
        return components.filter!(x => x is T);
    }
}
