DEF=imp
EXT=imp
KOMPILE_FLAGS=--transition "division lookup increment assignment read print"
KOMPILE_BACKEND?=java
KRUN_FLAGS=--output none

include ../../../find-k.mak
include ${K_HOME}/include/kframework/ktest.mak


tests/div.imp: kompile
	cat $@.in 2>/dev/null | $(KRUN_OR_LEGACY) $@ -d $(DEFDIR) --search $(CHECK) $@.out

tests/spawn.imp: kompile
	cat $@.in 2>/dev/null | $(KRUN_OR_LEGACY) $@ -d $(DEFDIR) --search --pattern "<store> Store </store> <output> ListItem(_) ListItem(_) ListItem(#buffer(Out:String)) </output>" $(CHECK) $@.out
