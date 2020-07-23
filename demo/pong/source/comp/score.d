module comp.score;

import re.ecs;
import re.gfx.text;
import std.string;

class Scoreboard : Component {
    private Text text;
    public int player_score = 0;
    public int enemy_score = 0;

    override void setup() {
        text = entity.get_component!Text();
        refresh();
    }

    public void add_point_player() {
        player_score++;
        refresh();
    }

    public void add_point_enemy() {
        enemy_score++;
        refresh();
    }

    public void refresh() {
        text.text = format("%d | %d", player_score, enemy_score);
    }
}
