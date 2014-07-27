module miao.string.horspool;

/*!
Main features
simplification of the Boyer-Moore algorithm;
easy to implement;
preprocessing phase in O(m+sigma) time and O(sigma) space complexity;
searching phase in O(mn) time complexity;
the average number of comparisons for one text character is between 1/sigma and 2/(sigma+1).

Description
The bad-character shift used in the Boyer-Moore algorithm (see chapter Boyer-Moore algorithm) is not very efficient for small alphabets, but when the alphabet is large compared with the length of the pattern, as it is often the case with the ASCII table and ordinary searches made under a text editor, it becomes very useful.
Using it alone produces a very efficient algorithm in practice. Horspool proposed to use only the bad-character shift of the rightmost character of the window to compute the shifts in the Boyer-Moore algorithm.
The preprocessing phase is in O(m+sigma) time and O(sigma) space complexity.
The searching phase has a quadratic worst case but it can be proved that the average number of comparisons for one text character is between 1/sigma and 2/(sigma+1).
*/

@trusted:

import miao.common.skip_table;
import miao.common.check;
import miao.common.util;

version(unittest) import std.stdio;

struct Horspool_searcher(PatRange, CorpusRange = PatRange) 
    if (isValidParam!(PatRange, CorpusRange)) {
public:
    this(in PatRange pattern)
	{
		pattern_ = pattern;
		if (pattern_.length > 0) {
			skip_ = build_bm_table(pattern_);
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
	int search_(in CorpusRange corpus) const
	{
		immutable cmp_len = corpus.length - pattern_.length;
		
		int window_pos = 0;
		
		while (window_pos <= cmp_len) {
			const window = corpus[window_pos .. window_pos + pattern_.length];
            
            int cursor = pattern_.length - 1;
			
			//! find mismatch
			while (cursor >= 0 && window[cursor] == pattern_[cursor]) {
				--cursor;
			}
			
			if (cursor == -1) {
				return window_pos;
			}
			else {
				// sliding window
				const bad_char = window[$ - 1];
				window_pos += skip_[bad_char];
			}
		}
		
		return -1;
	}
	
private:
	immutable Skip_table!(ValueType!PatRange) skip_;
	const PatRange pattern_;
}

alias horspool_search = GenerateFunction!Horspool_searcher;

unittest {
	import miao.string.test;
	
    testAll!(Horspool_searcher, horspool_search)();
}
