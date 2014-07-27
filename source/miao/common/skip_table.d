module miao.common.skip_table;

@trusted:

struct Skip_table(KeyType) {
public pure nothrow:
    this(in int default_val)
    {
        default_val_ = default_val;
    }

    int opIndex(in KeyType idx) const
    {
        const ret = idx in skip_table_;
        return ret? *ret: default_val_;
    }

    int opIndexAssign(in int val, in KeyType idx)
    {
        return skip_table_[idx] = val;
    }

private:
    int[KeyType] skip_table_;
    immutable int default_val_;
}

import miao.common.util;

pure auto build_bm_table(PatRange)(in PatRange pattern) nothrow
in {
    assert(pattern.length > 0);
}
body {
    auto table = Skip_table!(ValueType!PatRange)(pattern.length);

    const last_pos = pattern.length - 1;

    foreach (const idx, letter; pattern[0 .. last_pos]) {
        table[letter] = last_pos - idx;
    }

    return table;
}

pure auto build_qs_table(PatRange)(in PatRange pattern) nothrow
in {
    assert(pattern.length > 0);
}
body {
    auto table = Skip_table!(ValueType!PatRange)(pattern.length + 1);

    foreach (const idx, letter; pattern) {
        table[letter] = pattern.length - idx;
    }

    return table;
}

unittest {
    auto x = build_bm_table(" ");
    const y = build_bm_table(" ");
    immutable z = build_bm_table(" ");

    auto x1 = build_bm_table([1]);
    const y1 = build_bm_table([1]);
    immutable z1 = build_bm_table([1]);
}