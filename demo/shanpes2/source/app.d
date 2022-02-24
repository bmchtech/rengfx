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

	this() {
		super(WIDTH, HEIGHT, "shanpes2");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH, HEIGHT);
		content.paths ~= ["../content/", "content/"];

		raylib.SetConfigFlags(raylib.ConfigFlags.FLAG_MSAA_4X_HINT);
		debug {
		} else {
			raylib.SetTraceLogLevel(raylib.TraceLogLevel.LOG_WARNING);
		}

		load_scenes([new PlayScene(), new HUDScene()]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
