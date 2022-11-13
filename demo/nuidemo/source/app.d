module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import gui_scene;
import std.getopt;

static import raylib;

class Game : Core {
	enum WIDTH = 960;
	enum HEIGHT = 540;

	this() {
		// sync_render_window_resolution = true;
		auto_compensate_hidpi = true;
		// auto_oversample_hidpi = true;

		super(WIDTH, HEIGHT, "pksave explorer");
	}

	override void initialize() {
		// default_resolution = Vector2(WIDTH, HEIGHT);
		content.paths ~= ["../content/", "content/", "./res/"];

		raylib.SetWindowState(raylib.ConfigFlags.FLAG_WINDOW_RESIZABLE);

		// auto_compensate_hidpi = true;
		load_scenes([new GuiScene()]);
	}
}

int main(string[] args) {
	bool verbose;
	auto help = getopt(args,
		"verbose|v", &verbose,
	);

	if (help.helpWanted) {
		defaultGetoptPrinter("Usage: ./a", help.options);
		return 1;
	}

	raylib.SetWindowState(raylib.ConfigFlags.FLAG_WINDOW_HIGHDPI);

	if (verbose) {
		raylib.SetTraceLogLevel(raylib.TraceLogLevel.LOG_INFO);
	} else {
		raylib.SetTraceLogLevel(raylib.TraceLogLevel.LOG_WARNING);
	}

	// Game.auto_compensate_hidpi = false;

	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up

	return 0;
}
