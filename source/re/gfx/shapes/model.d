module re.gfx.shapes.model;

import re.gfx;
import re.gfx.shapes.mesh;
import re.math;
static import raylib;

/// represents a 3d model
class Model3D : RenderableMesh {
    private Model _mdl;
    this(Model model) {
        _mdl = model;
        gen_mesh();
    }

    protected override Mesh gen_mesh() {
        return model.meshes[0];
    }
}
