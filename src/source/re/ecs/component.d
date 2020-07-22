module re.ecs.component;

import std.array;
import std.algorithm;
import re.ecs.entity;
import re.ecs.manager;
import re.ecs.renderable;
import re.ecs.updatable;

abstract class Component {
    public Entity entity;
}

enum ComponentType {
    Base,
    Updatable,
    Renderable
}

struct ComponentId {
    size_t index;
    size_t owner;
    ComponentType type;
}

class ComponentStorage {
    public Component[] components;
    public Component[] updatable_components;
    public Component[] renderable_components;
    public EntityManager manager;

    this(EntityManager manager) {
        this.manager = manager;
    }

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

    private ref Component[] get_storage(ComponentId id) {
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

    public Component get(ComponentId id) {
        auto storage = get_storage(id);
        return storage[id.index];
    }

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

    public T[] get_all(T)(Entity entity) {
        // check all referenced components, return all matches
        auto matches = Appender!(T[]);
        foreach (id; entity.components) {
            auto component = get(id);
            if (auto match = cast(T) component) {
                matches ~= match;
            }
        }
        return matches.data;
    }

    public void remove(Entity entity, Component to_remove) {
        // check all referenced components, see if any match, then remove
        foreach (id; entity.components) {
            auto component = get(id);
            if (component == to_remove) {
                // delete the component id from the entity
                entity.components = entity.components.remove!(x => x == id);

                // - update component storage
                auto storage = get_storage(id);
                // empty the slot, and swap it to the end
                storage[id.index] = null; // dereference
                if (storage.length > 1) { // check if we need to swap
                    auto last_slot = cast(size_t) storage.length - 1;
                    auto tmp = storage[last_slot];
                    assert(tmp.entity);
                    storage[last_slot] = storage[id.index];
                    storage[id.index] = tmp;
                    // find out who owns tmp, and tell them that their component has moved
                    auto other = tmp.entity;
                    // find the id that points to the old place
                    auto other_id_pos = other.components.countUntil!(x => x.index == last_slot);
                    other.components[other_id_pos].index = id.index; // point to the new place
                }

                return; // done
            }
        }
        assert(0,
                "no matching component was found. use has_component() to ensure that the component exists.");
    }
}
