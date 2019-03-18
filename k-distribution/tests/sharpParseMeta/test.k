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

module FILE-UTIL
  imports K-IO
  imports DOMAINS
  // saveToFile(path:String, contents:String) -> .K
  syntax KItem ::= saveToFile(String, String)

  syntax KItem ::= callWriteToFile(String)
                 | callCloseFile(Int)
  rule saveToFile(Path, S)
    => #open(Path, "w") ~> callWriteToFile(S)
  rule Fd:Int ~> callWriteToFile(S)
    => #write(Fd, S) ~> callCloseFile(Fd)
  rule callCloseFile(Fd)
    => #close(Fd)
endmodule

module EXTERNAL-PARSE
  imports K-IO
  imports LIST
  imports DOMAINS
  imports META
  imports FILE-UTIL
  // externalParse(cmd:String, input:String) -> KAST
  syntax KItem ::= externalParse(String, String)
                 | parseResult(K)
  syntax KItem ::= callSystem ( K )
                 | makeTempFile (String, String)
                 | "callParseAST"
                 | "callParseResult"
                 | deleteTempFile(String)
  rule externalParse(Path, S)
    => #tempFilename("", ".k") ~> makeTempFile(Path, S)
  rule Fname:String ~> makeTempFile(Path, S)
    => saveToFile(Fname, S) ~> callSystem(Path +String " " +String Fname) ~> deleteTempFile(Fname)
  rule callSystem(Path)
    => #system(Path) ~> callParseAST
  rule #systemResult(0, Stdout, _) ~> callParseAST => #parseAST(Stdout) ~> callParseResult
  rule Term:KItem ~> callParseResult => parseResult(Term)
  rule parseResult(Term) ~> deleteTempFile(Fname) => #remove(Fname) ~> parseResult(Term)
  
  // meta AST declarations
  syntax MetaKLabel
  syntax MetaValue
  syntax MetaKSort
  syntax MetaK ::= MetaKLabel | MetaValue | MetaKSort
                 | metaKApply (K, K)
                 | metaKToken (K, K)
                 | metaKList  (K, K)
                 | metaEmptyKList (K)
endmodule

module SHARP-PARSE
  imports EXTERNAL-PARSE
  
  // parseWithProds (listOfProductions:List, startSymbol:String, input:String) -> KAST
  syntax KItem ::= parseWithProds(List, String, String)

  syntax String ::= token2String ( K )    [function, functional, hook(STRING.token2string)] // TODO: move this in domains.k somewhere

  // generate grammar
  syntax K ::= pp(K, String) // pretty print
  rule parseWithProds(L, Start, Input) => pp(.K, "module TEMPPRETTYPRINT\n") ~> L ListItem("endmodule\n") ~> Start ~> Input
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
  syntax KItem ::= callParse(String, String, String)
  rule pp(.K, S) ~> .List ~> Start:String ~> Input:String
    => #tempFilename("grm", ".k") ~> callParse(S, Start, Input)
  rule Fname:String ~> callParse(S, Start, Input)
    => saveToFile(Fname, S)
    ~> externalParse("k-light2k5.sh --output meta-kast --module TEMPPRETTYPRINT " +String Fname +String " " +String Start, Input)
    ~> deleteTempFile(Fname)

endmodule

module TEST
  imports COMMONS
  imports K-IO
  imports LIST
  imports ID-SYNTAX
  imports DOMAINS
  imports META
  imports EXTERNAL-PARSE
  imports SHARP-PARSE

  configuration <k> $PGM:Any </k>

  // take the input given as argument and run outer parsing to get the syntax AST
  rule S:Any => outerParse(token2String(S)) ~> eP(.K, .K, .List)

  syntax KItem ::= outerParse(K)
  rule outerParse(S) => externalParse("k-light2k5.sh --output meta-kast outer-k.k KDefinition", S)
  rule parseResult(Term) ~> eP(.K, .K, .List) => eP(Term, .K, .List)

  // collect productions from anywhere in the AST and put them in a List
  syntax KItem ::= eP(K, K, List) // extractProduction
  syntax KItem ::= prods(K, List) // productions collector
  //rule eP(metaKApply(Tk, Kl),     Srt, L) => eP(Kl, Srt, L) [owise] // generic descent
  rule eP(metaKList(T1, T2),      Srt, L) => eP(T1, Srt, L) ~> T2 // generically visiting every child
  rule eP(`metaEmptyKList`(.KList), Srt, L) => prods(Srt, L)
  rule eP(metaKToken(_, _),       Srt, L) => prods(Srt, L)
  rule prods(Srt, L) ~> T:KItem          => eP(T, Srt, L)
  
  // TODO: adding these instead of one `owise` rule because it doesn't work in the java-backend :(
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

  // parse with the collected productions
  rule <k> prods(_, L) => parseWithProds(L, "E", "1+2") </k>
endmodule

