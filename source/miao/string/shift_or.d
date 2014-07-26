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

struct Shift_or_searcher {
public pure nothrow:
    this(in string pattern) inout
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
            lim_ = ~0 << (pat_len_ - 1);
        }
    }
    
    int search(in string corpus) const
	out(result) {
			assert(result == -1 || (0 <= result && result < corpus.length));
		}
	body {
        if (corpus.length == 0 || pat_len_ == 0) return -1;
		if (corpus.length < pat_len_) return -1;
		
		return search_(corpus);
    }

private pure nothrow:
    enum word_len = int.sizeof * 8;
    enum ascii_size = 127;
    
    int search_(in string corpus) const
    {
        auto state = ~0U;
        
        foreach (const cursor, letter; corpus) {
            state = (state << 1) | s_[letter];
            if (state < lim_) {
                return cursor - pat_len_ + 1;
            }
        }
    
        return -1;
    }
    
    uint[] preprocess_(in string pattern) inout
    in {
        assert(0 < pat_len_ && pat_len_ <= word_len);
        assert(s_ == null);
        assert(lim_ == 0);
    }
    body {
        auto s = new uint[ascii_size];
        foreach (ref x; s) {
            x = ~0;
        }
        
        //! record each letter's occurence on the pattern string
        foreach (const cursor, letter; pattern) {
			s[letter] &= ~(0x1 << cursor);
		}

        return s;
    }
    
private:
    immutable uint[] s_;
    immutable uint lim_;
    immutable int pat_len_;
}

pure int shift_or(in string corpus, in string pattern) nothrow
{
    return Shift_or_searcher(pattern).search(corpus);
}

unittest {
    import miao.string.test;

    runCreate!Shift_or_searcher();

	import miao.string.test;
	import std.stdio;

	writeln("Test shift_or");
    
    alias fn = shift_or;
    
    const haystack1 = "NOW AN FOWEGER ANNMAN THE ANPANMANEND";
    const needle1 = "ANPANMAN";
    const needle2 = "MAN THE";
    const needle3 = "WEGER";
    const needle4 = "NOW ";
    const needle5 = "NEND";
    const needle6 = "NOT FOUND";
    const needle7 = "NOT FOTND";

    const haystack2 = "ABC ABCDAB ABCDABCDABDE";
    const needle11 = "ABCDABD";
    
    const haystack3 = "abra abracad abracadabra";
    const needle12 = "abracadabra";
    const needle13 = "";

    const haystack4 = "";

    import std.conv : to;

    assert(fn("", "") == -1);
    assert(fn("abc", "") == -1);
    assert(fn("", " ") == -1);

    assert(fn("abc", "a") == 0);
    assert(fn("abcd", "bc") == 1);

    assert(fn(haystack1, needle1) == 26);
    assert(fn(haystack1, needle2) == 18);
    assert(fn(haystack1, needle3) == 9);
    assert(fn(haystack1, needle4) == 0);
    assert(fn(haystack1, needle5) == 33);
    assert(fn(haystack1, needle6) == -1);
    assert(fn(haystack1, needle7) == -1);
    
    //assert(fn(needle1, haystack1) == -1);

    assert(fn(haystack2, haystack2) == 0);

    assert(fn(haystack2, needle11) == 15, fn(haystack2, needle11).to!string);
    assert(fn(haystack3, needle12) == 13);

    assert(fn(haystack1, needle13) == -1);
    assert(fn(haystack4, needle1) == -1);

    assert(fn("GCATCGCAGAGAGTATACAGTACG", "GCAGAGAG") == 5);
}