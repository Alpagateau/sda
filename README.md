
# Jeux SDA 2026

Dans ce jeu, une oeuvre d'art sera présentée chaque jour (ou demi journée). L'objectif du joueur est de deviner la date de création de cette oeuvre en un nombre de coup limité. 
A chaque coup, le jeu indiquera si la date donnée est trop tot ou trop tard. 
Quand le joueur trouve la bonne année (a une marge près pour les oeuvres ancienne ex. paintures rupestres), un nombre de points est attribué en fonction du nombres de coups utilisés. 

# Front End

- Moteur : Godot 4.6
- DA : Voir avec Loïc
- Export : WebGL

Le front-end peut se diviser en plusieurs states : Loading, Guessing, Lost, Won

## Loading

C'est dans cet état que le jeu commence. C'est ici qu'une requette est faite au server pour obtenir l'oeuvre du jour, ainsi que les données liées au joueuer (streak, name etc..)
Le nom du jeu est visible, et un bouton "Jouer" ou "Commencer" permet d'acceder a l'étape Guessing. Un autre bouton permet d'afficher les règles du jeu. 

Si le joueur a déjà joué aujourd'hui, on accède directement aux état Lost ou Win en fonction. 

## Guessing

C'est l'état principal du jeu. Dans celui-ci, une image de l'oeuvre du jour est visible, accompagnée du nombre d'essaies restants. 
On a aussi une frise chronologique sur laquelle figure les dates essentielles (ex : Chaque siècle), et une entrée de texte pour donner la date, avec un bonton "Guess" ou "Dater". 
Appuyer sur entrer dans la zone de texte valide aussi l'éssaie. 
Une fois une date donnée, le jeu verifie avec la date de l'oeuvre et place un pin a la date donnée, surlignant du meme temps la zone possible ou se trouve l'oeuvre. 
En d'autre mots, si la date est antèrieure a l'oeuvre, un pin est placé, et toute la frise entre ce pin et le premier pin postèrieur a l'oeuvre est coloré. 
Idem pour si la date est posterieur a l'oeuvre. 

>Error Handling
>Si le texte dans la zone texte ne peut pas etre parsé, on vide la zone de text, un message d'erreur est affiché et le nombre d'essaies n'est pas décompté. 

Le nombre d'essaie est alors décrementer.

Si la date donnée est dans un rayon acceptable, le jeu passe en état Won
Si il n'y as plus d'essaie, le jeu passe en état Lost

## Won

Ici, on affiche une popup indiquant que le joueur a gagné, avec la date exacte et l'oeuvre nommée. On incrémente sa streak et son nombre de réussite total. 
(Si possible) On peut lui proposer de partager son score sur les réseaux en préparant un message par defaut. 

Un text affichant le temps avant la prochaine oeuvre est visible. 

## Lost

Cet état est très similaire a Won. Les différences sont les suivantes. Le message indique que le joueur a perdu. Le total de victoire n'est pas incrémenté, et le streak est remis a zéro. 

# Important

Ce jeu sera hébergé sur le site du BDA, et va donc devoir être responsive. Il est important de créer le UI de tel façon a ce qu'il soit lisible sur PC comme sur téléphone et tablette. 
Il est aussi important donc que l'interface soit utilisable aux clavier-souris et en tactile. 

Quelle que soit le nombre d'oeuvre par jour, le mieux serait d'en préparer un maximum, pour pouvoir ralonger la durée de vie du jeu si nécessaire. 

# Details 

Pour le développement, on utilisera un petit server local pour gerer les requettes HTTP. Dans les faits, ce server sera géré par le pôle web, mais on va commencer le developpement avant celui ci. 
Il est donc important de mettre en forme l'API que l'on va utiliser, pour que le pôle web puisse l'implémenter simplement. 
On considère aussi que toute personne jouant a ce jeu s'est déjà connectée avec son CAS. Cette partie là est déjà mise en place sur le site du BDA. 
