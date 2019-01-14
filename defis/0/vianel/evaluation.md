Vincent Bonnevalle

# Correction
## Définition
Le programme est conforme à la spécification

## Évaluation

Il n'y a pas de `makefile` pour compiler le programme.

Le programme ne prend pas les bons paramètre en ligne de commande.

Par exemple, l'appel suivant
```
g++ anagrame/main.cpp
./a.out ../american-english tide dog
```

produit

```
manoir
```

# Complexité
## Définition
La complexité algorithmique du programme est proche de la meilleur complexité algorithmique
de l'algorithme résolvant le problème.

## Évaluation
La complexité du programme est en *O(n² . log(n))* (en supposant que le tri à une complexité en *O(n . log(n)))*.


# Performance
## Définition


## Évaluation


# Robustesse
## Définition
Le programme peut se remettre d'une erreur ou s'arrêter avec un message d'erreur utile et
en libérant les ressources allouées.

## Évaluation
Le programme affiche un message d'erreur explicite lorsque le fichier n'a pas pût être ouvert.

# Portabilité
## Définition
Le programme peut être compilé et exécuté sur différents environnements sans être modifié.

## Évaluation
Ce programme peut être compiler sans modification dans tout environnement possédant un compilateur C++.

# Lisibilité
## Définition
Le code respecte les règles de bonne pratique du langage.
Le code est découpé en fonctions courtes.
Le code suit une convention de nommage cohérente dans tout le code.
Le code n'est pas inutilement trop verbeux ou trop concis.

## Évaluation
Le code est bien découpé en fonction courte.

# Modularité
## Définition
Le programme est découpé en modules. Ces modules doivent être indépendants entre eux

## Évaluation

# Généralité
## Définition

## Évaluation

# Extensibilité
## Définition
Il est possible de rajouter des fonctionnalités sans modifier l'architecture du programme.

## Évaluation

# Évolutivité
## Définition
Il est possible de modifier le code pour la maintenir, le déboguer, l'optimiser sans modifier l'architecture du programme.

## Évaluation
