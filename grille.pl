grilleDeDepart([[-,-,-],[-,-,-],[-,-,-]]).


coucou


succNum(1, 2).
succNum(2, 3).
succNum(3, 4).
succNum(4, 5).
succNum(5, 6).
succNum(6, 7).
succNum(7, 8).


succAlpha(a, b).
succAlpha(b, c).
succAlpha(c, d).
succAlpha(d, e).
succAlpha(e, f).
succAlpha(f, g).
succAlpha(g, h).


afficheLigne([]) :- nl, nl.
afficheLigne([H|T]) :-
	write(H),
	write(" | "),
	afficheLigne(T).

/* On décompose l'affichage en trois sous-prédicats */
afficheGrilleTes([], _) :- nl.
afficheGrilleTes([H|T], Alpha) :-
	write(Alpha), write(" | "),
	afficheLigne(H),
	succAlpha(Alpha, AlphaSucc), afficheGrilleTes(T, AlphaSucc).

afficheGrilleBis(Grille, [], _) :-
	nl, nl,
	afficheGrilleTes(Grille, a).
afficheGrilleBis(Grille, [_|T], I) :-
	succNum(I, ISucc),
	write(I), tab(3),
	afficheGrilleBis(Grille, T, ISucc).

afficheGrille([H|T]) :-
	tab(4),
	afficheGrilleBis([H|T], H, 1).


ligneDansGrille(a, [Ligne|_], Ligne) :- !.
ligneDansGrille(Alpha, [_|T], Ligne) :-
	succAlpha(AlphaPred, Alpha ),
	ligneDansGrille(AlphaPred, T, Ligne).


/* On va décompose ce prédicat en deux pour découper la liste de liste correctement */
donneValeurDeCaseLigne( [Valeur|_], 1, Valeur ) :- !.
donneValeurDeCaseLigne( [_|T], I, Valeur ) :-
	succNum(IPred, I),
	donneValeurDeCaseLigne(T, IPred, Valeur).
donneValeurDeCase( Grille, Alpha, I, Valeur ) :-
	ligneDansGrille(Alpha, Grille, L),
	donneValeurDeCaseLigne(L, I, Valeur).

caseVide( Grille, Alpha, I ) :-
	donneValeurDeCase( Grille, Alpha, I, - ).
