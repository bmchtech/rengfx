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

debug {
    import std.stdio : writefln;
}

/// helper class for storing components in an optimized way
class ComponentStorage {
    /// basic component storage
    public Component[] components;
    /// components that implement Updatable
    public Component[] updatable_components;
    /// components that implement Renderable
    public Component[] renderable_components;
    /// components that implement Updatable and Renderable
    public Component[] updatable_renderable_components;
    /// the entity manager
    public EntityManager manager;

    /// sets up a component storage helper
    this(EntityManager manager) {
        this.manager = manager;
    }

    /// attaches a component to an entity
    public ComponentId insert(Entity entity, Component component) {
        bool is_updatable = (cast(Updatable) component) !is null;
        bool is_renderable = (cast(Renderable) component) !is null;
        bool is_updatable_renderable = is_updatable && is_renderable;

        if (is_updatable_renderable) {
            updatable_renderable_components ~= component;
            return ComponentId(cast(size_t) updatable_renderable_components.length - 1,
                entity.id, ComponentType.UpdatableRenderable);
        } else if (is_updatable) {
            updatable_components ~= component;
            return ComponentId(cast(size_t) updatable_components.length - 1,
                entity.id, ComponentType.Updatable);
        } else if (is_renderable) {
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
            auto component = get_from_id(id);
            if (auto match = cast(T) component) {
                return true;
            }
        }
        return false;
    }

    /// get the internal buffer based on the referenced component type
    private Component[] get_storage(ComponentId id) {
        switch (id.type) {
        case ComponentType.Base:
            return components;
        case ComponentType.Updatable:
            return updatable_components;
        case ComponentType.Renderable:
            return renderable_components;
        case ComponentType.UpdatableRenderable:
            return updatable_renderable_components;
        default:
            assert(0);
        }
    }

    private void set_storage(ComponentId id, ref Component[] buffer) {
        switch (id.type) {
        case ComponentType.Base:
            components = buffer;
            break;
        case ComponentType.Updatable:
            updatable_components = buffer;
            break;
        case ComponentType.Renderable:
            renderable_components = buffer;
            break;
        case ComponentType.UpdatableRenderable:
            updatable_renderable_components = buffer;
            break;
        default:
            assert(0);
        }
    }

    /// get a component from its id reference
    public ref Component get_from_id(ref ComponentId id) {
        auto storage = get_storage(id);
        writefln("get_from_id: %s (storage: %s)", id, storage);
        return storage[id.index];
    }

    /// get the first component in an entity matching a type
    public T get(T)(Entity entity) {
        // check all referenced components, see if any match
        foreach (id; entity.components) {
            auto component = get_from_id(id);
            if (auto match = cast(T) component) {
                return match;
            }
        }
        assert(0,
            format("no matching component (%s) was found. use has_component() to ensure that the component exists.",
                typeid(T).name));
    }

    /// get all components in an entity matching a type
    public T[] get_all(T)(Entity entity) {
        auto all_components = get_all(entity);
        T[] matches;
        for (int i = 0; i < all_components.length; i++) {
            auto component = all_components[i];
            // auto comp = cast(T) component;
            //     matches ~= cast(T) component;
            // }
            writefln("all components 1: %s", get_all(entity));
            if (typeid(T) is typeid(component)) {
                auto match = (cast(T) component);
                writefln("all components 2: %s", get_all(entity));
                matches ~= match;
                writefln("all components 3: %s", get_all(entity));
                writefln("match: %s", match);
                writefln("match ref: %s", &match);
                writefln("all components 4: %s", get_all(entity));
            }
        }
        return matches;
    }

    /// get all components in an entity
    public Component[] get_all(Entity entity) {
        Component[] list;
        foreach (ref id; entity.components) {
            list ~= get_from_id(id);
        }
        return list;
    }

