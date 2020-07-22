module re.ecs.entity;

import std.array;
import std.algorithm.iteration;
import std.algorithm.searching;
import re.ecs.component;
import re.math;

class Entity {
    public Appender!(Component[]) components;
    public bool alive;
    public Transform transform;
    public string name;

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
        return components.data.any!(x => cast(T) x);
    }

    public T get_component(T)() {
        auto i = components.data.countUntil!(x => cast(T) x !is null);
        assert(i < components.data.length,
                "no matching component was found. use has_component() to ensure that the component exists.");
        return cast(T) components.data[i];
    }

    public T[] get_components(T)() {
        return components.filter!(x => x is T);
    }

    // - transform
    @property Vector2 position2() {
        return transform.position2;
    }

    @property Vector2 position2(Vector2 value) {
        return transform.position2 = value;
    }

    @property Vector3 position() {
        return transform.position;
    }

    @property Vector3 position(Vector3 value) {
        return transform.position = value;
    }
}
