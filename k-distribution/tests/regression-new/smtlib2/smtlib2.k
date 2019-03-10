requires "smt.k"

module SMTLIB2-TEST-DRIVER
  imports ML-TO-SMTLIB2
  imports PREDICATE-DEFINITIONS
  imports Z3
  imports CVC4

  configuration <k> $PGM:ImplicativeForm </k>
                <z3> .K </z3>
                <cvc4> .K </cvc4>

  rule <k> SCRIPT:SMTLIB2Script </k>
       <z3> .K => Z3CheckSAT(Z3Prelude ++SMTLIB2Script SCRIPT) </z3>
  rule <k> SCRIPT:SMTLIB2Script </k>
       <cvc4> .K => CVC4CheckSAT(CVC4Prelude ++SMTLIB2Script SCRIPT) </cvc4>
endmodule
