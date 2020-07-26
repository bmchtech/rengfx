module re.gfx.shapes.mesh;

import re.ecs;
import re.gfx;
import re.math;
import re.ng.diag;
static import raylib;

/// renders a model given a mesh. should only be used for procedural meshes; use Model3D for models instead
abstract class RenderableMesh : Component, Renderable3D {
    /// effect
    private Effect _effect;
    private Mesh _mesh;
    private Model _model;

    override void setup() {
        gen_model();
    }

    @property BoundingBox bounds() {
        return raylib.MeshBoundingBox(_mesh);
    }

    /// gets the effect
    @property ref Effect effect() {
        return _effect;
    }

    /// sets the effect
    @property Effect effect(Effect value) {
        _effect = value;
        _model.materials[0].shader = _effect.shader;
        return value;
    }

    /// gets the model
    @property Model model() {
        return _model;
    }

    /// create the mesh
    protected abstract Mesh gen_mesh();

    /// generate the model (from the mesh)
    protected void gen_model() {
        _mesh = gen_mesh();
        _model = raylib.LoadModelFromMesh(_mesh);
    }

    public void render() {
        raylib.DrawModel(_model, entity.position, 1, effect.color);
    }

    public void debug_render() {
        Debugger.default_debug_render(this);
    }

    override void destroy() {
        // freeing the model also frees the mesh
        raylib.UnloadModel(_model);
    }
}
