/* Deshayes Léonhard - M1 Informatique */

/*
Si l'on veut modifier le jeu 3x3 en un 4x4, on doit modifier tous les prédicats qui ne sont pas pas généraux.
- Exemples :
Modification :
afficheLigne([A,B,C]) :-
	write(A), tab(3),
	write(B), tab(3),
	write(C), tab(3).

Ajout de :
succNum(2,3).
succAlpha(b,c).
*/

/*
Étapes de conception d'un jeu :
- Gestion d'un plateau de jeu ( création / affichage )
- Ensemble de règles spécifiques au jeu en question
- Gestion des coups ( jouer dans le plateau / décider d'un coup par rapport à un autre )
- Vérifier l'état de la partie ( en cours / gagnée par X / perdue par X )
- Moteur qui lie tous les éléments nécessaires
*/

/* - - - - - Gestion du plateau - - - - - */

% Predicat : afficheLigne/1
/*
Affiche la ligne passée en argument sous la forme.
?- afficheLigne([o,-,x]).
o   -   x
*/
afficheLigne([A,B,C]) :-
	write(A), tab(3),
	write(B), tab(3),
	write(C), tab(3).


% Predicat : afficheGrille/1
/*
Affiche la grille passée en argument.
?- afficheGrille([[x,x,-],[x,-,o],[-,-,o]]).
x   x   -
x   -   o
-   -   o
*/
afficheGrille([[A1,B1,C1],[A2,B2,C2],[A3,B3,C3]]) :-
	afficheLigne([A1,B1,C1]), nl,
	afficheLigne([A2,B2,C2]), nl,
	afficheLigne([A3,B3,C3]).


% Predicat : succNum/2
/*
Lien entre les numéros de lignes.
?- succNum(1,X).
X = 2.
*/
succNum(1,2).
succNum(2,3).


% Predicat : succAlpha/2
/*
Lien entre les numéros de colonnes.
?- succAlpha(X,b).
X = a.
*/
succAlpha(a,b).
succAlpha(b,c).


% Predicat : ligneDeGrille(NumLigne, Grille, Ligne).
% Satisfait si Ligne est la ligne numero NumLigne dans la Grille
/*
?- ligneDeGrille(3, [[x,x,-],[x,-,o],[-,-,o]],[-,-,o]).
true .

?- ligneDeGrille(2, [[x,x,-],[x,-,o],[-,-,o]],[x,x,-]).
false.
*/
ligneDeGrille(1, [Test |_], Test).
ligneDeGrille(NumLigne, [_|Reste],Test) :- succNum(I, NumLigne),
		ligneDeGrille(I,Reste,Test).


% Predicat : caseDeLigne(Col, Liste, Valeur).
% Satisfait si Valeur est dans la colonne Col de la Liste
/*
?- caseDeLigne(a, [x,x,-],x).
true .

?- caseDeLigne(b, [x,-,-],o).
false.
*/
caseDeLigne(a, [A|_],A).
caseDeLigne(Col, [_|Reste],Test) :- succAlpha(I, Col),caseDeLigne(I,Reste, Test).


% Predicat : caseDeGrille(NumCol, NumLigne, Grille, Case).
% Satisfait si Case est la case de la Grille en position NumCol-NumLigne
/*
?- caseDeGrille(a,3,[[x,x,-],[x,-,o],[-,-,o]],-).
true .

?- caseDeGrille(a,3,[[x,x,-],[x,-,o],[-,-,o]],a).
false.
*/
caseDeGrille(C,L,G, Elt) :- ligneDeGrille(L,G,Res),caseDeLigne(C,Res,Elt).


% Predicat : afficheCaseDeGrille(Colonne,Ligne,Grille) .
/*
Affiche la case aux coordonnées ColonnexLigne.
?- afficheCaseDeGrille(a,3,[[x,x,-],[x,-,o],[-,-,o]]).
-
true .

?- afficheCaseDeGrille(c,2,[[x,x,-],[x,-,o],[-,-,o]]).
o
true .
*/
afficheCaseDeGrille(C,L,G) :- caseDeGrille(C,L,G,Case),write(Case).


/* - - - - - Gestion des coups ( validité / décision d'un coup pour le CPU ) - - - - - */

% Predicat : leCoupEstValide/3
/*
Indique si la case CxL dans laquelle on veut jouer est vide.
?- leCoupEstValide(b,3,[[x,x,-],[x,-,o],[-,-,o]]).
true .

?- leCoupEstValide(c,2,[[x,x,-],[x,-,o],[-,-,o]]).
false.
*/
leCoupEstValide(C,L,G) :- caseDeGrille(C,L,G,-).


