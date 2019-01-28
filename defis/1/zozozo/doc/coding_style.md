# Coding style
## Nommage
1. Général
 - en anglais

2. Module
 - Majuscule pour chaque début de mot
   ex : ModuleToDoThings
 - nom descriptif

3. Fonctions principales (qui apparaissent dans le .mli)
   - nom descriptif
   - tout en minuscule
   - mots séparés par des _
   ex : function_that_does_things

3. Fonctions auxiliaires : Cas recursion avec acc
   - si fonction récursive avec accumulateur : nom de la fonction principale +_
   ex :
   let rec my_function_ l acc = ...
   let my_function l = my_function_ l []

4. Fonctions secondaires (pas dans le .mli mais utilisé dans une ou
   plusieurs fonctions principales)
   - nom descriptif mais court
   - tout en minuscule
   - mots séparés par des _
   - fonctionnalités claires et uniques
   - (probablement que des fonctions très courtes)

5. Variables
   - nom descriptif
   - tout en minuscule
   - mots séparés par des _ mais idéalement un unique mot
   - Convention :
	 acc = accumulateur,
	 l = liste ,
	 n, m i j = entier
	 r = row,
	 c = column
	 g = graph
  -

6. ADT et GADT :
 - nom : minuscule
 - Constructeur : majuscule pour chaque début de mot
   ex :
   type term =
   | Var of string
   | Lambda of term
   | App of term*term


6. Exception
 - Majuscule pour chaque début de mot
   ex : NotWhatYouShouldDo
 - nom descriptif

## Style
1. Mli ?

2. Fonctions auxiliaires : Cas recursion avec acc ou similaire
   ex :
   let rec my_function_ l acc = ...
   let my_function l = my_function_ l []

	à éviter (?) :
   let my_function l =
	   let rec my_function_ l acc = ...  in
	   my_function_ l []

   La fonction auxilaire doit être directement au dessus de la
   fonction qui l'utilise

## Commentaires vs Doc

*
