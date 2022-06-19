using DiffEqBase, ForwardDiff, Test

u0 = 2.0
p = 2.0
t0 = 1.0

@test DiffEqBase.promote_u0(u0,p,t0) isa Float64
@test DiffEqBase.promote_u0(u0,p,t0) == 2.0

struct MyStruct{T,T2} <: Number
    x::T
    y::T2
end

struct MyStruct2{T,T2}
    x::T
    y::T2
    MyStruct2(x) = new{typeof(x),Any}(x)
end

struct MyStruct3{T,T2}
    x::T
    y::T2
    MyStruct3(x) = new{typeof(x),Float64}(x)
end

p_possibilities = [ForwardDiff.Dual(2.0),(ForwardDiff.Dual(2.0),2.0),
    [ForwardDiff.Dual(2.0)],([ForwardDiff.Dual(2.0)],2.0),
    (2.0,ForwardDiff.Dual(2.0)),(;x=2.0,y=ForwardDiff.Dual(2.0)),
    (;x=2.0,y=[ForwardDiff.Dual(2.0)]),(;x=2.0,y=[[ForwardDiff.Dual(2.0)]]),
    Set([2.0,ForwardDiff.Dual(2.0)]),(SciMLBase.NullParameters(),ForwardDiff.Dual(2.0)),
    ((),ForwardDiff.Dual(2.0)),ForwardDiff.Dual{Nothing}(ForwardDiff.Dual{MyStruct}(2.0)),
    ((;),ForwardDiff.Dual(2.0)),MyStruct3(ForwardDiff.Dual(2.0)),
]

for p in p_possibilities
    @show p
    @test DiffEqBase.anyeltypedual(p) <: ForwardDiff.Dual
    u0 = 2.0
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
    u0 = ForwardDiff.Dual(2.0)
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
    @inferred DiffEqBase.anyeltypedual(p)
end

higher_order_p_possibilities = [ForwardDiff.Dual{Nothing}(ForwardDiff.Dual{MyStruct}(2.0)),
    (ForwardDiff.Dual{Nothing}(ForwardDiff.Dual{MyStruct}(2.0)), SciMLBase.NullParameters()),
    (ForwardDiff.Dual{Nothing}(ForwardDiff.Dual{MyStruct}(2.0)), ForwardDiff.Dual{Nothing}(2.0)),
    (ForwardDiff.Dual{Nothing}(2.0), ForwardDiff.Dual{Nothing}(ForwardDiff.Dual{MyStruct}(2.0)))
]

for p in higher_order_p_possibilities
    @show p
    @test DiffEqBase.anyeltypedual(p) <: ForwardDiff.Dual
    @test DiffEqBase.anyeltypedual(p) <: ForwardDiff.Dual{Nothing,ForwardDiff.Dual{MyStruct,Float64,0},0}
    u0 = 2.0
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
    u0 = ForwardDiff.Dual(2.0)
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
    @inferred DiffEqBase.anyeltypedual(p)
end

p_possibilities17 = [
    MyStruct(2.0,ForwardDiff.Dual(2.0)), [MyStruct(2.0,ForwardDiff.Dual(2.0))],
    [MyStruct(2.0,[2.0,ForwardDiff.Dual(2.0)])],
    [MyStruct(2.0,(2.0,ForwardDiff.Dual(2.0)))],
]

for p in p_possibilities17
    @show p
    @test DiffEqBase.anyeltypedual(p) <: ForwardDiff.Dual
    u0 = 2.0
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
    u0 = ForwardDiff.Dual(2.0)
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual

    if VERSION >= v"1.7"
        # v1.6 does not infer `getproperty` mapping
        @inferred DiffEqBase.anyeltypedual(p)
    end
end

p_possibilities_uninferrred = [
    Dict(:x => 2.0, :y => ForwardDiff.Dual(2.0)),
    Dict(:x => 2.0, :y => [ForwardDiff.Dual(2.0)]),
    Dict(:x => 2.0, :y => [(;x=(ForwardDiff.Dual(2.0),2.0),y=2.0)]),
    Dict(:x => 2.0, :y => [(;x=[MyStruct(2.0,[2.0,ForwardDiff.Dual(2.0)])],y=2.0)]),
    [MyStruct("2",[2.0,ForwardDiff.Dual(2.0)])],
    Set([2.0,"s",ForwardDiff.Dual(2.0)]),
    Dict(:x=>[MyStruct("2",[2.0,MyStruct(ForwardDiff.Dual(2.0),2.0)])],:y=>ForwardDiff.Dual{MyStruct}(2.0)),
    Set([2.0,ForwardDiff.Dual(2.0),SciMLBase.NullParameters()]),
    ((Dict(:x=>nothing)),ForwardDiff.Dual(2.0)),
    MyStruct2(ForwardDiff.Dual(2.0)),

    # Vectors of non-number types won't infer
    [MyStruct(2.0,ForwardDiff.Dual(2.0))],
    (;x=2.0,y=[[MyStruct3(ForwardDiff.Dual(2.0))]]),

]

for p in p_possibilities_uninferrred
    @test DiffEqBase.anyeltypedual(p) <: ForwardDiff.Dual
    u0 = 2.0
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
    u0 = ForwardDiff.Dual(2.0)
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
end

p_possibilities_notdual= [
    (),(;),[2.0],[2.0,2],[2.0,(2.0)],[2.0,MyStruct(2.0,2f0)],
    [2.0,MyStruct3(2.0)],[2.0,MyStruct2(2.0)],[2.0,MyStruct2(2.0),[]],
    Dict(:x=>2,:y=>5),Dict(:x=>2,"y"=>5),[Dict(:x=>2,"y"=>5),MyStruct2(2.0)],
]

for p in p_possibilities_notdual_inferred
    @test !(DiffEqBase.anyeltypedual(p) <: ForwardDiff.Dual)
    u0 = 2.0
    @test !(DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual)
    u0 = ForwardDiff.Dual(2.0)
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
    @inferred DiffEqBase.anyeltypedual(p)
end

p_possibilities_notdual_uninferred = [
    [],
]

for p in p_possibilities_notdual_uninferred
    @test !(DiffEqBase.anyeltypedual(p) <: ForwardDiff.Dual)
    u0 = 2.0
    @test !(DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual)
    u0 = ForwardDiff.Dual(2.0)
    @test DiffEqBase.promote_u0(u0,p,t0) isa ForwardDiff.Dual
end