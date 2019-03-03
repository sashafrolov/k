// Copyright (c) 2013-2019 K Team. All Rights Reserved.
// Author: Radu Mereuta

module COMMONS
  syntax Any

endmodule

module TEST-SYNTAX
  imports COMMONS
  // parse anything sent to the input as a single token of sort Any
  syntax Any ::= r"([\\n\\r]|.)*" [token]
endmodule

module TEST
  imports COMMONS
  imports K-IO
  imports LIST
  imports ID-SYNTAX
  imports DOMAINS
  imports META
  
  syntax String ::= token2String ( K )    [function, functional, hook(STRING.token2string)]

  configuration <k> $PGM:Any </k>

  // take the input given as argument and run outer parsing to get the syntax AST
  // rule S:Any => eP(#parseString("k-light2k5.sh --output meta-kast outer-k.k KDefinition", S), .K, .List)
  rule S:Any => outerParse(S)
  
  syntax KItem ::= outerParse(K)
  syntax KItem ::= nextWriteToFile(K, K)
                 | nextCloseFile(K, K)
                 | "nextParseKore"
                 | "nextExtractProds"
  rule outerParse(S) => externalParse("k-light2k5.sh --output meta-kast outer-k.k KDefinition tempToParse.k", S)
  syntax KItem ::= externalParse(String, K)
  rule externalParse(Path, S)
    => #open("tempToParse.k", "w") ~> nextWriteToFile(Path, S)
  rule Fd:Int ~> nextWriteToFile(Path, S)
    => #write(Fd, token2String(S)) ~> nextCloseFile(Path, Fd)
  rule nextCloseFile(Path, Fd)
    => #close(Fd) ~> #system(Path) ~> nextParseKore
  rule #systemResult(0, Stdout, _) ~> nextParseKore => #parseKore(Stdout) ~> nextExtractProds
  rule Term:MetaK ~> nextExtractProds => eP(Term, .K, .List)

  // meta AST declarations
  syntax MetaKLabel
  syntax MetaValue
  syntax MetaKSort
  syntax MetaK ::= MetaKLabel | MetaValue | MetaKSort
                 | metaKApply (K, K)
                 | metaKToken (K, K)
                 | metaKList  (K, K)
                 | metaEmptyKList (K)

  // collect productions from anywhere in the AST and put them in a List
  syntax KItem ::= eP(K, K, List) // extractProduction
  syntax KItem ::= prods(K, List) // productions collector
  //rule eP(metaKApply(Tk, Kl),     Srt, L) => eP(Kl, Srt, L) [owise] // generic descent
  rule eP(metaKList(T1, T2),      Srt, L) => eP(T1, Srt, L) ~> T2 // generically visiting every child
  rule eP(`metaEmptyKList`(.KList), Srt, L) => prods(Srt, L)
  rule eP(metaKToken(_, _),       Srt, L) => prods(Srt, L)
  rule prods(Srt, L) ~> T:KItem          => eP(T, Srt, L)
  
  // TODO: adding these instead of one `owise` rule because it doesn't work :(
  rule eP(metaKApply(#token("kDefinition","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("emptyKRequireList","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("kModuleList","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("kModule","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("emptyKModuleList","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("noKAttributesDeclaration","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("emptyKImportList","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("kSentenceList","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("emptyKSentenceList","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("prodBlock","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("prioritySeqBlock","MetaKLabel"), Kl), Srt, L) => eP(Kl, Srt, L)

  rule eP(metaKApply(#token("kSyntaxProduction","MetaKLabel"), metaKList(Srt, Kl)), S, L) => eP(Kl, Srt, L)
  rule eP(metaKApply(#token("kProductionWAttr", "MetaKLabel"), Kl), Srt, L) =>
       prods(Srt, L ListItem(metaKApply(#token("kSyntaxProduction", "MetaKLabel"), metaKList(Srt, metaKApply(#token("kProductionWAttr",  "MetaKLabel"), Kl)))))

  // generate grammar
  syntax K ::= pp(K, String) // pretty print
  rule <k> prods(_, L) => pp(.K, "module TEMPPRETTYPRINT\n") ~> L ListItem("endmodule\n") </k>
  rule pp(.K, S) ~> ListItem(T) L => pp(T, S) ~> L
  rule pp(metaKList(T1, T2), S) ~> L:List => pp(T1, S) ~> ListItem(T2) L // generically visiting every child
  rule pp(`metaEmptyKList`(.KList), S) => pp(.K, S)
  rule pp(T:String, S) => pp(.K, S +String T) // closing matching element (for ] or endmodule)
  rule pp(metaKApply(
            #token("kSyntaxProduction", "MetaKLabel"),
           metaKList(metaKToken(Srt, #token("KSort","MetaKSort")), metaKApply(#token("kProductionWAttr",  "MetaKLabel"), Kl))), S) 
    => pp(Kl, S +String "  " +String "syntax " +String token2String(Srt) +String " ::= ")
  rule pp(metaKApply(#token("regexTerminal","MetaKLabel"),metaKList(metaKToken(Tk, #token("KString","MetaKSort")),`metaEmptyKList`(.KList))), S)
    => pp(.K, S +String "r" +String token2String(Tk) +String " ")
  rule pp(metaKApply(#token("kAttributesDeclaration","MetaKLabel"), Kl), S) ~> L
    => pp(Kl, S +String "[") ~> ListItem("dummy]\n") L
  rule pp(metaKApply(#token("kAttributesList","MetaKLabel"), Kl), S)
    => pp(Kl, S)
  rule pp(metaKApply(#token("tagSimple","MetaKLabel"),metaKList(metaKToken(Tk,#token("KEY","MetaKSort")),`metaEmptyKList`(.KList))), S)
    => pp(.K, S +String token2String(Tk) +String ", ")
  rule pp(metaKApply(#token("tagContent","MetaKLabel"),
           metaKList(
            metaKToken(Key, #token("KEY","MetaKSort")),
            metaKList(metaKToken(Vl, #token("TAGList","MetaKSort")),`metaEmptyKList`(.KList)))), S)
    => pp(.K, S +String token2String(Key) +String "(" +String token2String(Vl) +String ")" +String ", ")
  rule pp(metaKApply(#token("nonTerminal","MetaKLabel"),metaKList(metaKToken(Tk,#token("KSort","MetaKSort")),`metaEmptyKList`(.KList))), S)
    => pp(.K, S +String token2String(Tk) +String " ")
  rule pp(metaKApply(#token("terminal","MetaKLabel"),metaKList(metaKToken(Tk, #token("KString","MetaKSort")),`metaEmptyKList`(.KList))), S)
    => pp(.K, S +String token2String(Tk) +String " ")
  rule pp(metaKApply(#token("kProduction","MetaKLabel"), Kl), S)
    => pp(Kl, S)
  rule pp(metaKApply(#token("noKAttributesDeclaration","MetaKLabel"),`metaEmptyKList`(.KList)), S)
    => pp(.K, S +String "\n")

  // pretty printing finished, time to write to file
  rule pp(.K, S) ~> .List
    => #open("tempPrettyPrint.k", "w") ~> S
  rule Fd:Int ~> S:String
    => #write(Fd, S) ~> #close(Fd) ~> #parseString("k-light2k5.sh --output meta-kast tempPrettyPrint.k E", #token("1", "Input"))

endmodule

