module miao.string.shift_or;

/*!
Main features
    uses bitwise techniques;
    efficient if the pattern length is no longer than the memory-word size of the machine;
    preprocessing phase in O(m + sigma) time and space complexity;
    searching phase in O(n) time complexity (independent from the alphabet size and the pattern length);
    adapts easily to approximate string matching.
*/

@trusted:

import miao.common.check;
import miao.common.util;

struct Shift_or_searcher(PatRange, CorpusRange = PatRange) 
    if (isValidParam!(PatRange, CorpusRange)) {
public:
    this(in PatRange pattern)
    in {
		import std.string;

        debug assert(pattern.length <= word_len, 
			format("@Shift_or_searcher: pattern length %s must less than word size %s", 
			   pattern.length, 
			   word_len)
			);
    }
    body {
        pat_len_ = pattern.length;
        if (pat_len_ > 0) {
            s_ = preprocess_(pattern);
            lim_ = ~cast(underly_type)0 << (pat_len_ - 1);
        }
    }
    
    int search(in CorpusRange corpus) const
	out(result) {
			assert(result == -1 || (0 <= result && result < corpus.length));
	}
	body {
        if (corpus.length == 0 || pat_len_ == 0) return -1;
		if (corpus.length < pat_len_) return -1;
		
		return search_(corpus);
    }

private:
    alias underly_type = ulong;

    enum word_len = underly_type.sizeof * 8;
    enum ascii_size = cast(uint)0xff;
    
    int search_(in CorpusRange corpus) const
    {
        auto state = ~cast(underly_type)0;
        
        foreach (const cursor, letter; corpus) {
            state = (state << 1) | s_[letter];
            if (state < lim_) {
                assert(cursor - pat_len_ + 1 >= 0);
                return cursor - pat_len_ + 1;
            }
        }
    
        return -1;
    }
    
    underly_type[] preprocess_(in PatRange pattern) const
    in {
        assert(0 < pat_len_ && pat_len_ <= word_len);
        assert(s_ == null);
        assert(lim_ == 0);
    }
    body {
        auto s = new underly_type[ascii_size];
        foreach (ref x; s) {
            x = ~cast(underly_type)0;
        }
        
        //! record each letter's occurence on the pattern string
        foreach (const cursor, letter; pattern) {
			s[letter] &= ~(cast(underly_type)0x1 << cursor);
		}

        return s;
    }
    
private:
    immutable underly_type[] s_;
    immutable underly_type lim_;
    immutable int pat_len_;
}

alias shift_or_search = GenerateFunction!Shift_or_searcher;

unittest {
    import miao.string.test;

    testAll!(Shift_or_searcher, shift_or_search)();
}