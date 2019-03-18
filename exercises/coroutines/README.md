# Prérequis

Téléchargez la micro-bibliothèque
[`ocoro`](https://proglang.informatik.uni-freiburg.de/projects/coroutines/ocoro-0.1.tar.gz).

Téléchargez la micro-bibliothèque
[`ocaml-callcc`](https://xavierleroy.org/software/ocaml-callcc-1.0.tar.gz).
(Pour l'installer, il faut ocaml 4.02.3.)

# Exercice

Implémentez:
```
zip    : (unit, α) coro → (unit, β) coro → (unit, α × β) coro
filter : (unit, α) coro → (α → bool) → (unit, α) coro
```

