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
 
@trusted:

struct Karp_rabin_searcher {
public pure nothrow:
	this(in string pattern) inout
	{
		/* preprocessing */
		pattern_ = pattern;
		pattern_length_ = pattern.length;
		hashed_pattern_ = hash_(pattern);
		if (pattern_length_ > 0) {
			d_ = pow(2, pattern_length_ - 1);
		}
	}
	
	int search(in string corpus) const
	out(result) {
		assert(result == -1 || (0 <= result && result < corpus.length));
	}
	body {
		if (corpus.length == 0 || pattern_.length == 0) return -1;
		if (corpus.length < pattern_.length) return -1;
		
		return search_(corpus);
	}
	
private pure nothrow:
	int search_(in string corpus) const
	{		
		const compare_length = corpus.length - pattern_length_;

		auto hashed_window = hash_(corpus);
		auto window_pos = 0;

		for (; window_pos < compare_length; ++window_pos) {
			if (hashed_pattern_ == hashed_window && 
				pattern_ == corpus[window_pos .. window_pos + pattern_length_]) {
				return window_pos;
			}
			
			hashed_window = rehash_(corpus[window_pos], 
									corpus[window_pos + pattern_length_], 
									hashed_window);
		}

		if (hashed_pattern_ == hashed_window && 
			pattern_ == corpus[window_pos .. $]) {
			return window_pos;
		}

		return -1;
	}

	int hash_(in string s) const
	{
		int code = 0;
		
		for (auto i = 0; i < pattern_length_; ++i) {
			code = (code << 1) + s[i];
		}
		
		return code;
	}
	
	int rehash_(in int oldv, in int newv, in int hcode) const
	{
		assert(pattern_length_ > 0);
		return ((hcode - oldv * d_) << 1) + newv;
	}
	
private:
	immutable string pattern_;
	immutable int hashed_pattern_;
	immutable int pattern_length_;
	immutable int d_;
}

pure int karp_rabin(in string corpus, in string pattern) nothrow
{
	return Karp_rabin_searcher(pattern).search(corpus);
}

unittest {
	import miao.string.test;
	import std.stdio;

	writeln("Test karp_rabin");
	runTest!karp_rabin();
    runCreate!Karp_rabin_searcher();
}