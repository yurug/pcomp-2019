*ACHAHOUR Hamza*

Correction : le code respect la specification
	->ca marche mais il prend les doublons en sortie

Complexité : N*(M*log(M)+F*log(F))

Performance : faire des test avec des fichiers de grand taille 
   -> mydict 52 oct
   	real	0m0.071s
	user	0m0.060s
	sys		0m0.008s
   -> mydict0 1.3 ko
    real	0m0.084s
	user	0m0.076s
	sys		0m0.004s
	->mydict1 4.1Mo
	real	0m10.565s
	user	0m8.012s
	sys		0m2.516s
	-> ouverture de fichier pour chaque mot

Robustesse :  

Portabilité : oui 

Lisibilité : oui car c est un petit programme bien lisible

Modularité : oui et non

Généralité : non le code utilise le nom de fichier dans le code et aussi le Makefile deja defini par foo et bar 

Extensibilité : possible de rajouté d autre extension mais 
Evolutivité : non c est une fonction qui fait un tache précise