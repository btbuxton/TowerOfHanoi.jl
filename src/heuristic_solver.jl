using TowerOfHanoi
using DataStructures

function heuristic_solve(initial_state::Tower, end_state::Tower)
    visited = Set()
    heuristic_func = (tower::Tower) -> heuristic(initial_state, tower)
    to_explore = MutableBinaryHeap{Tower}(Base.By(heuristic_func, Base.Reverse), [initial_state])
    back_trace = Dict()
    end_state_found = false
    while length(to_explore) > 0
        next_tower = pop!(to_explore)
        if in(next_tower, visited)
            continue
        end
        push!(visited, next_tower)
        for_each_valid_move(next_tower) do each_move
            child = each_move()
            if in(child, visited)
                return
            end
            back_trace[child] = each_move
            if child == end_state
                #println("END!")
                end_state_found = true
                return
            end
            push!(to_explore, child)
        end
        if end_state_found
            break
        end
    end
    if !end_state_found
        return nothing
    end
    curr_state = end_state
    #show(end_state)
    moves_to_end = []
    while curr_state != initial_state
        move = back_trace[curr_state]
        push!(moves_to_end, move)
        curr_state = move.tower
    end
    return reverse(moves_to_end)
end

function main()
    initial = Tower(4, 1)
    final = Tower(4, 2)
    moves = heuristic_solve(initial, final) # TODO make end_state => end_states
    println("Moves to solve: $(length(moves))")
    for each in moves
        show(each.tower)
        heuristic_value = heuristic(initial, each.tower)
        println("heurstic value: ", heuristic_value)
        println("Move from $(each.from) to $(each.to)")
    end
    show(last(moves)())
end

main()