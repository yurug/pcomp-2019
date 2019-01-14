Hugo

# Correction

## Définition

Le programme passe-t-il un jeu de tests vérifiant la correction ?

## Jeu de tests

Pour l'instant... un singleton.
Le programme renvoie-t-il un résultat correct quand on exécute la commande suivante :
java Anagram ../american-english dog tide line boss teacher hello sister father glass water

## Résultat

OK

# Complexité

## Définition

En toute rigueur, la manière d'évaluer la complexité devrait dépendre de celle de l'algorithme optimal. Sans l'avoir sous la main, on va l'évaluer en se demandant s'il existe un algorithme plus optimal.

## Existe-t-il un algorithme plus optimal ?

Il est possible de ne pas trier le fichier d'entrée (qui ne change pas) pour chaque paramètre.

## Résultat

KO

# Performance

Je ne sais pas évaluer la performance sans spécification de performances.

# Robustesse

## Définition

Ne "crashe" jamais.

## Jeu de tests

Un singleton : java Anagram abbb line, où abbb n'existe pas.

## Sortie

FileNotFoundException non rattrapée

## Résultat

KO

# Portabilité

## Définition

Y a-t-il dans le code des éléments qui le rendent dépendant d'une machine en particulier ?

## Résultat

OK

# Lisibilité

## Taille des fonctions < 10 lignes

Plus grosse fonction, le main, 32 lignes : KO

## Niveau d'indentation max < 5

Niveau d'indentation max, 6 : KO

## Nommage clair

Le nom des variables et des fonctions est clair : OK

# Modularité

## Définition

Au sens faible, chaque fonctionnalité est séparée dans le code (encapsulée dans une méthode ou une classe) ; au sens fort, chaque fonctionnalité est utilisable hors de ce programme particulier.

## Critère employé ici

Sens faible... La lecture dans un fichier n'est pas séparée du reste du main.

## Résultat

KO

# Généralité

## Définition

Le programme est-il généralisable à l'usage d'autres types de base (que les strings) ? Et donc permet-il de généraliser les "propriétés d'anagrammie", par exemple à des listes d'entiers ?

## Critère en Java

L'usage de la généricité, le type des fonctions n'étant fixé qu'à un endroit du code.

## Résultat

KO

# Extensibilité

## Définition

On peut étendre le programme sans réécrire le code existant.

## Critère dans un langage objet comme java

On peut étendre les fonctionnalités du programme en héritant/composant.
Ici, toutes les méthodes sont statiques.

## Résultat

KO

# Évolutivité