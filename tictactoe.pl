*
règles spécifiques au morpion
On teste la condition de victoire

*/
:-module(regles,[]).
:-use_module(grille).

grilleDeDepart([[-,-,-],[-,-,-],[-,-,-]]).
adversaire(x,o).
adversaire(o,x).
toutesLesCasesDepart([[a,1],[a,2],[a,3],[b,1],[b,2],[b,3],[c,1],[c,2],[c,3]]).
/*Test de validité des coups de morpion*/
ligneDeGrille(1, [Test |_], Test).
ligneDeGrille(NumLigne, [_|Reste],Test) :- display:succNum(I, NumLigne),
		ligneDeGrille(I,Reste,Test).

% Predicat : caseDeLigne(Col, Liste, Valeur).
% Satisfait si Valeur est dans la colonne Col de la Liste
/*
?- caseDeLigne(2,[1,5,3,4,2],5).
false.

?- caseDeLigne(2,[b,a,c],a).
false.

?- caseDeLigne(b,[b,a,c],a).
true ;
false.

*/

caseDeLigne(a, [A|_],A).
caseDeLigne(Col, [_|Reste],Test) :- display:succAlpha(I, Col),caseDeLigne(I,Reste, Test).

caseDeGrille(C,L,G, Elt) :- ligneDeGrille(L,G,Res),caseDeLigne(C,Res,Elt).

leCoupEstValide(C,L,G) :- caseDeGrille(C,L,G,-).

% Predicat : ligneFaite/2
/*
On teste récursivement si la ligne est pleine et composé du même symbole
*/
ligneFaite(Val, [Val]).
ligneFaite(Val, [Val|R]) :- ligneFaite(Val, R).


% Predicat : ligneExiste/3
% ?- ligneExiste(x,[[x,-,x],[x,x,x],[-,o,-]],V).
% V = 2 ;
/*
Teste si il existe une ligne victorieuse récursivement pour le symbole Val
*/
ligneExiste(Val, [L1|_], 1) :- ligneFaite(Val, L1).
ligneExiste(Val, [_|R], NumLigne) :- display:succNum(I,NumLigne), ligneExiste(Val, R, I).


% Predicat : colonneExiste/3
/*
Teste si il existe une Colonne victorieuse récursivement pour le symbole Val
*/
colonneExiste(Val, [[Val|_],[Val|_],[Val|_]], a).
colonneExiste(Val, [[_|R1],[_|R2],[_|R3]], NomCol) :-
	display:succAlpha(I,NomCol),
	colonneExiste(Val, [R1,R2,R3], I).


% Predicats diagonaleDG/2 et diagonaleGD/2
/*
Défini la notion de diagonale gagnante pour la grille.
*/
diagonaleGD(Val, [[Val,_,_],[_,Val,_],[_,_,Val]]).
diagonaleDG(Val, [[_,_,Val],[_,Val,_],[Val,_,_]]).

partieGagnee(Val, G) :- ligneExiste(Val, G, _).
partieGagnee(Val, G) :- colonneExiste(Val, G, _).
partieGagnee(Val, G) :- diagonaleGD(Val, G).
partieGagnee(Val, G) :- diagonaleDG(Val, G).
