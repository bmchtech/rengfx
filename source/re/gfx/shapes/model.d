module re.gfx.shapes.model;

import re.ecs;
import re.gfx;
import re.math;
import re.ng.diag;
import re.math;
static import raylib;

/// represents a 3d model
class Model3D : Component, Renderable3D {
    mixin Reflect;
    /// the model
    public Model model;
    private Effect _effect;

    this(Model model) {
        this.model = model;
    }

    /// gets the effect
    @property ref Effect effect() {
        return _effect;
    }

    /// sets the effect
    @property Effect effect(Effect value) {
        _effect = value;
        model.materials[0].shader = _effect.shader;
        return value;
    }

    @property BoundingBox bounds() {
        return raylib.MeshBoundingBox(model.meshes[0]);
    }

    public void render() {
        raylib.DrawModel(model, entity.position, 1, effect.color);
    }

    public void debug_render() {
        DebugRender.default_debug_render(this, model);
    }
}
