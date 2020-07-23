module re.content;

static import raylib;
import std.string;
import re.util.cache;

/// manages external content loading
class ContentManager
{
    private KeyedCache!(raylib.Image) _image_cache;
    /// base path for content
    public string base_path = string.init;

    /// initializes the content manager
    this()
    {
        // setup
    }

    private char* get_path(string path)
    {
        return cast(char*) toStringz(base_path ~ path);
    }

    /// loads a texture from disk
    public raylib.Texture2D load_texture2d(string path)
    {
        raylib.Image image;
        auto cached = _image_cache.get(path);
        if (cached.isNull)
        {
            image = raylib.LoadImage(get_path(path));
            _image_cache.put(path, image);
        }
        else
        {
            image = cached.get;
        }

        // copy image to VRAM
        return raylib.LoadTextureFromImage(image);
    }

    /// releases all resources
    public void destroy()
    {
        _image_cache.drop();
    }
}
