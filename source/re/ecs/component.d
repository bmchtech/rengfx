module re.ecs.component;

import re.ecs.entity;
import re.math.transform;
public import re.util.reflect;

/// the composable unit of functionality
abstract class Component : ReflectableObject {
    mixin Reflect;

    /// owner entity
    public Entity entity;

    /// initialize the component. entity is already set.
    public void setup() {
    }

    /// release resources and clean up
    public void destroy() {
    }

    /// forward to entity.transform
    @property public ref Transform transform() {
        return entity.transform;
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