% Predicat : coupJoueDansLigne/4
% version bof
coupJoueDansLigneBof(a, Val, [-, X, Y], [Val, X, Y]).
coupJoueDansLigneBof(b, Val, [X, -, Y], [X, Val, Y]).
coupJoueDansLigneBof(c, Val, [X, Y, -], [X, Y, Val]).


% version recursive
/*
Condition générale : Avancer dans les deux listes.
Condition d'arrêt : NomCol = a.
*/
coupJoueDansLigne(a, Val, [-|Reste],[Val|Reste]).
coupJoueDansLigne(NomCol, Val, [X|Reste1],[X|Reste2]):-
		succAlpha(I,NomCol),
		coupJoueDansLigne(I, Val, Reste1, Reste2).


% Predicat : coupJoueDansGrille/5
/*
?- coupJoueDansGrille(a,2,x,[[-,-,x],[-,o,-],[x,o,o]],V).
V = [[-,-,x],[x,o,-],[x,o,o]] ;
false.
*/
coupJoueDansGrille(NCol,1,Val,[A|Reste],[B|Reste]):-
	coupJoueDansLigne(NCol, Val, A, B).
coupJoueDansGrille(NCol, NLig, Val, [X|Reste1], [X|Reste2]):-
	succNum(I, NLig),
	coupJoueDansGrille(NCol, I, Val, Reste1, Reste2).


/* - - - - - Gestion des conditions de victoire - - - - - */

% Predicat : ligneFaite/2
%
% version bof
% ligneFaiteBof(x,[x,x,x]).
% ligneFaiteBof(o,[o,o,o]).
% ligneFaiteBof(-,[-,-,-]).
/*
Vérifie si un ligne est complète avec le symbole Val.
?- ligneFaite(-,[-,-,-]).
true .

?- ligneFaite(-,[-,x,-]).
false.
*/
ligneFaite(Val, [Val]).
ligneFaite(Val, [Val|R]) :- ligneFaite(Val, R).


% Predicat : ligneExiste/3
/*
Vérifie si la ligne Numligne est complète avec le symbole Val.
?- ligneExiste(x,[[x,-,x],[x,x,x],[-,o,-]],V).
V = 2 ;
*/
ligneExiste(Val, [L1|_], 1) :- ligneFaite(Val, L1).
ligneExiste(Val, [_|R], NumLigne) :- succNum(I,NumLigne), ligneExiste(Val, R, I).


% Predicat : colonneExiste/3
/*
Similaire à ligneExiste mais sur les colonnes.
*/
colonneExiste(Val, [[Val|_],[Val|_],[Val|_]], a).
colonneExiste(Val, [[_|R1],[_|R2],[_|R3]], NomCol) :-
	succAlpha(I,NomCol),
	colonneExiste(Val, [R1,R2,R3], I).


% Predicats diagonaleDG/2 et diagonaleGD/2
/*
Vérifie si l'une des deux diagonales est complète avec le symbole Val.
*/
diagonaleGD(Val, [[Val,_,_],[_,Val,_],[_,_,Val]]).
diagonaleDG(Val, [[_,_,Val],[_,Val,_],[Val,_,_]]).


% Predicat partieGagnee/2
/*
Vérifie si il existe une ligne/colonne/diagonale gagnante pour le symbole Val.
?- partieGagnee(x, [[-,-,x],[-,o,-],[x,o,o]]).
no
?- partieGagnee(x, [[-,-,x],[-,x,-],[x,o,o]]).
yes --> diagonale
?- partieGagnee(o,[[o,-,-],[o,-,-],[o,-,-]]).
yes --> colonne
?- partieGagnee(b,[[b,b,b],[g,z,t],[e,t,y]]).
yes --> ligne
*/
partieGagnee(Val, G) :- ligneExiste(Val, G, _).
partieGagnee(Val, G) :- colonneExiste(Val, G, _).
partieGagnee(Val, G) :- diagonaleGD(Val, G).
partieGagnee(Val, G) :- diagonaleDG(Val, G).


% coordonneesOuListe(NomCol, NumLigne, Liste).
/*
?- coordonneesOuListe(a, 2, [a,2]).
true .
*/
coordonneesOuListe(NomCol, NumLigne, [NomCol, NumLigne]).


