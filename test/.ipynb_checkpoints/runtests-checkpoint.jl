using Test, TowerOfHanoi

@testset "Domain" begin
    let
        local t = Tower(4)
        @test length(t.rods) == 3
        @test length(t.rods[1].discs) == 4
        @test length(t.rods[2].discs) == 0
        @test length(t.rods[3].discs) == 0

        @test isa(Move(t,1,2), Move{Possible})
        @test isa(TowerOfHanoi.check(Move(t,1,2)), Move{Valid})
    end
    
    let
        local t = Tower(4,2)
        @test length(t.rods[1].discs) == 0
        @test length(t.rods[2].discs) == 4
        @test length(t.rods[3].discs) == 0
    end
    
    
    t = Tower(4)
    r = Move(t,1,2)()
    r = Move(r,1,3)()
    r = Move(r,2,3)()
    
    m = Move(r,1,3)
    @test isa(TowerOfHanoi.check(m), Move{Invalid})
    
    r = Move(r,3,2)()
    r = Move(r,3,1)()
    r = Move(r,2,1)()
    
    @test r == t
    @test hash(r) == hash(t)
    
    moves = []
    for_each_valid_move(t) do each_move
        push!(moves,each_move)
    end
    @test length(moves) == 2
    @test moves[1].from == 1
    @test moves[1].to == 2
    @test moves[2].from == 1
    @test moves[2].to == 3
end




