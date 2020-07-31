module re.ng.diag.debugger;

import re.core;
import re.ecs;
import re.input.input;
import re.math;
import re.gfx;
import re.gfx.render_ext;
import re.ng.diag.console;
import re.ng.diag.inspector;
static import raylib;
static import raygui;

/// a robust overlay debugging tool
debug class Debugger {
    public enum screen_padding = 12;
    private enum bg_col = Color(180, 180, 180, 180);
    private raylib.RenderTexture2D _render_target;
    private enum _render_col = Color(255, 255, 255, 160);

    /// inspector panel
    public static Inspector inspector;

    /// debug console
    public static Console console;

    /// sets up debugger
    this() {
        inspector = new Inspector();
        console = new Console();
        if (!Core.headless) {
            _render_target = raylib.LoadRenderTexture(Core.window.width, Core.window.height);
        }
    }

    public void update() {
        if (!Core.headless) {
            // auto-resize inspector
            inspector.width = cast(int)(Core.window.width * 0.7);
        }

        if (Input.is_key_pressed(console.key)) {
            Core.debug_render = !Core.debug_render;
            console.open = !console.open;
        }

        if (inspector.open)
            inspector.update();
        if (console.open)
            console.update();
    }

    public void render() {
        raylib.BeginTextureMode(_render_target);
        raylib.ClearBackground(Colors.BLANK);
        if (inspector.open)
            inspector.render();
        if (console.open)
            console.render();
        raylib.EndTextureMode();

        // draw render target
        RenderExt.draw_render_target(_render_target, Rectangle(0, 0,
                Core.window.width, Core.window.height), _render_col);
    }

    /// clean up
    public void destroy() {
        if (inspector.open) {
            inspector.close();
        }
        raylib.UnloadRenderTexture(_render_target);
    }
}
