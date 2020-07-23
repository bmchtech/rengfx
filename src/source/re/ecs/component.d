module re.ecs.component;

import re.ecs.entity;

/// the composable unit of functionality
abstract class Component {
    /// owner entity
    public Entity entity;
    public void setup() {

    }

    public void destroy() {
    }
}

/// basic component classification
enum ComponentType {
    Base,
    Updatable,
    Renderable
}

/// reference to a stored component
struct ComponentId {
    /// index in storage
    size_t index;
    /// entity owner index
    size_t owner;
    /// component classification
    ComponentType type;
}
