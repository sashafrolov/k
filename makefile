#define SETENV
#eval $$(opam config env) && . ${HOME}/.cargo/env
#endef

define SETENV
eval $$(opam config env)
endef


.PHONY: like-the-semantics-offline
	$(SETENV) && \
		mvn package \
		-DskipTests -DskipKTest \
		-Dhaskell.backend.skip -Dllvm.backend.skip \
		-Dcheckstyle.skip \
		--offline

.PHONY: like-the-semantics
like-the-semantics:
	$(SETENV) && \
		mvn package \
		-DskipTests -DskipKTest \
		-Dhaskell.backend.skip -Dllvm.backend.skip \
		-Dcheckstyle.skip

.PHONY: all
all:
	$(SETENV) && \
		mvn verify

.PHONY: all-U
all-U:
	$(SETENV) && \
		mvn verify -U

.PHONY: clean
clean:
	mvn clean
