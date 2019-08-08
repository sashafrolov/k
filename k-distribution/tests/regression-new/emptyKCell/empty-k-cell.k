module EMPTY-K-CELL
    imports BOOL

    configuration <k> $PGM:Pgm </k>
                  <foo> .Foo </foo>

    syntax Pgm ::= ".Pgm"
    syntax Foo ::= ".Foo"
    rule <k> . </k>
         <foo> _ => .Foo </foo>
endmodule
