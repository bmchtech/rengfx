module re.gfx.shapes.cube;

import re.gfx;
import re.gfx.shapes.mesh;
import re.math;
static import raylib;

/// represents a 3d rectangular prism (we abbreviate as cube)
class Cube : RenderableMesh {
    private Vector3 _size;
    this(Vector3 size, Color color = Colors.WHITE) {
        effect.color = color;
        this.size = size;
    }

    /// get rectangular prism dimensions
    @property Vector3 size() {
        return _size;
    }

    /// set rectangular prism dimensions
    @property Vector3 size(Vector3 value) {
        _size = value;
        gen_model();
        return value;
    }

    protected override void gen_mesh() {
        _mesh = raylib.GenMeshCube(_size.x, _size.y, _size.z);
    }
}
