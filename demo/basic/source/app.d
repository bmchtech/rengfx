import std.stdio;
import game;

void main() {
	auto game = new Game(); // init game
	game.run();
	game.destroy(); // clean up
}
