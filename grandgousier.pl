:- use_module(library(lists)).

/* --------------------------------------------------------------------- */
/*                                                                       */
/*        PRODUIRE_REPONSE(L_Mots,L_Lignes_reponse) :                    */
/*                                                                       */
/*        Input : une liste de mots L_Mots representant la question      */
/*                de l'utilisateur                                       */
/*        Output : une liste de liste de lignes correspondant a la       */
/*                 reponse fournie par le bot                            */
/*                                                                       */
/*        NB Pour l'instant le predicat retourne dans tous les cas       */
/*            [  [je, ne, sais, pas, '.'],                               */
/*               [les, etudiants, vont, m, '\'', aider, '.'],            */
/*               ['vous le verrez !']                                    */
/*            ]                                                          */
/*                                                                       */
/*        Je ne doute pas que ce sera le cas ! Et vous souhaite autant   */
/*        d'amusement a coder le predicat que j'ai eu a ecrire           */
/*        cet enonce et ce squelette de solution !                       */
/*                                                                       */
/* --------------------------------------------------------------------- */

%Premières questions à implémenter :

%Quels vins de Bourgogne me conseillez-vous ?
%Que donne le Nuits-Saint-Georges en bouche ?
%Quel nez presente le Chambolle-Musigny ?
%Que recouvre l'appellation Haut-Medoc ?


/*                      !!!    A MODIFIER   !!!                          */

produire_reponse([fin],[L1]) :-
   L1 = [merci, de, m, '\'', avoir, consulte], !.    

produire_reponse(L,Rep) :-
%   write(L),
   mclef(M,_), member(M,L),
   clause(regle_rep(M,_,Pattern,Rep),Body),
   match_pattern(Pattern,L),
   call(Body), !.

produire_reponse(_,[L1,L2, L3]) :-
   L1 = [je, ne, sais, pas, '.'],
   L2 = [les, etudiants, vont, m, '\'', aider, '.' ],
   L3 = ['vous le verrez !'].

match_pattern(Pattern,Lmots) :-
   nom_vins_uniforme(Lmots,L_mots_unif),
   sublist(Pattern,L_mots_unif).

match_pattern(LPatterns,Lmots) :-
   nom_vins_uniforme(Lmots,L_mots_unif),
   match_pattern_dist([100|LPatterns],Lmots_unif).

match_pattern_dist([],_).
match_pattern_dist([N,Pattern|Lpatterns],Lmots) :-
   within_dist(N,Pattern,Lmots,Lmots_rem),
   match_pattern_dist(Lpatterns,Lmots_rem).

within_dist(_,Pattern,Lmots,Lmots_rem) :-
   prefixrem(Pattern,Lmots,Lmots_rem).
within_dist(N,Pattern,[_|Lmots],Lmots_rem) :-
   N > 1, Naux is N-1,
  within_dist(Naux,Pattern,Lmots,Lmots_rem).


sublist(SL,L) :- 
   prefix(SL,L), !.
sublist(SL,[_|T]) :- sublist(SL,T).

sublistrem(SL,L,Lr) :- 
   prefixrem(SL,L,Lr), !.
sublistrem(SL,[_|T],Lr) :- sublistrem(SL,T,Lr).

prefixrem([],L,L).
prefixrem([H|T],[H|L],Lr) :- prefixrem(T,L,Lr).

nom_vins_uniforme(Lmots,L_mots_unif) :-
   L1 = Lmots,
   replace_vin([beaumes,de,venise,2015],beaumes_de_venise_2015,L1,L2),
   replace_vin([les,chaboeufs,2013],les_chaboeufs_2013,L2,L3),
   L_mots_unif = L3.
   
replace_vin(L,X,In,Out) :-
   append(L,Suf,In), !, Out = [X|Suf].
replace_vin(_,_,[],[]) :- !.
replace_vin(L,X,[H|In],[H|Out]) :-
   replace_vin(L,X,In,Out).

% ----------------------------------------------------------------%

