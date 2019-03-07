module IMP-SYNTAX
  syntax Int ::= r"[0-9]+" [prefer, token, prec(2)]
  syntax E ::= E "+" E [klabel(plus)] | E "*" E [klabel(mul)] | Int
endmodule

