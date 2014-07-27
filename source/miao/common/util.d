module miao.common.util;

@safe:

import std.traits;
import std.range;

template GenerateFunction(alias Searcher) {
    int GenerateFunction(CorpusRange, PatRange)(
                    in CorpusRange corpus, 
                    in PatRange pattern)
    {
        return Searcher!(PatRange, CorpusRange)(pattern).search(corpus);
    }
}

/* return unqualified element type */
template ValueType(Rng) {
    static if (isSomeString!(Rng)) {
        alias Type = typeof(Rng.init[0]);
    }
    else {
        alias Type = ElementType!Rng;
    }

    alias ValueType = Unqual!Type;
}