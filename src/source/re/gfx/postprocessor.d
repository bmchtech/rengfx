module re.gfx.postprocessor;

import re.gfx;
static import raylib;

class PostProcessor {
    public Effect effect;

    this(Effect effect) {
        this.effect = effect;
    }

    public void process(RenderTarget source, RenderTarget dest) {
        // TODO: draw src to dest
        // RenderExt.draw_render_target(source, dest);
    }
}
