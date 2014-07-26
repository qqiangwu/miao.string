module miao.string.not_so_naive;

/*!
Main features
    preprocessing phase in constant time and space;
    searching phase in O(nm) time complexity;
    slightly (by coefficient) sub-linear in the average case.

Description
    During the searching phase of the Not So Naive algorithm the character comparisons are made with the pattern positions in the following order 1, 2, ... , m-2, m-1, 0.
    For each attempt where the window is positioned on the text factor y[j .. j+m-1]: if x[0]=x[1] and x[1] neq y[j+1] of if x[0] neq x[1] and x[1]=y[j+1] the pattern is shifted by 2 positions at the end of the attempt and by 1 otherwise.
    Thus the preprocessing phase can be done in constant time and space. The searching phase of the Not So Naive algorithm has a quadratic worst case but it is slightly (by coefficient) sub-linear in the average case.
*/

@trusted:

struct Not_so_naive_searcher {
public pure nothrow:
    this(in string pattern) inout
    {
        pattern_ = pattern;
        if (pattern_.length >= 2) {
            if (pattern_[0] == pattern_[1]) {
                skip_ = 2;
                slide_ = 1;
            }
            else {
                skip_ = 1;
                slide_ = 2;
            }
        }
    }

    int search(in string corpus) const
    out(result) {
            assert(result == -1 || (0 <= result && result < corpus.length));
    }
	body {
		if (corpus.length == 0 || pattern_.length == 0) return -1;
		if (corpus.length < pattern_.length) return -1;
        if (pattern_.length == 1) {
            return pattern_[0] == corpus[0]? 0: -1;
        }
		return search_(corpus);
	}

private pure nothrow:
    int search_(in string corpus) const
    in {
        assert(corpus.length >= 2);
        assert(pattern_.length >= 2);
    }
    body {
        const cmp_len = corpus.length - pattern_.length;

        for (auto window_pos = 0; window_pos <= cmp_len; ) {
            const window = corpus[window_pos .. window_pos + pattern_.length];
            if (window[1] != pattern_[1]) {
                window_pos += skip_;
            }
            else {
                if (window == pattern_) return window_pos;
                window_pos += slide_;
            }
        }

        return -1;
    }
    
private:
    immutable string pattern_;
    immutable uint skip_;
    immutable uint slide_;
}

pure int not_so_naive(in string corpus, in string pattern) nothrow
{
    return Not_so_naive_searcher(pattern).search(corpus);
}

unittest {
    import miao.string.test;
    import std.stdio;

    writeln("Test not_so_naive");
    runTest!not_so_naive();
    runCreate!Not_so_naive_searcher();
}