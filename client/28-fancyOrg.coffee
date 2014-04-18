console.log 'FANCY MODE!'

{
  resolve,
  lazy,
  defaultEnv,
} = root = module.exports = require '15-base'
rz = resolve
lz = lazy
{
  TAB,
  ENTER,
  BS,
  DEL,
} = require '21-browserSupport'
{
  getType,
  define,
  makeSyncMonad,
} = require '16-ast'
{
  runMonad,
  isMonad,
  escapePresentationHtml,
  unescapePresentationHtml,
} = require '17-runtime'
{
  parseOrgMode,
  Headline,
  headlineRE,
  HL_TAGS,
  Fragment,
  Meat,
  Keyword,
  keywordRE,
  KW_BOILERPLATE,
  KW_NAME,
  KW_INFO,
  Source,
  srcStartRE,
  HTML,
  Results,
  AttrHtml,
  resultsRE,
  ListItem,
  SimpleMarkup,
  Link,
  Drawer,
  drawerRE,
  parseTags,
  matchLine,
} = require '11-org'
{
  getCodeItems,
  isCodeBlock,
} = require '12-docOrg'
{
  orgNotebook,
  parseOrgMode,
  orgAttrs,
  content,
  contentSpan,
  checkStart,
  optionalBoundary,
  boundarySpan,
  displaySource,
  checkEnterReparse,
  checkCollapsed,
  checkExtraNewline,
  followingSpan,
  currentLine,
  checkSourceMod,
  isCollapsed,
  nextOrgId,
  modifyingKey,
  getOrgParent,
  getOrgType,
  executeText,
  executeDef,
  getResultsForSource,
  swapMarkup,
  modifiers,
  keyFuncs,
  defaultBindings,
  addKeyPress,
  findKeyBinding,
  invalidateOrgText,
  setCurKeyBinding,
  presentValue,
  propsFor,
  escapeHtml,
  escapeAttr,
  splitLines,
  orgSrcAttrs,
  baseEnv,
  getNodeSource,
  resultsType,
  isDef,
  getTextPosition,
  findDomPosition,
  nativeRange,
  textNodeAfter,
  textNodeBefore,
  PAGEUP,
  PAGEDOWN,
  HOME,
  END,
  watchNodeText,
  markupData,
  orgForNode,
} = require '24-orgSupport'
{
  redrawAllIssues,
  createComment,
} = require '26-storage'
{
  edited,
} = require '23-collaborate'
_ = require 'lodash.min'

fancyOrg = null
slideMode = false
lastOrgOffset = -1
curPos = -1
emptyPresenter =
  hide: ->
  isRelated: -> false
presenter = emptyPresenter
DOCUMENT_POSITION_CONTAINED_BY = 16

#root.restorePosition = restorePosition = (parent, delta, block)->
#  if !block
#    block = delta
#    delta = 0
#  sel = getSelection()
#  slide = slideParent sel.focusNode
#  slideIndex = slideOffset slide
#  if sel?.rangeCount && slideIndex > -1
#    doc = topNode(slide).parentNode
#    parent = doc.parentNode
#    docPos = childIndex parent, doc
#    r = sel.getRangeAt 0
#    start = delta + getTextPosition doc, r.startContainer, r.startOffset
#    if start > -1
#      end = delta + getTextPosition doc, r.endContainer, r.endOffset
#      [container, sta] = findDomPosition doc, start
#      if (isCollapsed container) && sta == 0 then container = textNodeBefore container
#      #offset = documentTop(container) - window.pageYOffset
#      offset = getDocumentOffset(nativeRange [container, sta]) - window.pageYOffset
#    block() # block shouldn't remove doc
#    if doc = parent.children[docPos]
#      newSlide = $('[data-org-headline="1"]')[slideIndex]
#      if slideMode then setCurrentSlide newSlide
#      if start > -1 && (r = nativeRange findDomPosition doc, start)
#        if isCollapsed r.startContainer
#          c = r.startContainer
#          while isCollapsed c
#            c = textNodeBefore c
#          r.setStart c, 0
#          r.collapse true
#        else
#          [endContainer, endOffset] = findDomPosition doc, end
#          if endOffset == 0
#            endContainer = textNodeBefore endContainer
#            endOffset = endContainer.data.length
#          r.setEnd endContainer, endOffset
#        sel.removeAllRanges()
#        sel.addRange r
#        #window.scrollTo window.pageXOffset, documentTop(r.startContainer) - offset
#        window.scrollTo window.pageXOffset, getDocumentOffset(r) - offset
#    return
#  block()

root.restorePosition = restorePosition = (parent, delta, block)->
  if !block
    block = delta
    delta = 0
  sel = getSelection()
  slide = slideParent sel.focusNode
  slideIndex = slideOffset slide
  if sel?.rangeCount && slideIndex > -1
    doc = topNode(slide).parentNode
    docRange = getDocRange()
    [start, end, offset, note] = docRange
    docRange = [start + delta, end + delta, offset, note]
    parent = doc.parentNode
    docPos = childIndex parent, doc
    r = sel.getRangeAt 0
    block() # block shouldn't remove doc
    if doc = parent.children[docPos]
      newSlide = $('[data-org-headline="1"]')[slideIndex]
      if slideMode then setCurrentSlide newSlide
      restoreDocRange doc, docRange
  else block()

# get a logical document range with an optional note
# [startPos, endPos, scrollOffset, noteId]
# if note is null, the positions are in the main doc
# otherwise, note is the id of a note
#
# Assumes the document has only two levels -- the main doc and notes
getDocRange = ->
  s = getSelection()
  r = s.getRangeAt 0
  offset = getDocumentOffset r
  if s.focusNode?.nodeType == 1 && s.rangeCount == 1 && r.collapsed && shadow = r.startContainer.children[r.startOffset]?.shadowRoot
    s = shadow.getSelection()
    note = $(s.focusNode).closest('[data-note-origin]')?[0]
    if note then [getTextPosition(note, s.anchorNode, s.anchorOffset), getTextPosition(note, s.extentNode, s.extentOffset), window.pageYOffset - offset, note.id]
    else [null, null, null]
  else
    doc = topNode s.focusNode
    [getTextPosition(doc, r.startContainer, r.startOffset), getTextPosition(doc, r.endContainer, r.endOffset), window.pageYOffset - offset]

restoreDocRange = (parent, [start, end, offset, noteId])->
  if noteId
    noteNode = $("[data-org-note-instances~='#{noteId}']")[0]
    parent = $(noteNode.shadowRoot.firstChild).find("##{noteId}")[0]
  [startContainer, startOffset] = findDomPosition parent, start
  [endContainer, endOffset] = findDomPosition parent, end
  r = document.createRange()
  r.setStart startContainer, startOffset
  r.setEnd endContainer, endOffset
  if noteId
    offR = document.createRange()
    offR.selectNode noteNode
    window.scrollTo window.pageXOffset, offset + getDocumentOffset(offR)
    s = noteNode.shadowRoot.getSelection()
  else
    window.scrollTo window.pageXOffset, offset + getDocumentOffset(r)
    s = getSelection()
  s.removeAllRanges()
  s.addRange r

getDocumentOffset = (r)->
  c = (if r.startOffset == 0 then (textNodeBefore r.startContainer) ? r.startContainer else r.startContainer)
  while isCollapsed c
    c = textNodeBefore c
  documentTop c

