module miao.common.check;

@safe:

import std.range;
import std.traits;

template isValidParam(PatRange, CorpusRange) {
    enum bool isValidParam = __traits(compiles, {
        alias T1 = ElementType!PatRange;
        alias T2 = ElementType!CorpusRange;
        static assert(is(typeof(T1.init == T2.init)));

        PatRange a;
        CorpusRange b;
        static assert(is(typeof(a[$ - 1])));
        static assert(is(typeof(b[$ - 1])));
    });
}

unittest {
    static assert(isValidParam!(int[], uint[]));
    static assert(isValidParam!(char[], int[]));
    static assert(isValidParam!(dchar[], char[]));
    static assert(isValidParam!(dchar[], int[]));
    static assert(isValidParam!(const(char)[], int[]));
    static assert(!isValidParam!(int, int[]));
    static assert(!isValidParam!(char, char));
}