/** utilities for runtime type reflection */

module re.util.type;

template name_of(alias nameType) {
    enum string name_of = __traits(identifier, nameType);
}

@("util-type")
unittest {
    auto test_var = 1;
    assert(name_of!test_var == "test_var");

    class TestClass {
    }

    assert(name_of!TestClass == "TestClass");
}
