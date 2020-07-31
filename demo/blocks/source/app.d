module app;

import std.stdio;

import re;
import re.math;
import std.stdio;
import play;
import hud;

int width = 1280;
int height = 720;

class Game : Core {
	this() {
		super(width, height, "blocks");
	}

	override void initialize() {
		// default_resolution = Vector2(WIDTH / 2, HEIGHT / 2);
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene(), new HUDScene()]);
	}
}

int main(string[] args) {
	import std.getopt : getopt, defaultGetoptPrinter;

	auto help = getopt(args, "width", &width, "height", &height);
	if (help.helpWanted) {
		defaultGetoptPrinter("Some information about the program.", help.options);
		return 1;
	}

	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
	return 0;
}
