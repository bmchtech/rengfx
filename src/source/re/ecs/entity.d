module re.ecs.entity;

import std.array;
import std.conv;
import std.algorithm.iteration;
import std.algorithm.searching;
import re.ecs.manager;
import re.ecs.component;
import re.ecs.storage;
import re.math;

class Entity {
    public size_t id;
    public bool alive;
    public Transform transform;
    public string name;
    public EntityManager manager;
    public ComponentId[] components;

    this(EntityManager manager) {
        this.manager = manager;
    }

    public void initialize() {
        alive = true;
        components = [];
    }

    public void destroy() {
        alive = false;
        manager.storage.destroy_all(this);
    }

    public T add_component(T)() {
        return add_component(new T());
    }

    public T add_component(T)(T component) {
        auto id = manager.storage.insert(this, component);
        components ~= id;
        component.entity = this;
        component.setup();
        return component;
    }

    public void remove_component(T)() {
        auto component = get_component!T();
        remove_component(component);
    }

    public void remove_component(T)(T component) {
        manager.storage.remove(this, component);
    }

    public bool has_component(T)() {
        // return components.data.any!(x => cast(T) x);
        return manager.storage.has_component!T(this);
    }

    public T get_component(T)() {
        // auto i = components.data.countUntil!(x => cast(T) x !is null);
        // assert(i < components.data.length,
        //         "no matching component was found. use has_component() to ensure that the component exists.");
        // return cast(T) components.data[i];
        return cast(T) manager.storage.get!T(this);

    }

    public T[] get_components(T)() {
        return manager.storage.get_all!T(this);
    }

    // - transform
    @property Vector2 position2() {
        return transform.position2;
    }

    @property Vector2 position2(Vector2 value) {
        return transform.position2 = value;
    }

    @property float rotation() {
        return transform.rotation;
    }

    @property float rotation(float value) {
        return transform.rotation = value;
    }

    @property Vector3 position() {
        return transform.position;
    }

    @property Vector3 position(Vector3 value) {
        return transform.position = value;
    }
}
