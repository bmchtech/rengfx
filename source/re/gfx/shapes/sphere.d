module re.gfx.shapes.sphere;

import re.gfx;
import re.ecs.component;
import re.gfx.shapes.mesh;
import re.math;
static import raylib;

/// represents a 3d rectangular prism (we abbreviate as cube)
class Sphere : RenderableMesh {
    mixin Reflect;
    private float _radius;
    private int _rings;
    private int _slices;

    this(float radius, int rings, int slices, Color color = Colors.WHITE) {
        effect.color = color;
        _radius = radius;
        _rings = rings;
        _slices = slices;
    }

    /// get rectangular prism dimensions
    @property float radius() {
        return _radius;
    }

    protected override Mesh gen_mesh() {
        return raylib.GenMeshSphere(_radius, _rings, _slices);
    }
}