childIndex = (parent, child)->
  for i in [0...parent.children.length]
    if parent.children[i] == child then return i
  return -1

topNode = (node)->
  top = node
  while node
    if node.hasAttribute? 'data-org-headline' then top = node
    node = node.parentNode
  return top

replaceUnrelatedPresenter = (target, newPres)->
  if result = !presenter || !presenter.isRelated target
    replacePresenter newPres
  result

replaceRelatedPresenter = (target, newPres)->
  if result = presenter && presenter.isRelated target
    replacePresenter newPres
  result

replacePresenter = (pres)->
  presenter?.hide()
  if pres != null then presenter = pres else presenter = emptyPresenter

markupOrg = (text)->
  [node, result] = markupOrgWithNode text
  result

markupOrgWithNode = (text, note, replace)->
  nodes = {}
  if typeof text == 'string'
    # ensure trailing newline -- contenteditable doesn't like it, otherwise
    if text[text.length - 1] != '\n' then text = text + '\n'
    org = parseOrgMode text
  if text instanceof Org.Node then org = text
  if org
    #if note then org = org.children[0]
    [org, markupNewNode org, null, null, note, replace]
  else
    console.log "Attempt to display uknown object type: ", text
    throw new Error "Attempt to display unknown type of object: #{text}"

markupNewNode = (org, middleOfLine, delay, note, replace)->
  lastOrgOffset = -1
  markupNode org, middleOfLine, delay, note, replace

markupNode = (org, middleOfLine, delay, note, replace)->
  if org.offset <= lastOrgOffset then ''
  else if org instanceof Results
    pos = org.contentPos
    text = org.text.substring pos
    "<span #{orgAttrs org}><span data-org-type='text'>#{escapeHtml org.text.substring(0, pos)}</span>#{contentSpan text}"
  else if org instanceof Fragment then markupFragment org, delay, note
  else if org instanceof HTML then markupHtml org
  else if org instanceof AttrHtml then markupAttr org
  else if org instanceof Keyword
    if org.name.match /^name$/i
      intertext = ''
      name = org
      src = org.next
      while src instanceof Meat && !(src instanceof Source)
        intertext += src.text
        src = src.next
      if src instanceof Source then markupSource src, name, intertext, delay
      else defaultMarkup org
    else if org instanceof Source then markupSource org, null, null, delay
    else defaultMarkup org
  else if org instanceof Headline then markupHeadline org, delay, note, replace
  else if org instanceof Drawer && org.name.toLowerCase() == 'properties' then markupProperties org, delay
  else if org instanceof Drawer && org.name.toLowerCase() == 'data' then markupData org
  else if org instanceof ListItem then markupListItem org, delay
  else if org instanceof SimpleMarkup then markupSimple org
  else if org instanceof Link then markupLink org
  else if content(org.text).length then defaultMarkup org
  else
    tag = (if middleOfLine then 'span' else 'div')
    "<#{tag} #{orgAttrs org}>#{escapeHtml org.text}</#{tag}>"

markupFragment = (org, delay, note)->
  if isCodeBlock org.children[0]
    {first, name, source, last} = getCodeItems org.children[0]
    if first == org.children[0] && !last
      prelude = ''
      first = name.next
      while first != source
        prelude += first.allText()
        first = first.next
      return "<div #{orgAttrs org}>#{markupSource source, name, prelude, delay, true}</div>"
  "<div #{orgAttrs org}>#{(markupNode child, false, delay, note for child in org.children).join ''}</div>"

markupProperties = (org, delay)->"<span data-note-location class='hidden'>#{escapeHtml org.text}</span>"

lastAttr = null

markupAttr = (org)->
  lastAttr = org
  "<span class='hidden'>#{org.text}</span>"

markupLink = (org)->
  if org.isImage()
    #console.log "last: " + lastAttr
    pre = ''
    post = ""
    if lastAttr && lastAttr.type == 'attr'
      pre = "<div class='image-draggable'>"
      post = "</div>"
    lastAttr = null
    pre + "<span class='hidden'>#{org.text}</span><img src='#{org.path}'>" + post
  else
    guts = ''
    for c in org.children
      guts += markupNode c, true
    if !guts then "<span class='hidden'>[[</span><a onclick='Leisure.followLink(event)' href='#{org.path}'>#{org.path}</a><span class='hidden'>]]</span>"
    else "<span class='hidden'>[[#{org.path}][</span><a onclick='Leisure.followLink(event)' href='#{org.path}'>#{guts}</a><span class='hidden'>]]</span>"

root.followLink = (e)->
  t = e.target
  while t && t.nodeName != 'A'
    t = t.parentNode
  if t then window.open t.href, "links"

markupSimple = (org)->
  guts = ''
  for c in org.children
    guts += markupNode c, true
  text = switch org.markupType
    when 'bold' then "<b>#{guts}</b>"
    when 'italic' then "<i>#{guts}</i>"
    when 'underline' then "<span style='text-decoration: underline'>#{guts}</span>"
    when 'strikethrough' then "<span style='text-decoration: line-through'>#{guts}</span>"
    when 'code' then "<code>#{guts}</code>"
    when 'verbatim' then "<code>#{guts}</code>"
  "<span class='hidden'>#{org.text[0]}</span>#{text}<span class='hidden'>#{org.text[0]}</span>"

hlStars = /^\*+ */

markupHeadline = (org, delay, note, replace)->
  match = org.text.match headlineRE
  start = "#{org.text.substring 0, org.text.length - (match?[HL_TAGS] ? '').length - 1}".trim()
  if org.text[org.text.length - 1] == '\n'
    tags = escapeHtml org.text.substring start.length, org.text.length
  else
    tags = escapeHtml org.text.substring start.length
  if starsM = start.match hlStars
    stars = start.substring 0, starsM[0].length
    start = start.substring stars.length
  else stars = ''
  properties = []
  for k, v of org.properties
    properties.push "#{k} = #{v}"
  properties = if properties.length then "<span class='headline-properties' title='#{escapeAttr properties.join '<br>'}'><i class='fa fa-wrench'></i></span>" else ''
  if org.level == 1 && !note && !org.properties?.note
    if org.text.trim() != ''
      "#{startNewSlide replace}<div #{orgAttrs org} data-org-headline-text='#{escapeAttr start}'#{noteAttrs org}><div class='maincontent'><span class='hidden'>#{stars}</span><span data-org-type='text'><div data-org-type='text-content'><div class='textcontent'>#{escapeHtml start}</div><span class='tags'>#{properties}#{tags}</span><div class='textborder'></div></div></span>#{markupGuts org, checkStart start, org.text}</div></div>"
    else "#{startNewSlide()}<div #{orgAttrs org}><span data-org-type='text'><span data-org-type='text-content'><span class='hidden'>#{org.text}</span></span></span>#{markupGuts org, checkStart start, org.text}</div>"
  else
    slide = if org.text.trim() != ''
      "<div #{orgAttrs org} data-org-headline-text='#{escapeAttr start}'#{noteAttrs org}><span class='hidden'>#{stars}</span><span data-org-type='text'><div data-org-type='text-content'><div class='textcontent'>#{escapeHtml start}</div><span class='tags'>#{properties}#{tags}</span><div class='textborder'></div></div></span>#{markupGuts org, checkStart start, org.text}</div>"
    else "<div #{orgAttrs org}><span data-org-type='text'><span data-org-type='text-content'><span class='hidden'>#{org.text}</span></span></span>#{markupGuts org, checkStart start, org.text}</div>"
    floatize org, slide
    #slide

