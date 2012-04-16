(function(){
var root;

if ((typeof window !== 'undefined' && window !== null) && (!(typeof global !== 'undefined' && global !== null) || global === window)) {
  ttt = root = {};
  global = window;
} else {
  root = typeof exports !== 'undefined' && exports !== null ? exports : this;
  Lazp = require('./lazp');
  Lazp.req('./std');
  require('./prim');
  ReplCore = require('./replCore');
  Repl = require('./repl');
}
root.defs = {};
root.tokenDefs = [];
root.macros = {};

var setType = Lazp.setType;
var setDataType = Lazp.setDataType;
var define = Lazp.define;
var defineMacro = Lazp.defineMacro;
var defineToken = Lazp.defineToken;
var processResult = Repl.processResult;

var _digits, _player1, _player2, _empty, _player1Win, _player2Win, _startBoard, _testBoard, _win1Board, _win2Board, _slowBoard, _div, _ending, _spot, _row, _col, _diag1, _diag2, _showRow, _showRowDiv, _showBoard2, _showBoard, _showStartBoard, _playMove, _base_win, _win, _tie, _nextPlayer, _isLegalMove, _checkMove, _gameOver, _convertMove, _winner, _promptOrEnd, _playGame, _main, _minmax, _all_moves, _base_legalMoves, _legalMoves;
//digits = AST([ 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 , 9 ])
root.defs._digits = _digits = define('digits', _$r()((function(){return "0"}))(_$b)((function(){return "1"}))(_$b)((function(){return "2"}))(_$b)((function(){return "3"}))(_$b)((function(){return "4"}))(_$b)((function(){return "5"}))(_$b)((function(){return "6"}))(_$b)((function(){return "7"}))(_$b)((function(){return "8"}))(_$b)((function(){return "9"}))(_$s));
;
//player1 = AST(X)
root.defs._player1 = _player1 = define('player1', "X");
;
//player2 = AST(O)
root.defs._player2 = _player2 = define('player2', "O");
;
//empty = AST( )
root.defs._empty = _empty = define('empty', " ");
;
//player1Win = AST(concat ([ player1 , player1 , player1 ]))
root.defs._player1Win = _player1Win = define('player1Win', _concat()((function(){var $m; return function(){return $m || ($m = (_$r()(_player1)(_$b)(_player1)(_$b)(_player1)(_$s)))}})()));
;
//player2Win = AST(concat ([ player2 , player2 , player2 ]))
root.defs._player2Win = _player2Win = define('player2Win', _concat()((function(){var $m; return function(){return $m || ($m = (_$r()(_player2)(_$b)(_player2)(_$b)(_player2)(_$s)))}})()));
;
//startBoard = AST([ empty , empty , empty , empty , empty , empty , empty , empty , empty ])
root.defs._startBoard = _startBoard = define('startBoard', _$r()(_empty)(_$b)(_empty)(_$b)(_empty)(_$b)(_empty)(_$b)(_empty)(_$b)(_empty)(_$b)(_empty)(_$b)(_empty)(_$b)(_empty)(_$s));
;
//testBoard = AST([ a , b , c , d , e , f , g , h , i ])
root.defs._testBoard = _testBoard = define('testBoard', _$r()((function(){return "a"}))(_$b)((function(){return "b"}))(_$b)((function(){return "c"}))(_$b)((function(){return "d"}))(_$b)((function(){return "e"}))(_$b)((function(){return "f"}))(_$b)((function(){return "g"}))(_$b)((function(){return "h"}))(_$b)((function(){return "i"}))(_$s));
;
//win1Board = AST([ player1 , empty , empty , empty , player1 , empty , empty , empty , player1 ])
root.defs._win1Board = _win1Board = define('win1Board', _$r()(_player1)(_$b)(_empty)(_$b)(_empty)(_$b)(_empty)(_$b)(_player1)(_$b)(_empty)(_$b)(_empty)(_$b)(_empty)(_$b)(_player1)(_$s));
;
//win2Board = AST([ empty , empty , player2 , empty , empty , player2 , empty , empty , player2 ])
root.defs._win2Board = _win2Board = define('win2Board', _$r()(_empty)(_$b)(_empty)(_$b)(_player2)(_$b)(_empty)(_$b)(_empty)(_$b)(_player2)(_$b)(_empty)(_$b)(_empty)(_$b)(_player2)(_$s));
;
//slowBoard = AST([ a , b , c , d , e , f , g , empty , empty ])
root.defs._slowBoard = _slowBoard = define('slowBoard', _$r()((function(){return "a"}))(_$b)((function(){return "b"}))(_$b)((function(){return "c"}))(_$b)((function(){return "d"}))(_$b)((function(){return "e"}))(_$b)((function(){return "f"}))(_$b)((function(){return "g"}))(_$b)(_empty)(_$b)(_empty)(_$s));
;
//div = AST([ \n , - , - , - , - , - , \n ])
root.defs._div = _div = define('div', _$r()((function(){return "\n"}))(_$b)((function(){return "-"}))(_$b)((function(){return "-"}))(_$b)((function(){return "-"}))(_$b)((function(){return "-"}))(_$b)((function(){return "-"}))(_$b)((function(){return "\n"}))(_$s));
;
//ending = AST([ \n ])
root.defs._ending = _ending = define('ending', _$r()((function(){return "\n"}))(_$s));
;
//spot = AST(\b r c . at b (+ c (+ r (+ r r))))
root.defs._spot = _spot = define('spot', function(_b){return function(_r){return function(_c){return _at()(_b)((function(){var $m; return function(){return $m || ($m = (_$o()(_c)((function(){var $m; return function(){return $m || ($m = (_$o()(_r)((function(){var $m; return function(){return $m || ($m = (_$o()(_r)(_r)))}})())))}})())))}})())}}});
;
//row = AST(\b r . concat ([ (spot b r 0) , (spot b r 1) , (spot b r 2) ]))
root.defs._row = _row = define('row', function(_b){return function(_r){return _concat()((function(){var $m; return function(){return $m || ($m = (_$r()((function(){var $m; return function(){return $m || ($m = (_spot()(_b)(_r)((function(){return 0}))))}})())(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)(_r)((function(){return 1}))))}})())(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)(_r)((function(){return 2}))))}})())(_$s)))}})())}});
;
//col = AST(\b c . concat ([ (spot b 0 c) , (spot b 1 c) , (spot b 2 c) ]))
root.defs._col = _col = define('col', function(_b){return function(_c){return _concat()((function(){var $m; return function(){return $m || ($m = (_$r()((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 0}))(_c)))}})())(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 1}))(_c)))}})())(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 2}))(_c)))}})())(_$s)))}})())}});
;
//diag1 = AST(\b . concat ([ (spot b 0 0) , (spot b 1 1) , (spot b 2 2) ]))
root.defs._diag1 = _diag1 = define('diag1', function(_b){return _concat()((function(){var $m; return function(){return $m || ($m = (_$r()((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 0}))((function(){return 0}))))}})())(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 1}))((function(){return 1}))))}})())(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 2}))((function(){return 2}))))}})())(_$s)))}})())});
;
//diag2 = AST(\b . concat ([ (spot b 0 2) , (spot b 1 1) , (spot b 2 0) ]))
root.defs._diag2 = _diag2 = define('diag2', function(_b){return _concat()((function(){var $m; return function(){return $m || ($m = (_$r()((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 0}))((function(){return 2}))))}})())(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 1}))((function(){return 1}))))}})())(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)((function(){return 2}))((function(){return 0}))))}})())(_$s)))}})())});
;
//showRow = AST(\b r . [ (spot b r 0) , | , (spot b r 1) , | , (spot b r 2) ])
root.defs._showRow = _showRow = define('showRow', function(_b){return function(_r){return _$r()((function(){var $m; return function(){return $m || ($m = (_spot()(_b)(_r)((function(){return 0}))))}})())(_$b)((function(){return "|"}))(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)(_r)((function(){return 1}))))}})())(_$b)((function(){return "|"}))(_$b)((function(){var $m; return function(){return $m || ($m = (_spot()(_b)(_r)((function(){return 2}))))}})())(_$s)}});
;
//showRowDiv = AST(\b r . append (showRow b r) div)
root.defs._showRowDiv = _showRowDiv = define('showRowDiv', function(_b){return function(_r){return _append()((function(){var $m; return function(){return $m || ($m = (_showRow()(_b)(_r)))}})())(_div)}});
;
//showBoard2 = AST(\b . concat (append (showRowDiv b 0) (append (showRowDiv b 1) (append (showRow b 2) ending))))
root.defs._showBoard2 = _showBoard2 = define('showBoard2', function(_b){return _concat()((function(){var $m; return function(){return $m || ($m = (_append()((function(){var $m; return function(){return $m || ($m = (_showRowDiv()(_b)((function(){return 0}))))}})())((function(){var $m; return function(){return $m || ($m = (_append()((function(){var $m; return function(){return $m || ($m = (_showRowDiv()(_b)((function(){return 1}))))}})())((function(){var $m; return function(){return $m || ($m = (_append()((function(){var $m; return function(){return $m || ($m = (_showRow()(_b)((function(){return 2}))))}})())(_ending)))}})())))}})())))}})())});
;
//showBoard = AST(\b . print (showBoard2 b))
root.defs._showBoard = _showBoard = define('showBoard', function(_b){return _print()((function(){var $m; return function(){return $m || ($m = (_showBoard2()(_b)))}})())});
;
//showStartBoard = AST(showBoard startBoard)
root.defs._showStartBoard = _showStartBoard = define('showStartBoard', _showBoard()(_startBoard));
;
//playMove = AST(\p b m . append (take m b) (append ([ p ]) (drop (++ m) b)))
root.defs._playMove = _playMove = define('playMove', function(_p){return function(_b){return function(_m){return _append()((function(){var $m; return function(){return $m || ($m = (_take()(_m)(_b)))}})())((function(){var $m; return function(){return $m || ($m = (_append()((function(){var $m; return function(){return $m || ($m = (_$r()(_p)(_$s)))}})())((function(){var $m; return function(){return $m || ($m = (_drop()((function(){var $m; return function(){return $m || ($m = (_$o$o()(_m)))}})())(_b)))}})())))}})())}}});
;
//base_win = AST(\b cond . or (eq cond (row b 0)) (or (eq cond (row b 1)) (or (eq cond (row b 2)) (or (eq cond (col b 0)) (or (eq cond (col b 1)) (or (eq cond (col b 2)) (or (eq cond (diag1 b)) (eq cond (diag2 b)))))))))
root.defs._base_win = _base_win = define('base_win', function(_b){return function(_cond){return _or()((function(){var $m; return function(){return $m || ($m = (_eq()(_cond)((function(){var $m; return function(){return $m || ($m = (_row()(_b)((function(){return 0}))))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_or()((function(){var $m; return function(){return $m || ($m = (_eq()(_cond)((function(){var $m; return function(){return $m || ($m = (_row()(_b)((function(){return 1}))))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_or()((function(){var $m; return function(){return $m || ($m = (_eq()(_cond)((function(){var $m; return function(){return $m || ($m = (_row()(_b)((function(){return 2}))))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_or()((function(){var $m; return function(){return $m || ($m = (_eq()(_cond)((function(){var $m; return function(){return $m || ($m = (_col()(_b)((function(){return 0}))))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_or()((function(){var $m; return function(){return $m || ($m = (_eq()(_cond)((function(){var $m; return function(){return $m || ($m = (_col()(_b)((function(){return 1}))))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_or()((function(){var $m; return function(){return $m || ($m = (_eq()(_cond)((function(){var $m; return function(){return $m || ($m = (_col()(_b)((function(){return 2}))))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_or()((function(){var $m; return function(){return $m || ($m = (_eq()(_cond)((function(){var $m; return function(){return $m || ($m = (_diag1()(_b)))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_eq()(_cond)((function(){var $m; return function(){return $m || ($m = (_diag2()(_b)))}})())))}})())))}})())))}})())))}})())))}})())))}})())))}})())}});
;
//win = AST(\b . if (base_win b player1Win) player1 (if (base_win b player2Win) player2 empty))
root.defs._win = _win = define('win', function(_b){return _if()((function(){var $m; return function(){return $m || ($m = (_base_win()(_b)(_player1Win)))}})())(_player1)((function(){var $m; return function(){return $m || ($m = (_if()((function(){var $m; return function(){return $m || ($m = (_base_win()(_b)(_player2Win)))}})())(_player2)(_empty)))}})())});
;
//tie = AST(\b . not (any (eq empty) b))
root.defs._tie = _tie = define('tie', function(_b){return _not()((function(){var $m; return function(){return $m || ($m = (_any()((function(){var $m; return function(){return $m || ($m = (_eq()(_empty)))}})())(_b)))}})())});
;
//nextPlayer = AST(\p . if (eq p player1) player2 player1)
root.defs._nextPlayer = _nextPlayer = define('nextPlayer', function(_p){return _if()((function(){var $m; return function(){return $m || ($m = (_eq()(_p)(_player1)))}})())(_player2)(_player1)});
;
//isLegalMove = AST(\b m . (\i . and (not (eq i nil)) (eq (at b i) empty)) (indexof digits m))
root.defs._isLegalMove = _isLegalMove = define('isLegalMove', function(_b){return function(_m){return function(_i){return _and()((function(){var $m; return function(){return $m || ($m = (_not()((function(){var $m; return function(){return $m || ($m = (_eq()(_i)(_nil)))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_eq()((function(){var $m; return function(){return $m || ($m = (_at()(_b)(_i)))}})())(_empty)))}})())}((function(){var $m; return function(){return $m || ($m = (_indexof()(_digits)(_m)))}})())}});
;
//checkMove = AST(\p b move . if (isLegalMove b move) (playGame (nextPlayer p) (playMove p b (indexof digits move))) (promptOrEnd p b))
root.defs._checkMove = _checkMove = define('checkMove', function(_p){return function(_b){return function(_move){return _if()((function(){var $m; return function(){return $m || ($m = (_isLegalMove()(_b)(_move)))}})())((function(){var $m; return function(){return $m || ($m = (_playGame()((function(){var $m; return function(){return $m || ($m = (_nextPlayer()(_p)))}})())((function(){var $m; return function(){return $m || ($m = (_playMove()(_p)(_b)((function(){var $m; return function(){return $m || ($m = (_indexof()(_digits)(_move)))}})())))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_promptOrEnd()(_p)(_b)))}})())}}});
;
//gameOver = AST(\b winner . if (eq winner empty) (if (tie b) WE HAVE A TIE!!! empty) (concat ([ WINNER: Player  , winner , !!! ])))
root.defs._gameOver = _gameOver = define('gameOver', function(_b){return function(_winner){return _if()((function(){var $m; return function(){return $m || ($m = (_eq()(_winner)(_empty)))}})())((function(){var $m; return function(){return $m || ($m = (_if()((function(){var $m; return function(){return $m || ($m = (_tie()(_b)))}})())((function(){return "WE HAVE A TIE!!!"}))(_empty)))}})())((function(){var $m; return function(){return $m || ($m = (_concat()((function(){var $m; return function(){return $m || ($m = (_$r()((function(){return "WINNER: Player "}))(_$b)(_winner)(_$b)((function(){return "!!!"}))(_$s)))}})())))}})())}});
;
//convertMove = AST(\p b move . eq move c (checkMove p b (minmax p b)) (checkMove p b move))
root.defs._convertMove = _convertMove = define('convertMove', function(_p){return function(_b){return function(_move){return _eq()(_move)((function(){return "c"}))((function(){var $m; return function(){return $m || ($m = (_checkMove()(_p)(_b)((function(){var $m; return function(){return $m || ($m = (_minmax()(_p)(_b)))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_checkMove()(_p)(_b)(_move)))}})())}}});
;
//winner = AST(\w p b . if (eq empty w) (bind (prompt (concat ([ Your move player  , p , > ]))) \move . convertMove p b move) (print w))
root.defs._winner = _winner = define('winner', function(_w){return function(_p){return function(_b){return _if()((function(){var $m; return function(){return $m || ($m = (_eq()(_empty)(_w)))}})())((function(){var $m; return function(){return $m || ($m = (_bind()((function(){var $m; return function(){return $m || ($m = (_prompt()((function(){var $m; return function(){return $m || ($m = (_concat()((function(){var $m; return function(){return $m || ($m = (_$r()((function(){return "Your move player "}))(_$b)(_p)(_$b)((function(){return ">"}))(_$s)))}})())))}})())))}})())((function(){var $m; return function(){return $m || ($m = (function(_move){return _convertMove()(_p)(_b)(_move)}))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_print()(_w)))}})())}}});
;
//promptOrEnd = AST(\p b . winner (gameOver b (win b)) p b)
root.defs._promptOrEnd = _promptOrEnd = define('promptOrEnd', function(_p){return function(_b){return _winner()((function(){var $m; return function(){return $m || ($m = (_gameOver()(_b)((function(){var $m; return function(){return $m || ($m = (_win()(_b)))}})())))}})())(_p)(_b)}});
;
//playGame = AST(\p b . bind (showBoard b) \_ . promptOrEnd p b)
root.defs._playGame = _playGame = define('playGame', function(_p){return function(_b){return _bind()((function(){var $m; return function(){return $m || ($m = (_showBoard()(_b)))}})())((function(){var $m; return function(){return $m || ($m = (function(__){return _promptOrEnd()(_p)(_b)}))}})())}});
;
//main = AST(playGame player1 startBoard)
root.defs._main = _main = define('main', _playGame()(_player1)(_startBoard));
;
//minmax = AST(\p b . at digits (head (legalMoves b)))
root.defs._minmax = _minmax = define('minmax', function(_p){return function(_b){return _at()(_digits)((function(){var $m; return function(){return $m || ($m = (_head()((function(){var $m; return function(){return $m || ($m = (_legalMoves()(_b)))}})())))}})())}});
;
//all_moves = AST([ 0 , 1 , 2 , 3 , 4 , 5 , 6 , 7 , 8 ])
root.defs._all_moves = _all_moves = define('all_moves', _$r()((function(){return 0}))(_$b)((function(){return 1}))(_$b)((function(){return 2}))(_$b)((function(){return 3}))(_$b)((function(){return 4}))(_$b)((function(){return 5}))(_$b)((function(){return 6}))(_$b)((function(){return 7}))(_$b)((function(){return 8}))(_$s));
;
//base_legalMoves = AST(\b all . if (eq all nil) nil (if (eq (at b (head all)) empty) (cons (head all) (base_legalMoves b (tail all))) (base_legalMoves b (tail all))))
root.defs._base_legalMoves = _base_legalMoves = define('base_legalMoves', function(_b){return function(_all){return _if()((function(){var $m; return function(){return $m || ($m = (_eq()(_all)(_nil)))}})())(_nil)((function(){var $m; return function(){return $m || ($m = (_if()((function(){var $m; return function(){return $m || ($m = (_eq()((function(){var $m; return function(){return $m || ($m = (_at()(_b)((function(){var $m; return function(){return $m || ($m = (_head()(_all)))}})())))}})())(_empty)))}})())((function(){var $m; return function(){return $m || ($m = (_cons()((function(){var $m; return function(){return $m || ($m = (_head()(_all)))}})())((function(){var $m; return function(){return $m || ($m = (_base_legalMoves()(_b)((function(){var $m; return function(){return $m || ($m = (_tail()(_all)))}})())))}})())))}})())((function(){var $m; return function(){return $m || ($m = (_base_legalMoves()(_b)((function(){var $m; return function(){return $m || ($m = (_tail()(_all)))}})())))}})())))}})())}});
;
//legalMoves = AST(\b . base_legalMoves b all_moves)
root.defs._legalMoves = _legalMoves = define('legalMoves', function(_b){return _base_legalMoves()(_b)(_all_moves)});
;

if (typeof window !== 'undefined' && window !== null) {
  Lazp.processTokenDefs(root.tokenDefs);
}
return root;
}).call(this)