module re.gfx.shapes.mesh;

import re.ecs;
import re.gfx;
import re.math;
import re.ng.diag;
static import raylib;

/// represents a 3d mesh
abstract class RenderableMesh : Component, Renderable3D {
    /// color
    public Color color;
    protected Mesh _mesh;
    protected Model _model;

    this(Color color) {
        this.color = color;
    }

    @property BoundingBox bounds() {
        return raylib.MeshBoundingBox(_mesh);
    }

    /// gets the model
    @property Model model() {
        return _model;
    }

    protected abstract void gen_mesh();

    protected void gen_model() {
        gen_mesh();
        _model = raylib.LoadModelFromMesh(_mesh);
    }

    public void render() {
        raylib.DrawModel(_model, entity.position, 1, color);
    }

    public void debug_render() {
        Debugger.default_debug_render(this);
    }

    override void destroy() {
        // freeing the model also frees the mesh
        raylib.UnloadModel(_model);
    }
}
