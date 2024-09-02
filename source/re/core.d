/** globally available game core, providing access to most key game services and scene control */

module re.core;

import std.array;
import std.typecons;
import std.format;

import re.input;
import re.content;
import re.time;
import re.gfx.window;
import re.ng.scene;
import re.ng.diag;
import re.ng.manager;
import re.gfx.render_ext;
import re.math;
import re.util.logger;
import re.util.tweens.tween_manager;
import re.util.env;
import re.util.jar;
static import raylib;

/**
Core class
*/
abstract class Core {
    /// logger utility
    public static Logger log;

    /// game window
    public static Window window;

    /// content manager
    public static ContentManager content;

    /// the current scenes
    private static Scene[] _scenes;

    /// type registration container
    public static Jar jar;

    /// global managers
    public static Manager[] managers;

    /// whether to draw debug information
    public static bool debug_render;

    /// inspector overlay utility
    public static InspectorOverlay inspector_overlay;

    /// whether the game is running
    public static bool running;

    version (unittest) {
        /// the frame limit (used for testing)
        public static int frame_limit = 60;
    }

    /// target frames per second
    public static int target_fps = 60;

    /// whether graphics should be disabled
    public static bool headless = false;

    /// whether to pause when unfocused
    public static bool pause_on_focus_lost = true;

    /// whether to exit when escape pressed
    public static bool exit_on_escape_pressed = true;

    /// oversampling factor for internal rendering
    public static int render_oversample_factor = 1;

    /// whether to automatically resize the render target to the window size
    public static bool sync_render_target_to_window_resolution = false;

    /// whether to make the window resizable
    public static bool window_resizable = false;

    /// the default render resolution for all scenes
    public static Vector2 default_resolution;

    /// the default texture filtering mode for render targets
    public static raylib.TextureFilter default_filter_mode
        = raylib.TextureFilter.TEXTURE_FILTER_POINT;

    version (vr) {
        import re.gfx.vr;

        public static VRSupport vr;
    }

    private void read_environment_config() {
        target_fps = Environment.get_int("RENG_TARGET_FPS", target_fps);
        headless = Environment.get_bool("RENG_HEADLESS", headless);
        pause_on_focus_lost = Environment.get_bool("RENG_PAUSE_ON_FOCUS_LOST", pause_on_focus_lost);
        exit_on_escape_pressed = Environment.get_bool("RENG_EXIT_ON_ESCAPE_PRESSED", exit_on_escape_pressed);
    }

    /// sets up a game core
    this(int width, int height, string title) {
        log = Logger(Verbosity.info);

        read_environment_config();

        version (unittest) {
        } else {
            log.info("initializing rengfx core");
        }

        default_resolution = Vector2(width, height);
        if (!Core.headless) {
            window = new Window();
            window.set_resizable(window_resizable);
            window.initialize(width, height);
            window.set_title(title);
            calculate_render_resolution();
        }

        // disable default exit key
        raylib.SetExitKey(raylib.KeyboardKey.KEY_NULL);

        content = new ContentManager();

        jar = new Jar();

        add_manager(new TweenManager());

        inspector_overlay = new InspectorOverlay();
        debug {
            // in debug builds, enable the inspector overlay by default
            inspector_overlay.enabled = true;
            // add the default inspector commands
            inspector_overlay.console.add_default_inspector_commands();
        }

        version (vr) {
            import re.gfx.vr;

            vr = new VRSupport();
        }

        version (unittest) {
        } else {
            log.info("initializing game");
        }

        initialize();
    }

    @property public static int fps() {
        return raylib.GetFPS();
    }

    /// sets up the game
    abstract void initialize();

    /// starts the game
    public void run() {
        running = true;
        // start the game loop
        while (running) {
            if (!headless) {
                running = !raylib.WindowShouldClose();
            }

            update();
            draw();

            version (unittest) {
                if (Time.frame_count >= frame_limit) {
                    running = false;
                }
            }
        }
    }

    /// gracefully exits the game
    public static void exit() {
        running = false;
        version (unittest) {
        } else {
            log.info("gracefully exiting");
        }
    }

    protected void update() {
        // update window
        if (!Core.headless) {
            if (pause_on_focus_lost && raylib.IsWindowMinimized()) {
                return; // pause
            }
            if (exit_on_escape_pressed && raylib.IsKeyPressed(raylib.KeyboardKey.KEY_ESCAPE)) {
                exit();
            }
            if (raylib.IsWindowResized()) {
                handle_window_resize();
            }
        }

        version (unittest) {
            Time.update(1f / target_fps); // 60 fps
        } else {
            Time.update(raylib.GetFrameTime());
        }
        foreach (manager; managers) {
            manager.update();
        }
        // update input
        Input.update();
        // update scenes
        foreach (scene; _scenes) {
            scene.update();
        }

        if (inspector_overlay.enabled) {
            inspector_overlay.update();
        }
    }

