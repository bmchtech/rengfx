/** provides runtime debugging functionality in an overlay */

module re.ng.diag.inspector_overlay;

import std.format;

import re.core;
import re.ecs;
import re.input.input;
import re.math;
import re.gfx;
import re.gfx.render_ext;
import re.ng.diag.console;
import re.ng.diag.inspector_overlay;
import re.ng.diag.entity_inspect_view;
static import raylib;
static import raygui;

/// a robust overlay debugging tool
class InspectorOverlay {
    public bool enabled = false;
    public enum screen_padding = 12;
    public Rectangle ui_bounds;
    private enum bg_col = Color(180, 180, 180, 180);
    private RenderTarget _render_target;
    private enum _render_col = Color(255, 255, 255, 160);

    /// inspector panel
    debug {
        public static EntityInspectView entity_inspect_view;
    }

    /// debug console
    public static InspectorConsole console;

    /// sets up debugger
    this() {
        debug {
            entity_inspect_view = new EntityInspectView();
        }
        console = new InspectorConsole();
        if (!Core.headless) {
            ui_bounds = Rectangle(0, 0, Core.window.screen_width, Core.window.screen_height);
            _render_target = RenderExt.create_render_target(
                cast(int) ui_bounds.width, cast(int) ui_bounds.height
            );
            Core.log.info(
                format("debugger info: ui_bounds=%s, resolution=%s",
                    ui_bounds, Core.default_resolution)
            );
        }
    }

    public void update() {
        if (Input.is_key_pressed(console.key)) {
            Core.debug_render = !Core.debug_render;
            console.open = !console.open;
        }

        if (console.open)
            console.update();

        debug {
            if (!Core.headless) {
                // auto-resize inspector
                entity_inspect_view.width = cast(int)(ui_bounds.width * 0.7);
            }
            if (entity_inspect_view.open)
                entity_inspect_view.update();
        }
    }

    public void render() {
        raylib.BeginTextureMode(_render_target);
        raylib.ClearBackground(Colors.BLANK);

        if (console.open)
            console.render();

        debug {
            if (entity_inspect_view.open)
                entity_inspect_view.render();
        }

        raylib.EndTextureMode();

        // draw render target
        RenderExt.draw_render_target(_render_target,
            Rectangle(0, 0, Core.window.screen_width, Core.window.screen_height),
            _render_col
        );
    }

    /// clean up
    public void destroy() {
        debug {
            if (entity_inspect_view.open) {
                entity_inspect_view.close();
            }
        }
        RenderExt.destroy_render_target(_render_target);
    }
}
