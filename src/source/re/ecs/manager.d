module re.ecs.manager;

import re.ecs.entity;
import re.ecs.component;
import std.algorithm;
import std.array;

class EntityManager {
    public Entity[] entities;
    public ComponentStorage storage;
    private size_t[] entities_to_remove;
    private size_t entity_counter;

    this() {
        storage = new ComponentStorage(this);
    }

    public Entity create_entity() {
        auto nt = new Entity(this);
        nt.initialize();
        nt.id = entity_counter++;
        entities ~= nt;
        return nt;
    }

    public void remove_entity(Entity entity) {
        entities.remove!(x => x == entity);
        // TODO: entity pooling
    }

    public void update() {
        entities_to_remove = [];
        for (size_t i = 0; i < entities.length; i++) {
            auto nt = entities[i];
            if (!nt.alive) {
                entities_to_remove ~= i;
            }
        }

        // remove entities
        foreach (to_remove; entities_to_remove) {
            entities = remove(entities, to_remove);
        }
    }

    public void destroy() {
        // destroy all entities
    }
}

unittest {
    class Food : Component {
        public bool tasty = true;
    }

    auto ecs = new EntityManager();
    auto nt = ecs.create_entity();
    auto food = new Food();
    nt.add_component(food);
    assert(nt.has_component!Food(), "component was not properly added");
    assert(nt.get_component!Food == food, "component cannot be retrieved");
    nt.remove_component!Food();
    assert(!nt.has_component!Food(), "component cannot be removed");
}

unittest {
    class Butter : Component {
        public bool tasty = true;
    }
    class Jelly : Component {
        public int rank = 4;
    }

    auto ecs = new EntityManager();
    auto sandwich1 = ecs.create_entity();
    auto sandwich2 = ecs.create_entity();
    auto sandwich3 = ecs.create_entity();

    sandwich1.add_component(new Butter());
    sandwich1.add_component(new Jelly());
    assert(sandwich1.has_component!Butter());
    assert(sandwich1.has_component!Jelly());

    sandwich2.add_component(new Butter());
    assert(sandwich2.has_component!Butter());

    sandwich3.add_component(new Jelly());
    assert(sandwich3.has_component!Jelly());

    sandwich1.remove_component!Butter();

    // make sure everything else is still good
    assert(!sandwich1.has_component!Butter());
    assert(sandwich1.has_component!Jelly());
    assert(sandwich2.has_component!Butter());
    assert(sandwich3.has_component!Jelly());
}
