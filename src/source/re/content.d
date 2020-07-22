module re.content;

static import raylib;
import std.string;

class ContentManager {
    private raylib.Image[string] _cache_images;
    public string base_path = string.init;

    this() {
        // setup
    }

    private char* get_path(string path) {
        return cast(char*) toStringz(base_path ~ path);
    }

    public raylib.Texture2D load_texture2d(string path) {
        auto image = raylib.LoadImage(get_path(path));
        _cache_images[path] = image;

        // copy image to VRAM
        return raylib.LoadTextureFromImage(image);
    }

    public void destroy() {
        // release all resources

        // release images
        foreach (item; _cache_images.byValue()) {
            raylib.UnloadImage(item);
        }
    }
}