% duneListeALautre(LC1, Case, LC2)
/*
?- duneListeALautre([[a,1],[a,2],[a,3]], [a,2], [[a,1],[a,3]]).
true .
*/
duneListeALautre([A|B], A, B).
duneListeALautre([A|B], C, [A|D]):- duneListeALautre(B,C,D).


% toutesLesCasesValides(Grille, LC1, C, LC2).
/*
Se verifie si l'on peut jouer dans la case C de Grille et que la liste LC1 est une liste composee de toutes les cases de LC2 et de C.
Permet de dire si la case C est une case ou l'on peut jouer, en evitant de jouer deux fois dans la meme case.
*/
toutesLesCasesValides(Grille, LC1, C, LC2) :-
	coordonneesOuListe(Col, Lig, C),
	leCoupEstValide(Col, Lig, Grille),
	duneListeALautre(LC1, C, LC2).


/* - - - - - Base de faits - - - - - */

/*
Base de faits concernant l'état initial du jeu.
*/
toutesLesCasesDepart([[a,1],[a,2],[a,3],[b,1],[b,2],[b,3],[c,1],[c,2],[c,3]]).

grilleDeDepart([[-,-,-],[-,-,-],[-,-,-]]).

campCPU(x).


campAdverse(x,o).
campAdverse(o,x).


/* - - - - - Gestion des coups ( validité / saisie ) - - - - - */

/*
Capacité à jouer et saisir un coup dans le plateau de jeu.
*/
joueLeCoup(Case, Valeur, GrilleDep, GrilleArr) :-
	coordonneesOuListe(Col, Lig, Case),
	leCoupEstValide(Col, Lig, GrilleDep),
	coupJoueDansGrille(Col, Lig, Valeur, GrilleDep, GrilleArr),
	nl, afficheGrille(GrilleArr), nl.

saisieUnCoup(NomCol,NumLig) :-
	writeln("entrez le nom de la colonne a jouer (a,b,c) :"),
	read(NomCol), nl,
	writeln("entrez le numero de ligne a jouer (1, 2 ou 3) :"),
	read(NumLig),nl.

%saisieUnCoupValide(Col,Lig,Grille):-
%	saisieUnCoup(Col,Lig),
%	leCoupEstValide(Col,Lig,Grille),
%	writef('attention, vous ne pouvez pas jouer dans cette case'), nl,
%	writef('reessayer SVP dans une autre case'),nl,
%	saisieUnCoupValide(Col,Lig,Grille).


/* - - - - - Gestion du moteur - - - - - */

% Predicat : moteur/3
% Usage : moteur(Grille,ListeCoups,Camp) prend en parametre une grille dans
% laquelle tous les coups sont jouables et pour laquelle
% Camp doit jouer.


% cas gagnant pour le joueur
moteur(Grille,_,Camp):-
	partieGagnee(Camp, Grille), nl,
	write('le camp '), write(Camp), write(' a gagne').


% cas gagnant pour le joueur adverse
moteur(Grille,_,Camp):-
	campAdverse(CampGagnant, Camp),
	partieGagnee(CampGagnant, Grille), nl,
	write('le camp '), write(CampGagnant), write(' a gagne').


% cas de match nul, plus de coups jouables possibles
moteur(_,[],_) :-nl, write('game over').


% cas ou l ordinateur doit jouer
moteur(Grille, [Premier|ListeCoupsNew], Camp) :-
	campCPU(Camp),
	joueLeCoup(Premier, Camp, Grille, GrilleArr),
	campAdverse(AutreCamp, Camp),
	moteur(GrilleArr, ListeCoupsNew, AutreCamp).


% cas ou c est l utilisateur qui joue
moteur(Grille, ListeCoups, Camp) :-
	campCPU(CPU),
	campAdverse(Camp, CPU),
	saisieUnCoup(Col,Lig),
	joueLeCoup([Col,Lig], Camp, Grille, GrilleArr),
	toutesLesCasesValides(Grille, ListeCoups, [Col, Lig], ListeCoupsNew),
	moteur(GrilleArr, ListeCoupsNew, CPU).


/* - - - - - Point de départ du JEU - - - - - */

/* Point de départ du programme */
% Predicat : lanceJeu/0
% Usage :  lanceJeu permet de lancer une partie.

lanceJeu:-
  grilleDeDepart(G),
	toutesLesCasesDepart(ListeCoups),
	afficheGrille(G),nl,
   writeln("L ordinateur est les x et vous etes les o."),
   writeln("Quel camp doit debuter la partie ? "),read(Camp),
	toutesLesCasesDepart(ListeCoups),
	moteur(G,ListeCoups,Camp).
