1. Créer un répertoire de votre nom "yoda".
2. On doit pouvoir lancer l'exécution de:
``
cd yoda
make
/usr/bin/time ./anagram mydict foo bar baz
``
et cela doit produire:
``
foo:
ofo
oof
bar:
arb
bar
bra
baz:
``
sur la sortie standard, sachant que mydict est un fichier
qui contient un mot par ligne et un mot apparaît au plus
une fois. Par exemple:
``
off
bra
oof
ofo
arb
bar
tro
fofofo
qwe
``

Rappel: Le mot w est un anagramme de u si on peut réordonner
les lettres de w pour obtenir u.

Notez que les anagrammes sont classés dans l'ordre alphabétique.
