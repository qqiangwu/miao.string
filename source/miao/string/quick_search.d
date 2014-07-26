module miao.string.quick_search;

/*!
Main features
    simplification of the Boyer-Moore algorithm;
    uses only the bad-character shift;
    easy to implement;
    preprocessing phase in O(m+sigma) time and O(sigma) space complexity;
    searching phase in O(mn) time complexity;
    very fast in practice for short patterns and large alphabets.

Description
    The Quick Search algorithm uses only the bad-character shift table (see chapter Boyer-Moore algorithm). After an attempt where the window is positioned on the text factor y[j .. j+m-1], the length of the shift is at least equal to one. So, the character y[j+m] is necessarily involved in the next attempt, and thus can be used for the bad-character shift of the current attempt.
    The bad-character shift of the present algorithm is slightly modified to take into account the last character of x as follows: for c in Sigma, qsBc[c]=min{i : 0  < i leq m and x[m-i]=c} if c occurs in x, m+1 otherwise (thanks to Darko Brljak).
    The preprocessing phase is in O(m+sigma) time and O(sigma) space complexity.
    During the searching phase the comparisons between pattern and text characters during each attempt can be done in any order. The searching phase has a quadratic worst case time complexity but it has a good practical behaviour.
*/

@trusted:

import miao.common.bad_char_table;

struct Quick_search_searcher {
public:
    this(in string pattern)
    {
        pattern_ = pattern;

        if (pattern_.length > 0) {
            skip_ = build_qs_table(pattern_);
        }
    }

    int search(in string corpus) nothrow const
	out(result) {
            assert(result == -1 || (0 <= result && result < corpus.length));
    }
	body {
		if (corpus.length == 0 || pattern_.length == 0) return -1;
		if (corpus.length < pattern_.length) return -1;

		return search_(corpus);
	}

private:
    int search_(in string corpus) nothrow const
    {
        const cmp_len = corpus.length - pattern_.length;

        auto window_pos = 0;
        while (window_pos < cmp_len) {
            const window = corpus[window_pos .. window_pos + pattern_.length];
            
            if (window == pattern_) {
                return window_pos;
            }

            //! sliding window
            const bad_char = corpus[window_pos + pattern_.length];
            window_pos += skip_[bad_char];
        }

        if (window_pos == cmp_len && corpus[window_pos .. $] == pattern_) {
            return window_pos;
        }

        return -1;
    }

private:
    Bad_char_table skip_ = void;
    string pattern_;
}

int quick_search(in string corpus, in string pattern)
{
	return Quick_search_searcher(pattern).search(corpus);
}

unittest {
	import miao.string.test;
	import std.stdio;

	writeln("Test quick_search");
	runTest!quick_search();
}