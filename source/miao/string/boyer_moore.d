module miao.string.boyer_moore;

/*!
Main features
    performs the comparisons from right to left;
    preprocessing phase in O(m+sigma) time and space complexity;
    searching phase in O(mn) time complexity;
    3n text character comparisons in the worst case when searching for a non periodic pattern;
    O(n / m) best performance.

Description
    The Boyer-Moore algorithm is considered as the most efficient string-matching algorithm in usual applications. A simplified version of it or the entire algorithm is often implemented in text editors for the «search» and «substitute» commands.
    The algorithm scans the characters of the pattern from right to left beginning with the rightmost one. In case of a mismatch (or a complete match of the whole pattern) it uses two precomputed functions to shift the window to the right. These two shift functions are called the good-suffix shift (also called matching shift and the bad-character shift (also called the occurrence shift).
*/

@trusted:

import miao.common.util;
import miao.common.check;
import miao.common.skip_table;

import std.algorithm : max;

struct Boyer_moore_searcher(PatRange, CorpusRange = PatRange) 
    if (isValidParam!(PatRange, CorpusRange)) {
public:
    this(in PatRange pattern)
    {
        pattern_ = pattern;

        if (pattern_.length > 0) {
            bad_char_ = build_bm_table(pattern_);
            good_suffix_ = build_gs_table_();
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

        for (auto win_pos = 0; win_pos <= cmp_len; ) {
            const window = corpus[win_pos .. win_pos + pattern_.length];
            
            //! compare backward
            int cursor = pattern_.length - 1;
            for (; cursor >= 0 && window[cursor] == pattern_[cursor]; --cursor) {
                /* empty */
            }

            if (cursor < 0) {
                return win_pos;
            }
            else {
                //! sliding window
                const bc = window[cursor];
                win_pos += max(bad_char_[bc] - (pattern_.length - 1 - cursor), good_suffix_[cursor]);
            }
        }

        return -1;
    }

private:
    pure auto build_gs_table_() const nothrow
    {
        auto gs = new int[pattern_.length];
        
        gs[] = 1;

        if (pattern_.length >= 2) {
        }

        return gs;
    }

private:
    immutable Skip_table!(ValueType!PatRange) bad_char_;
    immutable int[] good_suffix_;
    const PatRange pattern_;
}

alias boyer_moore_search = GenerateFunction!Boyer_moore_searcher;

unittest {
    import miao.string.test;

    testAll!(Boyer_moore_searcher, boyer_moore_search)();
}