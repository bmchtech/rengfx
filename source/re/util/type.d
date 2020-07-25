module re.util.type;

template name_of(alias nameType) {
    enum string nameOf = __traits(identifier, nameType);
}
