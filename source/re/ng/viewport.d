module re.ng.viewport;

static import raylib;

import re;
import re.math;
import re.gfx;

import re.ng.camera.cam2d;
import re.ng.camera.cam3d;

/// represents a view of a scene
abstract class Viewport {
    /// the render target texture
    public RenderTarget render_target;
    /// the render target's output rectangle
    public Rectangle output_rect;
    /// whether to sync the render target to maximum size
    public bool sync_maximized;
    /// texture filter
    public raylib.TextureFilter filter;

    public @property Vector2 resolution() {
        return Vector2(render_target.texture.width, render_target.texture.height);
    }

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