nom(beaumes_de_venise_2015,'Beaumes-de-Venise 2015').
nom(les_chaboeufs_2013,'Nuits-Saint-Georges 1er Cru 2013, Les Chaboeufs').

prix(beaumes_de_venise_2015, 12.34).
prix(les_chaboeufs_2013, 42.35).

bouche(beaumes_de_venise_2015, 
  [ [ 'les aromes de fraise, de violette cotoient les nuances' ],
    [ 'de baies de genevrier, de sureau et une delicate touche' ],
    [ 'de fleur d\'oranger. Cette intensite se poursuit en' ],
    [ 'bouche avec des saveurs juteuses, racees et tres elegantes', '.' ]
  ]).
nez(beaumes_de_venise_2015, 
    [ [ nez, intensement, parfume, '.' ] 
]).
description(beaumes_de_venise_2015, 
    [ [ 'vignoble situe au sud-est des Dentelles de Montmirail', '.' ],
      [ 'grand vin', '.' ]
]).

mclef(bouche,10).
mclef(nez,10).
mclef(prix,10).
mclef(vin,5).
mclef(vins,5).


% ----------------------------------------------------------------%

%regle_rep( mot-clef, numero-de-pattern,
%           pattern_sous_forme_de_liste_de_mots,
%           reponse_sous_forme_de_liste_de_listes_de_lignes ) :-
%     condition_eventuelle .


regle_rep(bouche,1,
  [ que, donne, le, Vin, en, bouche ],
  Rep ) :-

     bouche(Vin,Rep).

% ----------------------------------------------------------------%

regle_rep(vins,2,
  [ auriezvous, des, vins, entre, X, et, Y, eur ],
  Rep) :-

     lvins_prix_min_max(X,Y,Lvins),
     rep_lvins_min_max(Lvins,Rep).

rep_lvins_min_max([], [[ non, '.' ]]).
rep_lvins_min_max([H|T], [ [ oui, '.', je, dispose, de ] | L]) :-
   rep_litems_vin_min_max([H|T],L).

rep_litems_vin_min_max([],[]) :- !.
rep_litems_vin_min_max([(V,P)|L], [Irep|Ll]) :-
   nom(V,Appellation),
   Irep = [ '- ', Appellation, '(', P, ' EUR )' ],
   rep_litems_vin_min_max(L,Ll).

prix_vin_min_max(Vin,P,Min,Max) :-
   prix(Vin,P),
   Min =< P, P =< Max.

lvins_prix_min_max(Min,Max,Lvins) :-
   findall( (Vin,P) , prix_vin_min_max(Vin,P,Min,Max), Lvins ).
   



/* --------------------------------------------------------------------- */
/*                                                                       */
/*          CONVERSION D'UNE QUESTION DE L'UTILISATEUR EN                */
/*                        LISTE DE MOTS                                  */
/*                                                                       */
/* --------------------------------------------------------------------- */

% lire_question(L_Mots) 

lire_question(LMots) :- read_atomics(LMots).



/*****************************************************************************/
% my_char_type(+Char,?Type)
%    Char is an ASCII code.
%    Type is whitespace, punctuation, numeric, alphabetic, or special.

my_char_type(46,period) :- !.
my_char_type(X,alphanumeric) :- X >= 65, X =< 90, !.
my_char_type(X,alphanumeric) :- X >= 97, X =< 123, !.
my_char_type(X,alphanumeric) :- X >= 48, X =< 57, !.
my_char_type(X,whitespace) :- X =< 32, !.
my_char_type(X,punctuation) :- X >= 33, X =< 47, !.
my_char_type(X,punctuation) :- X >= 58, X =< 64, !.
my_char_type(X,punctuation) :- X >= 91, X =< 96, !.
my_char_type(X,punctuation) :- X >= 123, X =< 126, !.
my_char_type(_,special).


/*****************************************************************************/
% lower_case(+C,?L)
%   If ASCII code C is an upper-case letter, then L is the
%   corresponding lower-case letter. Otherwise L=C.

lower_case(X,Y) :-
	X >= 65,
	X =< 90,
	Y is X + 32, !.

