module CompressHashDisplace

include("hash.jl")
export create_minimal_perfect_hash, perfect_hash_lookup

# Computes a minimal perfect hash table using the given python dictionary. It
# returns a tuple (G, V). G and V are both arrays. G contains the intermediate
# table of values needed to compute the index of the value in V. V contains the
# values of the dictionary.
function create_minimal_perfect_hash(dict::Dict{K, V}, sz = 2^17) where {K, V}
    szmask = UInt64(sz - 1)

    # Step 1: Place all of the keys into buckets
    buckets = [ K[] for i in 1:sz ]
    G = zeros(Int, sz)
    values = Vector{Union{Int, Nothing}}(undef, sz)

    for key in keys(dict)
        push!(buckets[hash(key, UInt64(0)) & szmask + 1], key)
    end

    # Step 2: Sort the buckets and process the ones with the most items first.
    sort!(buckets, by = length, rev = true)
    for b in 1:sz
        bucket = buckets[b]
        length(bucket) <= 1 && break

        d = UInt64(1)
        item = 1
        slots = []

        # Repeatedly try different values of d until we find a hash function
        # that places all items in the bucket into free slots

        while item <= length(bucket)
            slot = hash(bucket[item], d) & szmask + 1
            if (values[slot] != nothing) || (slot in slots)
                d += UInt64(1)
                item = 1
                slots = []
            else
                push!(slots, slot)
                item += 1
            end
        end

        G[hash(bucket[1], UInt64(0)) & szmask + 1] = d
        for i in 1:length(bucket)
            values[slots[i]] = dict[bucket[i]]
        end
    end

    # Only buckets with 1 item remain. Process them more quickly by directly
    # placing them into a free slot. Use a negative value of d to indicate
    # this.
    freelist = []
    for i in 1:sz
        values[i] == nothing && push!(freelist, i)
    end

    for b in 1:sz
        bucket = buckets[b]
        length(bucket) != 1 && continue
        slot = pop!(freelist)
        G[hash(bucket[1], UInt64(0)) & szmask + 1] = -slot
        values[slot] = dict[bucket[1]]
    end

    vals = Vector{Int}(undef, sz)
    for i in 1:sz
        values[i] == nothing && continue
        vals[i] = values[i]
    end

    return G, vals
end

# Look up a value in the hash table, defined by G and V.
function perfect_hash_lookup(G, V, key)
    szmask = UInt64(2^17 - 1)
    @inbounds d = G[hash(key, UInt64(0)) & szmask + UInt64(1)]
    if d < 0
        @inbounds return V[-d]
    else
        @inbounds return V[hash(key, d % UInt64) & szmask + UInt64(1)]
    end
end

end # module
