module VERIF
    imports DOMAINS

 // KEVM code
 // -----------------------------------------------------------

    syntax Set ::= "#precompiledAccounts" "(" ")" [function]
 // -----------------------------------------------------------
    rule #precompiledAccounts()           => SetItem(1) SetItem(2)

    syntax KItem ::= OpCode
    syntax OpCode ::= NullStackOp | InternalOp
    syntax NullStackOp   ::= PrecompiledOp
    syntax PrecompiledOp ::= #precompiled ( Int ) [function]
 // --------------------------------------------------------
    rule #precompiled(1) => ECREC
    rule #precompiled(2) => SHA256

    syntax PrecompiledOp ::= "ECREC" | "SHA256"

    syntax InternalOp ::= "#precompiled?" "(" Int ")"
 // --------------------------------------------------------------
    /*rule <k> #precompiled?(ACCTCODE) => #next [ #precompiled(ACCTCODE) ] ... </k>
      requires         ACCTCODE in #precompiledAccounts()
    rule <k> #precompiled?(ACCTCODE) => .                                ... </k>
      requires notBool ACCTCODE in #precompiledAccounts()*/

    syntax InternalOp ::= "#next" "[" OpCode "]"
 // --------------------------------------------------------
    rule <k> #next [ OP ] => OP ... </k>

    syntax Int ::= #newAddr ( Int , Int )         [function]
    rule #newAddr(ACCT, NONCE) => ACCT +Int NONCE [concrete]

 // ERC20 verifier code
 // -----------------------------------------------------------
    rule <k> #precompiled?(ACCTCODE) => #next [ #precompiled(ACCTCODE) ] ... </k>
      requires         #inPrecompiledAccounts(ACCTCODE)                            [priority(40)]
    rule <k> #precompiled?(ACCTCODE) => .                                ... </k>
      requires notBool #inPrecompiledAccounts(ACCTCODE)                            [priority(40)]

    syntax Bool ::= #inPrecompiledAccounts ( Int )                                 [function]
    rule #inPrecompiledAccounts(ACCTCODE)  => ACCTCODE in #precompiledAccounts()
    rule #inPrecompiledAccounts(#newAddr(_,_)) => false                            [priority(40)]

endmodule
