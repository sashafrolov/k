module SMTLIB2-SPEC
  imports SMTLIB2-TEST-DRIVER
  
  syntax SMTLIB2SimpleSymbol ::= "a"        [token]
                               | "b"        [token]
                               | "f"        [token]
                               | "f_2"      [token]
                               | "f_6"      [token]
                               | "f_14"     [token]
                               | "fa"       [token]
                               | "g1"       [token]
                               | "g2"       [token]
                               | "g2_9"     [token]
                               | "h"        [token]
                               | "la"       [token]
                               | "length"   [token]
                               | "length_6" [token]
                               | "list"     [token]
                               | "n"        [token]
                               | "x"        [token]
                               | "x_15"     [token]
                               | "y"        [token]
                               | "y_3"      [token]
                               | "y_7"      [token]
                               | "z"        [token]
                               | "SetInt"   [token]

  rule <smt>
            (declare-const a Bool)
            (assert (= a true .SMTLIB2TermList))
            (assert (= a false .SMTLIB2TermList))
       </smt>
       <z3> .K => unsat </z3>
       <cvc4> .K => unsat </cvc4>

  rule <smt>
            (declare-const a Bool)
            (assert (= a false))
       </smt>
       <z3> .K => sat </z3>
       <cvc4> .K => sat </cvc4>

  rule <smt>
            (declare-const a Int)
            (declare-const b Int)
            (declare-const n Int)
            (assert (= b (* (^ a n) a):SMTLIB2Term))
            (assert (not (= b (^ a (+ n 1):SMTLIB2Term):SMTLIB2Term):SMTLIB2Term))
       </smt>
       <z3> .K => unknown(.K) </z3>
       <cvc4> .K => unknown(_) </cvc4>

  rule <smt> 
            ( declare-const f SetInt )  
            ( declare-const z Int )  
            ( declare-const h ( Array Int  Int  .SMTLIB2SortList ) )  
            ( declare-const y Int )  
            ( declare-const fa SetInt )  
            ( declare-const la Int )  
            ( declare-const length_6 Int )  
            ( declare-const length Int )  
            ( declare-const x Int )  
            ( declare-const y_7 Int )  
            ( declare-const f_6 SetInt )  
            ( assert ( and ( = f  ( unionx fa  ( singleton y  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  
                     ( and ( disjointx fa  ( singleton y  .SMTLIB2TermList )  .SMTLIB2TermList )  
                     ( and ( = z  ( select h  y  .SMTLIB2TermList )  .SMTLIB2TermList )  
                     ( and ( = length  ( + la  1  .SMTLIB2TermList )  .SMTLIB2TermList )  
                     ( and ( > y  0  .SMTLIB2TermList )  
                     ( and ( = x  y  .SMTLIB2TermList )  
                     ( and ( = fa  emptysetx  .SMTLIB2TermList )  
                     ( and ( = la  0  .SMTLIB2TermList )  
                     ( and ( = length_6  ( - length  1  .SMTLIB2TermList )  .SMTLIB2TermList )  
                     ( and ( = x  y_7  .SMTLIB2TermList )  
                     ( and ( = f_6  emptysetx  .SMTLIB2TermList )  true  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList ) )  
            ( assert ( not ( and ( > y_7  0  .SMTLIB2TermList )  
                           ( and ( = z  ( select h y_7  .SMTLIB2TermList )  .SMTLIB2TermList )  
                           ( and ( = f  ( unionx f_6  ( singleton y_7  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  
                           ( and ( disjointx f_6  ( singleton y_7  .SMTLIB2TermList )  .SMTLIB2TermList )  
                           ( and ( = length_6  0  .SMTLIB2TermList )  true  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList ) )
            .SMTLIB2Script
       </smt>
       <z3> .K => unsat </z3>
       <cvc4> .K => unsat </cvc4>

    rule <smt> 
              ( declare-const f SetInt )  
              ( declare-const g2 SetInt )  
              ( declare-const y Int )  
              ( declare-const g1 SetInt )  
              ( declare-const f_2 SetInt )  
              ( declare-const h ( Array Int Int .SMTLIB2SortList ) )  
              ( declare-const y_3 Int )  
              ( declare-const x_15 Int )  
              ( declare-fun list ( ( Array Int  Int  .SMTLIB2SortList )  Int  SetInt  .SMTLIB2SortList ) Bool )  
              ( assert ( and ( list h  y  g2  .SMTLIB2TermList )  
                       ( and ( disjointx g1  g2  .SMTLIB2TermList )  
                       ( and ( = f  ( unionx g1  g2  .SMTLIB2TermList )  .SMTLIB2TermList )  
                       ( and ( > y_3  0  .SMTLIB2TermList )  
                       ( and ( = y  ( select h  y_3  .SMTLIB2TermList )  .SMTLIB2TermList )  
                       ( and ( = g1  ( unionx f_2  ( singleton y_3  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  
                       ( and ( disjointx f_2  ( singleton y_3  .SMTLIB2TermList )  .SMTLIB2TermList )  
                       ( and ( = x_15  ( select h  y_3  .SMTLIB2TermList )  .SMTLIB2TermList )  
                       ( and ( = ( select h  y_3  .SMTLIB2TermList )  x_15  .SMTLIB2TermList )  true  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList ) )  
              ( assert ( forall ( ( g2_9 SetInt )  ( f_14 SetInt )  .SMTLIB2SortedVarList )
                            ( not ( and ( disjointx f_2  g2_9  .SMTLIB2TermList )  
                                  ( and ( = f  ( unionx f_2  g2_9  .SMTLIB2TermList )  .SMTLIB2TermList )  
                                  ( and ( list h  x_15  f_14  .SMTLIB2TermList )  
                                  ( and ( = g2_9  ( unionx f_14  ( singleton y_3  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  
                                  ( and ( disjointx f_14  ( singleton y_3  .SMTLIB2TermList )  .SMTLIB2TermList )  true  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList )  .SMTLIB2TermList ) ) )  .SMTLIB2Script
         </smt>
         <z3> .K => unknown(.K) </z3>
         <cvc4> .K => unsat </cvc4>

endmodule
