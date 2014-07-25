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

struct Horspool_searcher {
public:
	this(in string pattern)
	{
		pattern_ = pattern;
		if (pattern_.length > 0) {
			build_skip_table_();
		}
	}
	
	uint search(in string corpus) pure nothrow
	out(result) {
		assert(-1 <= result && result < corpus.length);
	}
	body {
		if (corpus.length == 0) return -1;
		if (corpus.length < pattern_.length) return -1;
		
		return search_(corpus);
	}
	
private:
	uint search_(in string corpus) pure nothrow
	{
		const cmp_len = corpus.length - pattern_.length;
		
		auto cursor = pattern_.length - 1;
		auto window_pos = 0;
		
		while (window_pos < cmp_len) {
			const window = corpus[window_pos .. window_pos + pattern_.length];
			
			//! find mismatch
			while (cursor >= 0 && window[cursor] == pattern_[cursor]) {
				--cursor;
			}
			
			if (cursor == 0) {
				return window_pos;
			}
			else {
				// sliding window
				cursor = pattern_.length - 1;
				window_pos = pattern_.length - skip_.get(window[cursor]);
			}
		}
		
		return -1;
	}

	void build_skip_table_()
	{
		for (auto i = 0; i < pattern_.length - 1; ++i) {
			skip_.insert(pattern_[i], i);
		}
	}
	
private:
	Skip_table skip_ = Skip_table(0);
	string pattern_;
}

uint horspool(in string corpus, in string pattern)
{
	return Horspool_searcher(corpus).search(pattern);
}

private struct Skip_table {
	uint[char] skip_;
	uint default_;
	
	this(in uint default_val)
	{
		default_ = default_val;
	}
	
	void insert(in char c, in uint idx)
	{
		skip_[c] = idx;
	}
	
	uint get(in char ch) pure nothrow
	{
		const val = ch in skip_;
		return val? *val: default_;
	}
}