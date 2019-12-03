// Copyright (c) 2014-2019 K Team. All Rights Reserved.

requires "substitution.k"

module IMP-SYNTAX
  imports DOMAINS-SYNTAX
  imports KVAR
  syntax Var ::= KVar
  syntax AExp  ::= Int [klabel(intLit), avoid, symbol, function] | Var
                 | "-" Int                    [function]
                 | AExp "/" AExp              [left, strict]
                 > AExp "+" AExp              [left, strict]
                 | "(" AExp ")"               [bracket]
  syntax BExp  ::= Bool
                 | AExp "<=" AExp             [seqstrict, latex({#1}\leq{#2})]
                 | "!" BExp                   [strict]
                 > BExp "&&" BExp             [left, strict(1)]
                 | "(" BExp ")"               [bracket]
  syntax Block ::= "{" "}"
                 | "{" Stmt "}"
  syntax Stmt  ::= Block
                 | Var "=" AExp ";"            [strict(2)]
                 | "if" "(" BExp ")"
                   Block "else" Block         [strict(1)]
                 | "while" "(" BExp ")" Block
                 > Stmt Stmt                  [left]
  syntax Pgm ::= "int" KVars ";" Stmt
  syntax KVars ::= List{KVar,","}
endmodule


module IMP
  imports IMP-SYNTAX
  imports MINT
  imports DOMAINS
  imports SUBSTITUTION
  syntax MInt{64}
  syntax AExp ::= MInt{64}
  syntax KResult ::= MInt{64} | Bool

  syntax Var ::= Slot
  syntax Slot ::= id(Int)

  configuration <T color="yellow">
                  <k color="green"> $PGM:Pgm </k>
                  <state color="red"> .List </state>
	          <vars> .Set </vars>
                  <counter> 0 </counter>
                </T>

  rule intLit(I:Int) => Int2MInt(I)

// AExp
  rule <k> id(N:Int) => Rho [ N ] ...</k> <state> Rho </state>
  rule I1 / I2 => I1 /sMInt I2  requires I2 =/=MInt 0p64
  rule I1 + I2 => I1 +MInt I2
  rule - I1 => intLit(0 -Int I1)
// BExp
  rule I1 <= I2 => I1 <=sMInt I2
  rule ! T => notBool T
  rule true && B => B
  rule false && _ => false
// Block
  rule {} => .   [structural]
  rule {S} => S  [structural]
// Stmt
  rule <k> id(N) = I:MInt{64} ; => . ...</k> <state> Rho => Rho [ N <- I ] </state>
  rule S1:Stmt S2:Stmt => S1 ~> S2  [structural]
  rule if (true)  S else _ => S
  rule if (false) _ else S => S
  rule while (B) S => if (B) {S while (B) S} else {}  [structural]
// Pgm
  rule <k> int (X,Xs => Xs);(S => S [ id(N) / X ]) </k> <state>... .List => ListItem(0) </state> <counter> N => N +Int 1 </counter> <vars> Rho => Rho SetItem(X) </vars>
    requires notBool (X in Rho)
  rule int .KVars; S => S  [structural]

// verification ids
  syntax KVar ::= "n"     [token]
                | "sum"   [token]
endmodule