#noteAttrs = (org)->
#  if org.properties?.notes then "data-org-notes='#{org.properties.notes}'"
#  else ''

nextNoteId = 0

noteAttrs = (org)->
  if org.level != 1 then ''
  else if org.properties?.note == 'sidebar' then " data-org-note='sidebar' data-org-noteid='#{nextNoteId++}'"
  else if org.properties?.note?.match /^float / then " data-org-note='float' data-org-noteid='#{nextNoteId++}' data-org-floatval='#{org.properties.note}'"
  else " data-org-note='main'"

floatize = (org, slide)->
  if org.properties?.note?.match /^float /
    "<div data-draggable data-float-holder='#{nextNoteId - 1}'><div data-resizable style='width: 600px; height: 600px; background: lightgray;'><h2 class='note_drag_handle' contenteditable='false'>YOUR NOTE</h2><div contenteditable='true'>#{slide}</div></div></div>"
  else slide

updateNoteProperties = (span, index, txt) ->
  old = span.textContent
  lines = old.split /\n/
  s = lines[1].split /\s*,\s*/
  if index != 0 then s[index] = txt else s[index] = ":notes: " + txt
  lines[1] = s.join ', '
  span.textContent = lines.join '\n'

saveNoteLocation = (target) ->
  drag = target.closest("[data-draggable]")
  resize = $(drag.children()[0])
  orig_id = drag.attr 'data-note-origin'
  orig = $("#" + orig_id)
  span = orig.find("[data-note-location]")[0]
  if span
    index = drag.attr 'data-note-index'
    #console.log "span: " + span + " => " + index
    updateNoteProperties span, index, "float #{drag.css('top')} #{drag.css('left')} #{resize.width()}px #{resize.height()}px"

createNotes = (node)->
  watchNodeText node, editedNote node.id, node.id
  $(node).addClass 'herpderp'
  for noteSpec in node.getAttribute('data-org-notes').split /\s*,\s*/
    #console.log "NOTE FOR #{node.id}: #{noteSpec}"
    noteId = "note-#{nextNoteId++}"
    [org, html] = markupOrgWithNode node.textContent, true
    newNote = $("<div class='sidebar_notes' data-note-origin='#{node.id}' id='#{noteId}' contenteditable='true'>#{html}</div>")[0]
    switch (splitSpec = noteSpec.split(/\s+/))[0]
      when 'sidebar'
        if dest = $("[data-org-headline-text='#{splitSpec[1]}'] div.sidebar")[0]
          if !dest.shadowRoot then setShadowHtml dest, "<div contenteditable='true'></div>"
          dest.shadowRoot.firstChild.appendChild newNote
      when 'float'
        parent = topNode node
        dest = $(document.body).find('[data-org-floats]')[0]
        if !dest then $(document.body).prepend dest = $("<div data-org-floats='true' contenteditable='true'></div>")[0]
        inside = $('<div data-resizable style="width: 600px; height: 600px; background: black;"><h2 class="note_drag_handle" contenteditable="false">YOUR NOTE</h2><div></div></div>')
        holder = $("<div data-draggable data-note-origin='#{node.id}' data-note-index='#{nextNoteId - 1}'></div>")
        #console.log node
        holder.append inside
        dest.appendChild holder[0]
        holder.draggable({handle: 'h2'})
        inside.resizable()
        holder.bind 'dragstop', (event) ->
          saveNoteLocation $(event.target)
        inside.bind 'resizestop', ->
          saveNoteLocation $(event.target)
        child = inside[0].children[1]
        setShadowHtml child, "<div contenteditable='true' class='float_note'></div>"
        child.shadowRoot.firstChild.appendChild newNote
        dest = child
        orig = $("#" + node.id)[0]
        #$("<span data-note-location  class='hidden'></span>").appendTo orig
        [skip, top, left, width, height] = noteSpec.split /\s+/
        holder.css({top: top, left: left})
        inside.css({width: width, height: height})
        saveNoteLocation holder
      else continue
    if dest
      #for n in $(dest.shadowRoot.firstChild).find('[data-org-headline="1"]')
      #  setShadowHtml n, "<div class='page'><div class='border'></div><div class='pagecontent'><content></content></div></div>"
      addWord dest, 'data-org-note-content', node.id
      addWord dest, 'data-org-note-instances', noteId
      watchNodeText newNote, editedNote node.id, noteId
      fixupHtml newNote

addWord = (node, attr, value)->
  vals = (node.getAttribute(attr) ? '').split ' '
  vals = vals.filter (el) ->
    el.length != 0
  if !(value in vals) then vals.push value
  node.setAttribute attr, vals.join ' '

editing = false

editedNote = (mainId, editedId)-> ->
  if !editing
    setTimeout (->
      restorePosition $("##{editedId}")[0], ->
        targets = $("##{mainId}")
        main = targets[0]
        for node in $("[data-org-note-content~='#{mainId}']")
          targets = targets.add($(node.shadowRoot.firstChild).find "[data-note-origin='#{mainId}']")
        origin = targets.filter "##{editedId}"
        editing = true
        try
          t = targets.not("##{editedId}")
          t.html origin.html()
          for node in t
            fixupHtml node, node != main
        finally
          setTimeout (-> editing = false), 1), 1

markupHtml = (org)->
  "<div #{orgAttrs org}><span data-org-html='true'>#{$('<div>' + org.content() + '</div>').html()}</span><span class='hidden'>#{escapeHtml org.text}</span></div>"

