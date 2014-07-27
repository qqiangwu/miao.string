module miao.string.knuth_morris_pratt;

/*!
performs the comparisons from left to right;
preprocessing phase in O(m) space and time complexity;
searching phase in O(n+m) time complexity (independent from the alphabet size);
delay bounded by logPhi(m) where Phi is the golden ratio ( golden ratio ).
*/

@trusted:

import miao.common.check;
import miao.common.util;

struct Knuth_morris_pratt_searcher(PatRange, CorpusRange = PatRange) 
    if (isValidParam!(PatRange, CorpusRange)) {
public:
	this(in PatRange pattern)
	{
		pattern_ = pattern;
		
		if (pattern_.length != 0) {
			skip_ = build_skip_table_();
		}
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
	pure int[] build_skip_table_() inout nothrow
	{
		auto skip = new int[pattern_.length];
		
		skip[0] = -1;
		
		int cursor = 2;
		while (cursor < pattern_.length) {
			int prev = cursor - 1;
			int prefix_cursor = skip[prev];
			
            while (prefix_cursor >= 0 && pattern_[prev] != pattern_[prefix_cursor]) {
				prefix_cursor = skip[prefix_cursor];
			}
			
            prefix_cursor++;

			skip[cursor] = prefix_cursor;
			
            cursor++;
		}

        return skip;
	}
	
	int search_(in CorpusRange corpus) const
	{
		const cmp_len = corpus.length - pattern_.length;
		const last_pos = pattern_.length - 1;
		
		int window_pos = 0;
		int cursor = 0;
		
		while (window_pos <= cmp_len) {
			assert(0 <= cursor && cursor < pattern_.length);

			const window = corpus[window_pos .. window_pos + pattern_.length];
			
			// find the first mismatch
			for (; window[cursor] == pattern_[cursor]; ++cursor) {
				if (cursor == last_pos) return window_pos; 
			}
			
			// move window and cursor
			const prefix_cursor = skip_[cursor];
			window_pos += cursor - prefix_cursor;
			cursor = prefix_cursor >= 0? prefix_cursor: 0; 

			assert(window_pos >= 0);
			assert(0 <= cursor && cursor < pattern_.length);
		}
		
		return -1;
	}

private:
	const PatRange pattern_;
	immutable int[] skip_;
}

alias knuth_morris_pratt_search = GenerateFunction!Knuth_morris_pratt_searcher;

unittest {
	import miao.string.test;
	
    testAll!(Knuth_morris_pratt_searcher, knuth_morris_pratt_search)();
}