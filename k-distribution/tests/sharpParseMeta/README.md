This definition contains a proposal of how `#parse` should work with K.

Proposal 1:

`#parseString ( <external path to parser>, <token to parse>)`
which takes as input an executable path to an external parser and any token
and returns a string representation of the AST as a K term.
Ex:
`#parseString("k-light2k5.sh --output meta-kast outer-k.k KDefinition", "module TEST endmodule")`
will return:
```
metaKApply(metatoken("kDefinition", "MetaKLabel"), metaKList(
  metaKApply(metatoken("emptyKRequireList", "MetaKLabel"), metaEmptyKList(.KList)),metaKList(metaKApply(metatoken("kModuleList", "MetaKLabel"), metaKList(metaKApply(metatoken("emptyKModuleList", "MetaKLabel"), metaEmptyKList(.KList)),metaKList(
   metaKApply(metatoken("kModule", "MetaKLabel"), metaKList(metaKToken(metatoken("TEST", "MetaValue"), metatoken("KModuleName", "MetaKSort")),metaKList(metaKApply(metatoken("noKAttributesDeclaration", "MetaKLabel"), metaEmptyKList(.KList)),metaKList(
   metaKApply(metatoken("emptyKImportList", "MetaKLabel"), metaEmptyKList(.KList)),metaKList(
   metaKApply(metatoken("emptyKSentenceList", "MetaKLabel"), metaEmptyKList(.KList)),metaEmptyKList(.KList)))))),metaEmptyKList(.KList)))),metaEmptyKList(.KList))))
```

Proposal 2:

Implement `#parse` using more basic operations like `#write` which writes a String to a file and 
`#system` which calls an external command line and returns a term `#systemResult(<exit-code>, <stdout>, <stderr>)`.
After that `#parseKore` ca be called on `<stdout>` to create a term.

The user will be exposed to the same functionality:
`parseWithProds (listOfProductions:List, startSymbol:String, input:String) -> KAST`
which takes the list of productions and pretty prints them to a format accepted by the external parser.
Then saves it to a file and calls the external parser for that grammar file, start symbol and input.

The implementation can be found in the `java-backend:org.kframework.backend.java.builtins.BuiltinIOOperations`
and `/include/ocaml/hooks.ml` for ocaml.

`k-light2k5.sh` is a script that calls the K-Light parser. This is the same parser used in K4,
but taken out of the K repository along with all the K references.
Note that the K5 parser is the same, but with some performance improvements. Most notably it
has a scanner (flex), but this also means that it is not scannerless, a property which
is needed when parsing rules as bubbles.

Requirements:
https://github.com/radumereuta/k-light/tree/evenLighter
and k-light/bin to be in the PATH

Usage:
`kompile test.k` for ocaml (or `--backend-java`) (sometimes `-v --debug` can be useful)
`krun imp.k` (sometimes `--output kast` can be useful)

