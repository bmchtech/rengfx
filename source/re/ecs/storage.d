module re.ecs.storage;

import re.ecs.entity;
import re.ecs.component;
import re.ecs.manager;
import re.ecs.renderable;
import re.ecs.updatable;
import std.array;
import std.conv : to;
import std.string : format;
import std.container.array;
import std.algorithm;

/// helper class for storing components in an optimized way
class ComponentStorage {
    /// basic component storage
    public Array!Component components;
    /// components that implement Updatable
    public Array!Component updatable_components;
    /// components that implement Renderable
    public Array!Component renderable_components;
    /// the entity manager
    public EntityManager manager;

    /// sets up a component storage helper
    this(EntityManager manager) {
        this.manager = manager;
    }

    /// attaches a component to an entity
    public ComponentId insert(Entity entity, Component component) {
        if (auto updatable = cast(Updatable) component) {
            updatable_components ~= component;
            return ComponentId(cast(size_t) updatable_components.length - 1,
                    entity.id, ComponentType.Updatable);
        } else if (auto renderable = cast(Renderable) component) {
            renderable_components ~= component;
            return ComponentId(cast(size_t) renderable_components.length - 1,
                    entity.id, ComponentType.Renderable);
        } else {
            components ~= component;
            return ComponentId(cast(size_t) components.length - 1, entity.id, ComponentType.Base);
        }
    }

    /// checks if an entity has a component with a matching type
    public bool has_component(T)(Entity entity) {
        // check all referenced components, see if any match
        foreach (id; entity.components) {
            auto component = get(id);
            if (auto match = cast(T) component) {
                return true;
            }
        }
        return false;
    }

    /// get the internal buffer based on the referenced component type
    private ref Array!Component get_storage(ComponentId id) {
        switch (id.type) {
        case ComponentType.Base:
            return components;
        case ComponentType.Updatable:
            return updatable_components;
        case ComponentType.Renderable:
            return renderable_components;
        default:
            assert(0);
        }
    }

    /// get a component from its id reference
    public Component get(ComponentId id) {
        auto storage = get_storage(id);
        return storage[id.index];
    }

    /// get the first component in an entity matching a type
    public T get(T)(Entity entity) {
        // check all referenced components, see if any match
        foreach (id; entity.components) {
            auto component = get(id);
            if (auto match = cast(T) component) {
                return match;
            }
        }
        assert(0,
                "no matching component was found. use has_component() to ensure that the component exists.");
    }

    /// get all components in an entity matching a type
    public T[] get_all(T)(Entity entity) {
        // check all referenced components, return all matches
        auto matches = appender!(T[]);
        foreach (id; entity.components) {
            auto component = get(id);
            if (auto match = cast(T) component) {
                matches ~= match;
            }
        }
        return matches.data;
    }

    /// get all components in an entity
    public Component[] get_all(Entity entity) {
        auto list = appender!(Component[]);
        foreach (id; entity.components) {
            list ~= get(id);
        }
        return list.data;
    }

    /// removes a component from its owner entity
    public void remove(Entity entity, Component to_remove) {
        // check all referenced components, see if any match, then remove
        foreach (id; entity.components) {
            auto component = get(id);
            if (component == to_remove) {
                remove(entity, id);
                return; // done
            }
        }
        assert(0,
                "no matching component was found. use has_component() to ensure that the component exists.");
    }

    private void remove(Entity entity, ComponentId id) {
        // import std.stdio : writefln;

        // writefln("entity (%s) components(before): %s", entity.name, entity.components);

        // delete the component id from the entity
        entity.components = entity.components.remove!(x => x == id);

        // - update storage
        auto storage = get_storage(id);
        // writefln("REMOVING component_type: %s", to!string(id.type));
        // writefln("storage[%d]: %s", storage.length, storage.array);
        // empty the slot, and swap it to the end
        assert(id.index < storage.length,
                format("id points to invalid position in (%s) storage", to!string(id.type)));
        storage[id.index].destroy(); // cleanup
        storage[id.index] = null; // dereference
        auto last_slot = cast(size_t) storage.length - 1;
        // our goal now is to make sure the last slot is null, so we can pop it off the storage
        // check if we need to swap the slot we just nulled with the last s lot
        // if the array is length 1, we don't need to swap: our null space is already at the end
        // also check if the index we're removing is the last slot, in which case we've already nulled it.
        if (storage.length > 1 && id.index != last_slot) {
            // handle swapping our nulled slot with the last slot
            auto tmp = storage[last_slot];
            assert(tmp, "storage tail slot is null");
            assert(tmp.entity, "entity in tail slot is null");
            storage[last_slot] = storage[id.index];
            storage[id.index] = tmp;
            // find out who owns tmp, and tell them that their component has moved
            auto other = tmp.entity;
            // find the id that points to the old place
            auto other_id_pos = other.components.countUntil!(x => x.index == last_slot);
            other.components[other_id_pos].index = id.index; // point to the new place
        }
        // pop the last element off the array
        storage.removeBack();
    }

    /// destroy all components attached to an entity
    public void destroy_all(Entity entity) {
        auto components_to_remove = entity.components.dup;
        foreach (id; components_to_remove) {
            remove(entity, id);
        }
    }
}
