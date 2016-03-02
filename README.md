# netgengen

[![Build Status](https://travis-ci.org/juhanikataja/netgengen.jl.svg?branch=master)](https://travis-ci.org/juhanikataja/netgengen.jl)

A netgen algebraic3d CSG '''.geo'''-file generator for Julia. 

*Example use*:

        laatikko = brick("laatikko", [0.0,0.0,0.0],[1.0,1.0,1.0])
        loota = brick("loota", [0.0,0.0,0.0],[1.0,0.5,2.0])

        unioni2 = csgunion("unioni2", [not(brick([0.0,0.0,0.0],[1.0,1.0,1.0])), cylinder([0.0,0.0,0.0],[1.0,1.0,1.0], 1)])

        unioni = csgunion("unioni", [laatikko, loota])
        println("algebraic3d")
        tlo(unioni2, col=[1, 0, 0])
        tlo(unioni, col=[0, 1, 0])
