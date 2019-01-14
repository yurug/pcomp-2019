# Correction

 - si le dictionnaire contient exactement le mot a tester,
   cette anagramme n'est pas considere comme tel
 - anagrames pas triees

# Complexite

 Soit n le nombre de mots a tester
 Soit m le nombre de lignes du dictionnaire
 Soit x la taille moyenne des mots a tester

 Complexite => O(m * n * x * log(x))

# Performance

  JVM => glacialement lent

# Robustesse

  - pas de gestion des erreurs des arguments en ligne de commande

# Portabilite

  JVM => pas de soucis

# Lisibilite

  - code un peu trop compact, on etouffe
  - if true then true else false

# Modularite

 - pas assez d'atomicite

# Generalite

 - aucune abstraction, le programme repond specifiquement au probleme

# Extensibilite

 - pauvre, l'algorithmique est effectuee pour moitie dans le main

# Evolutivite

 - avec un main, tout est possible

 
