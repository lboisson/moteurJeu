/*
règles spécifiques à l'othello
On teste la condition de victoire
*/
:-module(regles,[]).
:-use_module(grille).

grilleDeDepart([[-,-,-,-,-,-,-,-],
[-,-,-,-,-,-,-,-],
[-,-,-,-,-,-,-,-],
[-,-,-,o,x,-,-,-],
[-,-,-,x,o,-,-,-],
[-,-,-,-,-,-,-,-],
[-,-,-,-,-,-,-,-],
[-,-,-,-,-,-,-,-]]).

adversaire(x,o).
adversaire(o,x).

toutesLesCasesDepart([[a,1],[b,1],[c,1],[d,1],[e,1],[f,1],[g,1],[h,1],
								      [a,2],[b,2],[c,2],[d,2],[e,2],[f,2],[g,2],[h,2],
		      						[a,3],[b,3],[c,3],[d,3],[e,3],[f,3],[g,3],[h,3],
		      						[a,4],[b,4],[c,4],            [f,4],[g,4],[h,4],
		      						[a,5],[b,5],[c,5],	          [f,5],[g,5],[h,5],
		      						[a,6],[b,6],[c,6],[d,6],[e,6],[f,6],[g,6],[h,6],
		      						[a,7],[b,7],[c,7],[d,7],[e,7],[f,7],[g,7],[h,7],
		      						[a,8],[b,8],[c,8],[d,8],[e,8],[f,8],[g,8],[h,8]]).

ligneDansGrille(1,[Tete|_],Tete).
ligneDansGrille(NumLig,[_|Reste],Lig):-
	display:succNum(I,NumLig),
	ligneDansGrille(I,Reste,Lig).


caseDansLigne(a,[Tete|_],Tete).
caseDansLigne(Col,[_|Reste],Case):-
	display:succAlpha(I,Col),
	caseDansLigne(I,Reste,Case).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat caseDeGrille/4
% usage : caseDeGrille(NumColonne,NumLigne,Grille,Case) est satisfait si la
%         Case correspond bien a l intersection de la de la colonne NumColonne
%	  et de la ligne NumLigne dans le Grille

caseDeGrille(NumColonne,NumLigne,Grille,Case):-
	ligneDansGrille(NumLigne,Grille,Ligne),
	caseDansLigne(NumColonne,Ligne,Case),!.

lePionEncadre(Direction,Camp,Grille,Case):-
    % on verifie la valeur de la direction
	member(Direction,[1,2,3,4,5,6,7,8]),
	% on parcourt la case suivante dans une direction donnee
	caseSuivante(Direction,Case,[ColonneSuiv,LigneSuiv]),
	% on cherche si il y a un adversaire dans cette position
	adversaire(Camp,CampAdv),
	caseDeGrille(ColonneSuiv,LigneSuiv,Grille,CampAdv),
	% on regarde si il y a bien un pion a 'nous' dans la case suivante
	caseSuivante(Direction,[ColonneSuiv,LigneSuiv],Case3),
	trouvePion(Direction,Camp,Grille,Case3),!.

leCoupEstValide(Camp,Grille,[Colonne,Ligne]):-
	caseDeGrille(Colonne,Ligne,Grille,-),
	lePionEncadre(_Direction,Camp,Grille,[Colonne,Ligne]),!.

trouvePion(_Direction,Camp,Grille,[Colonne,Ligne]):-
	caseDeGrille(Colonne,Ligne,Grille,Camp),!.

trouvePion(Direction,Camp,Grille,[Colonne,Ligne]):-
	adversaire(Camp,CampAdv),
	caseDeGrille(Colonne,Ligne,Grille,CampAdv),
	caseSuivante(Direction,[Colonne,Ligne],CaseSuiv),
	trouvePion(Direction,Camp,Grille,CaseSuiv).

