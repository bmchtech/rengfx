module gui_root;

import re;
import re.gfx;
import re.math;
import re.ecs;
import re.ng.diag;
import re.util.interop;

import raylib;
import raylib_nuklear;

import std.array;
import std.conv;
import std.string;

// font size
enum UI_FS = 16;
enum UI_PAD = 4;

class GuiRoot : Component, Renderable2D, Updatable {
    mixin Reflect;

    @property public Rectangle bounds() {
        return Rectangle(
            transform.position2.x, transform.position2.y, entity.scene.resolution.x, entity
                .scene.resolution.y);
    }

    nk_context* ctx;
    nk_colorf bg;

    override void setup() {
        bg = ColorToNuklearF(Colors.SKYBLUE);
        auto ui_font = raylib.LoadFontEx("./res/SourceSansPro-Regular.ttf", UI_FS, null, 0);
        ctx = InitNuklearEx(ui_font, UI_FS);

        // nk_color[nk_style_colors.NK_COLOR_COUNT] table;
        // table[nk_style_colors.NK_COLOR_TEXT] = nk_rgba(190, 190, 190, 255);
        // table[nk_style_colors.NK_COLOR_WINDOW] = nk_rgba(30, 33, 40, 215);
        // table[nk_style_colors.NK_COLOR_HEADER] = nk_rgba(181, 45, 69, 220);
        // table[nk_style_colors.NK_COLOR_BORDER] = nk_rgba(51, 55, 67, 255);
        // table[nk_style_colors.NK_COLOR_BUTTON] = nk_rgba(181, 45, 69, 255);
        // table[nk_style_colors.NK_COLOR_BUTTON_HOVER] = nk_rgba(190, 50, 70, 255);
        // table[nk_style_colors.NK_COLOR_BUTTON_ACTIVE] = nk_rgba(195, 55, 75, 255);
        // table[nk_style_colors.NK_COLOR_TOGGLE] = nk_rgba(51, 55, 67, 255);
        // table[nk_style_colors.NK_COLOR_TOGGLE_HOVER] = nk_rgba(45, 60, 60, 255);
        // table[nk_style_colors.NK_COLOR_TOGGLE_CURSOR] = nk_rgba(181, 45, 69, 255);
        // table[nk_style_colors.NK_COLOR_SELECT] = nk_rgba(51, 55, 67, 255);
        // table[nk_style_colors.NK_COLOR_SELECT_ACTIVE] = nk_rgba(181, 45, 69, 255);
        // table[nk_style_colors.NK_COLOR_SLIDER] = nk_rgba(51, 55, 67, 255);
        // table[nk_style_colors.NK_COLOR_SLIDER_CURSOR] = nk_rgba(181, 45, 69, 255);
        // table[nk_style_colors.NK_COLOR_SLIDER_CURSOR_HOVER] = nk_rgba(186, 50, 74, 255);
        // table[nk_style_colors.NK_COLOR_SLIDER_CURSOR_ACTIVE] = nk_rgba(191, 55, 79, 255);
        // table[nk_style_colors.NK_COLOR_PROPERTY] = nk_rgba(51, 55, 67, 255);
        // table[nk_style_colors.NK_COLOR_EDIT] = nk_rgba(51, 55, 67, 225);
        // table[nk_style_colors.NK_COLOR_EDIT_CURSOR] = nk_rgba(190, 190, 190, 255);
        // table[nk_style_colors.NK_COLOR_COMBO] = nk_rgba(51, 55, 67, 255);
        // table[nk_style_colors.NK_COLOR_CHART] = nk_rgba(51, 55, 67, 255);
        // table[nk_style_colors.NK_COLOR_CHART_COLOR] = nk_rgba(170, 40, 60, 255);
        // table[nk_style_colors.NK_COLOR_CHART_COLOR_HIGHLIGHT] = nk_rgba(255, 0, 0, 255);
        // table[nk_style_colors.NK_COLOR_SCROLLBAR] = nk_rgba(30, 33, 40, 255);
        // table[nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR] = nk_rgba(64, 84, 95, 255);
        // table[nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR_HOVER] = nk_rgba(70, 90, 100, 255);
        // table[nk_style_colors.NK_COLOR_SCROLLBAR_CURSOR_ACTIVE] = nk_rgba(75, 95, 105, 255);
        // table[nk_style_colors.NK_COLOR_TAB_HEADER] = nk_rgba(181, 45, 69, 220);
        // nk_style_from_table(ctx, cast(nk_color*) table);

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
        if (nk_begin(ctx, "Demo", RectangleToNuklear(ui_bounds), nk_panel_flags.NK_WINDOW_BORDER | nk_panel_flags
                .NK_WINDOW_TITLE)) {
            enum EASY = 0;
            enum HARD = 1;
            static int op = EASY;
            static int property = 20;
            nk_layout_row_static(ctx, 30, 80, 1);
            if (nk_button_label(ctx, "button"))
                TraceLog(TraceLogLevel.LOG_INFO, "button pressed");

            nk_layout_row_dynamic(ctx, 30, 2);
            if (nk_option_label(ctx, "easy", op == EASY))
                op = EASY;
            if (nk_option_label(ctx, "hard", op == HARD))
                op = HARD;

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

        nk_end(ctx);

        DrawNuklear(ctx);
    }

    void debug_render() {
        raylib.DrawRectangleLinesEx(bounds, 1, Colors.RED);
    }
}
