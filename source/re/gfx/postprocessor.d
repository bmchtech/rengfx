module re.gfx.postprocessor;

import re.gfx;
import re.math;
static import raylib;

/// applies an effect to a rendertarget
class PostProcessor {
    /// the effect to apply to the input buffer
    public Effect effect;
    /// the render target buffer of this postprocessor
    public RenderTarget buffer;
    /// whether to enable this postprocessor
    public bool enabled = true;

    this(Vector2 resolution, Effect effect) {
        this.effect = effect;

        // create render target
        buffer = RenderExt.create_render_target(cast(int) resolution.x, cast(int) resolution.y);
    }

    /// process the source and render to internal buffer
    public void process(RenderTarget source) {
        RenderExt.draw_render_target_from(source, buffer, effect);
    }

    /// release resources
    public void destroy() {
        RenderExt.destroy_render_target(buffer);
    }
}