markupSource = (org, name, doctext, delay, inFragment)->
  top = name ? org
  srcContent = org.content
  lead = org.text.substring 0, org.contentPos - org.offset
  trail = org.text.substring org.contentPos - org.offset + org.content.length
  lastOrgOffset = org.offset
  if name
    codeBlock = " data-org-codeblock='#{escapeAttr name.info.trim()}'>"
  else codeBlock = ">"
  codeBlock += "<div class='codeborder'></div>"
  startHtml = "<div "
  contHtml = "class='codeblock' contenteditable='false' #{orgAttrs org}#{codeBlock}"
  if channels = updateChannels org then contHtml = "data-org-update='#{channels}' #{contHtml}"
  node = org.next
  intertext = ''
  finalIntertext = ''
  resText = ''
  resOrg = null
  while node
    if node instanceof Results
      lastOrgOffset = node.offset
      resText = node.text.substring node.contentPos
      resOrg = node
      finalIntertext = intertext
      break
    else if node instanceof Drawer
      if node.name.toLowerCase() == 'expected'
        expected = node
        lastOrgOffset = node.offset
        finalIntertext = intertext += escapeHtml node.text
      else break
    else if node instanceof Headline || node instanceof Keyword then break
    else intertext += escapeHtml node.text
    node = node.next
  if name
    nameM = name.text.match keywordRE
    codeName = "<div class='codename' contenteditable='true'><span class='hidden'>#{escapeHtml nameM[KW_BOILERPLATE]}</span><div>#{escapeHtml name.info}</div>#{escapeHtml doctext}</div>"
  else codeName = "<div class='codename' contenteditable='true'></div>"
  wrapper = "<table class='codewrapper'><tr>"
  wrapper += "<td class='code-buttons'>"
  if testCaseButton = toTestCaseButton org then wrapper += "<div>#{testCaseButton}</div>"
  if testCaseButton
    wrapper += "<div><button class='results-indicator' onclick='Leisure.executeCode(event)' data-org-type='boundary'><i class='fa fa-gear'></i><div></div></button></div>"
    wrapper += "<div><button class='dyntoggle-button' onclick='Leisure.toggleDynamic(event)'><span class='dyntoggle'><i class='fa fa-link'></i><i class='fa fa-unlink'></i></span></button></div>"
  if name then wrapper += "<div>#{commentButton name.info.trim()}</div>"
  wrapper += "</td><td class='code-content'>"
  wrapper += codeName
  wrapper += "<div class='hidden'>#{escapeHtml lead}</div>"
  wrapper += "<div #{orgSrcAttrs org} contenteditable='true'>#{escapeHtml srcContent}</div><span class='hidden' data-org-type='boundary'>#{escapeHtml trail}</span>"
  wrapper += "<span class='hidden'>#{finalIntertext}</span>" + htmlForResults resText, resOrg
  if expected then wrapper += htmlForExpected expected.content()
  wrapper += "</td></tr></table>"
  testCase = resultsType(org) in ['test', 'autotest'] && expected
  result = contHtml + wrapper + (if name then "</div>#{commentBlock name.info.trim()}" else "</div>")
  if testCase
    testValue = testResult expected.content(), resText
    testAttr = "data-org-test='#{testValue}'"
    if delay then setTimeout (->
      $("##{escapeAttr org.nodeId}").attr 'data-org-test', testValue), 1
    startHtml + "onclick='Leisure.toggleTestCase(event)' #{if !delay then testAttr else ''} title='<div class=#{escapeAttr "'expected-hover'"}><b>Expr:</b> #{escapeHtml srcContent}<br><b>Expected:</b> #{escapeAttr expected.content()}</div>' data-org-expected='#{escapeAttr expected.content()}' #{result}"
  else
    fluff = if top.prev instanceof Source || top.prev instanceof Results then "<div class='fluff' data-newline></div>" else ''
    inner = fluff + startHtml + result
    if inFragment then inner
    else '<div>' + inner + '</div>'

updateChannels = (org)-> org instanceof Source && (org.info.match /:update *([^:]*)/)?[1]

testResult = (expected, actual)->
  if actual == '' then 'unknown'
  else if expected == actual then 'pass'
  else 'fail'

root.toggleTestCase = (evt)->
  node = codeBlockForNode evt.target
  selectPrevious node
  if node then replaceCodeBlock node, changeResultType node.textContent, (if node.getAttribute('data-org-results') == 'autotest' then 'dynamic' else 'static')

selectPrevious = (node)->
  top = topNode node
  pos = getTextPosition top, node, 0
  r = nativeRange findDomPosition top, Math.max 0, pos - 1
  sel = getSelection()
  sel.removeAllRanges()
  sel.addRange r

replaceCodeBlock = (node, text)->
  newNode = null
  restorePosition null, ->
    newNode = $(markupNewNode parseOrgMode(text).children[0], false, true)[0]
    $(node).replaceWith(newNode)
    for n in $(newNode).find('[data-org-src]')
      recreateAstButtons parent, n
    for n in $(newNode).find('.resultscontent')
      reprocessResults n
    setTimeout (=>
      nn = $(newNode)
      (if nn.is('.codeblock') then nn else nn.find('.codeblock')).addClass 'ready'
      for n in $(newNode).find('[data-org-comments]')
        setShadowHtml n.firstElementChild, "<div class='#{theme ? ''}'>" + newCommentBox n.getAttribute('data-org-comments') + '</div>', codeBlockForNode(n.previousElementSibling).id
      redrawAllIssues()), 1
  newNode

markupListItem = (org, delay)->
  if org.level == 0
    start = !org.getPreviousListItem()
    end = !org.getNextListItem()
  else
    start = (parent = org.getParent()) && parent == org.getPreviousListItem()
    next = org.getNextListItem()
    end = !next || next.level < org.level
  """#{if start then '<ul>' else ''}<li #{orgAttrs org} data-org-listlevel='#{
    org.level
  }'#{
    if org.checked? then ' data-org-checked="' + org.checked + '"' else ''
  }><span class='hidden'>#{
    escapeHtml org.text.substring 0, org.contentOffset
  }</span><span>#{markupListContents org.children}</span></li>#{
    eatListItem org
  }#{if end then '</ul>' else ''}"""

markupListContents = (children)-> (markupNode child, true for child in children).join ''

eatListItem = (org)->
  if org.next instanceof Meat && org.next.text[0] == '\n' then ''
  else
    item = org
    result = ''
    while ((org = org.next) instanceof Meat) && !(org instanceof ListItem)
      result += markupNode org
      lastOrgOffset = Math.max(lastOrgOffset, org.offset)
    result

unwrap = (node)->
  parent = node.parentNode
  if parent
    while node.firstChild?
      parent.insertBefore node.firstChild, node
    parent.removeChild node

recreateAstButtons = (parent, node)->
  restorePosition parent, ->
    for button in $(node).find('.ast-button')
      button.remove()
    for num in $(node).find('.org-num')
      unwrap num
    t = node.textContent
    if t && t[t.length - 1] != '\n' then node.textContent = t += '\n'
    chunk = /^[^ \n].*$/mg
    num = /(^|[^0-9.]+)([0-9][0-9.]*|\.[0-9.]+)/mg
    node.normalize()
    rest = t
    mchunk = chunk.exec t
    mnum = num.exec t
    cur = node.firstChild
    curStart = 0
    while cur && (mchunk || mnum)
      if mchunk && (!mnum || mchunk.index <= mnum.index + mnum[1].length)
        cur = (if mchunk.index > curStart then cur.splitText mchunk.index - curStart else cur)
        curStart = mchunk.index
        div = document.createElement 'div'
        div.setAttribute 'class', 'ast-button'
        div.setAttribute 'contenteditable', 'false'
        do (d = div, offset = mchunk.index)-> div.onmousedown = (e)-> showAst e, d, offset
        if curStart == 0 then div.setAttribute 'style', 'top: 0'
        node.insertBefore div, cur
        mchunk = chunk.exec t
        continue
      if mnum && (!mchunk || mnum.index + mnum[1].length <= mchunk.index)
        numStart = mnum.index + mnum[1].length
        mid = (if numStart > curStart then cur.splitText numStart - curStart else cur)
        cur = mid.splitText mnum[2].length
        curStart = mnum.index + mnum[0].length
        numberSpan = document.createElement 'span'
        numberSpan.appendChild mid
        numberSpan.classList.add 'org-num'
        node.insertBefore numberSpan, cur
        node.normalize()
        do (n = numberSpan)-> n.onmousedown = (e)->
          e.stopPropagation()
          e.preventDefault()
          showSliderButton node, n
        mnum = num.exec t

newCodeContent = (name, content)->
  parent = $("[data-org-codeblock='#{name}']")
  if node = parent.find('[data-org-src]')[0]
    node.innerHTML = escapeHtml content
    recreateAstButtons parent, node