    protected void draw() {
        if (Core.headless)
            return;
        if (raylib.IsWindowMinimized()) {
            return; // suppress draw
        }
        raylib.BeginDrawing();
        foreach (scene; _scenes) {
            // render scene
            scene.render();
            // post-render
            scene.post_render();
            // composite  (blit)screen render to window
            // when the scene is rendered, it is rendered to a texture. this texture is then composited onto the main display buffer.

            version (vr) {
                bool vr_distort = false;
                if (vr.enabled) {
                    assert(vr.distortion_shader != raylib.Shader.init, "vr.distortion_shader is not initialized");
                    vr_distort = true;
                }

                if (vr_distort)
                    raylib.BeginShaderMode(vr.distortion_shader);
            }

            foreach (viewport; scene.viewports) {
                RenderExt.draw_render_target_crop(
                    viewport.render_target, viewport.crop_bounds, viewport.output_bounds, scene.composite_mode.color
                );
            }

            version (vr) {
                if (vr_distort)
                    raylib.EndShaderMode();
            }
        }
        
        if (inspector_overlay.enabled) {
            inspector_overlay.render();
        }

        raylib.EndDrawing();
    }

    public static T get_scene(T)() {
        import std.algorithm.searching : find;

        // find a scene matching the type
        auto matches = _scenes.find!(x => (cast(T) x) !is null);
        assert(matches.length > 0, "no matching scene was found");
        return cast(T) matches.front;
    }

    public static Nullable!T get_manager(T)() {
        import std.algorithm.searching : find;

        // find a manager matching the type
        auto matches = managers.find!(x => (cast(T) x) !is null);
        if (matches.length > 0) {
            return Nullable!T(cast(T) matches.front);
        }
        return Nullable!T.init;
    }

    /// adds a global manager
    public T add_manager(T)(T manager) {
        managers ~= manager;
        manager.setup();
        return manager;
    }

    @property public static Scene[] scenes() {
        return _scenes;
    }

    @property public static Scene primary_scene() {
        return _scenes.front;
    }

    /// sets the current scenes
    static void load_scenes(Scene[] new_scenes) {
        foreach (scene; _scenes) {
            // end old scenes
            scene.end();
            scene = null;
        }
        // clear scenes list
        _scenes = [];

        _scenes ~= new_scenes;
        // begin new scenes
        foreach (scene; _scenes) {
            scene.begin();
        }
    }

    /// releases all resources and cleans up
    public void destroy() {
        version (vr) {
            if (vr.enabled) {
                assert(vr.config != raylib.VrStereoConfig.init, "vr config was not initialized");

                raylib.UnloadVrStereoConfig(vr.config);
            }

        }
        inspector_overlay.destroy();
        content.destroy();
        load_scenes([]); // end scenes
        foreach (manager; managers) {
            manager.destroy();
        }
        if (!Core.headless) {
            window.destroy();
        }
    }

    private void handle_window_resize() {
        log.info("window resized to (%s,%s)", window.screen_width, window.screen_height);
        // window was resized
        if (sync_render_target_to_window_resolution) {
            calculate_render_resolution();
        }
        // notify the active scenes
        foreach (scene; _scenes) {
            scene.on_window_resized();
        }
    }

    private void calculate_render_resolution() {
        // since window was resized, update our render resolution
        // first get the new window size
        auto render_res_x = window.render_width;
        auto render_res_y = window.render_height;

        // set mouse scale
        auto mouse_scale_factor = 1.0 * scale_factor;
        raylib.SetMouseScale(mouse_scale_factor, mouse_scale_factor);

        if (render_oversample_factor > 1) {
            // if oversampling is enabled, we need to multiply by the oversampling factor
            render_res_x *= render_oversample_factor;
            render_res_y *= render_oversample_factor;
        }

        // set the render resolution
        default_resolution = Vector2(render_res_x, render_res_y);
        Core.log.info(format("updating render resolution to %s (oversample %s)",
                default_resolution, render_oversample_factor));
    }

    /// overall scale factor from screen space coordinates to render space
    static @property float scale_factor() {
        return window.dpi_scale * render_oversample_factor;
    }
}

@("core-basic")
unittest {
    import re.util.test : TestGame;
    import std.string : format;
    import std.math : isClose;

    class Game : TestGame {
        override void initialize() {
            // nothing much
        }
    }

    auto game = new Game();
    game.run();

    // ensure time has passed
    auto target_time = Core.frame_limit / Core.target_fps;
    assert(isClose(Time.total_time, target_time),
        format("time did not pass (expected: %s, actual: %s)", target_time, Time.total_time));

    game.destroy(); // clean up

    assert(game.scenes.length == 0, "scenes were not removed after Game cleanup");
}
