// Copyright (c) 2020 K Team. All Rights Reserved.

requires "map-tests.k"

module LOOKUP-SPEC

    imports MAP-TESTS

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( MAP  ( Y |-> 2 ) [ Z ] )  </k> requires Y ==K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( 2 )  </k> requires Y ==K X andBool Z  ==K Y andBool Z  ==K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( MAP [ Z ] )  </k> requires Y ==K X andBool Z =/=K Y andBool Z =/=K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( ( MAP  X |-> 1 ) [ Y <- 2 ] [ Z ] )  </k>

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( MAP [ Y <- 2 ]  ( X |-> 1 ) [ Z ] )  </k> requires Y =/=K X

    // lookup-6-spec.k: Not resulting into #True but <k>lookupResult ( MAP [ Y <- 2 ] [ Z ])</k>
    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( MAP [ Y <- 2 ] [ Z ] )  </k> requires Y =/=K X andBool Z =/=K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( MAP [ Y <- 2 ]  ( X |-> 1 ) [ Z ] )  </k> requires Y =/=K X andBool Z =/=K Y

    // lookup-9-spec.k: Not resulting into #True but  <k>lookupResult ( MAP [ Y <- 2 ] [ Z ] )</k>
    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( MAP [ Y <- 2 ] [ Z ] )  </k> requires Y =/=K X andBool Z =/=K Y andBool Z =/=K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( ( MAP  Z |-> 1 ) [ Y <- 2 ] [ Z ] )  </k> requires Z  ==K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( ( MAP  X |-> 1 ) [ Y <- 2 ] [ Z ] )  </k> requires Z =/=K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( 2 )  </k> requires Z  ==K Y

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( MAP  ( X |-> 1 ) [ Z ] )  </k> requires Z =/=K Y

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( MAP [ Z ] )  </k> requires Z =/=K Y andBool Z =/=K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1) [Y:MyId <- 2] [ Z:MyId ] ) =>   lookupResult ( 1 )  </k> requires Z =/=K Y andBool Z  ==K X andBool Y =/=K X

    rule <k> lookup ( (MAP:Map X:MyId |-> 1 Y:MyId |-> 2) [ Y:MyId ] ) =>   lookupResult ( 2 )  </k> requires X =/=K Y

    rule <k> lookup ( (MAP:Map Y:MyId |-> 1 X:MyId |-> 2) [ Y:MyId ] ) =>   lookupResult ( 1 )  </k> requires X =/=K Y

    rule <k> lookup ( (X:MyId |-> 1 MAP:Map Y:MyId |-> 2) [ Y:MyId ] ) =>   lookupResult ( 2 )  </k> requires X =/=K Y

    rule <k> lookup ( (Y:MyId |-> 1 MAP:Map X:MyId |-> 2) [ Y:MyId ] ) =>   lookupResult ( 1 )  </k> requires X =/=K Y

    rule <k> lookup ( (X:MyId |-> 1 Y:MyId |-> 2 MAP:Map) [ Y:MyId ] ) =>   lookupResult ( 2 )  </k> requires X =/=K Y

    rule <k> lookup ( (Y:MyId |-> 1 X:MyId |-> 2 MAP:Map) [ Y:MyId ] ) =>   lookupResult ( 1 )  </k> requires X =/=K Y

    rule <k> lookup ( (X:MyId |-> 3 y |-> 4) [ x <- 5 ] [ X ] ) =>   lookupResult ( 3 )  </k> requires X =/=K x

    rule <k> lookup ( (y |-> 4) [ x ] ==K 4 ) =>   lookupResult ( false )  </k>

endmodule
