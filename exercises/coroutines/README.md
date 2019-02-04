# Prérequis

Téléchargez la micro-bibliothèque
[`ocoro`](https://proglang.informatik.uni-freiburg.de/projects/coroutines/ocoro-0.1.tar.gz).

# Exercice

Implémentez:
```
zip    : (unit, α) coro → (unit, β) coro → (unit, α × β) coro
filter : (unit, α) coro → (α → bool) → (unit, α) coro
```

