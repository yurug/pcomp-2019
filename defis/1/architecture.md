# Architecture
## Structures des données 
- structure de données du tableur (abstraite)
- graphe des dépendances : pour savoir quelle évaluation de formule change sur maj d'une case
- file avec les mises à jour effectué 
## Algo général
1. Lecture des données :
  - Initialisation du tableur + graphe des dépendances
  - Evaluation des formules (paradoxes si changement)
  - Enregistrement du tableur dans view0
2. Pour chaque action d'utilisateur
  - Si c'est une valeur : 
	  + appliquer graphe des dépendances pour réévaluer les formules altérées 
      + enregistrer les changements dans la file
  - Si c'est une formule
      ( La modif utilisateur prévaut sur l'état précédent :
	   + modifier le graphe des dépendances 
	   + évaluation des cases dépendantes (paradoxes si changement)
	  OU 
	   L'état précédent prévaut
	  + évaluation de la case modifiée 
      + modifier le graphe des dépendances
	  + évaluation des cases dépendantes (paradoxes si changement))
	  + enregistrer les changements
3. Enregistrer la file de changements dans changes.txt
  
## Difficultés (à réfléchir)
- complexité graphe de dépendances (parcours, changement etc ...) 
- résolution paradoxe 
- modification des formules (cf algo)

## Résolution des paradoxes
### Ordre de résolution
Question : si plusieurs solutions laquelle choisir ?

### Cas simples (solvables à priori) 
1. graphe dépendance en forêts d'arbres
2. cas de dépendance simple (à définir)

### Si on ne sait pas résoudre 
P dans chaque case concernée 

