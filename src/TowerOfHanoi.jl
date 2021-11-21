module TowerOfHanoi

export Disc, Rod, Tower, Move, Valid, Invalid, Possible
export for_each_valid_move, heuristic

struct Disc
    value::Integer
end

Base.show(io::IO, disc::Disc) = print(io, repeat("*", disc.value))

Base.:(<)(a::Disc, b::Disc) = a.value < b.value
Base.:(==)(a::Disc, b::Disc) = a.value == b.value
Base.hash(a::Disc,h::UInt) = hash(a.value,h)

function show_line(disc::Disc, max::Integer, depth::Integer)
    rpad(lpad(repeat("*", disc.value), Integer((max - disc.value) / 2 + disc.value)), max)
end

struct Rod
    discs::AbstractVector{Disc}
end

Rod() = Rod([])
Base.:(==)(a::Rod,b::Rod) = a.discs == b.discs
Base.hash(a::Rod,h::UInt) = hash(a.discs,h)

function show_line(rod::Rod, max::Integer, depth::Integer)
    disc = get(rod.discs, depth, nothing)
    if disc == nothing
        repeat(" ", max)
    else    
        show_line(disc, max, depth)
    end
end

top_disc(rod::Rod) = last(rod.discs)
has_discs(rod::Rod) = !isempty(rod.discs)

function can_accept(rod::Rod, disc::Disc)
    if !has_discs(rod)
        return true
    end
    top_disc(rod) > disc
end

struct Tower
    size::Integer
    rods::AbstractVector{Rod}
end

function Tower(size::Integer,initial::Integer=1)
    stack = reverse([Disc(each) for each in range(3, step=2,length=size)])
    rods = [Rod(), Rod(), Rod()]
    rods[initial]=Rod(stack)
    Tower(size, rods)
end

Base.:(==)(a::Tower,b::Tower) = a.size == b.size && a.rods == b.rods
Base.hash(a::Tower,h::UInt) = hash(a.rods,h)

function can_make_move(tower::Tower, from::Integer, to::Integer)
    if from == to
        return false, "Can not be same rod[$from]"
    end
    
    from_rod = tower.rods[from]
    if !has_discs(from_rod)
        return false, "No discs to move from rod[$from]"
    end
    
    if !can_accept(tower.rods[to], top_disc(from_rod))
        return false, "Disc at top of rod[$from] is greater than top of rod[$to]"
    end
    true, nothing
end

function Base.show(io::IO, tower::Tower)
    max = tower.size * 2 + 3
    for y in range(tower.size, length=tower.size, step=-1)
        for each_rod in tower.rods
            print(io, show_line(each_rod, max, y))
        end
        println(io)
    end
end

struct InvalidMoveException <: Exception
    value::String
end

abstract type MoveState end
struct Valid <: MoveState end
struct Invalid <: MoveState end
struct Possible <: MoveState end

struct Move{T}
    tower::Tower
    from::Integer
    to::Integer
    msg::String # less than ideal - only for invalid
    
    Move{Valid}(move::Move{Possible}) = new{Valid}(move.tower, move.from, move.to, "") # yuck
    Move{Invalid}(move::Move{Possible}, msg::String) = new{Invalid}(move.tower,move.from,move.to,msg)
    Move{Possible}(tower::Tower, from::Integer, to::Integer) = new{Possible}(tower,from,to,"")
    Move(tower::Tower, from::Integer, to::Integer) = Move{Possible}(tower,from,to)
end

function (move::Move{Possible})() 
    check(move)()
end

function (move::Move{Invalid})()
    throw(InvalidMoveException(move.msg))
end

function (move::Move{Valid})()
    rods = deepcopy(move.tower.rods)
    from_rod = rods[move.from]
    to_rod = rods[move.to]
    
    disc = pop!(from_rod.discs)
    push!(to_rod.discs, disc)
    Tower(move.tower.size, rods)
end

check(move::Move{Valid}) = move
check(move::Move{Invalid}) = move
function check(move::Move{Possible})
    is_valid, msg = can_make_move(move.tower,move.from,move.to)
    if is_valid
        Move{Valid}(move)
    else
        Move{Invalid}(move, msg)
    end
end

if_valid_do(func::Function, move::Move{Valid}) = func(move)
if_valid_do(func::Function, move::Move{Invalid}) = nothing
if_valid_do(func::Function, move::Move{Possible}) = if_valid_do(func, check(move))

function for_each_valid_move(func::Function, tower::Tower)
    for from_index in range(1, length=3)
        for to_index in range(1, length=3)
            if from_index === to_index
                continue
            end
            move = Move(tower, from_index, to_index)
            if_valid_do(func, move)
        end
    end
end

function heuristic(initial::Tower, state::Tower)
    disc_cache = Dict()
    for (r, rod) in enumerate(initial.rods)
        for (d, disc) in enumerate(rod.discs)
            disc_cache[disc]=(r,d)
        end
    end
    num_discs = length(disc_cache)
    result = 0
    for (r, rod) in enumerate(state.rods)
        for (d, disc) in enumerate(rod.discs)
            (ir, id) = disc_cache[disc]
            rod_diff = abs(ir - r) > 0 ? 2 : 1
            disc_diff = num_discs - abs(id - d)
            result += rod_diff * disc_diff
        end
    end
    result
end

end # module
