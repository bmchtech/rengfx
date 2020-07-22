module re.ecs.manager;

import re.ecs.entity;
import std.algorithm;
import std.array;

class EntityManager {
    public Entity[] entities;
    private size_t[] entities_to_remove;

    public Entity create_entity() {
        auto nt = new Entity();
        nt.initialize();
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
