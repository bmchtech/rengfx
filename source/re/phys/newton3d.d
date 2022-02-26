module re.phys.newton3d;

version (physics) {
    import std.math;
    import std.format;
    import std.typecons;
    import std.container.array;

    import re.ecs.component;
    import re.ecs.updatable;
    import re.math;
    import re.math.raytypes;
    import re.time;
    import re.core;
    import re.ng.manager;
    import re.ng.scene;
    import re.phys.collider;
    import re.util.dual_map;
    import re.util.newtonphys;
    import bindbc.newton;

    @nogc nothrow pragma(inline, true) {
        float[3] arrayof(Vector3 v) {
            return raymath.Vector3ToFloat(v);
        }

        float[4] arrayof(Quaternion q) {
            return [q.x, q.y, q.z, q.w];
        }

        float[16] arrayof(Matrix4 m) {
            return raymath.MatrixToFloat(m);
        }

        Vector3 xyz(Vector4 v) {
            return Vector3(v.x, v.y, v.z);
        }
    }

    extern (C) {
        nothrow @nogc void newtonBodyForceCallback(
            const NewtonBody* nbody,
            dFloat timestep,
            int threadIndex) {
            NewtonRigidBody b = cast(NewtonRigidBody) NewtonBodyGetUserData(nbody);
            if (b) {
                Vector3 gravityForce = b.gravity * b.mass;
                NewtonBodyAddForce(nbody, gravityForce.arrayof.ptr);
                NewtonBodyAddForce(nbody, b.force.arrayof.ptr);
                NewtonBodyAddTorque(nbody, b.torque.arrayof.ptr);
                b.force = Vector3(0.0f, 0.0f, 0.0f);
                b.torque = Vector3(0.0f, 0.0f, 0.0f);
            }
        }
    }

    class NewtonWorldManager {
        public NewtonWorld* newtonWorld;
        int defaultGroupId;

        this(NewtonWorld* world) {
            this.newtonWorld = world;
            defaultGroupId = NewtonMaterialGetDefaultGroupID(newtonWorld);
        }
    }

    class NewtonRigidBody {
        NewtonWorldManager world;
        NewtonBody* newtonBody;
        int materialGroupId;
        bool dynamic = false;
        float mass;
        Vector3 gravity = Vector3(0.0f, -9.8f, 0.0f);
        Vector3 force = Vector3(0.0f, 0.0f, 0.0f);
        Vector3 torque = Vector3(0.0f, 0.0f, 0.0f);
        Vector4 position = Vector4(0.0f, 0.0f, 0.0f, 1.0f);
        Quaternion rotation = raymath.QuaternionIdentity();
        Matrix4 transformation = Matrix4Identity;
        bool enableRotation = true;
        bool raycastable = true;
        bool sensor = false;
        void delegate(NewtonRigidBody, NewtonRigidBody) collisionCallback;

        bool isRaycastable() {
            return raycastable;
        }

        bool isSensor() {
            return sensor;
        }

        this(NewtonCollisionShape shape, float mass, NewtonWorldManager world) {
            this.world = world;

            newtonBody = NewtonCreateDynamicBody(world.newtonWorld, shape.newtonCollision, transformation
                    .arrayof.ptr);
            NewtonBodySetUserData(newtonBody, cast(void*) this);
            this.groupId = world.defaultGroupId;
            this.mass = mass;
            NewtonBodySetMassProperties(newtonBody, mass, shape.newtonCollision);
            NewtonBodySetForceAndTorqueCallback(newtonBody, &newtonBodyForceCallback);

            collisionCallback = &defaultCollisionCallback;
        }

        void defaultCollisionCallback(NewtonRigidBody, NewtonRigidBody) {
        }

        void update(double dt) {
            NewtonBodyGetPosition(newtonBody, position.arrayof.ptr);
            NewtonBodyGetMatrix(newtonBody, transformation.arrayof.ptr);
            if (enableRotation) {
                // rotation = Quaternion.fromMatrix(transformation);
                // raymath.QuaternionFromMatrix
                rotation = raymath.QuaternionFromMatrix(transformation);
            } else {
                rotation = raymath.QuaternionIdentity;
                // transformation = translationMatrix(position.xyz);
                transformation = raymath.MatrixTranslate(position.x, position.y, position.z);
                NewtonBodySetMatrix(newtonBody, transformation.arrayof.ptr);
            }
            // TODO: enableTranslation
        }

        void groupId(int id) @property {
            NewtonBodySetMaterialGroupID(newtonBody, id);
            materialGroupId = id;
        }

        int groupId() @property {
            return materialGroupId;
        }

        Vector3 worldCenterOfMass() {
            Vector3 centerOfMass;
            NewtonBodyGetCentreOfMass(newtonBody, centerOfMass.arrayof.ptr);
            // return position.xyz + rotation.rotate(centerOfMass);
            return Vector3(position.x, position.y, position.z) + raymath.Vector3RotateByQuaternion(centerOfMass, rotation);
        }

        void addForce(Vector3 f) {
            // force += f;
            this.force = this.force + f;
        }

        void addForceAtPos(Vector3 f, Vector3 pos) {
            this.force = this.force + f;
            // torque += cross(position.xyz - worldCenterOfMass(), force);
            this.torque = this.torque + raymath.Vector3CrossProduct(
                (position.xyz - worldCenterOfMass()), force);
        }

        void addTorque(Vector3 t) {
            // torque += t;
            this.torque = this.torque + t;
        }

        void createUpVectorConstraint(Vector3 up) {
            NewtonJoint* joint = NewtonConstraintCreateUpVector(world.newtonWorld, up.arrayof.ptr, newtonBody);
        }

        void velocity(Vector3 v) @property {
            NewtonBodySetVelocity(newtonBody, v.arrayof.ptr);
        }

        Vector3 velocity() @property {
            Vector3 v;
            NewtonBodyGetVelocity(newtonBody, v.arrayof.ptr);
            return v;
        }

        void onCollision(NewtonRigidBody otherBody) {
            collisionCallback(this, otherBody);
        }
    }

    abstract class NewtonCollisionShape {
        NewtonWorldManager world;
        NewtonCollision* newtonCollision;

        this(NewtonWorldManager world) {
            // super(world);
            this.world = world;
        }

        ~this() {
            //if (newtonCollision)
            //    NewtonDestroyCollision(newtonCollision);
        }

        void setTransformation(Matrix4 m) {
            if (newtonCollision)
                NewtonCollisionSetMatrix(newtonCollision, m.arrayof.ptr);
        }
    }

    class NewtonBoxShape : NewtonCollisionShape {
        Vector3 halfSize;

        this(Vector3 extents, NewtonWorldManager world) {
            super(world);
            newtonCollision = NewtonCreateBox(world.newtonWorld, extents.x, extents.y, extents.z, 0, null);
            NewtonCollisionSetUserData(newtonCollision, cast(void*) this);
            halfSize = extents * 0.5f;
        }
    }

    class NewtonSphereShape : NewtonCollisionShape {
        float radius;

        this(float radius, NewtonWorldManager world) {
            super(world);
            this.radius = radius;
            newtonCollision = NewtonCreateSphere(world.newtonWorld, radius, 0, null);
            NewtonCollisionSetUserData(newtonCollision, cast(void*) this);
        }
    }

    class NewtonCylinderShape : NewtonCollisionShape {
        float radius1;
        float radius2;
        float height;

        this(float radius1, float radius2, float height, NewtonWorldManager world) {
            super(world);
            this.radius1 = radius1;
            this.radius2 = radius2;
            this.height = height;
            newtonCollision = NewtonCreateCylinder(world.newtonWorld, radius1, radius2, height, 0, null);
            NewtonCollisionSetUserData(newtonCollision, cast(void*) this);
        }
    }

    class NewtonChamferCylinderShape : NewtonCollisionShape {
        float radius;
        float height;

        this(float radius, float height, NewtonWorldManager world) {
            super(world);
            this.radius = radius;
            this.height = height;
            newtonCollision = NewtonCreateChamferCylinder(world.newtonWorld, radius, height, 0, null);
            NewtonCollisionSetUserData(newtonCollision, cast(void*) this);
        }
    }

    class NewtonCapsuleShape : NewtonCollisionShape {
        float radius1;
        float radius2;
        float height;

        this(float radius, float height, NewtonWorldManager world) {
            super(world);
            this.radius1 = radius1;
            this.radius2 = radius2;
            this.height = height;
            newtonCollision = NewtonCreateCapsule(world.newtonWorld, radius1, radius2, height, 0, null);
            NewtonCollisionSetUserData(newtonCollision, cast(void*) this);
        }
    }

    class NewtonConeShape : NewtonCollisionShape {
        float radius;
        float height;

        this(float radius, float height, NewtonWorldManager world) {
            super(world);
            this.radius = radius;
            this.height = height;
            newtonCollision = NewtonCreateCone(world.newtonWorld, radius, height, 0, null);
            NewtonCollisionSetUserData(newtonCollision, cast(void*) this);
        }
    }

    // class NewtonMeshShape : NewtonCollisionShape {
    //     this(TriangleSet triangleSet, NewtonWorldManager world) {
    //         super(world);
    //         NewtonMesh* nmesh = NewtonMeshCreate(world.newtonWorld);
    //         NewtonMeshBeginBuild(nmesh);
    //         foreach (triangle; triangleSet)
    //             foreach (i, p; triangle.v) {
    //                 Vector3 n = triangle.n[i];
    //                 NewtonMeshAddPoint(nmesh, p.x, p.y, p.z);
    //                 NewtonMeshAddNormal(nmesh, n.x, n.y, n.z);
    //             }
    //         NewtonMeshEndBuild(nmesh);

    //         newtonCollision = NewtonCreateTreeCollisionFromMesh(world.newtonWorld, nmesh, 0);
    //         NewtonCollisionSetUserData(newtonCollision, cast(void*) this);

    //         NewtonMeshDestroy(nmesh);
    //     }
    // }

    // class NewtonConvexHullShape : NewtonCollisionShape {
    //     this(Mesh mesh, float tolerance, NewtonWorldManager world) {
    //         super(world);
    //         NewtonMesh* nmesh = NewtonMeshCreate(world.newtonWorld);
    //         NewtonMeshBeginBuild(nmesh);
    //         foreach (face; mesh.indices)
    //             foreach (i; face) {
    //                 Vector3 p = mesh.vertices[i];
    //                 Vector3 n = mesh.normals[i];
    //                 NewtonMeshAddPoint(nmesh, p.x, p.y, p.z);
    //                 NewtonMeshAddNormal(nmesh, n.x, n.y, n.z);
    //             }
    //         NewtonMeshEndBuild(nmesh);

    //         newtonCollision = NewtonCreateConvexHullFromMesh(world.newtonWorld, nmesh, tolerance, 0);
    //         NewtonCollisionSetUserData(newtonCollision, cast(void*) this);

    //         NewtonMeshDestroy(nmesh);
    //     }
    // }

    class NewtonCompoundShape : NewtonCollisionShape {
        this(NewtonCollisionShape[] shapes, NewtonWorldManager world) {
            super(world);
            newtonCollision = NewtonCreateCompoundCollision(world.newtonWorld, 0);
            NewtonCompoundCollisionBeginAddRemove(newtonCollision);
            foreach (shape; shapes) {
                NewtonCompoundCollisionAddSubCollision(newtonCollision, shape.newtonCollision);
            }
            NewtonCompoundCollisionEndAddRemove(newtonCollision);
        }
    }

    // class NewtonHeightmapShape : NewtonCollisionShape {
    //     uint width;
    //     uint height;
    //     float[] elevationMap;
    //     ubyte[] attributeMap;

    //     this(Heightmap heightmap, uint w, uint h, Vector3 scale, NewtonWorldManager world) {
    //         super(world);

    //         width = w;
    //         height = h;

    //         elevationMap = New!(float[])(width * height);
    //         attributeMap = New!(ubyte[])(width * height);

    //         foreach (x; 0 .. width)
    //             foreach (z; 0 .. height) {
    //                 float y = heightmap.getHeight(
    //                     cast(float) x / cast(float)(width - 1),
    //                     cast(float) z / cast(float)(height - 1));
    //                 elevationMap[z * width + x] = y;
    //                 attributeMap[z * width + x] = 0; // TODO
    //             }

    //         newtonCollision = NewtonCreateHeightFieldCollision(world.newtonWorld,
    //             width, height, 1, 0, elevationMap.ptr, cast(char*) attributeMap.ptr, scale.y, scale.x, scale.z, 0);
    //     }

    //     ~this() {
    //         Delete(elevationMap);
    //         Delete(attributeMap);
    //     }
    // }
}