define 'newCodeContent', lz (name)->$F(arguments, (content)->
  makeSyncMonad (env, cont)->
    newCodeContent rz(name), rz(content)
    cont rz L_true)

isOrContains = (parent, node)->
  (n = parent.compareDocumentPosition(node) & DOCUMENT_POSITION_CONTAINED_BY) || n == 0

linePat = /\r?\n(?=[^ ]|$)/

showAst = (evt, astButton, offset)->
  evt.preventDefault()
  evt.stopPropagation()
  if !replaceRelatedPresenter presenter.button, emptyPresenter
    if !astButton.firstChild then astButton.innerHTML = "<div></div>"
    text = astButton.parentNode.textContent.substring offset
    text = text.substring 0, (if m = text.match linePat then m.index else text.length)
    result = rz(L_newParseLine)(lz 0)(L_nil)(lz text)
    runMonad result, baseEnv, (ast)->
      if getType(ast) != 'parseErr'
        console.log "SIMPLIFIED: #{show lz(runMonad rz(L_simplify) lz text)}"
        try
          setShadowHtml astButton.firstChild, "<div class='#{theme ? ''} ast'>#{rz(L_wrappedTreeFor)(lz ast)(L_id)}</div>"
          #astButton.firstChild.innerHTML = "<div class='ast'>#{rz(L_wrappedTreeFor)(lz ast)(L_id)}</div>"
          replacePresenter
            hide: -> astButton.firstChild.remove()
            isRelated: (node)-> isOrContains astButton, node
            button: astButton
        catch err
          console.log "Error showing AST: #{err.stack}"

show = (obj)-> rz(L_show)(lz obj)


commentButton = (name)->
  "<button class='comment-button' onclick='Leisure.toggleComment(\"#{escapeAttr name}\", event)' contenteditable='false' data-org-commentcount='0'><i class='fa fa-comment'></i><span></span><div></div></button>"

toTestCaseButton = (org)->
  if isDef org then ''
  else "<button class='testcase-button' onclick='Leisure.createTestCase(event)' contenteditable='false' data-org-commentcount='0'><i class='fa fa-mail-reply'></i><div></div><span></span></button>"

codeBlockForNode = (node)->
  node = $(node).closest '[data-org-type="source"]'
  if node.is '[data-org-test]' then node[0] else node[0].parentNode

createTestCase = (evt)->
  alert 'Not converted to new model, yet...'; return
  console.log evt.target
  node = codeBlockForNode evt.target
  selectPrevious node
  text = node.textContent
  rest = text
  while match = rest.match drawerRE
    if match[0].trim().toLowerCase() == ':expected:'
      drawer = parseOrgMode(rest.substring(match.index), text.length - rest.length + match.index).children[0]
      break
    rest = rest.substring match.index + match[0].length
  resultsText = (if drawer then text.substring drawer.offset + drawer.text.length else text)
  if match = resultsRE.exec resultsText
    results = parseOrgMode(resultsText.substring(match.index), text.length - resultsText.length + match.index).children[0]
    if results.text.substring results.contentPos
      newExpectation = ":EXPECTED:\n#{results.text.substring results.contentPos}:END:\n"
      start = (if drawer then drawer else results).offset
      end = (if drawer then drawer.offset + drawer.text.length else results.offset)
      src = parseOrgMode(text).children[0]
      pre = changeResultType text.substring(0, start), (if resultsType(src) == 'dynamic' then 'autotest' else 'test')
      return replaceCodeBlock node, pre + newExpectation + text.substring end
  alert('You have to have results in order to make a test case')

newChangeResultType = (node, newType)->
  org = src = orgForNode node
  while src && !(src instanceof Source)
    src = src.next
  if src
    if m = src.text.match /(:results *)([\w]*)/i
      start = m.index + m[1].length
      end = start + m[2].length
      src.text = src.text.substring(0, start) + newType + src.text.substring(end)
    else
      pos = src.contentPos - 1
      src.text = src.text.substring(0, pos) + " :results #{newType}" + src.text.substring pos
  org

changeResultType = (text, newType)->
  src = parseOrgMode(text).children[0]
  while src && !(src instanceof Source)
    src = src.next
  if src
    if m = src.text.match /(:results *)([\w]*)/i
      start = src.offset + m.index + m[1].length
      end = start + m[2].length
      text.substring(0, start) + newType + text.substring(end)
    else
      pos = src.offset + src.contentPos - 1
      text.substring(0, pos) + " :results #{newType}" + text.substring pos
  else text

commentBlock = (name)->
  "<div class='comments' data-org-comments='#{escapeAttr name}'><div></div></div>"

toggleComment = (name, evt)->
  button = $(evt.target).closest('button')[0]
  block = $("[data-org-comments=#{name}]")
  console.log "comments clicked!"
  if block.hasClass 'showcomments'
    if !replaceRelatedPresenter button, null then block.removeClass 'showcomments'
  else
    block.addClass 'showcomments'
    $("[data-org-codeblock='#{escapeAttr name}'] button.comment-button").removeClass 'new-comments'
    replacePresenter
      hide: -> block.removeClass 'showcomments'
      isRelated: (target)->
        button == $(target).closest('button')[0] || $(target).closest("[data-org-comments]").is(block)

addComment = (name, event)->
  box = $(event.target.parentNode.querySelector('textarea'))
  createComment name, box.val()
  box.val ''

defaultMarkup = (org)-> "<span #{orgAttrs org}>#{escapeHtml org.text}</span>"

htmlForResults = (text, org)->
  attr = if org?.shared then " id='#{org.nodeId}' data-shared='true'" else ''
  """
  <div class='coderesults' data-org-type='results'#{attr}><span class='hidden'>#+RESULTS:\n</span><div class='resultscontent'><span></span><span class='hidden'>#{escapeHtml text}</span></div></div>"""

htmlForExpected = (text)->
  """
  <div class='codeexpected' data-org-type='expected'><div class='expectedcontent'><span>#{escapeHtml text}</span></div></div>"""

toggleDynamic = (event)->
  block = codeBlockForNode event.target
  resType = (if !block.hasAttribute 'data-org-type' then block.firstChild else block).getAttribute 'data-org-results'
  top = topNode block
  newNode = replaceCodeBlock block, changeResultType block.textContent, (if resType == 'dynamic' then 'static' else 'dynamic')
  if resType != 'dynamic' then executeSource top, $(newNode).find('[data-org-type="source"]')[0]

nonl = (txt)-> if txt[txt.length - 1] == '\n' then txt.substring 0, txt.length - 1 else txt

createResults = (srcNode)->
  srcNode = $(srcNode).closest('.codeblock')
  if created = (srcNode && !$(srcNode).find('.coderesults').length)
    $(srcNode).find('.codewrapper').append htmlForResults ''
  created

executeCode = (event)->
  selectPrevious codeBlockForNode event.target
  executeSource topNode(event.target), event.target, ->

#
# When to cancel line joins
# - BS at the start of a SRC block
# - DEL at the end of a SRC block
#
shouldCancelBS = (parent, r)-> atTextStart(r) && crossesHidden -1

atTextStart = (r)-> r.collapsed && (r.startContainer.nodeType == 1 || (r.startContainer.nodeType == 3 && r.startOffset == 0))

