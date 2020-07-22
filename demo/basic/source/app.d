import std.stdio;

import re;
import std.stdio;
import bounce;

class Game : Core {
	this() {
		super(540, 360, "basic demo");
	}

	override void initialize() {
		super.initialize();

		log.info("hello, basic game!");
		content.base_path = "../content/";

		scene = new BounceScene();
	}
}

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