caseSuivante(1,[Colonne,Ligne],[ColonneSuiv,LigneSuiv]):-
	display:succAlpha(ColonneSuiv,Colonne),
	display:succNum(LigneSuiv,Ligne),!.

caseSuivante(2,[Colonne,Ligne],[Colonne,LigneSuiv]):-
	display:succNum(LigneSuiv,Ligne),!.

caseSuivante(3,[Colonne,Ligne],[ColonneSuiv,LigneSuiv]):-
	display:succAlpha(Colonne,ColonneSuiv),
	display:succNum(LigneSuiv,Ligne),!.

caseSuivante(4,[Colonne,Ligne],[ColonneSuiv,Ligne]):-
	display:succAlpha(Colonne,ColonneSuiv),!.

caseSuivante(5,[Colonne,Ligne],[ColonneSuiv,LigneSuiv]):-
	display:succAlpha(Colonne,ColonneSuiv),
	display:succNum(Ligne,LigneSuiv),!.

caseSuivante(6,[Colonne,Ligne],[Colonne,LigneSuiv]):-
	display:succNum(Ligne,LigneSuiv),!.

caseSuivante(7,[Colonne,Ligne],[ColonneSuiv,LigneSuiv]):-
	display:succAlpha(ColonneSuiv,Colonne),
	display:succNum(Ligne,LigneSuiv),!.

caseSuivante(8,[Colonne,Ligne],[ColonneSuiv,Ligne]):-
	display:succAlpha(ColonneSuiv,Colonne),!.

campJoueur2(CampJ2):-
	campJoueur1(CampJ1),
	adversaire(CampJ1,CampJ2),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  --> placer le pion ou on veut jouer
%%%  --> retourner les autres pions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat : placePionDansLigne/4
% Usage : placePionDansLigne(NomCol,Val,LigneDep,LigneArr) est satisfait si LigneArr
%         peut etre obtenue a partir de LigneDep en jouant le coup valide qui consiste
%         a mettre la valeur Val en NomCol, NumLig.
%	  On suppose donc que le coup que l on desire jouer est valide.

placePionDansLigne(a,Val,[_|SuiteLigneDep],[Val|SuiteLigneDep]):-!.

placePionDansLigne(NomCol,Val,[Tete|SuiteLigneDep],[Tete|SuiteLigneArr]):-
	display:succAlpha(Predecesseur,NomCol),
	placePionDansLigne(Predecesseur,Val,SuiteLigneDep,SuiteLigneArr).


% Predicat : placePionDansGrille/5
% Usage : placePionDansGrille(NomCol,NumLig,Val,GrilleDep,GrilleArr) est satisfait
%         si GrilleArr est obtenue a partir de GrilleDep dans laquelle on a joue
%         Val en NomCol, NumLig, et cela etant d autre part un coup valide.

placePionDansGrille(NomCol,1,Val,[Ligne1|SuiteGrille],[Ligne2|SuiteGrille]):-
	placePionDansLigne(NomCol,Val,Ligne1,Ligne2),!.

placePionDansGrille(NomCol,NumLig,Val,[Ligne1|SuiteGrilleDep],[Ligne1|SuiteGrilleArr]):-
	display:succNum(Predecesseur,NumLig),
	placePionDansGrille(NomCol,Predecesseur,Val,SuiteGrilleDep,SuiteGrilleArr).



% Predicat : mangePion/5
% Usage : mangePion(Direction,Camp,Grille,GrilleArr,Case) retourne les pions entoures

mangePion(Direction,_Camp,Grille,Grille,Case):-
	not(caseSuivante(Direction,Case,_CaseSuiv)),!.

mangePion(Direction,Camp,Grille,Grille,Case):-
	caseSuivante(Direction,Case,CaseSuiv),
	not(trouvePion(Direction,Camp,Grille,CaseSuiv)),!.

mangePion(Direction,Camp,Grille,Grille,Case):-
	caseSuivante(Direction,Case,[Colonne,Ligne]),
	caseDeGrille(Colonne,Ligne,Grille,Camp),!.