    /// removes a component from its owner entity
    public void remove(Entity entity, Component to_remove) {
        // check all referenced components, see if any match, then remove
        foreach (id; entity.components) {
            auto component = get_from_id(id);
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
        // writefln("\nentity (%s) components(before): %s (removing %s)", entity.name, entity.components, id);

        // delete the component id from the entity
        entity.components = entity.components.remove!(x => x == id);

        // - update storage
        auto storage = get_storage(id);
        // writefln("REMOVING component_type: %s AT %d", to!string(id.type), id.index);
        // writefln("storage[%d]: %s", storage.length, storage.array);

        // empty the slot, and swap it to the end
        assert(id.index < storage.length, format("id points to invalid position (%d) in %s storage",
                id.index, to!string(id.type)));
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
            // writefln("swapped SLOT (%d) with TAIL (%d)", id.index, last_slot);
            // find out who owns tmp, and tell them that their component has moved
            auto other = tmp.entity;
            // find the id that points to the old place
            auto other_id_pos = other.components.countUntil!(x => x.index == last_slot);
            // writefln("working with OTHER, components %s", other.components);
            // writefln("(%s) updating COMPREF from OLDSLOT (%d) to NEWSLOT (%d)", other.name, other.components[other_id_pos].index, id.index);
            other.components[other_id_pos].index = id.index; // point to the new place
        }
        // pop the last element off the array
        storage = storage.remove(last_slot);
        set_storage(id, storage);
    }

    /// destroy all components attached to an entity
    public void destroy_all(Entity entity) {
        while (entity.components.length > 0) {
            remove(entity, entity.components.front);
        }
    }
}

static class Thing1 : Component {
}

static class Thing2 : Component, Updatable {
    void update() {
    }
}

// I HAVE NO IDEA WHY THIS DOESNT WORK AND ITS FRUSTRATING ME

@("ecs-storage-basic")
unittest {
    import std.string : format;
    import std.stdio;

    auto manager = new EntityManager();
    auto storage = new ComponentStorage(manager);
    auto nt = manager.create_entity();

    ComponentId manual_nt_add(Entity nt, Component component) {
        auto id = storage.insert(nt, component);
        nt.components ~= id;
        component.entity = nt;
        component.setup();
        return id;
    }

    void manual_nt_remove(Entity nt, ComponentId id) {
        storage.remove(nt, id);
    }

    // try adding stuff
    // insert 6 things1, and 4 thing2
    auto thing11 = manual_nt_add(nt, new Thing1());
    auto thing12 = manual_nt_add(nt, new Thing1());
    auto thing13 = manual_nt_add(nt, new Thing1());
    auto thing14 = manual_nt_add(nt, new Thing1());
    auto thing15 = manual_nt_add(nt, new Thing1());
    auto thing16 = manual_nt_add(nt, new Thing1());
    auto thing21 = manual_nt_add(nt, new Thing2());
    auto thing22 = manual_nt_add(nt, new Thing2());
    auto thing23 = manual_nt_add(nt, new Thing2());
    auto thing24 = manual_nt_add(nt, new Thing2());

    writefln("nt comps: %s", nt.components);
    writefln("all components: %s", storage.get_all(nt));
    auto thing1s = storage.get_all!Thing1(nt);
    assert(thing1s.length == 6, format("expected 6 thing1s, got %d", thing1s.length));

    auto thing2s = storage.get_all!Thing2(nt);
    assert(thing2s.length == 4, format("expected 4 thing2s, got %d", thing2s.length));

    // try removing random stuff
    manual_nt_remove(nt, thing13);
    manual_nt_remove(nt, thing11);
    thing1s = storage.get_all!Thing1(nt);
    assert(thing1s.length == 4, format("expected 4 thing1s, got %d", thing1s.length));

    manual_nt_remove(nt, thing22);
    thing2s = storage.get_all!Thing2(nt);
    assert(thing2s.length == 3, format("expected 3 thing2s, got %d", thing2s.length));
}

@("ecs-storage-types")
unittest {
    static class Thing1 : Component {
    }

    static class Thing2 : Component, Updatable {
        void update() {
        }
    }

    static class Thing3 : Component, Renderable {
        void render() {
        }

        void debug_render() {
        }
    }

    static class Thing4 : Component, Updatable, Renderable {
        void update() {
        }

        void render() {
        }

        void debug_render() {
        }
    }

    auto manager = new EntityManager();
    auto storage = new ComponentStorage(manager);
    auto nt = manager.create_entity();

    auto cid1 = storage.insert(nt, new Thing1());
    auto cid2 = storage.insert(nt, new Thing2());
    auto cid3 = storage.insert(nt, new Thing3());
    auto cid4 = storage.insert(nt, new Thing4());

    assert(cid1.type == ComponentType.Base);
    assert(cid2.type == ComponentType.Updatable);
    assert(cid3.type == ComponentType.Renderable);
    assert(cid4.type == ComponentType.UpdatableRenderable);
}
