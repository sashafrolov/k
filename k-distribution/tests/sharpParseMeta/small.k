module SMALL
  syntax Int ::= r"[0-9]+" [prefer, token, prec(2)]
  syntax E ::= E "+" E | E "*" E | Int
endmodule

