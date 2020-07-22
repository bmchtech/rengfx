module re.content;

static import raylib;
import std.string;

/// manages external content loading
class ContentManager {
    private raylib.Image[string] _cache_images;
    /// base path for content
    public string base_path = string.init;

    /// initializes the content manager
    this() {
        // setup
    }

    private char* get_path(string path) {
        return cast(char*) toStringz(base_path ~ path);
    }

    /// loads a texture from disk
    public raylib.Texture2D load_texture2d(string path) {
        auto image = raylib.LoadImage(get_path(path));
        _cache_images[path] = image;

        // copy image to VRAM
        return raylib.LoadTextureFromImage(image);
    }

    /// releases all cached resources
    public void destroy() {
        // release images
        foreach (item; _cache_images.byValue()) {
            raylib.UnloadImage(item);
        }
    }
}