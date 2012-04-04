U = require('util')
R = require('readline')
L = require('./lazp')
Prim = require('./prim')
Core = require('./replCore')
FS = require('fs')
Path = require('path')
P = require('./pretty')

#require('./std')
#console.log("cons: #{`_cons`}")

root = exports ? this
root.quiet = false

getType = L.getType

vars = {
  c: [false, 'show generated code'],
  a: [false, 'show parsed AST'],
  r: [true, 'show evaluation result'],
}

print = (args...)-> process.stdout.write(U.format.apply(null, args))
write = (args...)-> process.stdout.write args.join('')
face = null

init = ->
  if !face?
    face = R.createInterface(process.stdin, process.stdout)
    Prim.setTty(face)
    face.setPrompt "Lazp> "
    face.on 'close', ()->process.exit(0)
    face.on 'line', (line)->Core.processLine(line.trim())
    Core.setNext -> face.prompt()

repl = () ->
  print("Welcome to Lazp!\n")
  help()
  init()
  # face = R.createInterface(process.stdin, process.stdout)
  # Prim.setTty(face)
  # face.setPrompt "Lazp> "
  # face.on 'close', ()->process.exit(0)
  # face.on 'line', (line)->Core.processLine(line.trim())
  # Core.setNext -> face.prompt()
  face.prompt()

help = ()->
  write("""
:v -- vars
:h -- help
:c file -- compile file
:q -- quit
!code -- eval JavaScript code

  """)

compile = (file)->
  if !file
    console.log("No file to compile")
    face?.prompt()
  else
    contents = ''
    if !Path.existsSync(file)
      oldfile = file
      file = file + ".laz"
      if !Path.existsSync(file)
        console.log("No file: #{oldfile}")
        return Core.next()
    stream = FS.createReadStream(file)
    stream.on('data', (data)-> contents += data)
    stream.on('end', ()->
      out = Core.generateCode(file, contents, !root.quiet)
      stream = FS.createWriteStream("#{Path.basename file, '.laz'}.js")
      stream.end(out, 'utf8')
      Core.next())
    stream.on('error', (ex)->
      console.log("Exception reading file: ", ex.stack)
      Core.next())

processResult = (result)->
  init()
  write("#{getType result}: #{P.print(result)}\n")
  Core.processResult result

Core.setHelp help
Core.setCompiler compile
Core.setWriter (str)-> process.stdout.write(str)

root.print = print
root.repl = repl
root.compile = compile
root.init = init
root.processResult = processResult