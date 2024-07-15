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
		sync_render_window_resolution = true;
		oversample_hidpi = true;
		window_resizable = true;

		super(WIDTH, HEIGHT, "nuidemo");
	}

	override void initialize() {
		content.paths ~= ["./content/", "./res/"];
		load_scenes([new GuiScene()]);
	}
}

int main(string[] args) {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up

	return 0;
}
