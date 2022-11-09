module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import play;
import hud;
import std.getopt;

static import raylib;

class Game : Core {
	enum WIDTH = 960;
	enum HEIGHT = 540;

	public static string custom_mdl1_path = null;
	public static bool free_look = false;
	public static bool vr_enabled = false;

	this() {
		super(WIDTH, HEIGHT, "celtest");
	}

	override void initialize() {
		default_resolution = Vector2(WIDTH, HEIGHT);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene(), new HUDScene()]);
	}
}

int main(string[] args) {
	bool verbose;
	auto help = getopt(args,
		"verbose|v", &verbose,
		"model|m", &Game.custom_mdl1_path,
		"free-cam|f", &Game.free_look,
		"vr", &Game.vr_enabled,
	);

	Core.auto_compensate_hidpi = false;

	if (help.helpWanted) {
		defaultGetoptPrinter("Usage: ./a [--model /path/to/model.glb] [-f]", help.options);
		return 1;
	}

	raylib.SetConfigFlags(raylib.ConfigFlags.FLAG_MSAA_4X_HINT);
	if (verbose) {
		raylib.SetTraceLogLevel(raylib.TraceLogLevel.LOG_INFO);
	} else {
		raylib.SetTraceLogLevel(raylib.TraceLogLevel.LOG_WARNING);
	}

	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up

	return 0;
}
