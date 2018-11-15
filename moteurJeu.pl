/*
Léo Boisson - M1 Informatique

moteur de jeu generique

*/


prev_int ( M, N ) :- N is M-1.
next_int ( M, N ) :- N is M+1.

createLine( 0, [] ) :- !.
createLine( Len, [empty|List] ) :-
	prev_int( Len, NewLen ),
	createLine( NewLen, List ).

createGrid( 0, 0, [] ) :- !.
createGrid( IntCol, IntLin, [H|T] ) :-
	createLine( IntLin, H ),
	prev_int( IntCol, NewIntCol ),
	createGrid( NewIntCol, IntLin, T ).

/*
NEXT IS PRINTGRID, GET FOR THE TWO, SET FOR ALL
*/

grilleDeDepart([[-,-,-],[-,-,-],[-,-,-]]).


succ(0, 1).
succ(1, 2).
succ(2, 3).
succ(3, 4).
succ(4, 5).
succ(5, 6).
succ(6, 7).


printLine([]) :- nl, nl.
printLine([H|T]) :-
	write(H),
	write(" | "),
	printLine(T).


printGridTes([H|T], Col) :-
	write(Col), write(" | "),
	printLine(H),
	succ(Col, ColSucc), printGridTes(T, ColSucc).
printGridTes([], _) :- nl.


printGridBis(Grid, [_|T], Lin) :-
	succ(Lin, LinSucc),
	write(Lin), tab(3),
	printGridBis(Grid, T, LinSucc).
printGridBis(Grid, [], _) :-
	nl, nl,
	printGridTes(Grid, 0).


printGrid([H|T]) :-
	tab(4),
	printGridBis([H|T], H, 0).


getLine(0, [Lin|_], Lin) :- !.
getLine(Col, [_|T], Lin) :-
	succ(ColPred, Col ),
	getLigne(ColPred, T, Lin).


getCellBis( [Val|_], 0, Val ) :- !.
getCellBis( [_|T], Lin, Val ) :-
	succ(LinPred, Lin),
	getCellBis(T, LinPred, Val).

getCell( Grid, Col, Lin, Val ) :-
	getLine(Col, Grid, List),
	getCellBis(List, Lin, Val).