# returns:
# false if not at the end
# 1 if at the end
# 2 at an ending \n
atTextEnd = (r)-> r.collapsed && (r.startContainer.nodeType == 1 || (r.startContainer.nodeType == 3 &&
((r.startOffset == r.startContainer.length && 1) ||
  (r.startOffset == r.startContainer.length - 1 &&
  r.startContainer.textContent[r.startOffset] == '\n' && 2))))

shouldCancelDEL = (parent, r)-> (atEnd = atTextEnd r) && crossesHidden atEnd + 1

matchLineAt = (parent, pos)->
  text = parent.textContent
  start = text.substring(0, pos).lastIndexOf('\n')
  end = text.indexOf '\n', start + 1
  if end == -1 then end = text.length
  matchLine text.substring start + 1, end

slideStart = -> "<div class='slideholder'>"

slideEnd = -> "</div>"

firstSlideFlag = false

startNewSlide = (replace)->
  if replace then ''
  else if firstSlideFlag
    firstSlideFlag = false
    ''
  else "#{slideEnd()}#{slideStart()}"

createNoteShadows = ->
  for node in $('.slideholder')
    #setShadowHtml node, "<table class='slideshadow'><tr class='slideshadowrow'><td><content select='[data-org-note=\"main\"]'></content></td><td class='sidebar'><div class='sidebar'><div class='sidebarcontent'><content select='[data-org-note]'></content></div></div></td></tr></table>"
    setShadowHtml node, "<div class='page'><div class='border'></div><table class='pagecontent slideshadow'><tr class='slideshadowrow'><td class='slidemain'><content select='[data-org-note=\"main\"]'></content></td><td class='sidebar'><div class='sidebar'><div class='sidebarcontent'><content select='[data-org-note=\"sidebar\"]'></content></div></div></td></tr></table></div><content select='[data-org-note=\"skip\"],[data-float-holder]'></content>"
  for node in $('[data-float-holder]')
    holder = $(node)
    inside = $(node.firstChild)
    noteSpec = $(node).find('[data-org-floatval]').attr 'data-org-floatval'
    holder.draggable handle: 'h2'
    inside.resizable()
    holder.bind 'dragstop', (event) -> saveNoteLocation $(event.target)
    inside.bind 'resizestop', -> saveNoteLocation $(event.target)
    [skip, top, left, width, height] = noteSpec.split /\s+/
    window.setTimeout (->
      holder.css  top: top, left: left
      inside.css width: width, height: height), 1

markupGuts = (org, start)->
  if !org.children.length then ''
  else
    prev = if start then null else org
    hline = 'first'
    if org.level == 0 then firstSlideFlag = true
    guts = ((for c in org.children
      s = start
      start = false
      p = prev
      prev = c
      h = hline
      if c instanceof Headline then hline = 'inner'
      (hlineFor c, h) + markupNode(c, s)).join "") + (if org.level == 0 then "<hr class='last'>" else '')
    if org.level == 0
      "#{slideStart()}#{guts}#{slideEnd()}"
    else guts

hlineFor = (headline, hline)->
  if !(headline instanceof Headline) || headline.level != 1 then ''
  else "<hr class='#{hline}'>"

currentTextPosition = (parent, r)->
  if curPos > -1 then curPos
  else curPos = getTextPosition parent, r || getSelection().getRangeAt(0)

crossesHidden = (delta)->
  r = getSelection().getRangeAt 0
  !(0 <= r.startOffset < r.startContainer.length) && isCollapsed (if delta < 0 then textNodeBefore else textNodeAfter) r.startContainer

bindContent = (div)->
  div.addEventListener 'mousedown', (e)->
    if replaceUnrelatedPresenter e.target, emptyPresenter
      setCurKeyBinding null
  div.addEventListener 'keydown', handleKey div
  div.addEventListener 'DOMCharacterDataModified', handleMutation, true
  div.addEventListener 'DOMSubtreeModified', handleMutation, true
  displaySource()

handleKey = (div)->(e)->
  curPos = -1
  c = (e.charCode || e.keyCode || e.which)
  if !addKeyPress e, c then return
  s = getSelection()
  r = (if s.rangeCount > 0 then s.getRangeAt(0) else null)
  [bound, checkMod] = findKeyBinding e, div, r
  if bound then cancelled = !checkMod
  else
    checkMod = modifyingKey c
    cancelled = false
  if String.fromCharCode(c) == 'C' && e.altKey
    root.orgApi.executeSource div, getSelection().focusNode
  else if !bound #&& !slideMode
    if modifyingKey c
      n = s.focusNode
      el = r.startContainer
      par = el.parentNode
      currentMatch = matchLine currentLine div
      edited n
      if c == ENTER
        e.preventDefault()
        if n.nodeType == 3 && r.collapsed && r.startOffset == n.length && n.parentNode.getAttribute('data-org-type') == 'text'
          br = document.createTextNode('\n')
          $(br).prependTo followingSpan n.parentNode
        else r.insertNode br = document.createTextNode(checkExtraNewline r, n, div)
        r.setStart br, br.length
        r.setEnd br, br.length
        s.removeAllRanges()
        s.addRange(r)
        restorePosition br.parentNode, -> br.parentNode.normalize()
        setTimeout (->checkEnterReparse div, r), 1
      else if c in [BS, DEL]
        if (c == BS && shouldCancelBS div, r) || (c == DEL && shouldCancelDEL div, r)
          e.preventDefault()
          return
        else if c == BS && bsWillDestroyParent r
          e.preventDefault()
          el.data = el.data.substring 1
      else if el.nodeType == 3
        setTimeout (->
          fancyCheckSourceMod n, div, currentMatch, el
        ), 1
        return
  if !cancelled && checkMod
    if (getOrgType getOrgParent el) == 'boundary' then needsReparse = true
    setTimeout (->fancyCheckSourceMod n, div, currentMatch, (if el.nodeType == 1 then el.firstChild else el)), 1

getCodeContainer = (node)->
  node && ((node.getAttribute?('data-org-src') && node) || (!node.getAttribute?('data-org-type') && getCodeContainer node.parentNode))

fancyCheckSourceMod = (focus, div, currentMatch, el)->
  if code = getCodeContainer focus then recreateAstButtons div, code
  else if needsNewline el
    restorePosition el.parentNode, ->
      el.data += '\n'
      el.parentNode.normalize()
  checkSourceMod div, currentMatch

needsNewline = (el)->
  if !el then false
  else if el.nodeType == 3 then needsNewline el.parentNode
  else el.nodeType == 1 && $(el).is('[data-newline]')

bsWillDestroyParent = (r)->
  if r.startContainer.nodeType == 3 && r.startOffset == 1 && r.startContainer.data.match /^.\n?$/
    r.startContainer.parentNode.textContent == r.startContainer.data
  else false

allowEvents = true

handleMutation = (evt)->
  if allowEvents
    invalidateOrgText()
    displaySource()

executeSource = (parent, node, cont, skipTests)->
  doc = topNode node
  [srcNode, text] = getNodeSource node
  if srcNode
    createResults srcNode
    if text.trim().length
      executeText text.trim(), propsFor(srcNode), orgEnv(parent, srcNode), ->
        cont?()
        if !skipTests then runAutotests doc

fancyExecuteDef = (node, cont)->
  doc = topNode node
  executeDef node, ->
    cont?()
    runAutotests doc

