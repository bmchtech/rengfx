import std.stdio;

import re;
import std.stdio;
import play;

class Game : Core {
	this() {
		super(640, 480, "shanpes");
	}

	override void initialize() {
		super.initialize();

		content.base_path = "../content/";

		scene = new PlayScene();
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
