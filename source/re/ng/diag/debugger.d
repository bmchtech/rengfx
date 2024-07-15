/** provides runtime debugging functionality in an overlay */

module re.ng.diag.debugger;

import std.format;

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
    public Rectangle ui_bounds;
    private enum bg_col = Color(180, 180, 180, 180);
    private RenderTarget _render_target;
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
            ui_bounds = Rectangle(0, 0, Core.window.render_width, Core.window.render_height);
            _render_target = RenderExt.create_render_target(cast(int) ui_bounds.width, cast(int) ui_bounds
                    .height);
            Core.log.info(format("debugger info: ui_bounds=%s, resolution=%s",
                    ui_bounds, Core.default_resolution));
        }
    }

    public void update() {
        if (!Core.headless) {
            // auto-resize inspector
            inspector.width = cast(int)(ui_bounds.width * 0.7);
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
        if (!inspector.open && !console.open) {
            // nothing to render
            return;
        }

        raylib.BeginTextureMode(_render_target);
        raylib.ClearBackground(Colors.BLANK);

        if (inspector.open)
            inspector.render();
        if (console.open)
            console.render();

        raylib.EndTextureMode();

        // draw render target
        RenderExt.draw_render_target(_render_target,
            Rectangle(0, 0, Core.window.render_width, Core.window.render_height),
            _render_col
        );
    }

    /// clean up
    public void destroy() {
        if (inspector.open) {
            inspector.close();
        }
        RenderExt.destroy_render_target(_render_target);
    }
}
