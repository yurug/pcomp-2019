# Commentaires généraux sur l'algo
* compare l'occurence des caractères
# Correction : 
* ca marche
* Marche sur un dico non trié 
# Complexité pour mot: 
* nombre de mot du dict = M 
* taille du mot référence = N 
* taille du plus long mot du dict = T
complexité <= O (N2 * M + T * M ) (si méthode length linéaire)
* Optimisation 1 : ne teste que les mots de bonne longueur
* Optimisation 2 : arrête la comparaison au premier caractère différent
* Quadratique en N : à cause de count
* Autre limite : le mot ne décroit pas à chaque itération
# Performance :
./anagram ../american-english eat
-> plus de 1 s
* Problème : lit le dictionnaire à chaque mot testé + à chaque mot référence
# Robustesse :
* Ne plante pas si entrée invalide
* Mais : pas de message d'erreur
# Portabilité :
* Scala = ok (machine virtuelle java)
# Lisibilité :
* Nom des fonctions (relativement) bien choisi
* Concis
# Modularité :
* Non : très spécifique à l'exercice
* Pas de fonction de lecture du dictionnaire
* La fonction print appelle la fonction qui cherche les anagrammes !
# Généralité :
* ?
# Extensivité :
* Probablement, le code est concis
* Mais : code non modularisé
* Mais : la fonction print en fait plus que attendue
# Evolutivité :
* Vu la longueur du code, autant le réécrire
