module CompressHashDisplace

using MurmurHash3
include("hash.jl")
export FrozenDict, lookup

mmhash(str::String) = last(mmhash128_a(sizeof(str), pointer(str), 0%UInt32))
mmhash(str::String, d::UInt32) = last(mmhash128_a(sizeof(str), pointer(str), d))

struct FrozenDict{V}
    G::Vector{Int}
    values::Vector{V}
    sz::UInt64
end

optimal_size(dict) = 1 << (leading_zeros(0) - leading_zeros(length(dict)))

# Computes a minimal perfect hash table using the given python dictionary. It
# returns a tuple (G, V). G and V are both arrays. G contains the intermediate
# table of values needed to compute the index of the value in V. V contains the
# values of the dictionary.
function FrozenDict(dict::Dict{K, V}) where {K, V}
    sz = optimal_size(dict)
    szmask = (sz - 1) % UInt64

    # Step 1: Place all of the keys into buckets
    buckets = [K[] for _ in 1:sz]
    G = zeros(Int, sz)
    # values = Vector{Union{Int, Nothing}}(undef, sz)
    values = Vector{V}(undef, sz)
    keyset = BitArray(undef, sz)
    for i in 1:sz
        keyset[i] = false
    end

    for key in keys(dict)
        idx = mmhash(key, 0 % UInt32) & szmask + 1
        push!(buckets[idx], key)
    end

    # Step 2: Sort the buckets and process the ones with the most items first.
    sort!(buckets, by = length, rev = true)
    slots = Vector{Int}()
    sizehint!(slots, length(first(buckets)))
    b = 1
    while b <= sz
        bucket = buckets[b]
        length(bucket) <= 1 && break

        d = 1 % UInt32
        item = 1

        # Repeatedly try different values of d until we find a hash function
        # that places all items in the bucket into free slots
        while item <= length(bucket)
            slot = mmhash(bucket[item], d) & szmask + 1
            if keyset[slot] || (slot in slots)
                d += 1 % UInt32
                item = 1
                empty!(slots)
            else
                push!(slots, slot)
                item += 1
            end
        end

        # We already know this value, why do we calculate it again??
        G[mmhash(first(bucket), 0 % UInt32) & szmask + 1] = d
        for i in 1:length(bucket)
            values[slots[i]] = dict[bucket[i]]
            keyset[slots[i]] = true
        end
        empty!(slots)
        b += 1
    end

    idx = 1
    for b2 in b:sz
        bucket = buckets[b2]
        isempty(bucket) && break
        bucket = first(bucket)
        while keyset[idx]
            idx += 1
        end

        # why we calculate it second time?? It makes no sense at all
        G[mmhash(bucket, 0 % UInt32) & szmask + 1] = -idx
        values[idx] = dict[bucket]
        idx += 1
    end

    return FrozenDict{V}(G, values, sz)
end

# Look up a value in the hash table, defined by G and V.
function lookup(FD::FrozenDict{V}, key) where V
    szmask = UInt64(FD.sz - 1)
    @inbounds d = FD.G[mmhash(key, 0%UInt32) & szmask + 1%UInt32]
    if d < 0
        @inbounds return FD.values[-d]
    else
        @inbounds return FD.values[mmhash(key, d % UInt32) & szmask + 1%UInt32]
    end
end

end # module
