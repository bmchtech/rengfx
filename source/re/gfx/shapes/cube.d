module re.gfx.shapes.cube;

import re.gfx;
import re.ecs.component;
import re.gfx.shapes.mesh;
import re.math;
static import raylib;

/// represents a 3d rectangular prism (we abbreviate as cube)
class Cube : RenderableMesh {
    mixin Reflect;
    private Vector3 _size;

    this(Vector3 size, Color color = Colors.WHITE) {
        effect.color = color;
        _size = size;
    }

    /// get rectangular prism dimensions
    @property Vector3 size() {
        return _size;
    }

    protected override Mesh gen_mesh() {
        return raylib.GenMeshCube(_size.x, _size.y, _size.z);
    }
}
