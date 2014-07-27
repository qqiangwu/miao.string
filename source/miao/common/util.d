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

template ValueType(Rng) {
    static if (isSomeString!(Rng)) {
        alias ValueType = typeof(Rng.init[0]);
    }
    else {
        alias ValueType = ElementType!Rng;
    }
}