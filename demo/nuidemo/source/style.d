module style;

import raylib;
import nuklear;
import raylib_nuklear;

enum UI_PAD = 8;

void apply_style(nk_context* ctx) {

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

    ctx.style.button.padding.x = UI_PAD;
}
