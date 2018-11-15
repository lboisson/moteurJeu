/*

Les étapes d'un jeu sont :
-Définir la représentation logique d'un jeu(tableau,liste)
-Gérer l'affichage du jeu
-Gérer les coups autorisés pour un joueur
-Créer le moteur de jeu qui va gérer l'alternance des coups de 2 joueurs humains
-Conception d'un joueur artificiel
-Amélioration des stratégies du joueur artificiel

*/

/*-------------------REPRESENTATION DU JEU------------------*/
:- module(display, []).
% Chiffres et lettres utilisées
succNum(1,2).
succNum(2,3).
succNum(3,4).
succNum(4,5).
succNum(5,6).
succNum(6,7).
succNum(7,8).
succNum(8,9).
succAlpha(a,b).
succAlpha(b,c).
succAlpha(c,d).
succAlpha(d,e).
succAlpha(e,f).
succAlpha(f,g).
succAlpha(g,h).
succAlpha(h,i).

/* Affichage d'un ligne
Paramètre :
- Liste représentant la colonne en cours,
- symbole de la colonne (Modifié récursivement)
Déroulement du prédicat:
- On écrit le symbole
- On met un espace
- On recommence en dépilant la tête et en prenant le successeu du symbole.
*/

afficheLigne([]):- nl.
afficheLigne([H|T]):-write(H),tab(1),write("|"),tab(1),afficheLigne(T).

/* Affichage de la ligne du haut
Paramètre :
- Liste représentant la colonne en cours,
- symbole de la colonne (Modifié récursivement)
Déroulement du prédicat:
- On écrit le symbole
- On met un espace
- On recommence en dépilant la tête et en prenant le successeu du symbole.
*/
afficheAlpha([],_):-nl.
afficheAlpha([_|T],X):- write(X),tab(3),succAlpha(X,Y),afficheAlpha(T,Y).

/* Affichage de la grille
Paramètre :
- Liste représentant la grille,
- Numéro de la ligne (Modifié récursivement)
Déroulement du prédicat:
- On écrit le chiffre à gauche
- On pose la barre verticale
- On affiche la ligne,
- On recommence le prédicat en prenant la queue de la liste et le successeur du chiffre.

La condition d'arret est afficheGrille([],_)
*/


afficheGrille([],_):- nl.
afficheGrille([H|T],X):- write(X),write(" | "),afficheLigne(H),nl,succNum(X,Y),afficheGrille(T,Y).

/* Encapsulation de l'affichage de la grille
Paramètre : Liste représentant la grille
Déroulement du prédicat:
- On met un espace de 4
- On affiche la ligne du haut
- On passe à la ligne
- On affiche le reste de la grille
*/
affichage(L):-tab(4),afficheAlpha(L,a),nl,afficheGrille(L,1).


% ------------------FIN AFFICHAGE---------------------


%------------------ACCÈS GRILLE-----------------------
/*
On cherche si cette ligne existe à cet indice de la grille. Permet aussi de remonter la ligne à un indice précis
Condition d'arret quand le numéro est 1 et que la ligne courante est la ligne recherchée
Paramètre :
- Numéro de la ligne à vérifier (Modifié récursivement)
- Grille
- Ligne à vérifier

On fait déroule les numéros en marche arrière, Si la dernière ligne testée est la bonne, la condition d'arret renvoi true.

*/
ligneDansGrille(1,[Ligne|_],Ligne).
ligneDansGrille(NumLigne,[_|T],Ligne):-
  succNum(LignePrec,NumLigne),ligneDansGrille(LignePrec,T,Ligne).
/*
On cherche si cette case existe à cet indice de la ligne. Permet aussi de remonter la case à un indice précis
Condition d'arret quand le symbole est a et que la case courante est la case recherchée
Paramètre :
- symbole de la case à vérifier (Modifié récursivement)
- Ligne
- Case à vérifier

On fait déroule les numéros en marche arrière, Si la dernière case testée est la bonne, la condition d'arret renvoi true.

*/
caseDansLigne(a,[Case|_],Case).
caseDansLigne(NumCase,[_|T],Case):-
  succAlpha(ColPrec,NumCase),caseDansLigne(ColPrec,T,Case).
/*
Permet de vérifier une valeur à un couple de coordonées ou de retourner cette Valeur
Paramètre :
- Grille a tester
- Numéro de la ligne
- Symbole de la colonne
*/
donneValeurDeCase(Grille,NumColonne,NumLigne,Valeur):-
  ligneDansGrille(NumLigne,Grille,Ligne),caseDansLigne(NumColonne,Ligne,Valeur).
/*
Regarde si une case est vide
Paramètre :
- Grille
- Numéro de la Colonne
- Numéro de la Ligne
Utilise juste donneValeurDeCase en fixant le - du vide
*/
caseVide(Grille,NumColonne,NumLigne):-
  donneValeurdeCase(Grille,NumColonne,NumLigne,-).
