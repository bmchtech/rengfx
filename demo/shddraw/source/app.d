module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import play;
import hud;

static import raylib;

class Game : Core {
	enum WIDTH = 960;
	enum HEIGHT = 540;

	public static string custom_mdl1_path = null;

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
