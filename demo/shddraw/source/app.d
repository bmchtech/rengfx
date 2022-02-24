module app;

import std.stdio;
import std.getopt;

import re;
import re.math;
import play;
import hud;

static import raylib;

class Game : Core {
	enum WIDTH = 960;
	enum HEIGHT = 540;

	public static string custom_drawshd_path = null;
	public static string custom_presentshd_path = null;

	this() {
		super(WIDTH, HEIGHT, "shader drawing");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH, HEIGHT);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene(), new HUDScene()]);
	}
}

int main(string[] args) {
	auto help = getopt(args, "draw-shader|d", &Game.custom_drawshd_path, "present-shader|p", &Game
			.custom_presentshd_path);

	if (help.helpWanted) {
		defaultGetoptPrinter("Usage: ./a [-d /path/to/draw.frag -p /path/to/present.frag]", help
				.options);
		return 1;
	}

	raylib.SetConfigFlags(raylib.ConfigFlags.FLAG_MSAA_4X_HINT);
	debug {
	} else {
		raylib.SetTraceLogLevel(raylib.TraceLogLevel.LOG_WARNING);
	}

	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up

	return 0;
}
