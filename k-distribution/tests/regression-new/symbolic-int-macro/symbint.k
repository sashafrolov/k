// Copyright (c) 2019 K Team. All Rights Reserved.

module SYMBINT-SYNTAX
  imports INT
  imports ID

  syntax Int ::= "symbolicInt"
  rule symbolicInt => ?V:Int [macro]

  syntax Int ::= init ( Id )
endmodule

module SYMBINT
  imports SYMBINT-SYNTAX

  configuration <k> $PGM:Int </k>
                <mem> .Map </mem>

  rule <k> init(X) => . ... </k>
       <mem> MEM => MEM [ X <- symbolicInt ] </mem>
endmodule
