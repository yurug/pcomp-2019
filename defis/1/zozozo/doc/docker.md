# Docker

Docker est un système de *containers* (comprendre : des machines
virtuelles légères pour Linux). On commence par créer une *image* du
système que l’on souhaite exécuter. On peut ensuite lancer un
*container* (conteneur) qui exécute l’image.

Chaque nouveau conteneur démarre avec l’image d’origine. Un conteneur
stoppé peut être relancé depuis son état d’arrêt. Une image peut être
mise à jour à l’état d’un conteneur. Créer une image peut être long,
Docker produit des instantanés pour accélérer le processus de
re-création.

Les images et les conteneurs sont identifiés par des tags ou des id.

L’image est un système Arch Linux à jour, dans lequel opam a été
installé avec les paquets nécessaires au fonctionnement du projet. Le
repo a été cloné mais n’est pas forcément à jour. Le nom de
l’utilisateur est `zozozo`.

Toutes les commandes Docker doivent être exécutées en mode root.

## Intallation

1. Installer Docker sur votre machine.\
   `sudo apt-get install docker`
2. Lancer le daemon.\
   `sudo systemctl start docker.service`
3. Contruire l’image.\
   `sudo docker build --tag=zozozo .`

## Utilisation
1. Lancer un conteneur. Vous obtenez un shell qui s’exécute dans le
   conteneur.\
   `sudo docker run -it zozozo bash`
2. Mettre à jour le repo git (éventuellement).\
   `git pull`
3. Compiler le projet.\
   `make`
4. S’enjailler.\
   `./ws <data.csv> <user.txt> <view0.csv> <changes.txt>`
5. Relancer un conteneur.\
   `sudo docker restart <container>`
6. Attacher un nouveau shell à un conteneur en cours d’exécution.\
   `sudo docker exec -it <container> /bin/bash`.
7. Voir la liste des images.\
   `sudo docker images`.
8. Voir la liste des conteneurs.\
   `sudo docker container ls --all`
9. Stopper le daemon.\
   `sudo systemctl stop docker.service`
