# Défi 1 : un moteur de tableur minimaliste

On doit pouvoir lancer les commandes suivantes :

``` shell
cd votre-nom-de-groupe
make mrproper
make
./ws data.csv user.txt view0.csv changes.txt
```

## Entrées :
- un fichier `data.csv` (avec `;` pour séparateur) qui contient deux
  types de données :
  + *(a)* des entiers compris entre 0 et 255 ;
  + *(b)* des formules de la forme :

        =#(r1, c1, r2, c2, v)

    qui s’évaluent en le nombre d’occurrences de la valeur *v* parmi
    les cellules de coordonnées

        { (r, c) | r1 ≤ r ≤ r2 ∧ c1 ≤ c ≤ c2 }

    (Note: les coordonnées débutent à zéro.)

- un fichier `user.txt` qui contient sur chaque ligne une commande de
  la forme :

      r c d

  où *r* et *c* sont des entiers et *d* est soit une valeur du type
  *(a)* ou *(b)* précédent.

## Sorties :
- un fichier `view0.csv` qui contient l’évaluation initiale de la
  feuille de calcul. Il contient donc uniquement des entiers tels
  que :
  + les cellules qui contenaient des entiers contiennent les mêmes
    entiers ; et
  + les cellules qui contenaient des formules contiennent maintenant
    l’évaluation de ces formules. Les cellules de formules mal formées
    devront contenir `P`.

  `view0.csv` correspond à l’évaluation de `data.csv` avant les
  actions de `user.txt`.

- un fichier `changes.txt` de la forme :

      after "r c d":
      r0 c0 v0
      r1 c1 v1
      …
      rN cN vN

  Pour chaque ligne `r c d` du fichier `user.txt` initial et tel que
  `rI cI vI` indique qu’après l’exécution de la commande `r c d` la
  valeur de la cellule à la *rI*-ième ligne et la *cI*-ième colonne
  vaut l’entier *vI*.

  En d’autres termes, `changes.txt` indique comment mettre à jour les
  données de `view0.csv` après les commandes décrites dans `user.txt`.

  La séquence de `rI cI vI` sera classée par ordre lexicographique.
  (Les premières lignes en premier, et à ligne constante, les
  premières colonnes en premier.)
