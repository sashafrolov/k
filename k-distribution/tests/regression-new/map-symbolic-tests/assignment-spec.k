// Copyright (c) 2019 K Team. All Rights Reserved.

requires "map-tests.k"

module ASSIGNMENT-SPEC
    imports MAP-TESTS

    rule <k> assignment ( .Map [ x <- 3 ] ) =>   assignmentResult ( x |-> 3 )  </k>

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  X |-> 1 ) [ Y <- 2 ] [ Z <- 3 ] )  </k>

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP [ Y <- 2 ]  X |-> 1 ) [ Z <- 3 ] )  </k> requires Y =/=K X

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP [ Y <- 2 ]  X |-> 1 ) [ Z <- 3 ] )  </k> requires Y =/=K X andBool Y in_keys(MAP)

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  Y |-> 2 ) [ Z <- 3 ] )  </k> requires Y ==K X

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  Y |-> 2 ) [ Z <- 3 ] )  </k> requires Y ==K X andBool Z in_keys(MAP)

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  Y |-> 2 ) [ Z <- 3 ] )  </k> requires Y ==K X andBool notBool Z in_keys(MAP)

    // Error: assignment-9-spec.k
    //rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( MAP [ Y <- 2 ] [ Z <- 3 ]  X |-> 1 )  </k> requires Y =/=K X andBool Z =/=K X

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP [ Y <- 2 ]  X |-> 1 ) [ Z <- 3 ] )  </k> requires Y =/=K X andBool Z =/=K Y

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( MAP [ Y <- 2 ]  Z |-> 3 )  </k> requires Y =/=K X andBool Z =/=K Y andBool Z  ==K X

    //ERROR: assignment-14-spec.k
    //rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( MAP [ Y <- 2 ] [ Z <- 3 ]  X |-> 1 )  </k> requires Y =/=K X andBool Z =/=K Y andBool Z =/=K X

    //ERROR: assignment-15-spec.k
    //rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( MAP [ Y <- 2 ] [ Z <- 3 ]  X |-> 1 )  </k> requires Y =/=K X andBool Z =/=K Y andBool Z =/=K X andBool Y in_keys(MAP) andBool Z in_keys(MAP)

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( MAP  Z |-> 3 )  </k> requires Y ==K X andBool Z  ==K Y andBool Z  ==K X

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( MAP  Z |-> 3 )  </k> requires Y ==K X andBool Z  ==K Y andBool Z  ==K X andBool notBool X in_keys(MAP)

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( MAP [ Z <- 3 ]  Y |-> 2 )  </k> requires Y ==K X andBool Z =/=K Y andBool Z =/=K X

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  Z |-> 1 ) [ Y <- 2 ] [ Z <- 3 ] )  </k> requires Z  ==K X

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  X |-> 1 ) [ Y <- 2 ] [ Z <- 3 ] )  </k> requires Z =/=K X

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  X |-> 1 ) [ Z <- 3 ] )  </k> requires Z  ==K Y

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  X |-> 1 ) [ Y <- 2 ] [ Z <- 3 ] )  </k> requires Z =/=K Y

    rule <k> assignment ( (MAP:Map X:MyId |-> 1) [ Y:MyId <- 2 ] [ Z:MyId <- 3 ] ) =>   assignmentResult ( ( MAP  X |-> 1 ) [ Y <- 2 ] [ Z <- 3 ] )  </k> requires Z =/=K Y andBool Z =/=K X

    rule <k> assignment ( (X:MyId |-> 4) [ X <- 3 ] ) =>   assignmentResult ( X |-> 3 )  </k>

    rule <k> assignment ( (       X:MyId   |-> BAL_TO:Int       Y:MyId   |-> BAL_FROM:Int MAP:Map ) [       Y   <- BAL_FROM -Int 30 ] ) =>   assignmentResult ( MAP  X |-> BAL_TO  Y |-> BAL_FROM -Int 30 )  </k> requires       X   =/=K       Y

    rule <k> assignment ( ( foo ( X:MyId ) |-> BAL_TO:Int foo ( Y:MyId ) |-> BAL_FROM:Int MAP:Map ) [ foo ( Y ) <- BAL_FROM -Int 30 ] ) =>   assignmentResult ( MAP  foo ( X ) |-> BAL_TO  foo ( Y ) |-> BAL_FROM -Int 30 )  </k> requires foo ( X ) =/=K foo ( Y )

endmodule
