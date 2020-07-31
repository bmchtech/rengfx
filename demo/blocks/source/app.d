module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import play;
import hud;

/// window width
int width = 1280;
/// window height
int height = 720;
/// factor by which to divide the render resolution
int lowrez = 1;

class Game : Core {
	this() {
		super(width, height, "blocks");
	}

	override void initialize() {
		default_resolution = Vector2(width / lowrez, height / lowrez);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene(), new HUDScene()]);
	}
}

int main(string[] args) {
	import std.getopt : getopt, defaultGetoptPrinter;

	auto help = getopt(args, "width", "window width", &width, "height", "window height",
			&height, "lowrez", "factor by which to divide the render resolution", &lowrez);
	if (help.helpWanted) {
		defaultGetoptPrinter("Some information about the program.", help.options);
		return 1;
	}

	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
	return 0;
}