mangePion(Direction,Camp,Grille,GrilleArr,Case):-
	caseSuivante(Direction,Case,[Colonne,Ligne]),
	trouvePion(Direction,Camp,Grille,[Colonne,Ligne]),
	adversaire(Camp,CampAdv),
	caseDeGrille(Colonne,Ligne,Grille,CampAdv),
	placePionDansGrille(Colonne,Ligne,Camp,Grille,GrilleProv),
	mangePion(Direction,Camp,GrilleProv,GrilleArr,[Colonne,Ligne]).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%  --> placer le pion ou on veut jouer
%%%  --> retourner les autres pions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% Predicat : joueLeCoupDansGrille/4
% Usage : joueLeCoupDansGrille(Camp,Coups,Grille,GrilleArr) place le pion
%         Camp dans la Grille, retourne les pions entoures puis rend
%         la Grille d arrivee GrilleArr

joueLeCoupDansGrille(Camp,[Colonne,Ligne],Grille,GrilleArr):-
        leCoupEstValide(Camp,Grille,[Colonne,Ligne]),
	placePionDansGrille(Colonne,Ligne,Camp,Grille,_Grille0),
	mangePion(1,Camp,_Grille0,_Grille1,[Colonne,Ligne]),
	mangePion(2,Camp,_Grille1,_Grille2,[Colonne,Ligne]),
	mangePion(3,Camp,_Grille2,_Grille3,[Colonne,Ligne]),
	mangePion(4,Camp,_Grille3,_Grille4,[Colonne,Ligne]),
	mangePion(5,Camp,_Grille4,_Grille5,[Colonne,Ligne]),
	mangePion(6,Camp,_Grille5,_Grille6,[Colonne,Ligne]),
	mangePion(7,Camp,_Grille6,_Grille7,[Colonne,Ligne]),
	mangePion(8,Camp,_Grille7,GrilleArr,[Colonne,Ligne]),!.



scoreLigne([],_Camp,0):-!.

scoreLigne([Camp|Suite],Camp,Score):-
	scoreLigne(Suite,Camp,Score1),
	Score is Score1 +1.

scoreLigne([Tete|Suite],Camp,Score):-
	Tete \== Camp,
	scoreLigne(Suite,Camp,Score).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat : score/3
% Usage : score(Grille,Camp,Score) donne le nombre de pion Camp dans la
%         grille Grille

score([],_Camp,0):-!.

score([Ligne1|Suite],Camp,Score):-
	scoreLigne(Ligne1,Camp,Score1),
	score(Suite,Camp,Score2),
	Score is Score1 + Score2.

partieGagnee(Grille):-
    campJoueur1(CampJ1),campJoueur2(CampJ2),nomJoueur1(J1),
	score(Grille,CampJ1,ScoreJ1),
	score(Grille,CampJ2,ScoreJ2),
	ScoreJ1 > ScoreJ2,
	writeln('La partie est terminee'),
	writeln('Bravo ' + J1 +' vous avez gagne cette partie !!!').

%% la partie est terminee et c est le joueur 2 qui gagne
partieGagnee(Grille):-
	campJoueur1(CampJ1),campJoueur2(CampJ2),nomJoueur2(J2),
	score(Grille,CampJ1,ScoreJ1),
	score(Grille,CampJ2,ScoreJ2),
	ScoreJ1 < ScoreJ2,
	writeln('La partie est terminee'),
	writeln('Bravo ' + J2 + 'vous avez gagne cette partie !!!').


%% la partie est terminee et il n y a pas de gagnant
partieGagnee(Grille):-
	campJoueur1(CampJ1),campJoueur2(CampJ2),
	score(Grille,CampJ1,ScoreJ1),
	score(Grille,CampJ2,ScoreJ2),
	ScoreJ1 = ScoreJ2,
	writeln('La partie est terminee'),
	writeln('Vous etes aussi fort l un que l autre').
