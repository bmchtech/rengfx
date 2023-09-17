module gui_root;

import re;
import re.gfx;
import re.math;
import re.ecs;
import re.ng.diag;
import re.util.interop;

import raylib;
import raylib_nuklear;
import nuklear_ext;
import style;

import std.array;
import std.conv;
import std.string;

// font size
enum UI_FS = 16;
enum UI_UI_PAD = 4;

class GuiRoot : Component, Renderable2D, Updatable {
    mixin Reflect;

    @property public Rectangle bounds() {
        return Rectangle(transform.position2.x, transform.position2.y,
            entity.scene.resolution.x, entity.scene.resolution.y);
    }

    nk_context* ctx;
    nk_colorf bg;

    override void setup() {
        bg = ColorToNuklearF(Colors.SKYBLUE);
        auto ui_font = raylib.LoadFontEx("./res/SourceSansPro-Regular.ttf", UI_FS, null, 0);
        ctx = InitNuklearEx(ui_font, UI_FS);
        // SetNuklearScaling(ctx, cast(int) Core.window.scale_dpi);
        apply_style(ctx);

        status("ready.");
    }

    @property string status(string val) {
        // log status
        Core.log.info(format("status: %s", val));
        return status_text = val;
    }

    private string status_text = "";
    int active_tab = 0;
    bool tab_picker_open = false;

    void update() {
        // keyboard shortcuts
        if (Input.is_key_down(Keys.KEY_LEFT_CONTROL) && Input.is_key_pressed(Keys.KEY_TAB)) {
            // advance tab
            // active_tab = cast(int)((active_tab + 1) % tab_mds.length);
        }
    }

    void render() {
        auto ui_bounds = bounds;

        UpdateNuklear(ctx);

        // GUI
        // auto window_bounds = nk_rect(0, 0, GetRenderWidth(), GetRenderHeight());
        auto window_bounds = Rectangle(0, 0, GetRenderWidth(), GetRenderHeight());
        if (nk_begin(ctx, "Demo", RectangleToNuklear(ctx, window_bounds),
                nk_panel_flags.NK_WINDOW_BORDER | nk_panel_flags.NK_WINDOW_TITLE)) {
            enum EASY = 0;
            enum HARD = 1;

            nk_style_push_vec2(ctx, &ctx.style.window.spacing, nk_vec2(0, 0));
            nk_style_push_float(ctx, &ctx.style.button.rounding, 0);
            nk_layout_row_begin(ctx, nk_layout_format.NK_STATIC, 30, 2);
            enum TAB1 = 0;
            enum TAB2 = 1;
            static int tab_state = TAB1;
            if (nk_tab(ctx, "TAB1", tab_state == TAB1)) {
                tab_state = TAB1;
            }
            if (nk_tab(ctx, "TAB2", tab_state == TAB2)) {
                tab_state = TAB2;
            }

            if (tab_state == TAB1) {
                static int op = EASY;

                nk_layout_row_dynamic(ctx, UI_PAD, 1);

                nk_layout_row_static(ctx, 30, 80, 1);
                if (nk_button_label(ctx, "button"))
                    TraceLog(TraceLogLevel.LOG_INFO, "button pressed");

                nk_layout_row_dynamic(ctx, 30, 2);
                if (nk_option_label(ctx, "easy", op == EASY))
                    op = EASY;
                if (nk_option_label(ctx, "hard", op == HARD))
                    op = HARD;
            } else if (tab_state == TAB2) {
                static int property = 20;

                nk_layout_row_dynamic(ctx, UI_PAD, 1);

                nk_layout_row_dynamic(ctx, 25, 1);
                nk_property_int(ctx, "Compression:", 0, &property, 100, 10, 1);

                nk_layout_row_dynamic(ctx, 20, 1);
                nk_label(ctx, "background:", nk_text_alignment.NK_TEXT_LEFT);
                nk_layout_row_dynamic(ctx, 25, 1);
                if (nk_combo_begin_color(ctx, nk_rgb_cf(bg), nk_vec2(nk_widget_width(ctx), 400))) {
                    nk_layout_row_dynamic(ctx, 120, 1);
                    bg = nk_color_picker(ctx, bg, nk_color_format.NK_RGBA);
                    nk_layout_row_dynamic(ctx, 25, 1);
                    bg.r = nk_propertyf(ctx, "#R:", 0, bg.r, 1.0f, 0.01f, 0.005f);
                    bg.g = nk_propertyf(ctx, "#G:", 0, bg.g, 1.0f, 0.01f, 0.005f);
                    bg.b = nk_propertyf(ctx, "#B:", 0, bg.b, 1.0f, 0.01f, 0.005f);
                    bg.a = nk_propertyf(ctx, "#A:", 0, bg.a, 1.0f, 0.01f, 0.005f);
                    nk_combo_end(ctx);
                }
            }

            nk_style_pop_float(ctx);
            nk_style_pop_vec2(ctx);
        }

        nk_end(ctx);

        DrawNuklear(ctx);
    }

    void debug_render() {
        raylib.DrawRectangleLinesEx(bounds, 1, Colors.RED);
    }
}
