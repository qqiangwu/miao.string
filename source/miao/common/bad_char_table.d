module miao.common.bad_char_table;

@trusted:

struct Bad_char_table {
public:
    this(in int defaul_val)
    {
        default_val_ = defaul_val;
    }

    int opIndex(in char idx) nothrow const
    {
        const ret = idx in skip_table_;
        return ret? *ret: default_val_;
    }

package:
    int opIndexAssign(in int val, in char idx)
    {
        return skip_table_[idx] = val;
    }

private:
    int[char] skip_table_;
    immutable int default_val_;
}

Bad_char_table build_bm_table(in string pattern)
in {
    assert(pattern.length > 0);
}
body {
    auto table = Bad_char_table(pattern.length);

    const last_pos = pattern.length - 1;

    foreach (const idx, letter; pattern[0 .. last_pos]) {
        table[letter] = last_pos - idx;
    }

    return table;
}

Bad_char_table build_qs_table(in string pattern)
in {
    assert(pattern.length > 0);
}
body {
    auto table = Bad_char_table(pattern.length + 1);

    foreach (const idx, letter; pattern) {
        table[letter] = pattern.length - idx;
    }

    return table;
}