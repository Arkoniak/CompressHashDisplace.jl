# CompressHashDisplace

|                                                                                                  **Documentation**                                                                                                  |                                                                                                                          **Build Status**                                                                                                                          |
|:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
|  [![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://Arkoniak.github.io/CompressHashDisplace.jl/stable)[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://Arkoniak.github.io/CompressHashDisplace.jl/dev)  |   [![Build](https://github.com/Arkoniak/CompressHashDisplace.jl/workflows/CI/badge.svg)](https://github.com/Arkoniak/CompressHashDisplace.jl/actions)[![Coverage](https://codecov.io/gh/Arkoniak/CompressHashDisplace.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/Arkoniak/CompressHashDisplace.jl)   |

This package creates read-only dictionaries with fast access speed.

## Installation

```julia
julia> ] add CompressHashDisplace
```

## Usage

```julia
using BenchmarkTools
using CompressHashDisplace

DICTIONARY = "/usr/share/dict/words"
dict = Dict{String, Int}()

for (line, word) in enumerate(readlines(DICTIONARY))
    dict[word] = line
end

frozen_dict = FrozenDict(dict)
frozen_dict["hello"] # 50196

frozen_unsafe_dict = FrozenUnsafeDict(dict)
frozen_unsafe_dict["hello"] # 50196

word = "hello"
@btime $dict[$word]               # 76.615 ns (0 allocations: 0 bytes)
@btime $frozen_dict[$word]        # 60.028 ns (0 allocations: 0 bytes)
@btime $frozen_unsafe_dict[$word] # 22.124 ns (0 allocations: 0 bytes)
```

Main difference between `FrozenDict` and `FrozenUnsafeDict` is that `FrozenUnsafeDict`
do not validate input key

```julia
frozen_dict["foo"]         # KeyError: key "foo" not found
frozen_unsafe_dice["foo"]  # 59716, i.e. some random value
```
