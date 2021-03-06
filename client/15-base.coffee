###
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
###

(window ? global).Leisure = root = (module ? {}).exports = (global.Leisure ? module.exports)

root.currentNameSpace = 'core'
root.nameSpacePath = ['core']

#root.shouldNsLog = true
root.shouldNsLog = false

root.nsLog = (args...)-> if root.shouldNsLog then console.log args...

(window ? global).verbose = {}

verboseMsg = (label, msg...)-> if (window ? global).verbose[label] then console.log msg...

if !btoa? then (window ? global).btoa = require 'btoa'

defaultEnv =
  presentValue: (x)-> String(x) + '\n'
  values: {}
  errorHandlers: []
  prompt: ->

rz = (window ? global).resolve = (value)->
  if typeof value == 'function'
    if typeof value.memo != 'undefined' then value.memo
    else
      if value.creationStack then value.creationStack = null
      if value.args then value.args = null
      value.memo = value()
  else value

#global.lazy = (l)-> ->l
#global.lazy = (l)-> if typeof l == 'function'
#  count=0
#  ->
#    if count++ > 0 then console.log "EXTRA EXECUTION OF #{l}, #{new Error('stack').stack}"
#    l
#else l
(window ? global).lazy = (l)-> if typeof l == 'function' then l.memo = l else l

readFile = (fileName, cont)-> defaultEnv.readFile fileName, cont

writeFile = (fileName, data, cont)-> defaultEnv.writeFile fileName, data, cont

readDir = (fileName, cont)-> defaultEnv.readDir fileName, cont

statFile = (fileName, cont)-> defaultEnv.statFile fileName, cont

root.trackCreation = false
#root.trackVars = false
#root.trackCreation = true
root.trackVars = true

(window ? global).$F = (args, func)->
  if root.trackCreation then func.creationStack = new Error()
  if root.trackVars
    info = func.leisureInfo = arg: args[0]
    parent = args.callee
    if parent.leisureInfo then info.parent = parent.leisureInfo
    else if parent.leisureName? then info.name = parent.leisureName
  func

(window ? global).$G = (info, func)->
  func.leisureInfoNew = info
  func

funcInfo = (func)->
  if func.leisureInfoNew then primConsFrom func.leisureInfoNew, 0
  else if func.leisureInfo
    (window ? global).FUNC = func
    info = []
    callInfo = func.leisureInfo
    while callInfo
      info.push resolve callInfo.arg
      if callInfo.name
        info.push callInfo.name
        break
      callInfo = callInfo.parent
    root.consFrom info.reverse()
  else rz L_nil

primConsFrom = (array, index)->
  if index >= array.length then rz L_nil
  else root.primCons array[index], primConsFrom array, index + 1

class SimpyCons
  constructor: (@head, @tail)->
  toArray: ->
    @_array ? (
      h = @
      array = []
      while h != null
        array.push h.head
        h = h.tail
      @_array = array)
simpyCons = (a, b)-> new SimpyCons a, b

root.defaultEnv = defaultEnv
root.readFile = readFile
root.readDir = readDir
root.writeFile = writeFile
root.statFile = statFile
root.SimpyCons = SimpyCons
root.simpyCons = simpyCons
root.resolve = resolve
root.lazy = lazy
root.verboseMsg = verboseMsg
root.maxInt = 9007199254740992
root.minInt = -root.maxInt
root.funcInfo = funcInfo
