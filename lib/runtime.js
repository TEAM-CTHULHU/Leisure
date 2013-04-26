
/*
Copyright (C) 2013, Bill Burdick, Tiny Concepts: https://github.com/zot/Leisure

(licensed with ZLIB license)

This software is provided 'as-is', without any express or implied
warranty. In no event will the authors be held liable for any damages
arising from the use of this software.

Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it
freely, subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not
claim that you wrote the original software. If you use this software
in a product, an acknowledgment in the product documentation would be
appreciated but is not required.

2. Altered source versions must be plainly marked as such, and must not be
misrepresented as being the original software.

3. This notice may not be removed or altered from any source distribution.
*/

(function() {
  var Monad, codeMonad, define, exports, inspect, makeMonad, nextMonad, root, runMonad, values, _;

  if ((typeof window !== "undefined" && window !== null) && (!(typeof global !== "undefined" && global !== null) || global === window)) {
    window.global = window;
    root = window.Leisure = window.Leisure || {};
  } else {
    root = exports = module.exports = require('./base');
    define = require('./ast').define;
    inspect = require('util').inspect;
    _ = require('./lodash.min');
  }

  makeMonad = function makeMonad(guts) {
    var m;
    m = function m() {};
    m.__proto__ = Monad.prototype;
    m.cmd = guts;
    m.type = 'monad';
    return m;
  };

  nextMonad = function nextMonad(cont) {
    return cont;
  };

  runMonad = function runMonad(monad, env, cont) {
    try {
      if (monad.cmd != null) {
        return monad.cmd(env, nextMonad(cont));
      } else {
        return cont(monad);
      }
    } catch (err) {
      return console.log("ERROR RUNNING MONAD: " + err.stack);
    }
  };

  Monad = (function() {

    function Monad() {}

    Monad.prototype.andThen = function andThen(func) {
      var _this = this;
      return makeMonad(function(env, cont) {
        return runMonad(_this, env, function(value) {
          return runMonad(codeMonad(func), env, cont);
        });
      });
    };

    Monad.prototype.toString = function toString() {
      return "Monad: " + (this.cmd.toString());
    };

    return Monad;

  })();

  codeMonad = function codeMonad(code) {
    return makeMonad(function(env, cont) {
      var result;
      result = code(env);
      if (result instanceof Monad) {
        return runMonad(result, env, cont);
      } else {
        return cont(_false());
      }
    });
  };

  define('true', function() {
    return function(a) {
      return function(b) {
        return a();
      };
    };
  });

  define('false', function() {
    return function(a) {
      return function(b) {
        return b();
      };
    };
  });

  define('print', function() {
    return function(msg) {
      return makeMonad(function(env, cont) {
        var m;
        m = msg();
        env.write("" + (typeof m === 'string' ? m : Parse.print(m)) + "\n");
        return cont(L_false());
      });
    };
  });

  define('bind', function() {
    return function(m) {
      return function(binding) {
        return makeMonad(function(env, cont) {
          return runMonad(m(), env, function(value) {
            return runMonad(binding()(function() {
              return value;
            }), env, cont);
          });
        });
      };
    };
  });

  values = {};

  define('hasValue', function() {
    return function(name) {
      return makeMonad(function(env, cont) {
        return cont((values[name()] != null ? L_true() : L_false()));
      });
    };
  });

  define('getValueOr', function() {
    return function(name) {
      return function(defaultValue) {
        return makeMonad(function(env, cont) {
          var _ref;
          return cont((_ref = values[name()]) != null ? _ref : defaultValue());
        });
      };
    };
  });

  define('getValue', function() {
    return function(name) {
      return makeMonad(function(env, cont) {
        return cont(values[name()]);
      });
    };
  });

  define('setValue', function() {
    return function(name) {
      return function(value) {
        return makeMonad(function(env, cont) {
          values[name()] = value();
          return cont(L_false());
        });
      };
    };
  });

  define('createS', function() {
    return makeMonad(function(env, cont) {
      return cont({
        value: null
      });
    });
  });

  define('getS', function() {
    return function(state) {
      return makeMonad(function(env, cont) {
        return cont(state().value);
      });
    };
  });

  define('setS', function() {
    return function(state) {
      return function(value) {
        return makeMonad(function(env, cont) {
          state().value = value();
          return cont(L_false());
        });
      };
    };
  });

  root.stateValues = values;

  root.runMonad = runMonad;

  root.defaultEnv = {
    write: function write(str) {
      return process.stdout.write(str);
    }
  };

}).call(this);