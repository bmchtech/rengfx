module re.ng.manager;

import re.ng.scene;

/// represents a global engine system
abstract class Manager {
    /// set when attached to a scene
    public Scene scene;

    /// performs any setup needed for this manager
    void setup() {
    }

    /// updates this manager
    void update() {
    }

    /// frees resources used by this manager
    void destroy() {
    }
}
