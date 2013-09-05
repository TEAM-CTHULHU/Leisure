// Generated by CoffeeScript 1.6.2
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
  var SimpyCons, defaultEnv, readDir, readFile, root, simpyCons, statFile, writeFile;

  root = module.exports;

  defaultEnv = {
    presentValue: function(x) {
      return x;
    },
    values: {},
    errorHandlers: []
  };

  global.resolve = function(value) {
    if (typeof value === 'function') {
      return value.memo || (value.memo = value());
    } else {
      return value;
    }
  };

  global.lazy = function(l) {
    if (typeof l === 'function') {
      return function() {
        return l;
      };
    } else {
      return l;
    }
  };

  readFile = function(fileName, cont) {
    return defaultEnv.readFile(fileName, cont);
  };

  writeFile = function(fileName, data, cont) {
    return defaultEnv.writeFile(fileName, data, cont);
  };

  readDir = function(fileName, cont) {
    return defaultEnv.readDir(fileName, cont);
  };

  statFile = function(fileName, cont) {
    return defaultEnv.statFile(fileName, cont);
  };

  SimpyCons = (function() {
    function SimpyCons(head, tail) {
      this.head = head;
      this.tail = tail;
    }

    SimpyCons.prototype.toArray = function() {
      var array, h;

      h = this;
      array = [];
      while (h !== null) {
        array.push(h.head);
        h = h.tail;
      }
      return array;
    };

    return SimpyCons;

  })();

  simpyCons = function(a, b) {
    return new SimpyCons(a, b);
  };

  root.defaultEnv = defaultEnv;

  root.readFile = readFile;

  root.readDir = readDir;

  root.writeFile = writeFile;

  root.statFile = statFile;

  root.SimpyCons = SimpyCons;

  root.simpyCons = simpyCons;

  root.resolve = global.resolve;

  root.lazy = global.lazy;

}).call(this);

/*
//@ sourceMappingURL=base.map
*/
