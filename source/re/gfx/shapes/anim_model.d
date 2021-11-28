module re.gfx.shapes.anim_model;

import re.ecs;
import re.gfx;
import re.math;
import re.ng.diag;
import re.math;
import re.gfx.shapes.model;
static import raylib;

/// represents an animated 3d model
class AnimModel3D : Model3D, Updatable {
    mixin Reflect;

    public raylib.ModelAnimation[] anims;
    public int anim_ix = 0;
    public int anim_frame;
    public bool anim_playing = false;

    this(Model model, raylib.ModelAnimation[] anims) {
        super(model);
        this.anims = anims;
    }

    public void play_anim(int anim_index) {
        anim_ix = anim_index;
        anim_frame = 0;
        anim_playing = true;
    }

    public void update() {
        if (!anim_playing) return;

        auto curr_anim = &anims[anim_ix];
        if (anim_frame <= curr_anim.frameCount) {
            raylib.UpdateModelAnimation(this.model, *curr_anim, anim_frame);
            anim_frame++;
        } else {
            anim_playing = false;
        }
    }

    public override void render() {
        super.render();
    }
}
