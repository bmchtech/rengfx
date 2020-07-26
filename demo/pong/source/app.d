import std.stdio;

import re;
import std.stdio;
import play;

class Game : Core {
	this() {
		super(360, 640, "pong");
	}

	override void initialize() {
		content.paths ~= ["../content/", "content/"];

		load_scenes([new PlayScene()]);
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
