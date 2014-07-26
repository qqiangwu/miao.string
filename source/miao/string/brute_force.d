module miao.string.brute_force;

@trusted:

struct Brute_force_searcher {
public:
	this(in string pattern) nothrow
	{
		pattern_ = pattern;
	}
	
	int search(in string corpus) nothrow const
	out(result) {
		import std.conv : to;
		assert(result == -1 || (0 <= result && result < corpus.length));
	}
	body {
		if (corpus.length == 0 || pattern_.length == 0) return -1;
		if (corpus.length < pattern_.length) return -1;
		return search_(corpus);
	}
	
private:
	int search_(in string corpus) nothrow const
	{
		const compare_length = corpus.length - pattern_.length;
		
		auto window_pos = 0;
		
		for (; window_pos <= compare_length; ++window_pos) {
			immutable window = corpus[window_pos .. window_pos + pattern_.length];
			auto cursor = 0;
			
			for (; cursor < pattern_.length && window[cursor] == pattern_[cursor]; ++cursor) { 
				/* empty */
			}
			
			if (cursor == pattern_.length) return window_pos;
		}
		
		return -1;
	}

private:
	string pattern_;
}

int brute_force(in string corpus, in string pattern) nothrow
{
	return Brute_force_searcher(pattern).search(corpus);
}

unittest {
	import miao.string.test;
	import std.stdio;
		
	writeln("Test brute force");
	runTest!brute_force();
}
