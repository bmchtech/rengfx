module re.ng.viewport;

static import raylib;

import re;
import re.math;
import re.gfx;

import re.ng.camera.cam2d;
import re.ng.camera.cam3d;

/// represents a view of a scene
abstract class Viewport {
    /// the render target's texture
    public RenderTarget render_target;
    /// the render target's output bounds: the area of the screen it renders to
    public Rectangle output_bounds;
    /// the render target's crop region: the area of the render target that is rendered to the output bounds
    public Rectangle crop_bounds = RectangleZero; // default to full render target
    /// the render target's resolution
    public Vector2 resolution;

    /// whether to sync the render target to maximum size
    public bool sync_maximized;
    /// texture filter
    public raylib.TextureFilter filter;

    void update() {
        
    }

    void destroy() {
        RenderExt.destroy_render_target(render_target);
    }
}

class Viewport2D : Viewport {
    /// the 2d scene camera
    public SceneCamera2D cam;

    override void update() {
        cam.update();
    }
}

class Viewport3D : Viewport {
    /// the 3d scene camera
    public SceneCamera3D cam;

    override void update() {
        cam.update();
    }
}