runAutotests = (doc)->
  for n in $(doc).find("[data-org-results='autotest']").add($(doc).find("[data-org-update~='any']"))
    runTest doc, n

runTest = (doc, node)-> executeSource doc, node, (if $(node).is("[data-org-results='autotest']") then (-> checkTestResults node)), true

checkTestResults = (node)->
  node.setAttribute 'data-org-test', (if node.getAttribute('data-org-expected') == $(node).find('.resultscontent').text() then 'pass' else 'fail')

reprocessResults = (node)->
  if node.firstChild.shadowRoot
    node.firstChild.shadowRoot.innerHTML = ''
    node.firstChild.shadowRoot.applyAuthorStyles = true
  processResults node.firstChild.nextElementSibling.textContent, node, true

processResults = (str, node, skipText)->
  if !node.firstChild.shadowRoot
    node.firstChild.createShadowRoot()
    node.firstChild.shadowRoot.applyAuthorStyles = true
  shadow = node.firstChild.shadowRoot
  if !skipText
    node.firstChild.nextElementSibling.textContent += escapePresentationHtml(str.substring 0, str.length - 1) + str[str.length - 1]
    edited node
  classes = 'resultsline'
  if theme != null then classes = theme + ' ' + classes
  if $("body").hasClass 'bar_collapse' then classes += ' bar_collapse'
  for line in splitLines str
    if line.match /^: / then shadow.innerHTML += "<div class='#{classes}'>#{line.substring(2)}</div>"
  $(shadow.firstChild).attr 'data-shadowdom', 'true'

setShadowHtml = (holder, html)->
  if !(el = holder.shadowRoot)
    el = holder.createShadowRoot()
    el.applyAuthorStyles=true
  el.innerHTML = html
  $(el.firstChild).attr 'data-shadowdom', 'true'
  if theme != null then $(el.firstChild).addClass(theme)
  if $("body").hasClass 'bar_collapse' then $(el.firstChild).addClass('bar_collapse')

redrawIssue = (issue)->
  issueName = issue.leisureName
  if (name = $("[data-org-comments='#{issueName}']")).length
    count = issue.comments.length + 1
    button = $("[data-org-codeblock='#{issueName}'] button.comment-button")
    if button.attr('data-org-commentcount') != count
      button.attr 'data-org-commentcount', count
      button.addClass 'new-comments'
    setShadowHtml button.find('span')[0], count
    setShadowHtml name[0].firstChild, "<div class='#{theme ? ''}'>#{commentHtml issue, 'main'}#{(commentHtml c, 'added' for c in issue.comments).join ''}#{newCommentBox issueName, $(name[0].parentNode).find('.codeblock').attr 'id'}</div>"

commentHtml = (comment, type)->
  "<div class='commentbox'><img src='http://gravatar.com/avatar/#{comment.user.gravatar_id}?s=48'><div class='#{type}'>#{comment.body}</div></div>"

newCommentBox = (name, codeId)->
  "<div><textarea pseudo='x-new-comment'></textarea><br><button class='add_comment' onclick='Leisure.addComment(\"#{name}\", event)'>Add Comment</button></div>"

colonify = (str)-> ': ' + (str.replace /[\n\\]/g, (c)-> if c == '\n' then '\\n' else '\\\\') + '\n'

clearResults = (node)->
  if (r = node.firstChild.shadowRoot) then r.innerHTML = ''
  node.firstChild.nextElementSibling.innerHTML = ''

# like orgSupport's orgEnv, but wrap the leading ': ' in hidden spans
orgEnv = (parent, node)->
  #r = getResultsForSource parent, node
  r = node
  if !$(r).is('.resultscontent') then r = $(r).find('.resultscontent')[0]
  if r
    clearResults r
    __proto__: defaultEnv
    readFile: (filename, cont)-> window.setTimeout (->$.get filename, (data)-> cont false, data), 1
    write: (str)-> processResults (colonify (String str)), r
    presentValue: presentValue
    newCodeContent: (name, con)-> console.log "NEW CODE CONTENT: #{name}, #{con}"
    prompt: (msg, cont)-> cont prompt rz msg
  else
    __proto__: defaultEnv
    readFile: (filename, cont)-> window.setTimeout (->$.get filename, (data)-> cont false, data), 1
    write: (str)-> console.log colonify str
    newCodeContent: (name, con)-> console.log "NEW CODE CONTENT: #{name}, #{con}"
    prompt: (msg, cont)-> cont prompt rz msg

#################
# Value sliders
#################

hideSlider = (numberSpan)-> replaceRelatedPresenter numberSpan, emptyPresenter

showSliderButton = (parent, numberSpan)->
  if hideSlider numberSpan then return
  inside = false
  sliding = false
  d = $("<div style='z-index: 1; position: absolute; width: 200px; background: white; border: solid green 1px' slider contentEditable='false'></div>")[0]
  d.style.top = "#{numberSpan.offsetTop + numberSpan.offsetHeight + 5}px"
  d.style.minTop = '0px'
  d.style.left = "#{Math.max(0, numberSpan.offsetLeft + numberSpan.offsetWidth/2 - 100)}px"
  d.addEventListener 'mouseover', (e)->
    if !inside then inside = true
  d.addEventListener 'mouseout', (e)->
    if e.toElement != d && !d.contains e.toElement
      inside = false
      if !sliding then hideSlider numberSpan
  value = Number numberSpan.textContent
  min = if value < 0 then value * 2 else value / 2
  max = if value == 0 then 10 else value * 2
  orgParent = getOrgParent numberSpan
  orgType = orgParent.getAttribute 'data-org-results'
  computing = false
  sl = $(d).slider
    animate: 'fast'
    start: ->
      sliding = true
      allowEvents = false
      true
    stop: (event, ui)->
      setMinMax sl
      allowEvents = true
      sliding = false
      if !inside then hideSlider numberSpan
    slide: (event, ui)->
      numberSpan.innerHTML = String(ui.value)
      if !computing && orgType in ['dynamic', 'def']
        computing = true
        done = -> computing = false
        setTimeout (->
          if orgType == 'dynamic' then root.orgApi.executeSource parent, numberSpan.parentNode, done
          else if orgType == 'def' then root.orgApi.executeDef orgParent, done), 1
    value: value
  parent.insertBefore d, numberSpan
  setMinMax sl, value
  replacePresenter
    numberSpan: numberSpan
    hide: ->
      d.remove()
    isRelated: (node)-> (isOrContains d, node) || (isOrContains numberSpan, node)
  d.focus()

psgn = (x)-> if x < 0 then -1 else 1

setMinMax = (sl, value)->
  value = value || sl.slider("value")
  min = 0
  max = if 1 <= Math.abs(value) < 50 or value == 0 then 100 * psgn(value) else value * 2
  step = (max - min) / 100
  if Math.round(value) == value
    step = Math.round(step)
    step = Math.max(1, step - step % (max - min))
  sl.slider "option", "min", min
  sl.slider "option", "max", max
  sl.slider "option", "step", step

setCurrentSlide = (element)->
  for node in $('.currentSlide')
    if node.shadowRoot then $(node.shadowRoot.firstElementChild).removeClass 'currentSlide'
  $('.currentSlide').removeClass 'currentSlide'
  $(element).addClass 'currentSlide'
  if $(element).hasClass 'firstSlide' then $("body").addClass 'firstSlide' else $("body").removeClass 'firstSlide'
  if $(element).hasClass 'lastSlide' then $("body").addClass 'lastSlide' else $("body").removeClass 'lastSlide'
  # this is needed until there is support for :host (and/or ^ & ^^)
  if element.shadowRoot then $(element.shadowRoot.firstElementChild).addClass 'currentSlide'

