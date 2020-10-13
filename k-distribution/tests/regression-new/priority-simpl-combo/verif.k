module VERIF
    imports DOMAINS

 // KEVM code
 // -----------------------------------------------------------

    syntax Schedule ::= "DEFAULT" [klabel(DEFAULT_EVM), symbol, smtlib(schedule_DEFAULT)]
    syntax Schedule ::= "FRONTIER" [klabel(FRONTIER_EVM), symbol, smtlib(schedule_FRONTIER)]
    syntax Schedule ::= "HOMESTEAD" [klabel(HOMESTEAD_EVM), symbol, smtlib(schedule_HOMESTEAD)]
    syntax Schedule ::= "TANGERINE_WHISTLE" [klabel(TANGERINE_WHISTLE_EVM), symbol, smtlib(schedule_TANGERINE_WHISTLE)]
    syntax Schedule ::= "SPURIOUS_DRAGON" [klabel(SPURIOUS_DRAGON_EVM), symbol, smtlib(schedule_SPURIOUS_DRAGON)]
    syntax Schedule ::= "BYZANTIUM" [klabel(BYZANTIUM_EVM), symbol, smtlib(schedule_BYZANTIUM)]
    syntax Schedule ::= "CONSTANTINOPLE" [klabel(CONSTANTINOPLE_EVM), symbol, smtlib(schedule_CONSTANTINOPLE)]
    syntax Schedule ::= "PETERSBURG" [klabel(PETERSBURG_EVM), symbol, smtlib(schedule_PETERSBURG)]
    syntax Schedule ::= "ISTANBUL" [klabel(ISTANBUL_EVM), symbol, smtlib(schedule_ISTANBUL)]

    syntax Set ::= #precompiledAccounts ( Schedule ) [function]
 // -----------------------------------------------------------
    rule #precompiledAccounts(DEFAULT)           => SetItem(1) SetItem(2) SetItem(3) SetItem(4)
    rule #precompiledAccounts(FRONTIER)          => #precompiledAccounts(DEFAULT)
    rule #precompiledAccounts(HOMESTEAD)         => #precompiledAccounts(FRONTIER)
    rule #precompiledAccounts(TANGERINE_WHISTLE) => #precompiledAccounts(HOMESTEAD)
    rule #precompiledAccounts(SPURIOUS_DRAGON)   => #precompiledAccounts(TANGERINE_WHISTLE)
    rule #precompiledAccounts(BYZANTIUM)         => #precompiledAccounts(SPURIOUS_DRAGON) SetItem(5) SetItem(6) SetItem(7) SetItem(8)
    rule #precompiledAccounts(CONSTANTINOPLE)    => #precompiledAccounts(BYZANTIUM)
    rule #precompiledAccounts(PETERSBURG)        => #precompiledAccounts(CONSTANTINOPLE)
    rule #precompiledAccounts(ISTANBUL)          => #precompiledAccounts(PETERSBURG) SetItem(9)

    syntax KItem ::= OpCode
    syntax OpCode ::= NullStackOp | InternalOp
    syntax NullStackOp   ::= PrecompiledOp
    syntax PrecompiledOp ::= #precompiled ( Int ) [function]
 // --------------------------------------------------------
    rule #precompiled(1) => ECREC
    rule #precompiled(2) => SHA256
    rule #precompiled(3) => RIP160
    rule #precompiled(4) => ID
    rule #precompiled(5) => MODEXP
    rule #precompiled(6) => ECADD
    rule #precompiled(7) => ECMUL
    rule #precompiled(8) => ECPAIRING
    rule #precompiled(9) => BLAKE2F

    syntax PrecompiledOp ::= "ECREC" | "SHA256" | "RIP160" | "ID" | "MODEXP" | "ECADD" | "ECMUL" | "ECPAIRING" | "BLAKE2F"

    syntax InternalOp ::= "#precompiled?" "(" Int "," Schedule ")"
 // --------------------------------------------------------------
    rule <k> #precompiled?(ACCTCODE, SCHED) => #next [ #precompiled(ACCTCODE) ] ... </k>
      requires         ACCTCODE in #precompiledAccounts(SCHED)
    rule <k> #precompiled?(ACCTCODE, SCHED) => .                                ... </k>
      requires notBool ACCTCODE in #precompiledAccounts(SCHED)

    syntax InternalOp ::= "#next" "[" OpCode "]"

    syntax Int ::= #newAddr ( Int , Int ) [function]

 // ERC20 verifier code
 // -----------------------------------------------------------
    rule <k> #precompiled?(ACCTCODE, SCHED) => #next [ #precompiled(ACCTCODE) ] ... </k>
      requires         #inPrecompiledAccounts(ACCTCODE, SCHED)                            [priority(40)]
    rule <k> #precompiled?(ACCTCODE, SCHED) => .                                ... </k>
      requires notBool #inPrecompiledAccounts(ACCTCODE, SCHED)                            [priority(40)]

    syntax Bool ::= #inPrecompiledAccounts ( Int , Schedule )                             [function, functional]
    rule #inPrecompiledAccounts(ACCTCODE, SCHED)  => ACCTCODE in #precompiledAccounts(SCHED)
    rule #inPrecompiledAccounts(#newAddr(_,_), _) => false                                [simplification]

endmodule
