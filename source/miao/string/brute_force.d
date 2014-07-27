module miao.string.brute_force;

@trusted:

import miao.common.check;
import miao.common.util;

struct Brute_force_searcher(PatRange, CorpusRange = PatRange) 
    if (isValidParam!(PatRange, CorpusRange)) {
public:
	this(in PatRange pattern)
	{
		pattern_ = pattern;
	}
	
	int search(in CorpusRange corpus) const
	out(result) {
		assert(result == -1 || (0 <= result && result < corpus.length));
	}
	body {
		if (corpus.length == 0 || pattern_.length == 0) return -1;
		if (corpus.length < pattern_.length) return -1;
		return search_(corpus);
	}
	
private:
	int search_(in CorpusRange corpus) const
	{
	    immutable compare_length = corpus.length - pattern_.length;
		
		auto window_pos = 0;
		
		for (; window_pos <= compare_length; ++window_pos) {
			const window = corpus[window_pos .. window_pos + pattern_.length];
			auto cursor = 0;
			
			for (; cursor < pattern_.length && window[cursor] == pattern_[cursor]; ++cursor) { 
				/* empty */
			}
			
			if (cursor == pattern_.length) return window_pos;
		}
		
		return -1;
	}

private:
	const PatRange pattern_;
}

alias brute_force_search = GenerateFunction!Brute_force_searcher;

unittest {
	import miao.string.test;
	
    testAll!(Brute_force_searcher, brute_force_search)();
}