firstSlide = -> setCurrentSlide $('[data-org-headline="1"]')[0]

lastSlide = ->
  slides = $('[data-org-headline="1"]')
  setCurrentSlide slides[slides.length - 1]

nextSlide = ->
  if slide = $('.currentSlide')[0]
    while slide = slide.nextElementSibling
      if $(slide).is('[data-org-headline="1"]') then return setCurrentSlide slide

prevSlide = ->
  if slide = $('.currentSlide')[0]
    while slide = slide.previousElementSibling
      if $(slide).is('[data-org-headline="1"]') then return setCurrentSlide slide

showSlides = ->
  setCurrentSlide $('[data-org-headline="1"]')[0]
  document.body.classList.add 'slides'

slideParent = (node)->
  while node && !$(node).is '[data-org-headline="1"]'
    node = node.parentNode
  node

documentTop = (node)->
  top = 0
  while node
    if node.tagName
      top = top + node.offsetTop
      node = node.offsetParent
    else node = node.parentNode
  top

hideSlides = ->
  document.body.classList.remove 'slides'
  $('body').removeClass 'firstSlide'
  $('body').removeClass 'lastSlide'

slideBindings =
  'PAGEUP': (e, parent, r)->
    e.preventDefault()
    prevSlide()
    false
  'PAGEDOWN': (e, parent, r)->
    e.preventDefault()
    nextSlide()
    false
  'S-PAGEUP': (e, parent, r)->
    e.preventDefault()
    firstSlide()
    false
  'S-PAGEDOWN': (e, parent, r)->
    e.preventDefault()
    lastSlide()
    false
  'C-PAGEUP': (e, parent, r)->
    e.preventDefault()
    firstSlide()
    false
  'C-PAGEDOWN': (e, parent, r)->
    e.preventDefault()
    lastSlide()
    false

toggleSlides = ->
  slideMode = !slideMode
  fancyOrg.bindings = (if slideMode then slideBindings else defaultBindings)
  $('#prevSlide:not(.bound)').addClass('bound').bind('click',  prevSlide);
  $('#nextSlide:not(.bound)').addClass('bound').bind('click',  nextSlide);
  if slideMode
    s = $('[data-org-headline="1"]')
    s.first().addClass 'firstSlide'
    s.last().addClass 'lastSlide'
    restorePosition null, ->
      $('[data-org-html]').addClass 'slideHtml'
      $('body').addClass 'slides'
      firstSlide()
  else
    $('[data-org-headline="1"]').first().removeClass 'firstSlide'
    $('[data-org-headline="1"]').last().removeClass 'lastSlide'
    $('body').removeClass 'slides'
    $('body').removeClass 'firstSlide'
    $('body').removeClass 'lastSlide'
    $('[data-org-html]').removeClass 'slideHtml'

theme = null

setTheme = (str)->
  el = $('body')
  #all = $('[data-org-headline="1"]').add($('[data-org-comments]').find(':first-child')).add($('.resultscontent').find(':first-child')).add($('[data-org-html]').find(':first-child')).add($('[data-org-note-content]')).add('.slideholder')
  all = $('[data-org-comments]').find(':first-child').add($('.resultscontent').find(':first-child')).add($('[data-org-html]').find(':first-child')).add($('[data-org-note-content]')).add('.slideholder')
  for node in all
    if node.shadowRoot then el = el.add(node.shadowRoot.firstElementChild)
  if theme && theme != str then el.removeClass theme
  theme = str
  if str then el.addClass str
  for t in $("style.theme")
    $(t).prop 'disabled', true
  $("style#" + theme).removeProp 'disabled'
  dd = $("#themeSelect")
  if dd then dd.val theme

define 'setTheme', lz (str)->
  makeSyncMonad (env, cont)->
    if str != theme then setTheme rz str
    cont rz L_true

define 'toggleSlides', lz makeSyncMonad (env, cont)->
  toggleSlides()
  cont rz L_true

slideOffset = (slide)->
  if slide
    a = []
    a.push $("[data-org-headline='1']")...
    a.indexOf slide ? $('.currentSlide')[0]
  else -1

setSlideAt = (index)-> setCurrentSlide $("[data-org-headline='1']")[index]

restoreSlide = (block)->
  if !slideMode then block()
  else
    offset = slideOffset()
    block()
    setSlideAt offset

fancyOrg =
  __proto__: orgNotebook
  markupOrg: markupOrg
  markupOrgWithNode: markupOrgWithNode
  bindContent: bindContent
  installOrgDOM: (parent, orgNode, orgText, target)->
    @parent = parent
    restorePosition parent, ->
      parent.setAttribute 'class', 'org-fancy'
      parent.setAttribute 'maindoc', ''
      orgNotebook.installOrgDOM parent, orgNode, orgText, target
      fixupHtml parent
      setTheme theme
      nextNoteId = 0
      #for node in $(parent).find('[data-org-notes]')
      #  createNotes node
      $(".image-draggable").draggable()
      createNoteShadows()
      setTimeout (=>
        redrawAllIssues()
        ), 1
      $(document).tooltip()
  executeSource: executeSource
  executeDef: fancyExecuteDef
  createResults: createResults
  bindings: defaultBindings
  redrawIssue: (i)-> redrawIssue i
  leisureButton: ->
    restorePosition @parent, ->
      toggleSlides()
      if slideMode then setTimeout (-> if !getSelection().focusNode then $('[maindoc]').focus()), 1
      else swapMarkup()

# called on installing DOM and also on new notes
fixupHtml = (parent, note)->
  for node in $(parent).find('[data-org-html]')
    setShadowHtml node, node.innerHTML
    node.innerHTML = ''
  for node in $(parent).find('[data-org-src]')
    recreateAstButtons parent, node
  for node in $(parent).find('.resultscontent')
    reprocessResults node
  #for node in $(parent).find('[data-org-headline="1"]')
  #  setShadowHtml node, "<div class='page'><div class='border'></div><div class='pagecontent'><content></content></div></div>"
  createNoteShadows()
  if !note
    #for node in $(parent).find('[data-org-headline="1"]')
    for node in $(parent).find('[data-org-headline="1"] .maincontent')
      $("button.create_note").remove()
      $("<button class='create_note'><i class='fa fa-file-text-o'></i></button>").prependTo(node).click (e)->
        e.preventDefault()
        root.currentMode.createNote()
  setTimeout (=>
    for node in $(parent).find('[data-org-comments]')
      setShadowHtml node.firstElementChild, newCommentBox node.getAttribute('data-org-comments'), $(node.parentNode).find('.codeblock').attr 'id'
    ), 1

root.fancyOrg = fancyOrg
root.toggleComment = toggleComment
root.addComment = addComment
root.recreateAstButtons = recreateAstButtons
root.setTheme = setTheme
root.createTestCase = createTestCase
root.executeCode = executeCode
root.toggleDynamic = toggleDynamic
root.getDocRange = getDocRange
root.restoreDocRange = restoreDocRange
root.getDocumentOffset = getDocumentOffset
