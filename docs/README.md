# Programmation Comparée -- 2019

Le cours "Programmation Comparée" du Master 2 "Langages et
Programmation" de l'Université Paris Diderot est animé par Adrien
Guatto et Yann Régis-Gianas. Ce dépôt git contient les ressources
utilisées en cours et créés par les enseignants et leurs étudiants.
Sauf mention spécifique, l'ensemble des fichiers de ce dépôt est
diffusé sous licence Creative Commons [CC
BY-NC-ND](https://creativecommons.org/licenses/by-nc-nd/4.0/legalcode).

## Motivations

### La diversité des langages

Il existe plusieurs [*milliers* de langages de
programmation](http://codelani.com/posts/how-many-programming-languages-are-there-in-the-world.html)
dont plusieurs centaines sont activement utilisés
aujourd'hui. Qu'est-ce qui peut expliquer une telle diversité? Est-ce
que cette diversité a des raisons théoriques et pratiques profondes ou
bien traduit-elle un phénonème de [Tour de
Babel](http://www.philophil.com/philosophie/echange/analyses/linguistique/Babel.htm),
i.e. l'incapacité des hommes à construire ensemble un langage
universel (de programmation)?

🤔 Quelles sont les raisons de cette grande diversité des langages selon vous?

### La diversité des styles

Non seulement il existe de nombreux langages pour écrire les
programmes mais même si on se fixe un langage de programmation,
il y a une infinité de façon de l'utiliser pour écrire le
code source d'un programme. Parmi tous les programmes exprimables
dans un langage, y-a-t-il des codes sources "meilleurs" que
d'autres? Sur quels critères évaluer un code source? Qu'est-ce
qui influence, consciemment ou inconsciemment, le choix d'un
style de programmation plutôt que d'un autre? C'est une vaste
question, similaire à celle posée par la
[littérature comparée](https://fr.wikipedia.org/wiki/Litt%C3%A9rature_compar%C3%A9e)
dont est tiré le titre de ce cours.

🤔 Et vous, en tant que programmeur, qu'est-ce qui vous fait choisir un langage
ou un style de programmation plutôt qu'un autre lorsque vous commencez un nouveau
projet?

### La question de ce cours

> Comment un développeur doit-il se positionner vis-à-vis de cette pluralité des styles de programmation?

C'est la question que pose ce cours et à laquelle nous allons essayer de répondre.

#### Est-ce une question pertinente pour un développeur?

Cette question n'est-elle pas purement académique? Pourquoi
devrait-elle intéresser tout développeur? Dans la plupart des cas, un
développeur intègre un projet déjà existant dont le langage de
programmation a déjà été déterminé, il n'a qu'à l'utiliser! Plus
généralement, pourquoi s'intéresser à d'autres langages de
programmation que C, Java, Python, VB, C++, C#, Javascript, PHP, SQL
et Objective-C qui en 2018 représentaient à eux seuls 60% des langages
les plus "populaires" (d'après l'[index
TIOBE](https://www.tiobe.com/tiobe-index/))? De même, pourquoi
s'intéresser à d'autres paradigmes que ceux de la programmation
procédurale et de la programmation orientée objet alors qu'ils
semblent s'être imposées depuis plusieurs décennies dans l'industrie du
logiciel?

🤔 Vous en connaissez vous, d'autres
[paradigmes](https://fr.wikipedia.org/wiki/Paradigme) de
programmation? Ce n'est pas un peu grandiloquent ce terme
de "paradigme"? L'[hypothèse de Sapir-Whorf](https://fr.wikipedia.org/wiki/Hypoth%C3%A8se_de_Sapir-Whorf) prétend que non!

##### L'évolution des langages de programmation

[L'histoire des langages de
programmation](https://en.wikipedia.org/wiki/History_of_programming_languages)
montre qu'en 70 ans, un grand nombre d'approches et de langages se
sont succédés : FORTRAN, ALGOL, COBOL et LISP ont été les Java, Python
ou Javascript de leurs époques mais sont aujourd'hui dépassés en
popularité par ces derniers. Est-ce seulement parce que ces langages
sont démodés qu'ils ne sont plus tant utilisés? Est-ce qu'ils ont
toujours été remplacés par des langages ayant véritablement de
meilleures propriétés? Est-ce que le remplacement des langages de
programmation suit une forme de rationalité? Dans tous les cas,
l'histoire a tendance à se reproduire et Java, Python et Javascript
seront probablement remplacés par de nouveaux langages de
programmation dans les années à venir. Dès lors, il est essentiel de
savoir apprendre un nouveau langage de programmation.

Face à un nouveau langage, il faut réussir à distinguer ce que le
langage hérite de ses prédécesseurs et ce qu'il apporte de
véritablement nouveau. Cette tâche peut se révéler ardue si on ne sait
pas naviguer dans l'océan des milliers de langages de programmation
existants à ce jour.

##### Le style de programmation

S'intéresser aux différentes approches et styles de programmation
permet d'élargir son champ de pensée et de conception. Cela permet
de ne pas se trouver démuni face à du code écrit par une autre
personne ou par soi-même:

> "Any code of your own that you haven't looked at for six or more months might as well have been written by someone else."
> - Eagleson's law

#### Peut-on vraiment répondre à cette question?

Cette question admet-elle des réponses "scientifiques"? Sans aucun
doute!  Dans ce cours, nous verrons que l'on peut se doter d'une
 méthodologie rigoureuse  pour évaluer un code source ou plus
généralement la pertinence d'une approche de programmation pour
résoudre un problème fixé.

Les critères d'évaluation sont multiples et complexes : ils peuvent
être qualitatifs ou quantitatifs, s'appuyer sur des résultats
théoriques et formels ou sur des modèles construits de façon
empirique. Dans tous les cas, le positionnement du programmeur
vis-à-vis des approches et techniques de programmation est le résultat
d'un compromis visant à maximiser des mesures, parfois difficilement
conciliables. Une approche rigoureuse permet de retracer le raisonnement
qui a mené à ces choix.

## Objectifs

- Comprendre et comparer les différentes approches de la programmation
- Apprendre à communiquer avec le code et sur le code

## Méthodes

- Étude de l'Histoire et de la théorie des langages de programmation
- Expériences de communication autour du code
- Cours orienté "défis"

## Thèmes abordés

La liste suivante est indicative et évoluera:

- La qualité d'un code source
- De la crise du logiciel à la révolution de la programmation fonctionnelle
- "Programming-in-the-large"
- L'art de la programmation (lettrée, dirigée par les tests, par les types, "live", ...)
- L'optimisation des programmes séquentiels
- Programmation à grande échelle

## Validation

- Contrôle continu:
  - Exposé de groupe sur une approche de programmation
  - Exposé individuel sur un langage de programmation "inconnu"
  - Défis
- Examen final


