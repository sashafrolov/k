module VERIF
    configuration <k> $PGM:Pgm </k> <counter> 1 </counter> <sum> 0 </sum>

    syntax KItem ::= init1(    Int )
                   | init2(    Int )
                   | state1(   Int )
                   | state2(   Int )
                   | stateFoo( Int )
                   | stateBar( Int )

    syntax Int ::= foo( Int ) [function]
                 | bar( Int ) [function]

    rule <k> init1(I)        => state1(   I ) ... </k>
    rule <k> init1( foo(I) ) => stateFoo( I ) ... </k> [simplification]
    rule <k> init2(I)        => state2(   I ) ... </k>
    rule <k> init2( bar(I) ) => stateBar( I ) ... </k> [priority(40)]
endmodule
