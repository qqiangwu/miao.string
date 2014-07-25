module miao.string.karp_rabin;

/*!
 * uses an hashing function;
 * preprocessing phase in O(m) time complexity and constant space;
 * searching phase in O(mn) time complexity;
 * O(n+m) expected running time.
 *
 * \description
Hashing provides a simple method to avoid a quadratic number of character comparisons in most practical situations. Instead of checking at each position of the text if the pattern occurs, it seems to be more efficient to check only if the contents of the window “looks like” the pattern. In order to check the resemblance between these two words an hashing function is used.
To be helpful for the string matching problem an hashing function hash should have the following properties:
 	efficiently computable;
 	highly discriminating for strings;
 	hash(y[j+1 .. j+m]) must be easily computable from hash(y[j .. j+m-1]) and y[j+m]:
  hash(y[j+1 .. j+m])= rehash(y[j], y[j+m], hash(y[j .. j+m-1]).
For a word w of length m let hash(w) be defined as follows:
hash(w[0 .. m-1])=(w[0]*2m-1+ w[1]*2m-2+···+ w[m-1]*20) mod q
where q is a large number.
Then, rehash(a,b,h)= ((h-a*2m-1)*2+b) mod q
The preprocessing phase of the Karp-Rabin algorithm consists in computing hash(x). It can be done in constant space and O(m) time.
During searching phase, it is enough to compare hash(x) with hash(y[j .. j+m-1]) for 0 leq j < n-m. If an equality is found, it is still necessary to check the equality x=y[j .. j+m-1] character by character.
The time complexity of the searching phase of the Karp-Rabin algorithm is O(mn) (when searching for am in an for instance). Its expected number of text character comparisons is O(n+m).
 */

import std.math;
import core.stdc.string;
 
@trusted:

struct Karp_rabin_searcher {
public:
	this(in string pattern) nothrow
	{
		/* preprocessing */
		pattern_ = pattern;
		pattern_length_ = pattern.length;
		hashed_pattern_ = hash_(pattern);
		d_ = pow(2, pattern_length_ - 1);
	}
	
	uint search(in string corpus) pure nothrow
	out(result) {
		assert(-1 <= result && result < corpus.length);
	}
	body {
		if (pattern_length_ == 0) return -1;
		if (corpus.length == 0) return -1;
		if (corpus.length < pattern_length_) return -1;
		
		return search_(corpus);
	}
	
private pure nothrow:
	uint search_(in string corpus)
	{
		auto hashed_window = hash_(corpus);
		
		immutable compare_length = corpus.length - pattern_length_;
		
		for (auto window_pos = 0; window_pos < compare_length; ++window_pos) {
			if (hashed_pattern_ == hashed_window && 
				pattern_ == corpus[window_pos .. window_pos + pattern_length_]) {
				return window_pos;
			}
			
			hashed_window = rehash_(corpus[window_pos], corpus[window_pos + pattern_length_ + 1], hashed_window);
		}
		
		return -1;
	}

	uint hash_(in string s)
	{
		uint code = 0;
		
		for (auto i = 0; i < pattern_length_; ++i) {
			code = (code << 1) + s[i];
		}
		
		return code;
	}
	
	uint rehash_(in uint oldv, in uint newv, in uint hcode) 
	{
		return (hcode - oldv * d_) << 1 + newv;
	}
	
private:
	string pattern_;
	uint hashed_pattern_;
	uint pattern_length_;
	uint d_;
}

uint karp_rabin(in string corpus, in string pattern) nothrow
{
	return Karp_rabin_searcher(pattern).search(corpus);
}