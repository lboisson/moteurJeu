/*
Martin Lebourdais, Léonard Deshaye, Leo Boisson

Moteur generique

*/



campCPU(x).

% coordonneesOuListe(NomCol, NumLigne, Liste).
% ?- coordonneesOuListe(a, 2, [a,2]).
% true.
coordonneesOuListe(NomCol, NumLigne, [NomCol, NumLigne]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ligneDansGrille : verifier qu une ligne existe dans une grille;
% caseDansLigne : verifier qu une case existe dans une ligne;
% La methode consiste a tronquer la liste jusqu a arriver a la position qui nous interesse;
% on decremente les index a chaque recursion,
% la position qui nous interesse est en position 1 ou a.

ligneDansGrille(1,[Tete|_],Tete).
ligneDansGrille(NumLig,[_|Reste],Lig):-
	succNum(I,NumLig),
	ligneDansGrille(I,Reste,Lig).


caseDansLigne(a,[Tete|_],Tete).
caseDansLigne(Col,[_|Reste],Case):-
	succAlpha(I,Col),
	caseDansLigne(I,Reste,Case).


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat caseDeGrille/4
% usage : caseDeGrille(NumColonne,NumLigne,Grille,Case) est satisfait si la
%         Case correspond bien a l intersection de la de la colonne NumColonne
%	  et de la ligne NumLigne dans le Grille

caseDeGrille(NumColonne,NumLigne,Grille,Case):-
	ligneDansGrille(NumLigne,Grille,Ligne),
	caseDansLigne(NumColonne,Ligne,Case),!.



% duneListeALautre(LC1, Case, LC2)
% ?- duneListeALautre([[a,1],[a,2],[a,3]], [a,2], [[a,1],[a,3]]). est vrai
duneListeALautre([A|B], A, B).
duneListeALautre([A|B], C, [A|D]):- duneListeALautre(B,C,D).


%Joue le coup demandé

coupJoueDansLigne(a, Val, [-|Reste],[Val|Reste]).
coupJoueDansLigne(NomCol, Val, [X|Reste1],[X|Reste2]):-
		display:succAlpha(I,NomCol),
		coupJoueDansLigne(I, Val, Reste1, Reste2).

coupJoueDansGrille(NCol,1,Val,[A|Reste],[B|Reste]):- coupJoueDansLigne(NCol, Val, A, B).
coupJoueDansGrille(NCol, NLig, Val, [X|Reste1], [X|Reste2]):- display:succNum(I, NLig),
					coupJoueDansGrille(NCol, I, Val, Reste1, Reste2).

% toutesLesCasesValides(Grille, LC1, C, LC2).
% Se verifie si l'on peut jouer dans la case C de Grille et que la liste
% LC1 est une liste composee de toutes les cases de LC2 et de C.
% Permet de dire si la case C est une case ou l'on peut jouer, en evitant
% de jouer deux fois dans la meme case.
toutesLesCasesValides(Grille, LC1, C, LC2) :-
	coordonneesOuListe(Col, Lig, C),
	regles:leCoupEstValide(Col, Lig, Grille),
	duneListeALautre(LC1, C, LC2).

regles:joueLeCoup(Case, Valeur, GrilleDep, GrilleArr) :-
	coordonneesOuListe(Col, Lig, Case),
	regles:leCoupEstValide(Col, Lig, GrilleDep),
	coupJoueDansGrille(Col, Lig, Valeur, GrilleDep, GrilleArr),
	nl, display:affichage(GrilleArr), nl.

saisieUnCoup(NomCol,NumLig) :-
	writeln("entrez le nom de la colonne a jouer (a,b,c,...) :"),
	read(NomCol), nl,
	writeln("entrez le numero de ligne a jouer (1, 2, 3,...) :"),
	read(NumLig),nl.

moteur(Grille,_,Camp):-
	regles:partieGagnee(Camp, Grille), nl,
	write('le camp '), write(Camp), write(' a gagne').

% cas gagnant pour le joueur adverse
moteur(Grille,_,Camp):-
	regles:adversaire(CampGagnant, Camp),
	regles:partieGagnee(CampGagnant, Grille), nl,
	write('le camp '), write(CampGagnant), write(' a gagne').

% cas de match nul, plus de coups jouables possibles
moteur(_,[],_) :-nl, write('game over').

% cas ou l ordinateur doit jouer
moteur(Grille, [Premier|ListeCoupsNew], Camp) :-
	campCPU(Camp),
	regles:joueLeCoup(Premier, Camp, Grille, GrilleArr),
	regles:adversaire(AutreCamp, Camp),
	moteur(GrilleArr, ListeCoupsNew, AutreCamp).

% cas ou c est l utilisateur qui joue
moteur(Grille, ListeCoups, Camp) :-
	campCPU(CPU),
	regles:adversaire(Camp, CPU),
	saisieUnCoup(Col,Lig),
	regles:joueLeCoup([Col,Lig], Camp, Grille, GrilleArr),
	toutesLesCasesValides(Grille, ListeCoups, [Col, Lig], ListeCoupsNew),
	moteur(GrilleArr, ListeCoupsNew, CPU).

%implementation du minmax

/*
Il faut définire les fonctions suivantes pour chaque jeu

    move(+Pos, -NextPos) : states that NextPos is a legal move from Pos
    utility(+Pos, -Val) : states that Pos as a value equal to Val
    min_to_move(+Pos) : states that the current player in Pos is min
    max_to_move(+Pos) : states that the current player in Pos is max

*/
lanceMoteurHH(Grille,ListeCoups,o):-
    % le joueur1 commence, on lui associe les pions 'x'
    % et on ajoute l information a la base de fait
	retractall(campJoueur1(_X)),
	asserta(campJoueur1(x)),
	campJoueur1(CampJ1),regles:campJoueur2(CampJ2),
	% calcul du score actuel
	regles:score(Grille,CampJ1,ScoreJ1),
	regles:score(Grille,CampJ2,ScoreJ2),
	% on recupere le nom de chaque joueur pour afficher son score
	nomJoueur1(J1),nomJoueur2(J2),
	write(J1),write(' a '),write(ScoreJ1),writeln(' point(s)'),
	write(J2),write(' a '),write(ScoreJ2),writeln(' point(s)'),
	% lance le moteur de jeu pour 'x'
	moteurH1H2(Grille,ListeCoups,CampJ1),!.


/* Lance le moteur du joueur 2 */

lanceMoteurHH(Grille,ListeCoups,n):-
	% le joueur2 commence, on lui associe les pions 'x'
	% et on associe les 'o' au joueur 1
	retractall(campJoueur1(_X)),
	asserta(campJoueur1(o)),
	campJoueur1(CampJ1),regles:campJoueur2(CampJ2),
	regles:score(Grille,CampJ1,ScoreJ1),
	regles:score(Grille,CampJ2,ScoreJ2),
	nomJoueur1(J1),nomJoueur2(J2),
	write(J1),write(' a '),write(ScoreJ1),writeln(' point(s)'),
	write(J2),write(' a '),write(ScoreJ2),writeln(' point(s)'),
	moteurH2H1(Grille,ListeCoups,CampJ2),!.



%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Moteur du joueur 1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Predicat: moteurH1H2/3
% Usage : moteurH1H2(Grille,ListeCoups,CampJ1) est le moteur de jeu du joueur 1
%

% cas : partie finie
moteurH1H2(Grille,[],CampJ1):-
	campJoueur1(CampJ1),
	regles:partieGagnee(Grille),!.

% cas : il n y a plus de coups disponibles pour aucun des joueurs - partie finie
moteurH1H2(Grille,ListeCoups,CampJ1):-
	ListeCoups \== [],
	campJoueur1(CampJ1),
	regles:campJoueur2(CampJ2),
	not(testerCoup(ListeCoups,CampJ1,Grille)),
	not(testerCoup(ListeCoups,CampJ2,Grille)),
	regles:partieGagnee(Grille),!.

% cas : le joueur en cours n a plus de coups disponibles
moteurH1H2(Grille,ListeCoups,CampJ1):-
	nomJoueur1(J1),campJoueur1(CampJ1),regles:campJoueur2(CampJ2),
	not(testerCoup(ListeCoups,CampJ1,Grille)),
	write('Vous devez passer votre tour '),write(J1),write(' ( '),write(CampJ1),writeln(' )'),
	moteurH2H1(Grille,ListeCoups,CampJ2).


% cas : cas general  - le joueur 1 doit jouer
moteurH1H2(Grille,ListeCoups,CampJ1):-
    % gerer l alternance des coups
	campJoueur1(CampJ1),regles:campJoueur2(CampJ2),nomJoueur1(J1),nomJoueur2(J2),
	% verifier qu il y a bien des coups a jouer
	testerCoup(ListeCoups,CampJ1,Grille),
	% demander la saisie du coup
	write('A vous de jouer '),write(J1),write(' ( '),write(CampJ1),writeln(' )'),
	saisieUnCoup(NomCol,NumLig),
	% jouer le coup dans la grille et mettre a jour la grille
	regles:joueLeCoupDansGrille(CampJ1,[NomCol,NumLig],Grille,GrilleArr),
	% afficher la nouvelle grille
	display:affichage(GrilleArr),
	% afficher le score de chacun des joueurs
	regles:score(GrilleArr,CampJ1,ScoreJ1),
	regles:score(GrilleArr,CampJ2,ScoreJ2),
	write(J1),write(' a '),write(ScoreJ1),writeln(' point(s)'),
	write(J2),write(' a '),write(ScoreJ2),writeln(' point(s)'),
	write(J1),write(' a joue en ('),write(NomCol),write(','),write(NumLig),writeln(')'),
	% mettre a jour la liste des coups
	duneListeALautre(ListeCoups,[NomCol,NumLig],NouvelleListeCoups),
	% lancer le moteur pour l autre joueur
	moteurH2H1(GrilleArr,NouvelleListeCoups,CampJ2).

testerCoup([[Colonne,Ligne]|Suite],Camp,Grille):-
	regles:leCoupEstValide(Camp,Grille,[Colonne,Ligne]);
	testerCoup(Suite,Camp,Grille).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Moteur du joueur 2
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Predicat: moteurH2H1/3
% Usage : moteurH2H1(Grille,ListeCoups,CampJ2) est le moteur de jeu du joueur 2
% Comme si dessus pour le second joueur

moteurH2H1(Grille,[],CampJ2):-
	regles:campJoueur2(CampJ2),
	regles:partieGagnee(Grille),!.

moteurH2H1(Grille,ListeCoups,CampJ2):-
	ListeCoups \== [],
	campJoueur1(CampJ2),
	regles:campJoueur2(CampJ1),
	not(testerCoup(ListeCoups,CampJ2,Grille)),
	not(testerCoup(ListeCoups,CampJ1,Grille)),
	regles:partieGagnee(Grille),!.

moteurH2H1(Grille,ListeCoups,CampJ2):-
	nomJoueur2(J2),campJoueur1(CampJ1),regles:campJoueur2(CampJ2),
	not(testerCoup(ListeCoups,CampJ2,Grille)),
	write('Vous devez passer votre tour '),write(J2),write(' ( '),write(CampJ2),writeln(' )'),
	moteurH1H2(Grille,ListeCoups,CampJ1).

moteurH2H1(Grille,ListeCoups,CampJ2):-
	campJoueur1(CampJ1),regles:campJoueur2(CampJ2),nomJoueur1(J1),nomJoueur2(J2),
	testerCoup(ListeCoups,CampJ2,Grille),
	write('A vous de jouer '),write(J2),write(' ( '),write(CampJ2),writeln(' )'),
	saisieUnCoup(NomCol,NumLig),
	regles:joueLeCoupDansGrille(CampJ2,[NomCol,NumLig],Grille,GrilleArr),
	display:affichage(GrilleArr),
	regles:score(GrilleArr,CampJ1,ScoreJ1),
	regles:score(GrilleArr,CampJ2,ScoreJ2),
	write(J1),write(' a '),write(ScoreJ1),writeln(' point(s)'),
	write(J2),write(' a '),write(ScoreJ2),writeln(' point(s)'),
	write(J2),write(' a joue en ('),write(NomCol),write(','),write(NumLig),writeln(')'),
	duneListeALautre(ListeCoups,[NomCol,NumLig],NouvelleListeCoups),
	moteurH1H2(GrilleArr,NouvelleListeCoups,CampJ1),!.


saisieNomJoueur1:-
	writeln('Entrez le nom du Joueur 1 (sans oublier le point) : '),
	read(J1),
	% Supprime le nom du joueur 1 s il y en avait deja un dans la base de fait :
	%  - retract(P) : recherche une clause dans la base de connaissances qui s unifie avec P
	%        et l efface
	%  - retractall(P) : enleve toutes les clauses qui s unifient a P.
	retractall(nomJoueur1(_X)),
	% Rajoute le nouveau nom du joueur dans la base de fait :
	%  - assert(P) : permet d ajouter P a la base de faits, peut etre ecrit n importe ou
	%  - asserta(P) : ajoute en debut de base
	%  - assertz(P) : ajoute en fin de base
	asserta(nomJoueur1(J1)),!.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Predicat : saisieNomJoueur2
% Usage : saisieNomJoueur2 enregistre le nom du joueur 2
saisieNomJoueur2:-
	writeln('Entrez le nom du Joueur 2 (sans oublier le point) : '),
	read(J2),
	retractall(nomJoueur2(_X)),
	asserta(nomJoueur2(J2)),!.

lanceJeu(1):-
	consult(othello),
	saisieNomJoueur1,
	saisieNomJoueur2,
	% affiche la grille de depart
	regles:grilleDeDepart(Grille),
	display:affichage(Grille),nl,
	% initialise tous les coups disponibles au depart
	regles:toutesLesCasesDepart(ListeCoups),
	nomJoueur1(J1),
	writeln(J1 +' voulez-vous commencer ? o. pour OUI ou n. pour NON : '),
	read(Commence),
	% lance le moteur humain contre humain
	lanceMoteurHH(Grille,ListeCoups, Commence),!.
lanceJeu(2):-
	consult(tictactoe),
	regles:grilleDeDepart(G),
	regles:toutesLesCasesDepart(ListeCoups),
	display:affichage(G),nl,
  writeln("L ordinateur est les x et vous etes les o."),
  writeln("Quel camp doit debuter la partie ? "),read(Camp),
	regles:toutesLesCasesDepart(ListeCoups),
	moteur(G,ListeCoups,Camp).
main:-
	writeln("1 pour othello et 2 pour morpion"),
	read(Num),lanceJeu(Num).
