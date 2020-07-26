module re.gfx.shapes.model;

import re.gfx;
import re.gfx.shapes.mesh;
import re.math;
static import raylib;

/// represents a 3d model
class Model3D : RenderableMesh {
    this(Model model) {
        _model = model;
        gen_mesh();
    }

    protected override void gen_mesh() {
        _mesh = model.meshes[0];
    }
}
