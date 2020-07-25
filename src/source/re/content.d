module re.content;

import re.util.cache;
import re.util.interop;
import std.string;
import std.file;
import std.conv;
import std.path;
import std.stdio;
static import raylib;

/// manages external content loading
class ContentManager {
    alias TexCache = KeyedCache!(raylib.Texture2D);
    private TexCache _tex_cache;
    alias ModelCache = KeyedCache!(raylib.Model);
    private ModelCache _mdl_cache;
    alias ShaderCache = KeyedCache!(raylib.Shader);
    private ShaderCache _shd_cache;

    /// search paths for content
    public string[] paths;

    /// initializes the content manager
    this() {
        // setup
        _tex_cache = TexCache((tex) { raylib.UnloadTexture(tex); });
        _mdl_cache = ModelCache((mdl) { raylib.UnloadModel(mdl); });
        _shd_cache = ShaderCache((shd) { raylib.UnloadShader(shd); });
    }

    private const char* get_path(string path) {
        auto base = string.init;
        alias join_paths = std.path.buildNormalizedPath;
        // check search paths first
        foreach (search_path; paths) {
            // if the combination path exists, then make this base
            if (std.file.exists(join_paths(search_path, path))) {
                base = search_path;
                break;
            }
        }
        return join_paths(base, path).c_str();
    }

    /// loads a texture from disk
    public raylib.Texture2D load_texture2d(string path) {
        raylib.Texture2D tex;
        auto cached = _tex_cache.get(path);
        if (cached.isNull) {
            auto image = raylib.LoadImage(get_path(path));
            tex = raylib.LoadTextureFromImage(image);
            raylib.UnloadImage(image);
            _tex_cache.put(path, tex);
        } else {
            tex = cached.get;
        }

        // copy image to VRAM
        return tex;
    }

    /// loads a model from disk
    public raylib.Model load_model(string path) {
        raylib.Model mdl;
        auto cached = _mdl_cache.get(path);
        if (cached.isNull) {
            mdl = raylib.LoadModel(get_path(path));
            _mdl_cache.put(path, mdl);
        } else {
            mdl = cached.get;
        }
        return mdl;
    }

    /// loads a shader from disk
    public raylib.Shader load_shader(string vs_path, string fs_path) {
        raylib.Shader shd;
        import std.digest.sha : sha1Of, toHexString;

        auto path_hash = to!string(sha1Of(vs_path ~ fs_path).toHexString);
        auto cached = _shd_cache.get(path_hash);
        if (cached.isNull) {
            // since LoadShader seems to be broken, we'll do it ourselves
            auto vs = to!string(get_path(vs_path));
            auto fs = to!string(get_path(fs_path));
            auto vs_code = readText(vs);
            auto fs_code = readText(fs);
            shd = raylib.LoadShaderCode(vs_code.c_str(), fs_code.c_str());
            _shd_cache.put(path_hash, shd);
        } else {
            shd = cached.get;
        }
        return shd;
    }

    /// releases all resources
    public void destroy() {
        // delete textures
        _tex_cache.drop();
        // delete models
        _mdl_cache.drop();
        // delete shaders
        _shd_cache.drop();
    }
}
