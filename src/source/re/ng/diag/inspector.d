module re.ng.diag.inspector;

/// real-time object inspector
class Inspector {
    /// whether the inspector is open
    public bool open = false;
    private Object _obj;
    private Object[string] _fields;

    this() {
        reset();
    }

    private void reset() {
        _obj = null;
        _fields.clear();
    }

    public void update() {
    }

    public void render() {
    }

    /// attach the inspector to an object
    public void inspect(Object obj) {
        assert(_obj is null, "only one inspector may be open at a time");
        open = true;
        _obj = obj;
    }

    /// close the inspector
    public void close() {
        assert(!open, "inspector is already closed");
        open = false;
        reset();
    }
}
