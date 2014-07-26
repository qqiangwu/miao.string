module miao.string.dfa;

/*!
Main features
    builds the minimal deterministic automaton recognizing the language Sigma*x;
    extra space in O(msigma) if the automaton is stored in a direct access table;
    preprocessing phase in O(msigma) time complexity;
    searching phase in O(n) time complexity if the automaton is stored in a direct access table, O(nlog(sigma)) otherwise.
    
Description
    Searching a word x with an automaton consists first in building the minimal Deterministic Finite Automaton (DFA)  A(x) recognizing the language Sigma*x.
    The DFA  A(x) =(Q, q0, T, E) recognizing the language Sigma*x is defined as follows:
        Q is the set of all the prefixes of x: Q={epsilon, x[0], x[0 .. 1], ... , x[0 .. m-2], x};
        q0=epsilon;
        T={x};
        for q in Q (q is a prefix of x) and a in Sigma, (q, a, qa) is in E if and only if qa is also a prefix of x, otherwise (q, a, p) is in E such that p is the longest suffix of qa which is a prefix of x.
    The DFA  A(x) can be constructed in O(m+sigma) time and O(msigma) space.
    Once the DFA  A(x) is build, searching for a word x in a text y consists in parsing the text y with the DFA  A(x) beginning with the initial state q0. Each time the terminal state is encountered an occurrence of x is reported.
    The searching phase can be performed in O(n) time if the automaton is stored in a direct access table, in O(nlog(sigma)) otherwise.
*/

@trusted:

//! \fix    generalized to all kinds of charset
struct Dfa_searcher {
public:
    this(in string pattern)
    {
        pat_len_ = pattern.length;
        if (pat_len_ > 0) {
            build_dfa_(pattern);
        }
    }
    
    int search(in string corpus) pure nothrow const
	out(result) {
		assert(result == -1 || (0 <= result && result < corpus.length));
	}
	body {
		if (corpus.length == 0 || pat_len_ == 0) return -1;
		if (corpus.length < pat_len_) return -1;
		
		return search_(corpus);
	}
    
private:
    enum ascii_size = 127;
    enum init_state = 0;
    
    void build_dfa_(in string pattern)
    in {
        assert(pat_len_ > 0);
    }
    body {
        dfa_ = new int[][pat_len_ + 1];
        
        auto state = init_state;
        
        for (auto i = 0; i < pat_len_; ++i) {
            const target = i + 1;
            const event = pattern[i];
            
            if (dfa_[state] == null) {
                dfa_[state] = new int[ascii_size];
            }
            
            auto old_target = dfa_[state][event];
            
            dfa_[state][event] = target;
            dfa_[target] = dfa_[old_target].dup;
            
            state = target;
        }
        
        terminal_ = pat_len_;
        
        assert(state == terminal_);
    }
  
    int search_(in string corpus) pure nothrow const
    {
        for (auto state = init_state, cursor = 0; cursor < corpus.length; ++cursor) {
            const event = corpus[cursor];
    
            assert(event < ascii_size, "@Dfa_searcher: only ascii are supported for the moment");
            
            if ((state = transit_(state, event)) == terminal_) {
                assert(cursor + 1 >= pat_len_);
                return cursor - pat_len_ + 1;
            }
        }
        
        return -1;
    }
    
    int transit_(int state, int event) pure nothrow const
    in {
        assert(0 <= state && state < terminal_);
        assert(0 <= event && event < ascii_size);
    }
    body {
        const table = dfa_[state];
        return table == null? 0: table[event];
    }
    
private:
    int[][] dfa_ = void;
    int terminal_;
    int pat_len_;
}

int dfa(in string corpus, in string pattern)
{
    return Dfa_searcher(pattern).search(corpus);
}

unittest {
	import miao.string.test;
	import std.stdio;

	writeln("Test dfa");
    
    alias fn = dfa;
    
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
    
    assert(fn(needle1, haystack1) == -1);

    assert(fn(haystack1, haystack1) == 0);
    assert(fn(haystack2, haystack2) == 0);

    assert(fn(haystack2, needle11) == 15, fn(haystack2, needle11).to!string);
    assert(fn(haystack3, needle12) == 13);

    assert(fn(haystack1, needle13) == -1);
    assert(fn(haystack4, needle1) == -1);

    assert(fn("GCATCGCAGAGAGTATACAGTACG", "GCAGAGAG") == 5);
}