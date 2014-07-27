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

import miao.common.check;
import miao.common.util;

//! \fix    generalized to all kinds of charset
struct Dfa_searcher(PatRange, CorpusRange = PatRange) 
    if (isValidParam!(PatRange, CorpusRange)) {
public:
    this(in PatRange pattern)
    {
        pat_len_ = pattern.length;
        if (pat_len_ > 0) {
            terminal_ = pat_len_;
            dfa_ = build_dfa_(pattern);
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
    enum ascii_size = cast(uint)0xff;
    enum init_state = 0;
    
    int[][] build_dfa_(in PatRange pattern) const
    in {
        assert(pat_len_ > 0);
    }
    body {
        auto dfa = new int[][pat_len_ + 1];
        
        auto state = init_state;
        
        for (auto i = 0; i < pat_len_; ++i) {
            const target = i + 1;
            const event = pattern[i];

            if (dfa[state] == null) {
                dfa[state] = new int[ascii_size];
            }

            assert(dfa[target] == null);

            auto old_target = dfa[state][event];
            
            dfa[state][event] = target;
            dfa[target] = new int[ascii_size];
            dfa[target][] = dfa[old_target][];
            
            state = target;
        }
        
        assert(state == terminal_);

        return dfa;
    }
  
    int search_(inout const CorpusRange corpus) const
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
    
    int transit_(int state, int event) const
    in {
        assert(0 <= state && state < terminal_);
        assert(0 <= event && event < ascii_size);
    }
    body {
        const table = dfa_[state];
        return table == null? 0: table[event];
    }
    
private:
    immutable int[][] dfa_;
    immutable int terminal_;
    immutable int pat_len_;
}

alias dfa_search = GenerateFunction!Dfa_searcher;

unittest {
	import miao.string.test;

    testAll!(Dfa_searcher, dfa_search)();
}