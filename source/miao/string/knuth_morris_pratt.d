module miao.string.knuth_morris_pratt;

/*!
performs the comparisons from left to right;
preprocessing phase in O(m) space and time complexity;
searching phase in O(n+m) time complexity (independent from the alphabet size);
delay bounded by logPhi(m) where Phi is the golden ratio ( golden ratio ).
*/

@trusted:

struct Knuth_morris_pratt_searcher {
public:
	this(in string pattern)
	{
		pattern_ = pattern;
		
		if (pattern_.length != 0) {
			build_skip_table_();
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
	void build_skip_table_()
	{
		skip_ = new int[pattern_.length];
		
		skip_[0] = -1;
		
		int cursor = 2;
		while (cursor < pattern_.length) {
			int prev = cursor - 1;
			int prefix_cursor = skip_[prev];
			
            while (prefix_cursor >= 0 && pattern_[prev] != pattern_[prefix_cursor]) {
				prefix_cursor = skip_[prefix_cursor];
			}
			
            prefix_cursor++;

			skip_[cursor] = prefix_cursor;
			
            cursor++;
		}
	}
	
	int search_(in string corpus) nothrow const
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
	string pattern_;
	int[] skip_;
}

int knuth_morris_pratt(in string corpus, in string pattern)
{
	return Knuth_morris_pratt_searcher(pattern).search(corpus);
}

unittest {
	import miao.string.test;
	import std.stdio;

	writeln("Test knuth_morris_pratt");
	runTest!knuth_morris_pratt();
}