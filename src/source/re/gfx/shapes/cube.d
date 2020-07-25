module re.gfx.shapes.cube;

import re.ecs;
import re.gfx;
import re.math;
import re.ng.diag;
static import raylib;

/// represents a 3d rectangular prism (we abbreviate as cube)
class Cube : Component, Renderable3D {
    private Vector3 _size;
    /// color
    public Color color;
    private Mesh _mesh;
    private Model _model;

    this(Vector3 size, Color color) {
        this.size = size;
        this.color = color;
    }

    /// get rectangular prism dimensions
    @property Vector3 size() {
        return _size;
    }

    /// set rectangular prism dimensions
    @property Vector3 size(Vector3 value) {
        _size = value;
        gen_mesh();
        return value;
    }

    @property BoundingBox bounds() {
        return raylib.MeshBoundingBox(_mesh);
    }

    /// gets the model
    @property Model model() {
        return _model;
    }

    private void gen_mesh() {
        _mesh = raylib.GenMeshCube(_size.x, _size.y, _size.z);
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
