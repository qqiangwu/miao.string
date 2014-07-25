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
	
	uint search(in string corpus) pure nothrow
	out(result) {
		assert(-1 <= result && result < corpus.length);
	}
	body {
		if (corpus.length == 0 || corpus.length < pattern_.length) return -1;
		return search_(corpus);
	}
	
private:
	void build_skip_table_()
	{
		skip_ = new uint[pattern_.length];
		
		skip_[0] = -1;
		
		uint prefix_cursor = 0;
		uint cursor = 1;
		
		while (cursor < pattern_.length) {
			while (prefix_cursor >= 0 && pattern_[cursor] != pattern_[prefix_cursor]) {
				prefix_cursor = skip_[prefix_cursor];
			}
			
			skip_[cursor] = prefix_cursor >= 0? prefix_cursor: 0;
			
			cursor++;
			prefix_cursor++;
		}
	}
	
	uint search_(in string corpus) pure nothrow
	{
		const cmp_len = corpus.length - pattern_.length;
		
		auto window_pos = 0;
		auto cursor = 0;
		
		while (window_pos < cmp_len) {
			const window = corpus[window_pos .. window_pos + pattern_.length];
			
			// find the first mismatch
			for (; window[cursor] == pattern_[cursor]; ++cursor) {
				/* empty */
			}
			
			// move window and cursor
			const prefix_cursor = skip_[cursor];
			window_pos += cursor - prefix_cursor;
			cursor = prefix_cursor >= 0? prefix_cursor: 0; 
		}
		
		return -1;
	}

private:
	string pattern_;
	uint[] skip_;
}

uint knuth_morris_pratt(in string corpus, in string pattern)
{
	return Knuth_morris_pratt_searcher(corpus).search(pattern);
}