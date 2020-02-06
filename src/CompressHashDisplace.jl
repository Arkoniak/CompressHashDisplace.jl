module CompressHashDisplace

# Based on http://stevehanov.ca/blog/?id=119

const DICT = "/usr/share/dict/words"

# Calculates a distinct hash function for a given string. Each value of the
# integer d results in a different hash value.
function fnv_hash(s, d::UInt32 = 0x811c9dc5)

    # Use the FNV algorithm from http://isthe.com/chongo/tech/comp/fnv/
    for c in s
        d *= 0x01000193
        d = d ⊻ c
    end

    return d
end

end # module