lower_case(X,X).


/*****************************************************************************/
% read_lc_string(-String)
%  Reads a line of input into String as a list of ASCII codes,
%  with all capital letters changed to lower case.

read_lc_string(String) :-
	get0(FirstChar),
	lower_case(FirstChar,LChar),
	read_lc_string_aux(LChar,String).

read_lc_string_aux(10,[]) :- !.  % end of line

read_lc_string_aux(-1,[]) :- !.  % end of file

read_lc_string_aux(LChar,[LChar|Rest]) :- read_lc_string(Rest).


/*****************************************************************************/
% extract_word(+String,-Rest,-Word) (final version)
%  Extracts the first Word from String; Rest is rest of String.
%  A word is a series of contiguous letters, or a series
%  of contiguous digits, or a single special character.
%  Assumes String does not begin with whitespace.

extract_word([C|Chars],Rest,[C|RestOfWord]) :-
	my_char_type(C,Type),
	extract_word_aux(Type,Chars,Rest,RestOfWord).

extract_word_aux(special,Rest,Rest,[]) :- !.
   % if Char is special, don't read more chars.

extract_word_aux(Type,[C|Chars],Rest,[C|RestOfWord]) :-
	my_char_type(C,Type), !,
	extract_word_aux(Type,Chars,Rest,RestOfWord).

extract_word_aux(_,Rest,Rest,[]).   % if previous clause did not succeed.


/*****************************************************************************/
% remove_initial_blanks(+X,?Y)
%   Removes whitespace characters from the
%   beginning of string X, giving string Y.

remove_initial_blanks([C|Chars],Result) :-
	my_char_type(C,whitespace), !,
	remove_initial_blanks(Chars,Result).

remove_initial_blanks(X,X).   % if previous clause did not succeed.


/*****************************************************************************/
% digit_value(?D,?V)
%  Where D is the ASCII code of a digit,
%  V is the corresponding number.

digit_value(48,0).
digit_value(49,1).
digit_value(50,2).
digit_value(51,3).
digit_value(52,4).
digit_value(53,5).
digit_value(54,6).
digit_value(55,7).
digit_value(56,8).
digit_value(57,9).


/*****************************************************************************/
% string_to_number(+S,-N)
%  Converts string S to the number that it
%  represents, e.g., "234" to 234.
%  Fails if S does not represent a nonnegative integer.

string_to_number(S,N) :-
	string_to_number_aux(S,0,N).

string_to_number_aux([D|Digits],ValueSoFar,Result) :-
	digit_value(D,V),
	NewValueSoFar is 10*ValueSoFar + V,
	string_to_number_aux(Digits,NewValueSoFar,Result).

string_to_number_aux([],Result,Result).


/*****************************************************************************/
% string_to_atomic(+String,-Atomic)
%  Converts String into the atom or number of
%  which it is the written representation.

string_to_atomic([C|Chars],Number) :-
	string_to_number([C|Chars],Number), !.

string_to_atomic(String,Atom) :- name(Atom,String).
  % assuming previous clause failed.


/*****************************************************************************/
% extract_atomics(+String,-ListOfAtomics) (second version)
%  Breaks String up into ListOfAtomics
%  e.g., " abc def  123 " into [abc,def,123].

extract_atomics(String,ListOfAtomics) :-
	remove_initial_blanks(String,NewString),
	extract_atomics_aux(NewString,ListOfAtomics).

extract_atomics_aux([C|Chars],[A|Atomics]) :-
	extract_word([C|Chars],Rest,Word),
	string_to_atomic(Word,A),       % <- this is the only change
	extract_atomics(Rest,Atomics).

extract_atomics_aux([],[]).


/*****************************************************************************/
% clean_string(+String,-Cleanstring)
%  removes all punctuation characters from String and return Cleanstring

clean_string([C|Chars],L) :-
	my_char_type(C,punctuation),
	clean_string(Chars,L), !.
clean_string([C|Chars],[C|L]) :-
	clean_string(Chars,L), !.
