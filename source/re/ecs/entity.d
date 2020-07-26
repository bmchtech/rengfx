module re.ecs.entity;

import std.array;
import std.conv;
import std.algorithm.iteration;
import std.algorithm.searching;
import re.ng.scene;
import re.ecs.manager;
import re.ecs.component;
import re.ecs.storage;
import re.math;

/// a container for components
class Entity {
    /// the unique id of this entity
    public size_t id;
    /// whether this entity is alive
    public bool alive;
    /// the scene that this entity is part of
    public Scene scene;
    /// world transform of entity
    public Transform transform;
    /// friendly name
    public string name;
    /// ecs manager
    public EntityManager manager;
    /// list of component references
    public ComponentId[] components;

    /// create entity given the ecs
    this(EntityManager manager) {
        this.manager = manager;
    }

    /// prepare the instance as a fresh entity
    public void initialize() {
        alive = true;
        transform = Transform();
        name = string.init;
        components = [];
    }

    /// release all resources and deinitialize
    public void destroy() {
        alive = false;
        manager.storage.destroy_all(this); // destroy all components
        name = string.init;
    }

    /// add an instance of a component given the type
    public T add_component(T)() {
        return add_component(new T());
    }

    /// add a component
    public T add_component(T)(T component) {
        auto id = manager.storage.insert(this, component);
        components ~= id;
        component.entity = this;
        component.setup();
        return component;
    }

    /// remove a matching component given a type
    public void remove_component(T)() {
        auto component = get_component!T();
        remove_component(component);
    }

    /// remove a specific component
    public void remove_component(T)(T component) {
        manager.storage.remove(this, component);
    }

    /// checks whether this entity contains a matching component
    public bool has_component(T)() {
        return manager.storage.has_component!T(this);
    }

    /// gets a matching component given a type
    public T get_component(T)() {
        return cast(T) manager.storage.get!T(this);

    }

    /// gets all matching components given a type
    public T[] get_components(T)() {
        return manager.storage.get_all!T(this);
    }

    /// gets all components attached to this entity
    public Component[] get_all_components() {
        return manager.storage.get_all(this);
    }

    // - transform

    /// forwards to transform
    @property Vector2 position2() {
        return transform.position2;
    }

    /// forwards to transform
    @property Vector2 position2(Vector2 value) {
        return transform.position2 = value;
    }

    /// forwards to transform
    @property ref Vector3 position() {
        return transform.position;
    }

    /// forwards to transform
    @property Vector3 position(Vector3 value) {
        return transform.position = value;
    }

    public override string toString() const {
        import std.string : format;

        return format("Entity[%d, %s]", id, name);
    }
}
