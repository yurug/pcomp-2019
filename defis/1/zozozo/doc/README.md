# Lancer des tests
Dans le dossier zozozo,
- make
- ./tests/tests (make test ne fonctionne pas pour l'instant)
- dans les dossiers de tests, comparez (attendus vs générés):
  * result.csv avec view0.csv
  * chg.txt avec changes.txt
  * view_final.csv donne le tableur avec tous les changements de
    "user.txt"

# Tests en top level
## Packets nécessaires
- utop (opam install utop)

## Manipulation
1. Ouvrir 'src/top\_level\_test.ml' avec emacs

2. Faire C-c C-e sur la première ligne.
Dans la ligne de commande emacs, remplacer "ocaml" par "dune utop".

3. Exécuter (C-c C-e) la ligne suivante

## Notes

a. Tous les modules du projet sont préchargées.

Ex : Pour appeler la fonction 'add\_node' du module 'Graph' il suffit
de taper 'Graph.add\_node' ou de faire 'open Graph' préalablement.

b. Le top level ne permet pas d'utiliser le typeur de merlin (C-c C-t)
ou l'autocomplétion, il est donc préférable d'écrire son test dans le
fichier 'top\_level\_test.ml' et d'exécuter (C-c C-e) les lignes dans
le top level ensuite.