clean_string([C|[]],[]) :-
	my_char_type(C,punctuation), !.
clean_string([C|[]],[C]).


/*****************************************************************************/
% read_atomics(-ListOfAtomics)
%  Reads a line of input, removes all punctuation characters, and converts
%  it into a list of atomic terms, e.g., [this,is,an,example].

read_atomics(ListOfAtomics) :-
	read_lc_string(String),
	clean_string(String,Cleanstring),
	extract_atomics(Cleanstring,ListOfAtomics).



/* --------------------------------------------------------------------- */
/*                                                                       */
/*        ECRIRE_REPONSE : ecrit une suite de lignes de texte            */
/*                                                                       */
/* --------------------------------------------------------------------- */

ecrire_reponse(L) :-
   nl, write('GGS :'),
   ecrire_li_reponse(L,1,1).

% ecrire_li_reponse(Ll,M,E)
% input : Ll, liste de listes de mots (tout en minuscules)
%         M, indique si le premier caractere du premier mot de 
%            la premiere ligne doit etre mis en majuscule (1 si oui, 0 si non)
%         E, indique le nombre d'espaces avant ce premier mot 

ecrire_li_reponse([],_,_) :- 
    nl.

ecrire_li_reponse([Li|Lls],Mi,Ei) :- 
   ecrire_ligne(Li,Mi,Ei,Mf),
   ecrire_li_reponse(Lls,Mf,2).

% ecrire_ligne(Li,Mi,Ei,Mf)
% input : Li, liste de mots a ecrire
%         Mi, Ei booleens tels que decrits ci-dessus
% output : Mf, booleen tel que decrit ci-dessus a appliquer 
%          a la ligne suivante, si elle existe

ecrire_ligne([],M,_,M) :- 
   nl.

ecrire_ligne([M|L],Mi,Ei,Mf) :-
   ecrire_mot(M,Mi,Maux,Ei,Eaux),
   ecrire_ligne(L,Maux,Eaux,Mf).

% ecrire_mot(M,B1,B2,E1,E2)
% input : M, le mot a ecrire
%         B1, indique s'il faut une majuscule (1 si oui, 0 si non)
%         E1, indique s'il faut un espace avant le mot (1 si oui, 0 si non)
% output : B2, indique si le mot suivant prend une majuscule
%          E2, indique si le mot suivant doit etre precede d'un espace

ecrire_mot('.',_,1,_,1) :-
   write('. '), !.
ecrire_mot('\'',X,X,_,0) :-
   write('\''), !.
ecrire_mot(',',X,X,E,1) :-
   espace(E), write(','), !.
ecrire_mot(M,0,0,E,1) :-
   espace(E), write(M).
ecrire_mot(M,1,0,E,1) :-
   name(M,[C|L]),
   D is C - 32,
   name(N,[D|L]),
   espace(E), write(N).

espace(0).
espace(N) :- N>0, Nn is N-1, write(' '), espace(Nn).


/* --------------------------------------------------------------------- */
/*                                                                       */
/*                            TEST DE FIN                                */
/*                                                                       */
/* --------------------------------------------------------------------- */

fin(L) :- member(fin,L).


/* --------------------------------------------------------------------- */
/*                                                                       */
/*                         BOUCLE PRINCIPALE                             */
/*                                                                       */
/* --------------------------------------------------------------------- */

grandgousier :- 

   nl, nl, nl,
   write('Bonjour, je suis Grandgousier, GGS pour les intimes,'), nl,
   write('conseiller en vin. En quoi puis-je vous etre utile ?'), 
   nl, nl, 

   repeat,
      write('Vous : '),
      lire_question(L_Mots),
      produire_reponse(L_Mots,L_ligne_reponse),
      ecrire_reponse(L_ligne_reponse),
   fin(L_Mots), !.
   

/* --------------------------------------------------------------------- */
/*                                                                       */
/*             ACTIVATION DU PROGRAMME APRES COMPILATION                 */
/*                                                                       */
/* --------------------------------------------------------------------- */

:- grandgousier.









