module re.gfx.lighting.blinn_phong;

import re.core;
import re.ecs;
import re.ng.manager;
import re.ng.scene3d;
import re.gfx;
import re.math;
import std.algorithm;
import std.container.array;
static import raylib;

/// acts as a manager for Light3D components
class BlinnPhongLightManager : Manager, Updatable {
    private Entity[] obj_entities;

    override void update() {

    }

    public void register_entity(Entity nt) {
        obj_entities ~= nt;
    }

    public void unregister_entity(Entity nt) {
        obj_entities.remove!(x => x == nt);
    }
}
