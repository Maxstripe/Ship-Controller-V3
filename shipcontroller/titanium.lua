local files = {
["MThemeManager.ti"]="local c=os.clock()local function d()os.queueEvent\"themeYield\"\
os.pullEvent\"themeYield\"c=os.clock()end\
class\"MThemeManager\"abstract(){themes={}}\
function MThemeManager:addTheme(_a)\
self:removeTheme(_a)table.insert(self.themes,_a)self:groupRules()end\
function MThemeManager:removeTheme(_a)\
local aa=(type(_a)==\"string\"and true)or(not\
Titanium.typeOf(_a,\"Theme\",true)and error\"Invalid target to remove\")local ba=self.themes;for i=1,#ba do\
if\
(aa and ba[i].name==_a)or(not aa and ba[i]==_a)then table.remove(ba,i)self:groupRules()return true end end end;function MThemeManager:importTheme(_a,aa)\
self:addTheme(Theme.fromFile(_a,aa))end\
function MThemeManager:groupRules()\
local _a,aa=self.themes,{}\
for i=1,#_a do\
for ba,ca in pairs(_a[i].rules)do if not aa[ba]then aa[ba]={}end;local da=aa[ba]for _b,ab in\
pairs(ca)do if not da[_b]then da[_b]={}end;local bb=da[_b]\
for r=1,#ab do bb[#bb+1]=ab[r]end end end end;self.rules=aa;self:dispatchThemeRules()end;function MThemeManager:dispatchThemeRules()local _a=self.collatedNodes;d()\
for i=1,#_a do if\
os.clock()-c>8 then d()end;_a[i]:retrieveThemes()end end",
["QueryParser.ti"]="\
local function b(c)if c==\"true\"then return true elseif c==\"false\"then return false end\
return\
tonumber(c)or\
error(\"Invalid value passed for parsing '\"..tostring(c)..\"'\")end;class\"QueryParser\"extends\"Parser\"function QueryParser:__init__(c)\
self:super(QueryLexer(c).tokens)end\
function QueryParser:parse()local c,d,_a={},{},{}local aa\
local function ba()if next(_a)then\
table.insert(d,_a)_a={direct=aa}aa=nil end end;local ca=self:stepForward()\
while ca do\
if ca.type==\"QUERY_TYPEOF\"then if _a.ambiguous then\
self:throw\"Attempted to set query section as 'ambiguous' using typeof operator (~). Already set as ambiguous (trailing ~)\"end\
_a.ambiguous=true elseif ca.type==\"QUERY_TYPE\"then if _a.type then\
self:throw(\"Attempted to set query type to '\"..ca.value..\"' when already set as '\"..\
_a.type..\"'\")end\
_a.type=ca.value elseif ca.type==\"QUERY_CLASS\"then if not _a.classes then _a.classes={}end\
table.insert(_a.classes,ca.value)elseif ca.type==\"QUERY_ID\"then if _a.id then\
self:throw(\"Attempted to set query id to '\"..ca.value..\
\"' when already set as '\".._a.id..\"'\")end;_a.id=ca.value elseif\
ca.type==\"QUERY_SEPERATOR\"then\
if\
self.tokens[self.position+1].type~=\"QUERY_DIRECT_PREFIX\"then ba()end elseif ca.type==\"QUERY_END\"then ba()if next(d)then table.insert(c,d)d={}else\
self:throw(\"Unexpected '\"..\
ca.value..\"' found, no left hand query\")end elseif\
ca.type==\"QUERY_COND_OPEN\"then _a.condition=self:parseCondition()elseif\
ca.type==\"QUERY_DIRECT_PREFIX\"and not aa then aa=true else\
self:throw(\"Unexpected '\"..\
ca.value..\"' found while parsing query\")end;ca=self:stepForward()end;ba()if next(d)then table.insert(c,d)end;self.query=c end\
function QueryParser:parseCondition()local c,d={},{}local _a=self:stepForward()\
while true do\
if\
_a.type==\
\"QUERY_COND_ENTITY\"and(d.symbol or not d.property)then d[d.symbol and\"value\"or\"property\"]=\
d.symbol and b(_a.value)or _a.value elseif _a.type==\
\"QUERY_COND_STRING_ENTITY\"and d.symbol then d.value=_a.value elseif\
_a.type==\
\"QUERY_COND_SYMBOL\"and not d.property and _a.value==\"#\"then d.modifier=_a.value elseif\
_a.type==\"QUERY_COND_SYMBOL\"and(d.property)then d.symbol=_a.value elseif\
_a.type==\"QUERY_COND_SEPERATOR\"and next(d)then c[#c+1]=d;d={}elseif _a.type==\"QUERY_COND_CLOSE\"and(not d.property or\
(d.property and d.value))then break else\
self:throw(\
\"Unexpected '\".._a.value..\"' inside of condition block\")end;_a=self:stepForward()end;if next(d)then c[#c+1]=d end;return#c>0 and c or nil end",
["Theme.ti"]="\
local function c(_a)\
return\
\
(_a.arguments.id and(\"#\".._a.arguments.id)or\"\").. (function(aa)local ba=\"\"for ca in aa:gmatch(\"%S+\")do ba=ba..\".\"..ca end;return ba end)(\
_a.arguments[\"class\"]or\"\")end\
local function d(_a,aa)\
for i=1,#aa do local ba=aa[i].children\
if ba then for n=1,#ba do local ca=aa[i].type\
_a[#_a+1]={(\
aa[i].arguments.typeOf and\"~\"or\"\")..\
(ca==\"Any\"and\"*\"or ca)..c(aa[i]),ba[n],aa[i]}end end end;return _a end;class\"Theme\"{name=false,rules={}}\
function Theme:__init__(_a,aa)\
self.name=\
type(_a)==\"string\"and _a or\
error(\"Failed to initialise Theme. Name '\"..\
tostring(_a)..\"' is invalid, expected string.\")if aa then self.rules=Theme.parse(aa)end end\
function Theme.static.parse(_a)\
local aa,ba,ca=d({},XMLParser(_a).tree),{},1\
local function da(_b)local ab,bb=_b[1],_b[2]local cb=bb.children\
if cb then\
for n=1,#cb do\
if\
not Titanium.getClass(bb.type)and bb.type~=\"Any\"then return\
error(\"Failed to generate theme data. Child target '\"..bb.type..\
\"' doesn't exist as a Titanium class\")end;local db=bb.type\
aa[#aa+1]={ab..\" \"..\
\
(bb.arguments.direct and\"> \"or\"\").. (db==\"Any\"and\"*\"or db)..c(bb),cb[n],bb}end elseif bb.content then local db=_b[3].type;local _c=bb.arguments.dynamic\
local ac,bc,cc,dc=db,false,bb.content,bb.type\
if db==\"Any\"then ac,bc=\"ANY\",true elseif not _c then\
local _d=Titanium.getClass(db).getRegistry()\
local ad=_d.constructor and _d.constructor.argumentTypes or{}if _d.alias[bb.type]then dc=_d.alias[bb.type]end\
cc=XMLParser.convertArgType(cc,ad[\
_d.alias[bb.type]or bb.type])end;if _c then cc=bb.content end;if not ba[ac]then ba[ac]={}end;if\
not ba[ac][ab]then ba[ac][ab]={}end\
table.insert(ba[ac][ab],{computeType=not _c and bc or nil,property=dc,value=cc,important=bb.arguments.important,isDynamic=_c})else return\
error(\"Failed to generate theme data. Invalid theme rule found. No value (XML_CONTENT) has been set for tag '\"..bb.type..\"'\")end end;while ca<=#aa do da(aa[ca])ca=ca+1 end;return ba end\
function Theme.static.fromFile(_a,aa)if not fs.exists(aa)then\
return error(\"Path '\"..\
tostring(aa)..\"' cannot be found\")end;local ba=fs.open(aa,\"r\")\
local ca=ba.readAll()ba.close()return Theme(_a,ca)end",
["Pane.ti"]="class\"Pane\"\
extends\"Node\"{backgroundColour=colours.black,allowMouse=true,useAnyCallbacks=true}\
function Pane:__init__(...)self:resolve(...)self:super()end\
function Pane:draw(a)local b=self.raw;if b.changed or a then b.canvas:clear()\
b.changed=false end end\
function Pane:onMouse(a,b,c)if not c or b then return end;a.handled=true end\
configureConstructor({orderedArguments={\"X\",\"Y\",\"width\",\"height\",\"backgroundColour\"}},true)",
["DynamicEqParser.ti"]="local d={\"NAME\",\"STRING\",\"NUMBER\",\"PAREN\",\"QUERY\"}\
local _a={\"binary\",\"ambiguos\"}local aa={\"unary\",\"ambiguos\"}class\"DynamicEqParser\"\
extends\"Parser\"{state=\"root\",stacks={{}},output=\"local args = ...; return \"}function DynamicEqParser:__init__(ba)\
self:super(DynamicEqLexer(ba).tokens)end\
function DynamicEqParser:testForOperator(ba,ca,da,_b,ab)\
local bb,cb,db=self:testAdjacent(ba and\
\"OPERATOR\",ca and\"OPERATOR\",false,_b,ab,not da)if not bb then return false end\
local function _c(cc,dc)\
if not cc then return true elseif not dc then return false end\
if type(dc)==\"table\"then for i=1,#dc do\
if cc[dc[i]]or dc[i]==\"*\"then return true end end else if type==\"*\"then return true end;return cc[dc]end end;local ac,bc=_c(cb,ba),_c(db,ca)if ba and ca then return ac and bc else return\
(ba and ac)or(ca and bc)end end\
function DynamicEqParser:testForTerms(ba,ca,da)return\
self:testAdjacent(ba and d,ca and d,false,false,false,not da)end\
function DynamicEqParser:resolveStacks(ba,ca)local da,_b=self.stacks,{}\
for i=1,#da-\
(#da[#da]==0 and 1 or 0)do local ab=da[i]if#ab<=1 then\
self:throw(\"Invalid stack '\"..\
ab[1]..\"'. At least 2 parts must exist to resolve\")end;local bb,cb=ab[1]\
if bb==\"self\"then\
cb=ba elseif bb==\"parent\"then cb=ba.parent elseif bb==\"application\"then cb=ba.application elseif\
bb:sub(1,1)==\"{\"then\
if not ba.application then if ca then return end\
self:throw\"Cannot resolve stacks. Resolution of node queries requires an application instance be set on the target\"end\
local db=NodeQuery(ba.application,bb:sub(2,-2)).result;if not db then if ca then return end\
self:throw(\"Failed to resolve stacks. Node query '\"..bb..\"' resolved to 0 nodes\")end;cb=db[1]else\
self:throw(\
\"Invalid stack start '\"..bb..\"'. Only self, parent and application allowed\")end\
for p=2,#ab-1 do if not cb then\
self:throw(\"Failed to resolve stacks. Index '\"..ab[p]..\
\"' could not be accessed on '\"..tostring(cb)..\"'\")end\
cb=cb[ab[p]]end;if not cb then if ca then return end;self:throw\"Invalid instance\"elseif not ab[#ab]then\
self:throw\"Invalid property\"end\
_b[#_b+1]={ab[#ab],cb}end;return _b end\
function DynamicEqParser:appendToOutput(ba)self.output=self.output.. (ba or\
self:getCurrentToken().value)end\
function DynamicEqParser:parseRootState(ba)\
ba=ba or self:getCurrentToken()\
if ba.type==\"NAME\"then local ca={\"OPERATOR\",\"DOT\",\"PAREN\"}if not\
self:testAdjacent(ca,ca)then\
self:throw(\"Unexpected name '\"..ba.value..\"'\")end\
self:appendToStack(ba.value)self:setState\"name\"\
self:appendToOutput(\"args[\"..#self.stacks..\"]\")elseif ba.type==\"PAREN\"then\
if ba.value==\"(\"then\
if not\
( (self:testForOperator(_a,false,true)or\
self:testAdjacent\"PAREN\")and(self:testForTerms(false,true)or\
self:testForOperator(false,aa)))then\
self:throw(\
\"Unexpected parentheses '\"..ba.value..\"'\")end elseif ba.value==\")\"then if not\
(self:testForTerms(true)and self:testForOperator(false,_a,true))then\
self:throw(\"Unexpected parentheses '\"..ba.value..\"'\")end else\
self:throw(\
\"Invalid parentheses '\"..ba.value..\"'\")end;self:appendToOutput()elseif ba.type==\"STRING\"then local ca=self:testForOperator\"unary\"and\
1 or 0\
if\
not\
(\
(\
self:testForOperator(_a,false,false,ca)or self:testAdjacent(\"PAREN\",false,false,ca))and\
(self:testForOperator(false,_a,true)or self:testAdjacent(false,\"PAREN\")))then\
self:throw(\"Unexpected string '\"..ba.value..\"'\")end\
self:appendToOutput((\"%s%s%s\"):format(ba.surroundedBy,ba.value,ba.surroundedBy))elseif ba.type==\"NUMBER\"then if not\
self:testAdjacent({\"OPERATOR\",\"PAREN\"},{\"OPERATOR\",\"PAREN\"},false,false,false)then\
self:throw(\"Unexpected number '\"..ba.value..\"'\")end\
self:appendToOutput()elseif ba.type==\"OPERATOR\"then\
if ba.unary then\
if not\
(self:testForTerms(false,true)and(\
self:testForOperator(_a)or self:testAdjacent\"PAREN\"))then\
self:throw(\"Unexpected unary operator '\"..ba.value..\
\"'. Operator must follow a binary operator and precede a term\")end elseif ba.binary then\
if not\
(self:testForTerms(true)and(self:testForOperator(false,\"unary\")or\
self:testForTerms(false,true)))then\
self:throw(\"Unexpected binary operator '\"..\
\
ba.value..\"'. Expected terms before and after operator, or unary operator following\")end elseif ba.ambiguos then local ca=self:testForTerms(false,true)\
if not\
(\
(\
(ca or(\
self:testForOperator(false,aa)and self:testForTerms(true)))and self:testForTerms(true,false,true))or(self:testForOperator(_a)and ca))then\
self:throw(\
\"Unexpected ambiguos operator '\"..ba.value..\"'\")end else\
self:throw(\"Unknown operator '\"..ba.value..\"'\")end\
self:appendToOutput((\" %s \"):format(ba.value))elseif ba.type==\"QUERY\"then self:appendToStack(ba.value)\
self:setState\"name\"\
self:appendToOutput(\"args[\"..#self.stacks..\"]\")else\
self:throw(\"Unexpected block '\"..\
ba.value..\"' of token type '\"..ba.type..\"'.\")end end\
function DynamicEqParser:parseNameState(ba)\
ba=ba or self:getCurrentToken()\
if ba.type==\"DOT\"then local ca=self:peek()\
if ca and ca.type==\"NAME\"then\
self:stepForward()self:appendToStack(ca.value)else local da=self:getStack()\
self:throw(\
\"Failed to index '\"..table.concat(da,\".\")..\"'. No name following dot.\")end else self:setState\"root\"table.insert(self.stacks,{})\
self:parseRootState(ba)end end;function DynamicEqParser:getStack(ba)return\
self.stacks[#self.stacks+ (ba or 0)]end;function DynamicEqParser:appendToStack(ba,ca)\
table.insert(self:getStack(ca),ba)end;function DynamicEqParser:setState(ba)\
self.state=ba end\
function DynamicEqParser:parse()\
local ba=self:stepForward()\
while ba do\
if self.state==\"root\"then self:parseRootState()elseif self.state==\"name\"then\
self:parseNameState()else\
self:throw(\"Invalid parser state '\"..self.state..\"'\")end;ba=self:stepForward()end end",
["KeyEvent.ti"]="class\"KeyEvent\"\
extends\"Event\"{main=\"KEY\",sub=false,keyCode=false,keyName=false}\
function KeyEvent:__init__(a,b,c,d)self.name=a\
self.sub=d or a==\"key_up\"and\"UP\"or\"DOWN\"self.held=c;self.keyCode=b;self.keyName=keys.getName(b)\
self.data={a,b,c}end",
["MKeyHandler.ti"]="class\"MKeyHandler\"\
abstract(){static={keyAlias={}},keys={},hotkeys={}}\
function MKeyHandler:handleKey(a)local b=a.keyCode\
if a.sub==\"DOWN\"then self.keys[b]=a.held\
self:checkHotkeys(b)else self.keys[b]=nil;self:checkHotkeys()end end\
function MKeyHandler:isPressed(a)return self.keys[a]~=nil end;function MKeyHandler:isHeld(a)return self.keys[a]end\
function MKeyHandler:matchesHotkey(a,b)\
for c in\
a:gmatch\"(%w-)%-\"do if self.keys[keys[c]]==nil then return false end end;return b==keys[a:gsub(\".+%-\",\"\")]end\
function MKeyHandler:registerHotkey(a,b,c)\
if\
not(type(a)==\"string\"and type(b)==\"string\"and\
type(c)==\"function\")then return error\"Expected string, string, function\"end;self.hotkeys[a]={b,c}end\
function MKeyHandler:checkHotkeys(a)for b,c in pairs(self.hotkeys)do if self:matchesHotkey(c[1],a)then\
c[2](self,a)end end end",
["MProjectorManager.ti"]="class\"MProjectorManager\"abstract(){projectors={}}\
function MProjectorManager:updateProjectors()\
local a,b=self.projectors;for i=1,#a do b=a[i]\
if b.changed then b:updateDisplay()b.changed=false end end end\
function MProjectorManager:addProjector(a)local b=self.projectors;for i=1,#b do\
if b[i].name==a.name then return\
error(\
\"Failed to register projector instance. Projector name '\"..a.name..\"' is already in use\")end end;b[\
#b+1]=a;a.application=self;if self.focusedNode then\
self.focusedNode:resolveProjectorFocus()end end\
function MProjectorManager:removeProjector(a)local b=type(a)==\"string\"\
if not b and not\
Titanium.typeOf(a,\"Projector\",true)then return\
error(\"Cannot perform search for projector using target '\"..\
tostring(a)..\"' to remove.\")end;local c,d=self.projectors;for i=1,#c do d=c[i]\
if\
(b and d.name==a)or(not b and d==a)then d.application=false;table.remove(c,i)return true,d end end;return false end\
function MProjectorManager:getProjector(a)local b=self.projectors;for i=1,#b do\
if b[i].name==a then return b[i]end end end",
["TML.ti"]="\
local function b(c,d)local _a=c:getRegistry()local aa,ba,ca=_a.constructor,_a.alias,d.arguments;local da=\
aa.requiredArguments or{}local _b,ab,bb={},{},{}if not aa then return nil end\
if\
aa.tmlContent and d.content then ca[aa.tmlContent]=d.content end;local cb=aa.argumentTypes\
local function db(cc,dc)if type(cc)~=\"string\"then return false end\
local _d,ad=cc:match\"^(%%*)%$(.*)$\"if not _d or#_d%2 ~=0 then return false end;bb[dc]=ad;return true end;local _c,ac,bc=aa.orderedArguments,{}\
for i=1,#_c do bc=_c[i]local cc=cb[ba[bc]or bc]\
local dc=ca[bc]\
if dc then\
if db(dc,bc)then\
_b[i]=\
cc==\"string\"and\"\"or(\
(cc==\"number\"or cc==\"colour\")and 1 or(cc==\"boolean\"))or error\"invalid argument type\"else _b[i]=XMLParser.convertArgType(dc,cc)end end;ac[_c[i]]=true end;for cc,dc in pairs(ca)do\
if not ac[cc]then if not db(dc,cc)then\
ab[cc]=XMLParser.convertArgType(dc,cb[ba[cc]or cc])end end end;if next(ab)then\
_b[#_c+1]=ab end;return\
c(unpack(_b,1,next(ab)and#_c+1 or#_c)),bb end;class\"TML\"{tree=false,parent=false}\
function TML:__init__(c,d)\
self.parent=c;self.tree=XMLParser(d).tree;self:parseTree()end\
function TML:parseTree()local c={{self.parent,self.tree}}local d,_a,aa,ba=1,{}\
while d<=#\
c do aa,ba=c[d][1],c[d][2]local ca\
for t=1,#ba do ca=ba[t]\
if aa:can\"addTMLObject\"then\
local da,_b=aa:addTMLObject(ca)if da and _b then table.insert(c,{da,_b})end else\
local da=ca.arguments[\"class\"]if da then ca.arguments[\"class\"]=nil end\
local _b=\
Titanium.getClass(ca.type)or\
error(\"Failed to spawn XML tree. Failed to find class '\"..ca.type..\"'\")if not Titanium.typeOf(_b,\"Node\")then\
error(\"Failed to spawn XML tree. Class '\"..ca.type..\
\"' is not a valid node\")end\
local ab,bb=b(_b,ca)\
if da then\
ab.classes=type(ab.classes)==\"table\"and ab.classes or{}for cb in da:gmatch\"%S+\"do ab.classes[cb]=true end end\
if ca.children then table.insert(c,{ab,ca.children})end;_a[#_a+1]={ab,bb}\
if aa:can\"addNode\"then aa:addNode(ab)else return\
error(\"Failed to spawn XML tree. \"..\
tostring(aa)..\" cannot contain nodes.\")end end end;d=d+1 end\
for i=1,#_a do local ca=_a[i][1]for da,_b in pairs(_a[i][2])do\
ca:setDynamicValue(DynamicValue(ca,da,_b))end end end\
function TML.static.fromFile(c,d)\
if not Titanium.isInstance(c)then return\
error\"Expected Titanium instance as first argument (parent)\"end;if not fs.exists(d)then return\
error(\"Path \"..tostring(d)..\" cannot be found\")end\
local _a=fs.open(d,\"r\")local aa=_a.readAll()_a.close()return TML(c,aa)end",
["RadioButton.ti"]="class\"RadioButton\"\
extends\"Checkbox\"{static={groups={}},group=false}\
function RadioButton:__init__(...)self:super(...)if self.toggled then\
RadioButton.deselectInGroup(self.group,self)end end\
function RadioButton:select()\
RadioButton.deselectInGroup(self.group)self.toggled=true;self:executeCallbacks\"select\"end\
function RadioButton:onMouseUp(a,b,c)if not b and c and self.active then self:select(a,b,c)\
a.handled=true end;self.active=false end\
function RadioButton:onLabelClicked(a,b,c,d)self:select(b,c,d,a)b.handled=true end;function RadioButton:setGroup(a)if self.group then\
RadioButton.removeFromGroup(self,self.group)end;self.group=a\
RadioButton.addToGroup(self,a)end\
function RadioButton.static.addToGroup(a,b)\
local c=RadioButton.groups[b]\
if type(c)==\"table\"then RadioButton.removeFromGroup(a,b)\
table.insert(c,a)else RadioButton.groups[b]={a}end end\
function RadioButton.static.removeFromGroup(a,b)\
local c=RadioButton.isInGroup(a,b)if c then table.remove(RadioButton.groups[b],c)\
if#\
RadioButton.groups[b]==0 then RadioButton.groups[b]=nil end end end\
function RadioButton.static.isInGroup(a,b)local c=RadioButton.groups[b]for i=1,#c do if\
c[i]==a then return i end end;return false end\
function RadioButton.static.deselectInGroup(a,b)local c=RadioButton.groups[a]for i=1,#c do\
if(\
not b or(b and c[i]~=b))then c[i].toggled=false end end end\
function RadioButton.static.getValue(a)local b=RadioButton.groups[a]\
if b then local c;for i=1,#b do\
c=b[i]if c.toggled then return c.value end end end end\
configureConstructor({orderedArguments={\"X\",\"Y\",\"group\"},requiredArguments={\"group\"},argumentTypes={group=\"string\"},useProxy={\"group\"}},true,true)",
["Event.ti"]="class\"Event\"abstract(){static={matrix={}}}function Event:is(a)return\
self.name==a end\
function Event:setHandled(a)self.raw.handled=a end;function Event.static.spawn(a,...)return\
(Event.matrix[a]or GenericEvent)(a,...)end;function Event.static.bindEvent(a,b)\
Event.matrix[a]=\
Titanium.getClass(b)or\
error(\"Class '\"..tostring(b)..\"' cannot be found\")end;function Event.static.unbindEvent(a)Event.matrix[a]=\
nil end",
["GenericEvent.ti"]="class\"GenericEvent\"extends\"Event\"\
function GenericEvent:__init__(...)local a={...}\
self.name=a[1]self.main=self.name:upper()self.data=a end",
["Terminal.ti"]="\
local function b(c)if not c.thread then return false end;return c.thread.running end;class\"Terminal\"extends\"Node\"\
mixin\"MFocusable\"{static={focusedEvents={MOUSE=true,KEY=true,CHAR=true}},canvas=true,displayThreadStatus=true}\
function Terminal:__init__(...)self:resolve(...)self:super()\
self.canvas=RedirectCanvas(self)self.redirect=self.canvas:getTerminalRedirect()end\
function Terminal:wrapChunk()if type(self.chunk)~=\"function\"then return\
error\"Cannot wrap chunk. No chunk function set.\"end\
self.canvas:resetTerm()self.thread=Thread(self.chunk)\
self:resume(GenericEvent\"titanium_terminal_start\")end\
function Terminal:resume(c)if not b(self)then return end\
if\
not Titanium.typeOf(c,\"Event\",true)then return error\"Invalid event object passed to resume terminal thread\"end;local d,_a=self.thread,term.redirect(self.redirect)\
d:filterHandle(c)term.redirect(_a)\
if not d.running then\
if type(d.exception)==\"string\"then if\
self.displayThreadStatus then\
self:emulate(function()\
printError(\"Thread Crashed: \"..tostring(d.exception))end)end\
self:executeCallbacks(\"exception\",d)else if self.displayThreadStatus then\
self:emulate(function()print\"Finished\"end)end\
self:executeCallbacks(\"finish\",d,true)end;self:executeCallbacks(\"finish\",d,false)end;self.changed=true end\
function Terminal:emulate(c)if type(c)~=\"function\"then\
return error(\"Failed to emulate function. '\"..\
tostring(c)..\"' is not valid\")end\
local d=term.redirect(self.redirect)local _a,aa=pcall(c)term.redirect(d)if not _a then\
return error(\"Failed to emulate function. Reason: \"..\
tostring(aa),3)end end\
function Terminal:setChunk(c)self.chunk=c;self:wrapChunk()end\
function Terminal:getCaretInfo()local d=self.canvas;return b(self)and d.tCursor,d.tX+self.X-1,d.tY+\
self.Y-1,d.tColour end\
function Terminal:handle(c)if not b(self)then self:unfocus()return end\
if c.main==\
\"MOUSE\"then if not c.handled and c:withinParent(self)then\
self:focus()else self:unfocus()end\
c=c:clone(self)elseif c.handled then return end;if Terminal.focusedEvents[c.main]and not self.focused then\
return end;self:resume(c)end;function Terminal:draw()end\
configureConstructor({orderedArguments={\"X\",\"Y\",\"width\",\"height\",\"chunk\"},argumentTypes={chunk=\"function\"},useProxy={\"chunk\"}},true)",
["Input.ti"]="local c,d=string.rep,string.sub;class\"Input\"extends\"Node\"\
mixin\"MActivatable\"\
mixin\"MFocusable\"{position=0,scroll=0,value=\"\",selection=false,selectedColour=false,selectedBackgroundColour=colours.lightBlue,placeholder=false,placeholderColour=256,allowMouse=true,allowKey=true,allowChar=true,limit=0,mask=\"\"}\
function Input:__init__(...)self:resolve(...)\
self:register(\"width\",\"selectedColour\",\"selectedBackgroundColour\",\"limit\")self:super()end\
function Input:onMouseClick(_a,aa,ba)\
if ba and not aa then if _a.button~=1 then return end\
if self.focused then\
local ca,da,_b,ab=self.application,self.position,self.width,self.scroll\
local bb=math.min(#self.value,_a.X-self.X+self.scroll)\
if\
ca:isPressed(keys.leftShift)or ca:isPressed(keys.rightShift)then\
if bb~=da then self.selection=bb else self.selection=false end else self.position,self.selection=bb,false end end;self.active,_a.handled=true,true else self.active=false;self:unfocus()end end\
function Input:onMouseDrag(_a,aa,ba)if not self.focused or aa then return end\
self.selection=math.min(\
#self.value,_a.X-self.X+self.scroll)_a.handled=true end\
function Input:onMouseUp(_a,aa,ba)if(not ba or aa)and self.focused then self:unfocus()elseif\
ba and not aa and self.active and not self.focused then\
self:focus()end\
self.active=false end\
function Input:onChar(_a,aa)if not self.focused or aa then return end\
local ba,ca,da=self.value,self.position,self.selection\
if da then local _b,ab=math.min(da,ca),math.max(da,ca)\
_b=_b>ab and _b-1 or _b\
self.value,self.selection=d(ba,1,_b).._a.char..\
d(ba,ab+ (_b<ab and 1 or 2)),false;self.position=_b+1;self.changed=true else if\
self.limit>0 and#ba>=self.limit then return end\
self.value=d(ba,1,ca).._a.char..d(ba,ca+1)self.position=self.position+1 end;self:executeCallbacks\"change\"_a.handled=true end\
function Input:onKeyDown(_a,aa)if not self.focused or aa then return end\
local ba,ca=self.value,self.position;local da=#ba\
if _a.sub==\"DOWN\"then\
local _b,ab,bb,cb=_a.keyName,self.selection,self.position,self.application\
local db,_c,ac=cb:isPressed(keys.leftShift)or cb:isPressed(keys.rightShift)if ab then\
_c,ac=ab<bb and ab or bb,ab>bb and ab+1 or bb+1 else _c,ac=bb-1,bb end\
if _b==\"enter\"then\
self:executeCallbacks(\"trigger\",self.value,\
self.selection and self:getSelectedValue())elseif ab then\
if _b==\"delete\"or _b==\"backspace\"then\
self.value=d(ba,1,_c)..d(ba,ac)self.position=_c;self.selection=false elseif\
not db and(_b==\"left\"or _b==\"right\")then\
self.position=_b==\"left\"and _c+1 or _b==\"right\"and ac-2;self.selection=false end end;local bc=self.selection or self.position;local function cc(dc)\
if db then\
self.selection=bc+dc else self.position=self.position+dc;self.selection=false end end\
if _b==\"left\"then\
cc(-1)elseif _b==\"right\"then cc(1)else\
if _b==\"home\"then cc(db and-bc or-bb)elseif _b==\"end\"then cc(db and da-\
bc or da-bb)elseif\
_b==\"backspace\"and db then self.value,self.position=d(self.value,ac+1),0 end end\
if not db then\
if _b==\"backspace\"and _c>=0 and not ab then self.value=d(ba,1,_c)..\
d(ba,ac+1)self.position=_c elseif _b==\"delete\"and not ab then self.value,self.changed=\
d(ba,1,ac)..d(ba,ac+2),true end end end end\
function Input:onLabelClicked(_a,aa,ba,ca)self:focus()aa.handled=true end\
function Input:draw(_a)local aa=self.raw\
if aa.changed or _a then\
local ba,ca,da=aa.canvas,aa.colour,aa.backgroundColour;if aa.focused then ca,da=aa.focusedColour,aa.focusedBackgroundColour elseif aa.active then\
ca,da=aa.activeColour,aa.activeBackgroundColour end\
ba:clear(da)\
local _b,ab,bb,cb,db=self.position,self.width,\
self.mask~=\"\"and c(self.mask,#self.value)or self.value,self.selection,self.placeholder\
if self.focused or not db or#bb>0 then\
if self.selection then local _c,ac=cb<_b and cb or _b,cb>\
_b and cb+1 or _b+1\
if _c<ac then ac=ac-1 end;local bc=-self.scroll+1\
ba:drawTextLine(bc,1,d(bb,1,_c+1),ca,da)\
ba:drawTextLine(bc+_c,1,d(bb,_c+1,ac),self.focused and self.selectedColour or ca,\
self.focused and self.selectedBackgroundColour or da)ba:drawTextLine(bc+ac,1,d(bb,ac+1),ca,da)else ba:drawTextLine(-\
self.scroll+1,1,bb,ca,da)end else\
ba:drawTextLine(1,1,d(db,1,self.width),self.placeholderColour,da)end;aa.changed=false end end\
function Input:repositionScroll(_a)local aa=self.limit;local ba=aa>0\
if _a>=self.width and _a> (\
self.scroll+self.width-1)then\
self.scroll=\
math.min(_a-\
self.width+1,#self.value-self.width+1)- (ba and _a>=aa and 1 or 0)elseif _a<=self.scroll then\
self.scroll=math.max(self.scroll- (self.scroll-_a),0)else\
self.scroll=math.max(math.min(self.scroll,#self.value-self.width+1),0)end end\
function Input:setSelection(_a)\
if type(_a)==\"number\"then\
local aa=math.max(math.min(_a,#self.value),0)\
self.selection=aa~=self.position and aa or false else self.selection=_a end\
self:repositionScroll(self.selection or self.position)self.changed=true end;function Input:getSelectedValue()local _a,aa=self.selection,self.position\
return d(self.value,\
(_a<aa and _a or aa)+1,(_a>aa and _a or aa))end\
function Input:setPosition(_a)if\
self.selection==_a then self.selection=false end\
self.position,self.changed=math.max(math.min(_a,\
#self.value),0),true;self:repositionScroll(self.position)end\
function Input:getCaretInfo(_a)local aa,ba=self:getAbsolutePosition(_a)\
local ca=self.limit\
return\
not self.selection and(ca<=0 or self.position<ca),aa+ (self.position-self.scroll),ba,self.focusedColour end\
configureConstructor({orderedArguments={\"X\",\"Y\",\"width\"},argumentTypes={value=\"string\",position=\"number\",selection=\"number\",placeholder=\"string\",placeholderColour=\"colour\",selectedColour=\"colour\",selectedBackgroundColour=\"colour\",limit=\"number\",mask=\"string\"},useProxy={\"toggled\"}},true)",
["NodeQuery.ti"]="\
local function aa(ab,bb,cb)local db=type(ab)==\"string\"and'\"'or\"\"local _c=type(cb)==\
\"string\"and'\"'or\"\"return\
(\"return %s%s%s %s %s%s%s\"):format(db,tostring(ab),db,bb,_c,tostring(cb),_c)end\
local function ba(ab,bb)\
local cb,db=loadstring(aa(ab[bb.property],bb.symbol,bb.value))if cb then return cb()end;return cb()end\
local function ca(ab,bb,cb)local db={}local _c\
for i=1,#ab do _c=ab[i]\
if\
(not bb.id or _c.id==bb.id)and\
(not bb.type or\
bb.type==\"*\"or(bb.ambiguous and Titanium.typeOf(_c,bb.type)or\
_c.__type==bb.type))and(\
not bb.classes or _c:hasClass(bb.classes))then local ac,bc=bb.condition;if ac then local cc;for c=1,#ac do\
if not ba(_c,ac[c])then bc=true;break end end end;if\
not bc then db[#db+1]=_c end end end;return db end\
local function da(ab,bb)local cb={}\
for i=1,#ab do\
local db=bb and ab[i].nodes or ab[i].collatedNodes;for r=1,#db do cb[#cb+1]=db[r]end end;return cb end;local function _b(ab,bb)local cb,db=bb\
for i=1,#ab do db=ab[i]cb=ca(da(cb,db.direct),db)end;return cb end\
class\"NodeQuery\"{static={supportedMethods={\"addClass\",\"removeClass\",\"setClass\",\"set\",\"animate\",\"on\",\"off\",\"remove\"}},result=false,parent=false}\
function NodeQuery:__init__(ab,bb)if not\
(Titanium.isInstance(ab)and type(bb)==\"string\")then\
return error\"Node query requires Titanium instance and string query\"end\
self.parent=ab;self.parsedQuery=QueryParser(bb).query\
self.result=self:query()local cb=NodeQuery.supportedMethods\
for i=1,#cb do self[cb[i]]=function(db,...)\
db:executeOnNodes(cb[i],...)end end end\
function NodeQuery:query()local ab,bb=self.parsedQuery,{}\
if type(ab)~=\"table\"then return\
error(\"Cannot perform query. Invalid query object passed\")end;local cb={self.parent}for i=1,#ab do local db=_b(ab[i],cb)for r=1,#db do\
bb[#bb+1]=db[r]end end;return bb end\
function NodeQuery:hasClass(ab)local bb=self.result;for i=1,#bb do\
if not bb[i]:hasClass(ab)then return false end end;return true end\
function NodeQuery:each(ab)local bb=self.result;for i=1,#bb do ab(bb[i])end end\
function NodeQuery:executeOnNodes(ab,...)local bb,cb=self.result;for i=1,#bb do cb=bb[i]if cb:can(ab)then\
cb[ab](cb,...)end end end",
["ContextMenu.ti"]="class\"ContextMenu\"\
extends\"Container\"{static={allowedTypes={\"Button\",\"Label\"}}}function ContextMenu:__init__(...)self:resolve(...)self:super()\
self.transparent=true end\
function ContextMenu:setParent(a)self.parent=a;if\
a then local b=self:addNode(ScrollContainer())b.frameID=1\
self:populate(b,self.structure)b.visible=true end end\
function ContextMenu:populate(a,b)local c,d,_a,aa,ba={{a,b}},1,0,0,1\
while d<=#c do\
local ca,da,_b=c[d][1],c[d][2],0;local ab,bb={},0\
for i=1,#da do bb=bb+1;local bc=da[i]local cc=bc[1]:lower()\
if cc==\"custom\"then else\
if\
cc==\"menu\"then\
local dc=self:addNode(ScrollContainer(nil,ca.Y+bb-1))if not ca.subframes then ca.subframes={dc}else\
table.insert(ca.subframes,dc)end;dc.visible=false\
local _d=#self.nodes;dc.frameID=_d\
ca:addNode(Button(bc[2],1,bb):on(\"trigger\",function()local ad=ca.subframes\
for i=1,#ad do if\
ad[i]~=dc and ad[i].visible then\
self:closeFrame(ad[i].frameID)end end\
if dc.visible then self:closeFrame(_d)else dc.visible=true end end))table.insert(c,{dc,bc[3],ca})elseif cc==\"rule\"then\
ab[#ab+1]=bb elseif cc==\"button\"then\
ca:addNode(Button(bc[2],1,bb):on(\"trigger\",bc[3]))elseif cc==\"label\"then ca:addNode(Label(bc[2],1,bb))end;if cc~=\"rule\"then _b=math.max(_b,#bc[2])end end end;if _b==0 then\
error\"Failed to populate context menu. Content given has no detectable width (or zero). Cannot proceed without width greater than 0\"end;for n=1,#\
ca.nodes do ca.nodes[n].width=_b end;for r=1,#ab do\
ca:addNode(Label((\"-\"):rep(_b),1,ab[r]))end;local cb,db,_c=c[d][3],0,0\
if cb then db,_c=cb.width,cb.X end\
local ac=(_c+db+_b+self.X-1)-self.parent.width\
if ac>0 then ca.X=_c- (cb and _b or ac)else ca.X=_c+db end;ba=math.min(ba,ca.X)ca.width,ca.height=_b,bb-\
math.max(ca.Y+bb-self.parent.height,0)\
ca:cacheContent()_a,aa=_a+ca.width,aa+\
math.max(ca.height- (cb and cb.Y or 0),1)d=d+1 end;if ba<1 then local ca=self.nodes\
for i=1,#ca do ca[i].X=ca[i].X-ba+1 end;self.X=self.X+ba end\
self.width=_a;self.height=aa end\
function ContextMenu:shipEvent(a)local b=self.nodes;for i=#b,1,-1 do\
if b[i].visible then b[i]:handle(a)end end end\
function ContextMenu:handle(a)\
if not self.super:handle(a)then return end;if\
a.main==\"MOUSE\"and not self:isMouseColliding(a)then if a.sub==\"CLICK\"then self:closeFrame(1)end\
a.handled=false end;return true end\
function ContextMenu:closeFrame(a)local b,c={self.nodes[a]},1;while c<=#b do\
local d=b[c].subframes or{}for f=1,#d do if d[f].visible then b[#b+1]=d[f]end end\
b[c].visible=false;c=c+1 end\
self.changed=true end\
configureConstructor{orderedArguments={\"structure\"},requiredArguments={\"structure\"},argumentTypes={structure=\"table\"}}",
["Titanium.lua"]="\
Event.static.matrix={mouse_click=MouseEvent,mouse_drag=MouseEvent,mouse_up=MouseEvent,mouse_scroll=MouseEvent,key=KeyEvent,key_up=KeyEvent,char=CharEvent}\
Image.setImageParser(\"\",function(_d)local ad=TermCanvas.static.hex\
width,lines,pixels=1,{},{}for bd in _d:gmatch\"([^\\n]*)\\n?\"do width=math.max(width,#bd)\
lines[#lines+1]=bd end;for l=1,#lines do\
local bd,cd=width* (l-1),lines[l]\
for i=1,width do local dd=ad[cd:sub(i,i)]pixels[bd+i]={\" \",dd,dd}end end\
return width,#lines,pixels end).setImageParser(\"nfp\",function(_d)\
end)\
Canvas.registerShader(\"darken\",{[1]=256,[2]=16384,[4]=1024,[8]=512,[16]=2,[32]=8192,[64]=4,[128]=32768,[256]=128,[512]=2048,[1024]=16384,[2048]=4096,[4096]=32768,[8192]=128,[16384]=128,[32768]=32768})\
Canvas.registerShader(\"lighten\",{[1]=1,[2]=16,[4]=64,[8]=1,[16]=1,[32]=16,[64]=1,[128]=256,[256]=1,[512]=8,[1024]=64,[2048]=8,[4096]=256,[8192]=32,[16384]=2,[32768]=256})\
Canvas.registerShader(\"inverse\",{[1]=32768,[2]=2048,[4]=32,[8]=4096,[16]=1024,[32]=1024,[64]=8192,[128]=256,[256]=128,[512]=4096,[1024]=32,[2048]=2,[4096]=8,[8192]=4,[16384]=512,[32768]=1})\
Canvas.registerShader(\"greyscale\",{[1]=1,[2]=256,[4]=256,[8]=256,[16]=1,[32]=256,[64]=256,[128]=128,[256]=256,[512]=128,[1024]=128,[2048]=128,[4096]=32768,[8192]=128,[16384]=128,[32768]=32768})\
Projector.registerMode{mode=\"monitor\",draw=function(_d)local ad,bd=_d.resolvedTarget\
local cd=\
_d.application and _d.application.focusedNode and _d.containsFocus;local dd=\
_d.textScale and XMLParser.convertArgType(_d.textScale,\"number\")or 1\
local __a,a_a,b_a,c_a;if cd then __a,a_a,b_a,c_a=cd[1],cd[2],cd[3],cd[4]end\
local d_a=term.current()\
for i=1,#ad do bd=ad[i]bd.setTextScale(dd)term.redirect(bd)\
_d.canvas:draw(true)term.setCursorBlink(__a or false)\
if __a then\
term.setCursorPos(a_a or 1,b_a or 1)term.setTextColour(c_a or 32768)end end;term.redirect(d_a)end,eventDispatcher=function(_d,ad)\
if\
ad.handled or not _d.resolvedTarget[ad.data[2]]or\
ad.main~=\"MONITOR_TOUCH\"then return end\
local function bd(__a)__a.projectorOrigin=true;local a_a=_d.mirrors;local b_a,c_a=__a.X,__a.Y\
for i=1,#a_a do\
local d_a=a_a[i]local _aa,aaa=d_a.projectX,d_a.projectY;local baa=_aa or aaa;if baa then\
__a.X,__a.Y=b_a+\
(d_a.X- (_aa or 0)),c_a+ (d_a.Y- (aaa or 0))end;d_a:handle(__a)if baa then\
__a.X,__a.Y=b_a,c_a end end end;local cd,dd=ad.data[3],ad.data[4]\
bd(MouseEvent(\"mouse_click\",1,cd,dd))\
_d.application:schedule(function()\
bd(MouseEvent(\"mouse_up\",1,cd,dd))end,0.1)end,targetResolver=function(_d,ad)\
if\
not type(ad)==\"string\"then return\
error(\"Failed to resolve target '\"..\
tostring(ad)..\
\"' for monitor projector mode. Expected number, got '\"..type(ad)..\"'\")end;local bd={}\
for cd in ad:gmatch\"%S+\"do\
if not bd[cd]then\
bd[#bd+1]=peripheral.wrap(cd)or\
error(\
\"Failed to resolve targets for projector '\".._d.name..\"'. Invalid target '\"..cd..\"'\")bd[cd]=true end end;_d.width,_d.height=bd[1].getSize()return bd end}\
local ab,bb,cb,db,_c,ac,bc=math.abs,math.pow,math.asin,math.sin,math.cos,math.sqrt,math.pi;local cc=Tween.static.easing\
Tween.addEasing(\"linear\",function(_d,ad,bd,cd)return bd*_d/cd+ad end)\
Tween.addEasing(\"inQuad\",function(_d,ad,bd,cd)return bd*bb(_d/cd,2)+ad end).addEasing(\"outQuad\",function(_d,ad,bd,cd)local dd=\
_d/cd;return-bd*dd* (dd-2)+ad end).addEasing(\"inOutQuad\",function(_d,ad,bd,cd)local dd=\
_d/cd*2\
if dd<1 then return bd/2 *bb(dd,2)+ad end\
return-bd/2 * ( (dd-1)* (dd-3)-1)+ad end).addEasing(\"outInQuad\",function(_d,ad,bd,cd)\
if\
_d<cd/2 then return cc.outQuad(_d*2,ad,bd/2,cd)end;return cc.inQuad((_d*2)-cd,ad+bd/2,bd/2,cd)end)\
Tween.addEasing(\"inCubic\",function(_d,ad,bd,cd)return bd*bb(_d/cd,3)+ad end).addEasing(\"outCubic\",function(_d,ad,bd,cd)return\
bd* (bb(_d/cd-1,3)+1)+ad end).addEasing(\"inOutCubic\",function(_d,ad,bd,cd)local dd=\
_d/cd*2\
if dd<1 then return bd/2 *dd*dd*dd+ad end;dd=dd-2;return bd/2 * (dd*dd*dd+2)+ad end).addEasing(\"outInCubic\",function(_d,ad,bd,cd)\
if\
_d<cd/2 then return cc.outCubic(_d*2,ad,bd/2,cd)end;return cc.inCubic((_d*2)-cd,ad+bd/2,bd/2,cd)end)\
Tween.addEasing(\"inQuart\",function(_d,ad,bd,cd)return bd*bb(_d/cd,4)+ad end).addEasing(\"outQuart\",function(_d,ad,bd,cd)return\
-bd* (bb(_d/cd-1,4)-1)+ad end).addEasing(\"inOutQuart\",function(_d,ad,bd,cd)local dd=\
_d/cd*2\
if dd<1 then return bd/2 *bb(dd,4)+ad end;return-bd/2 * (bb(dd-2,4)-2)+ad end).addEasing(\"outInQuart\",function(_d,ad,bd,cd)\
if\
_d<cd/2 then return cc.outQuart(_d*2,ad,bd/2,cd)end;return cc.inQuart((_d*2)-cd,ad+bd/2,bd/2,cd)end)\
Tween.addEasing(\"inQuint\",function(_d,ad,bd,cd)return bd*bb(_d/cd,5)+ad end).addEasing(\"outQuint\",function(_d,ad,bd,cd)return\
bd* (bb(_d/cd-1,5)+1)+ad end).addEasing(\"inOutQuint\",function(_d,ad,bd,cd)local dd=\
_d/cd*2\
if dd<1 then return bd/2 *bb(dd,5)+ad end;return bd/2 * (bb(dd-2,5)+2)+ad end).addEasing(\"outInQuint\",function(_d,ad,bd,cd)\
if\
_d<cd/2 then return cc.outQuint(_d*2,ad,bd/2,cd)end;return cc.inQuint((_d*2)-cd,ad+bd/2,bd/2,cd)end)\
Tween.addEasing(\"inSine\",function(_d,ad,bd,cd)return\
-bd*_c(_d/cd* (bc/2))+bd+ad end).addEasing(\"outSine\",function(_d,ad,bd,cd)return\
bd*db(_d/cd* (bc/2))+ad end).addEasing(\"inOutSine\",function(_d,ad,bd,cd)\
return\
-bd/2 * (_c(bc*_d/cd)-1)+ad end).addEasing(\"outInSine\",function(_d,ad,bd,cd)\
if\
_d<cd/2 then return cc.outSine(_d*2,ad,bd/2,cd)end;return cc.inSine((_d*2)-cd,ad+bd/2,bd/2,cd)end)\
Tween.addEasing(\"inExpo\",function(_d,ad,bd,cd)if _d==0 then return ad end;return\
bd*bb(2,10 * (_d/cd-1))+ad-bd*0.001 end).addEasing(\"outExpo\",function(_d,ad,bd,cd)if\
_d==cd then return ad+bd end;return bd*1.001 *\
(-bb(2,-10 *_d/cd)+1)+ad end).addEasing(\"inOutExpo\",function(_d,ad,bd,cd)if\
_d==0 then return ad elseif _d==cd then return ad+bd end;local dd=_d/cd*2;if dd<1 then return\
bd/\
2 *bb(2,10 * (dd-1))+ad-bd*0.0005 end\
return bd/2 *1.0005 * (-\
bb(2,-10 * (dd-1))+2)+ad end).addEasing(\"outInExpo\",function(_d,ad,bd,cd)\
if\
_d<cd/2 then return cc.outExpo(_d*2,ad,bd/2,cd)end;return cc.inExpo((_d*2)-cd,ad+bd/2,bd/2,cd)end)\
Tween.addEasing(\"inCirc\",function(_d,ad,bd,cd)return\
-bd* (ac(1 -bb(_d/cd,2))-1)+ad end).addEasing(\"outCirc\",function(_d,ad,bd,cd)\
return\
bd*ac(1 -bb(_d/cd-1,2))+ad end).addEasing(\"inOutCirc\",function(_d,ad,bd,cd)local dd=\
_d/cd*2;if dd<1 then return\
-bd/2 * (ac(1 -dd*dd)-1)+ad end;dd=dd-2;return bd/2 *\
(ac(1 -dd*dd)+1)+ad end).addEasing(\"outInCirc\",function(_d,ad,bd,cd)\
if\
_d<cd/2 then return cc.outCirc(_d*2,ad,bd/2,cd)end;return cc.inCirc((_d*2)-cd,ad+bd/2,bd/2,cd)end)\
local function dc(_d,ad,bd,cd)local dd,__a=_d or cd*0.3,ad or 0\
if __a<ab(bd)then return dd,bd,dd/4 end;return dd,__a,dd/ (2 *bc)*cb(bd/__a)end\
Tween.addEasing(\"inElastic\",function(_d,ad,bd,cd,dd,__a)if _d==0 then return ad end;local a_a,b_a=_d/cd\
if a_a==1 then return ad+bd end;a_a,p,a,b_a=a_a-1,dc(p,a,bd,cd)return\
- (a*bb(2,10 *a_a)*db((a_a*cd-b_a)*\
(2 *bc)/p))+ad end).addEasing(\"outElastic\",function(_d,ad,bd,cd,dd,__a)if\
_d==0 then return ad end;local a_a,b_a=_d/cd;if a_a==1 then return ad+bd end\
local c_a,d_a,_aa=dc(__a,dd,bd,cd)return\
d_a*bb(2,-10 *a_a)*\
db((a_a*cd-_aa)* (2 *bc)/c_a)+bd+ad end).addEasing(\"inOutElastic\",function(_d,ad,bd,cd,dd,__a)if\
_d==0 then return ad end;local a_a=_d/cd*2;if a_a==2 then return ad+bd end\
local b_a,c_a,d_a,_aa=a_a-1,dc(__a,dd,bd,cd)\
if b_a<0 then return\
-0.5 * (d_a*bb(2,10 *b_a)*\
db((b_a*cd-_aa)* (2 *bc)/c_a))+ad end;return\
d_a*bb(2,-10 *b_a)*\
db((b_a*cd-_aa)* (2 *bc)/c_a)*0.5 +bd+ad end).addEasing(\"outInElastic\",function(_d,ad,bd,cd,dd,__a)\
if\
_d<cd/2 then return cc.outElastic(_d*2,ad,bd/2,cd,dd,__a)end\
return cc.inElastic((_d*2)-cd,ad+bd/2,bd/2,cd,dd,__a)end)\
Tween.addEasing(\"inBack\",function(_d,ad,bd,cd,dd)local __a,a_a=dd or 1.70158,_d/cd;return bd*a_a*a_a*\
( (__a+1)*a_a-__a)+ad end).addEasing(\"outBack\",function(_d,ad,bd,cd,dd)local __a,a_a=\
dd or 1.70158,_d/cd-1\
return bd* (\
a_a*a_a* ( (__a+1)*a_a+__a)+1)+ad end).addEasing(\"inOutBack\",function(_d,ad,bd,cd,dd)local __a,a_a=(\
dd or 1.70158)*1.525,_d/cd*2;if a_a<1 then\
return bd/2 * (a_a*a_a* (\
(__a+1)*a_a-__a))+ad end;a_a=a_a-2\
return bd/2 * (a_a*a_a*\
( (__a+1)*a_a+__a)+2)+ad end).addEasing(\"outInBack\",function(_d,ad,bd,cd,dd)\
if\
_d<cd/2 then return cc.outBack(_d*2,ad,bd/2,cd,dd)end;return cc.inBack((_d*2)-cd,ad+bd/2,bd/2,cd,dd)end)\
Tween.addEasing(\"inBounce\",function(_d,ad,bd,cd)return\
bd-cc.outBounce(cd-_d,0,bd,cd)+ad end).addEasing(\"outBounce\",function(_d,ad,bd,cd)local dd=\
_d/cd\
if dd<1 /2.75 then\
return bd* (7.5625 *dd*dd)+ad elseif dd<2 /2.75 then dd=dd- (1.5 /2.75)return\
bd* (7.5625 *dd*dd+0.75)+ad elseif dd<2.5 /2.75 then\
dd=dd- (2.25 /2.75)\
return bd* (7.5625 *dd*dd+0.9375)+ad end;dd=dd- (2.625 /2.75)return\
bd* (7.5625 *dd*dd+0.984375)+ad end).addEasing(\"inOutBounce\",function(_d,ad,bd,cd)if\
_d<cd/2 then\
return cc.inBounce(_d*2,0,bd,cd)*0.5 +ad end\
return\
cc.outBounce(_d*2 -cd,0,bd,cd)*0.5 +bd*.5 +ad end).addEasing(\"outInBounce\",function(_d,ad,bd,cd)\
if\
_d<cd/2 then return cc.outBounce(_d*2,ad,bd/2,cd)end;return cc.inBounce((_d*2)-cd,ad+bd/2,bd/2,cd)end)",
["CharEvent.ti"]="class\"CharEvent\"\
extends\"Event\"{main=\"CHAR\",char=false}\
function CharEvent:__init__(a,b)self.name=a;self.char=b;self.data={a,b}end",
["MDialogManager.ti"]="class\"MDialogManager\"\
abstract(){dialogs={},dialogContainer=false}\
function MDialogManager:MDialogManager()\
self.dialogContainer=self:addNode(OverlayContainer()):set{id=\"application_dialog_overlay\",visible=\"$parent.isDialogOpen\",enabled=\"$self.visible\",width=\"$application.width\",height=\"$application.height\",consumeWhenDisabled=false,Z=10000}end\
function MDialogManager:addDialog(a)\
if not Titanium.typeOf(a,\"Window\",true)then return\
error\"Expected 'Window' instance to add dialog box\"end;self.dialogContainer:addNode(a)\
a:on(\"close\",function()self.isDialogOpen=#\
self.dialogContainer.nodes>0 end):on(\"windowFocus\",function()\
self:shiftDialogFocus(a)end)self.isDialogOpen=true end\
function MDialogManager:shiftDialogFocus(a)local b=self.dialogContainer.nodes;for i=1,#b do b[i].Z=\
b[i]==a and#b+1 or i end end;function MDialogManager:removeDialog(a)\
self.dialogContainer:removeNode(a)\
self.isDialogOpen=#self.dialogContainer.nodes>0 end\
configureConstructor{argumentTypes={isDialogOpen=\"boolean\"}}",
["MProjectable.ti"]="class\"MProjectable\"\
abstract(){projectX=false,projectY=false,projector=false,mirrorProjector=false}function MProjectable:MProjectable()\
self:on(\"focus\",function(a,b)a:resolveProjectorFocus()end)end\
function MProjectable:resolveProjector()\
local a,b=self.application,self.projector\
if a and b then local c=a:getProjector(b)self.resolvedProjector=c;if c then\
c:attachMirror(self)self:resolveProjectorFocus()end end end\
function MProjectable:resolveProjectorFocus()local a=self.application\
local b=a and a.focusedNode\
if a and b==self then local c=self\
while c do\
if c.resolvedProjector then\
c.resolvedProjector.containsFocus={b:getCaretInfo(c)}c.resolvedProjector.changed=true end;c=c.parent end end end\
function MProjectable:setProjector(a)if self.resolvedProjector then\
self.resolvedProjector:detachMirror(self)end;self.projector=a\
self:resolveProjector()end\
function MProjectable:getResolvedProjector()if not self.projector then return end;if\
not self.resolvedProjector then self:resolveProjector()end;return\
self.resolvedProjector end\
configureConstructor{argumentTypes={projectX=\"number\",projectY=\"number\",projector=\"string\",mirrorProjector=\"boolean\"}}",
["Dropdown.ti"]="class\"Dropdown\"extends\"Container\"\
mixin\"MActivatable\"{maxHeight=false,prompt=\"Please select\",horizontalAlign=\"left\",openIndicator=\" \\31\",closedIndicator=\" \\16\",backgroundColour=colours.lightBlue,colour=colours.white,activeBackgroundColour=colours.cyan,selectedColour=colours.white,selectedBackgroundColour=colours.grey,selectedOption=false,options={},transparent=true}\
function Dropdown:__init__(...)self:super(...)\
self.optionDisplay=self:addNode(Button\"\":linkProperties(self,\"horizontalAlign\",\"disabledColour\",\"disabledBackgroundColour\",\"activeColour\",\"activeBackgroundColour\"):on(\"trigger\",function()\
self:toggleOptionDisplay()end))\
self.optionContainer=self:addNode(ScrollContainer(1,2,self.width):set{xScrollAllowed=false,consumeWhenDisabled=false,consumeAll=false})self:closeOptionDisplay()end\
function Dropdown:closeOptionDisplay()local a=self.optionContainer;a.visible,a.enabled=false,false\
self:queueAreaReset()self:updateDisplayButton()end\
function Dropdown:openOptionDisplay()local a=self.optionContainer;a.visible,a.enabled=true,true\
self:queueAreaReset()self:updateDisplayButton()end;function Dropdown:toggleOptionDisplay()\
if self.optionContainer.visible then\
self:closeOptionDisplay()else self:openOptionDisplay()end end\
function Dropdown:setEnabled(a)\
self.super:setEnabled(a)if not a then self:closeOptionDisplay()end end\
function Dropdown:updateDisplayButton()\
self.height=1 + (self.optionContainer.visible and\
self.optionContainer.height or 0)\
self.optionDisplay.text=\
(type(self.selectedOption)==\"table\"and\
self.selectedOption[1]or self.prompt)..\
(self.optionContainer.visible and self.openIndicator or self.closedIndicator)\
self.optionDisplay.width=#self.optionDisplay.text\
self.optionDisplay:set{colour=self.selectedColour,backgroundColour=self.selectedBackgroundColour}end\
function Dropdown:updateOptions()local a,b=self.options,self.optionContainer.nodes\
local c=self.selectedOption;local d=1\
for i=1,#a do\
if not c or a[i]~=c then local _a=b[d]if _a then _a.text=a[i][1]\
_a:off(\"trigger\",\"dropdownTrigger\"):on(\"trigger\",function()\
self.selectedOption=a[i]end,\"dropdownTrigger\")end;d=d+1 end end end\
function Dropdown:checkOptions()local a,b=self.optionContainer,self.options;local c=a.nodes;local d=#c\
local _a=\
#b- (self.selectedOption and 1 or 0)\
if d>_a then repeat a:removeNode(c[#c])until#c==_a elseif d<_a then\
repeat\
a:addNode(Button(\"ERR\",1,#c+1,self.width):set(\"consumeWhenDisabled\",false):linkProperties(self,\"colour\",\"activeColour\",\"disabledColour\",\"backgroundColour\",\"activeBackgroundColour\",\"disabledBackgroundColour\",\"horizontalAlign\"))until#c==_a end;self:updateOptions()d=#c;if self.maxHeight then\
a.height=math.min(d,self.maxHeight-1)else a.height=d end\
self:updateDisplayButton()self.optionsChanged=false\
if#b>0 then a.yScroll=math.min(a.yScroll,d)end end\
function Dropdown:draw(...)\
if self.optionsChanged then self:checkOptions()end;self.super:draw(...)end\
function Dropdown:getSelectedValue()\
if type(self.selectedOption)~=\"table\"then return end;return self.selectedOption[2]end\
function Dropdown:addOption(a,b)\
if type(a)~=\"string\"or b==nil then return\
error\"Failed to add option to Dropdown node. Expected two arguments: string, val - where val is not nil\"end;self:removeOption(a)\
table.insert(self.options,{a,b})self.optionsChanged=true end\
function Dropdown:removeOption(a)local b=self.options;for i=#b,1,-1 do\
if b[i]==a then table.remove(b,i)end end;self.optionsChanged=true end\
function Dropdown:setPrompt(a)self.prompt=a;self.optionDisplay.text=a end;function Dropdown:setSelectedOption(a)self.selectedOption=a\
self:closeOptionDisplay()self.optionsChanged=true\
self:executeCallbacks(\"change\",a)end\
function Dropdown:handle(a)if\
not self.super:handle(a)then return end\
if\
a:is\"mouse_click\"and not\
self:isMouseColliding(a)and self.optionContainer.visible then self:closeOptionDisplay()a.handled=true end;return true end\
function Dropdown:addTMLObject(a)\
if a.type==\"Option\"then\
if a.content and a.arguments.value then\
self:addOption(a.content,a.arguments.value)else\
error\"Failed to add TML object to Dropdown object. 'Option' tag must include content (not children) and a 'value' argument\"end else\
error(\"Failed to add TML object to Dropdown object. Only 'Option' tags are accepted, '\"..\
tostring(a.type)..\"' is invalid\")end end\
configureConstructor({orderedArguments={\"X\",\"Y\",\"width\",\"maxHeight\",\"prompt\"},argumentTypes={maxHeight=\"number\",prompt=\"string\",selectedColour=\"colour\",selectedBackgroundColour=\"colour\"}},true)\
alias{selectedColor=\"selectedColour\",selectedBackgroundColor=\"selectedBackgroundColour\"}",
["Application.ti"]="class\"Application\"extends\"Component\"mixin\"MThemeManager\"\
mixin\"MKeyHandler\"mixin\"MCallbackManager\"mixin\"MAnimationManager\"\
mixin\"MNodeContainer\"mixin\"MProjectorManager\"\
mixin\"MDialogManager\"{width=51,height=19,threads={},timers={},running=false,terminatable=false}\
function Application:__init__(...)self:super()self:resolve(...)\
self.canvas=TermCanvas(self)\
self:setMetaMethod(\"add\",function(c,d)local _a=c~=self and c or d\
if\
Titanium.typeOf(_a,\"Node\",true)then return self:addNode(_a)elseif Titanium.typeOf(_a,\"Thread\",true)then return\
self:addThread(_a)end;error\"Invalid targets for application '__add'. Expected node or thread.\"end)end\
function Application:focusNode(a)\
if not Titanium.typeOf(a,\"Node\",true)then return\
error\"Failed to update application focused node. Invalid node object passed.\"end;self:unfocusNode()self.focusedNode=a;a.changed=true\
local b=self.projectors;for i=1,#b do b[i].containsFocus=false end\
a:executeCallbacks(\"focus\",self)end\
function Application:unfocusNode(a)local b=self.focusedNode;if not b or(a~=b)then return end;self.focusedNode=\
nil;b.raw.focused=false;b.changed=true\
b:executeCallbacks(\"unfocus\",self)end\
function Application:addThread(a)if not Titanium.typeOf(a,\"Thread\",true)then\
error(\
\"Failed to add thread, object '\"..tostring(a)..\"' is invalid. Thread Instance required\")end\
table.insert(self.threads,a)return a end\
function Application:removeThread(a)\
if not Titanium.typeOf(a,\"Thread\",true)then return\
error(\
\"Cannot perform search for thread using target '\"..tostring(a)..\"'.\")end;local b=type(a)==\"string\"local c,d,_a=self.threads\
for i=1,#c do d=c[i]if(b and d.id==a)or(\
not b and d==a)then d:stop()table.remove(c,i)\
return true,d end end;return false end\
function Application:handleThreads(a,...)local b=self.threads;local c;for i=1,#b do c=b[i]if c.titaniumEvents then c:handle(a)else\
c:handle(...)end end end\
function Application:schedule(a,b,c,d)local _a=self.timers\
if d then self:unschedule(d)end;local aa=os.startTimer(b)self.timers[aa]={a,b,c,d}return aa end\
function Application:unschedule(a)local b=self.timers\
for c,d in next,b do if d[4]==a then os.cancelTimer(c)\
b[c]=nil;return true end end;return false end;function Application:getAbsolutePosition()return self.X,self.Y end\
function Application:start()\
self:restartAnimationTimer()self.running=true\
while self.running do self:draw()\
local a={coroutine.yield()}local b=a[1]\
if b==\"timer\"then local c=a[2]\
if c==self.timer then\
self:updateAnimations()elseif self.timers[c]then local d=self.timers[c]if d[3]then\
self:schedule(unpack(d))end;self.timers[c]=nil;d[1](self,c)end elseif b==\"terminate\"and self.terminatable then\
printError\"Application Terminated\"self:stop()end;self:handle(unpack(a))end end\
function Application:draw(a)if not self.changed and not a then return end\
local b=self.canvas;local c,d=self.nodes\
for i=1,#c do d=c[i]\
if a or(d.needsRedraw and d.visible)then\
local _b,ab,bb=d.shader,d.shadeText,d.shadeBackground;d:draw(a)\
if d.projector then if d.mirrorProjector then\
d.canvas:drawTo(b,d.X,d.Y,_b,ab,bb)end;d.resolvedProjector.changed=true else\
d.canvas:drawTo(b,d.X,d.Y,_b,ab,bb)end;d.needsRedraw=false end end;self.changed=false;local _a,aa,ba,ca,da=self.focusedNode;if _a then\
_a:resolveProjectorFocus()\
if _a:can\"getCaretInfo\"then aa,ba,ca,da=_a:getCaretInfo()end end\
term.setCursorBlink(aa or false)\
b:draw(a,self.shader,self.shadeText,self.shadeBackground)\
if aa then\
term.setTextColour(da or self.colour or 32768)term.setCursorPos(ba or 1,ca or 1)end;self:updateProjectors()end\
function Application:handle(a,...)local b=Event.spawn(a,...)if b.main==\"KEY\"then\
self:handleKey(b)end;local c,d=self.nodes;for i=#c,1,-1 do d=c[i]\
if d then d:handle(b)end end;self:executeCallbacks(a,b)\
self:handleThreads(b,a,...)end;function Application:stop()\
if self.running then self.running=false\
os.queueEvent(\"ti_app_close\")else return error\"Application already stopped\"end end",
["TextContainer.ti"]="local c=string.sub\
local function d(_a,aa,ba,ca)local da=math.min(#aa,ca)if da==0 then return 0 end\
local _b=aa[da]return\
math.min(_b[3]- (da==#aa and 0 or 1),_b[2]+ba-_b[5])end;class\"TextContainer\"extends\"ScrollContainer\"mixin\"MTextDisplay\"\
mixin\"MFocusable\"{position=1,selection=false,text=\"\",selectedColour=colours.blue,selectedBackgroundColour=colours.lightBlue,allowMouse=true}function TextContainer:__init__(...)self:resolve(...)self:super()\
self.xScrollAllowed=false end\
function TextContainer:cacheContentSize()\
self.cache.contentWidth,self.cache.contentHeight=self.width,\
self.lineConfig.lines and#self.lineConfig.lines or 0 end\
function TextContainer:cacheDisplaySize()\
self.super:cacheDisplaySize(true)self:wrapText(self.cache.displayWidth)\
self:cacheContentSize()self:cacheScrollbarSize()end\
function TextContainer:draw()\
if self.changed then local _a=self.selection\
if _a then local aa=self.position\
self:drawLines(self.lineConfig.lines,\
_a<aa and _a or aa,_a<aa and aa or _a)else self:drawLines(self.lineConfig.lines)end;self:drawScrollbars()self.changed=false end end\
function TextContainer:drawLines(_a,aa,ba)local ca,da=self.verticalAlign,self.horizontalAlign\
local _b,ab=self.width,self.height;local bb=0;if ca==\"centre\"then\
bb=math.floor((ab/2)- (#_a/2)+.5)elseif ca==\"bottom\"then bb=ab-#_a end\
local cb,db,_c,ac\
if not self.enabled then cb,db=self.disabledColour,self.disabledBackgroundColour elseif\
self.focused then cb,db=self.focusedColour,self.focusedBackgroundColour\
_c,ac=self.selectedColour,self.selectedBackgroundColour end;cb,db=cb or self.colour,db or self.backgroundColour;_c,ac=_c or\
cb,ac or db;local bc,cc,dc=self.position,self.selection,self.canvas;local _d=aa and\
ba;dc:clear(db)\
local ad,bd,cd,dd=(da==\"centre\"and _b/2 or\
(da==\"right\"and _b)or 1),1,false,false\
for i=self.yScroll+1,#_a do local __a,a_a=bb+i-self.yScroll,_a[i]\
local b_a,c_a,d_a=a_a[1],a_a[2],a_a[3]local _aa=a_a[5]\
if _d then local aaa,baa,caa\
local daa,_ba=aa-c_a+1,d_a- (d_a-ba)-c_a+1\
if aa>=c_a and ba<=d_a then aaa=c(b_a,1,daa-1)baa=c(b_a,daa,_ba)\
caa=c(b_a,_ba+1)elseif aa>=c_a and aa<=d_a then aaa=c(b_a,1,daa-1)baa=c(b_a,daa)elseif\
ba>=c_a and ba<=d_a then aaa=\"\"baa=c(b_a,1,_ba)caa=c(b_a,_ba+1)elseif aa<=c_a and ba>=d_a then aaa=\"\"\
baa=b_a else aaa=b_a end;if aaa then dc:drawTextLine(_aa,__a,aaa,cb,db)end\
if\
baa then dc:drawTextLine(_aa+#aaa,__a,baa,_c,ac)end;if caa then\
dc:drawTextLine(_aa+#aaa+#baa,__a,caa,cb,db)end else\
dc:drawTextLine(_aa,__a,b_a,cb,db)end;if bc>=c_a and bc<=d_a then\
if\
bc==d_a and self.lineConfig.lines[i+1]then bd=i+1 else ad,bd=bc-c_a+_aa+1,i end end\
if cc and cc>=c_a and\
cc<=d_a then if cc==d_a and self.lineConfig.lines[i+1]then dd=i+\
1 else cd,dd=cc-c_a+1,i end end end;self.cache.x,self.cache.y=ad,bd\
self.cache.selX,self.cache.selY=cachcSelX,dd end\
function TextContainer:getSelectionRange()local _a,aa=self.position,self.selection;return\
_a<aa and _a or aa,_a<aa and aa or _a end\
function TextContainer:getSelectedText()if not self.selection then return false end;return\
self.text:sub(self:getSelectionRange())end\
function TextContainer:onMouseClick(_a,aa,ba)\
if not aa and ba then local ca=_a.X-self.X+1;if\
ca==self.width and self.cache.yScrollActive then\
self.super:onMouseClick(_a,aa,ba)return end\
local da=\
self.application:isPressed(keys.leftShift)or self.application:isPressed(keys.rightShift)if not da then self.selection=false end\
self[da and\"selection\"or\"position\"]=d(self,self.lineConfig.lines,\
ca+self.xScroll,_a.Y-self.Y+1 +self.yScroll)self.changed=true;self:focus()else self:unfocus()end end\
function TextContainer:onMouseDrag(_a,aa,ba)if aa or not ba then return end\
local ca=_a.X-self.X+1;if ca==self.width and self.cache.yScrollActive then\
self.super:onMouseDrag(_a,aa,ba)end;if self.mouse.selected==\"v\"or not\
self.focused then return end\
self.selection=d(self,self.lineConfig.lines,\
ca+self.xScroll,_a.Y-self.Y+1 +self.yScroll)self.changed=true end\
function TextContainer:setSelection(_a)\
self.selection=_a and\
math.max(math.min(#self.text,_a),1)or false;self.changed=true end\
function TextContainer:setPosition(_a)\
self.position=_a and\
math.max(math.min(#self.text,_a),0)or false;self.selection=false;self.changed=true end\
function TextContainer:setText(_a)self.text=_a\
self:wrapText(self.cache.displayWidth or 1)self:cacheContent()\
self.yScroll=math.min(self.yScroll,self.cache.contentHeight-\
self.cache.displayHeight)end\
configureConstructor({orderedArguments={\"text\",\"X\",\"Y\",\"width\",\"height\"},argumentTypes={text=\"string\"}},true)",
["DynamicValue.ti"]="\
class\"DynamicValue\"{target=false,equation=false,compiledEquation=false,resolvedStacks=false,cachedValues={},attached=false}\
function DynamicValue:__init__(a,b,c,d)\
if\
not(\
Titanium.typeOf(a,\"Node\",true)and type(b)==\"string\"and type(c)==\"string\")then return\
error(\"Failed to initialise DynamicValue. Expected 'Node Instance', string, string.\",3)end;self.target=a;self.property=b;self.equation=c;self.manualSetter=d\
self.eq=DynamicEqParser(c)\
self.compiledEquation=loadstring(self.eq.output,\"DYNAMIC_VALUE_EQUATION@\"..self.__ID)end\
function DynamicValue:solve()\
if not self.compiledEquation then return\
error\"Cannot solve DynamicValue. Dynamic equation has not been compiled yet, try :refresh\"end\
local a,b=pcall(self.compiledEquation,self.cachedValues)\
if a then local c=self.target;c.isUpdating=true\
if self.manualSetter then\
self.manualSetter(self,c,self.property,XMLParser.convertArgType(b,self.propertyType))else\
c[self.property]=XMLParser.convertArgType(b,self.propertyType)end;c.isUpdating=false else\
printError(\"[WARNING]: Failed to solve DynamicValue. Dynamic equation failed to execute '\"..\
tostring(b)..\"'\")self:detach()end end\
function DynamicValue:attach()local a=self.resolvedStacks\
if not a then return\
error\"Cannot attach DynamicValue. Dynamic stacks have not been resolved yet, try :refresh\"end;self:detach()local b;for i=1,#a do b=a[i]\
b[2]:watchProperty(b[1],function(c,d,_a)\
self.cachedValues[i]=_a;self:solve()end,\"DYNAMIC_VALUE_\"..self.__ID)end\
self.attached=true end\
function DynamicValue:detach()local a=self.resolvedStacks;if not a then return end;local b;for i=1,#a do b=a[i]\
b[2]:unwatchProperty(b[1],\
\"DYNAMIC_VALUE_\"..self.__ID)end;self.attached=false end\
function DynamicValue:destroy()if self.target then\
self.target:removeDynamicValue(self.property)end end\
function DynamicValue:refresh()\
local a,b=self.eq:resolveStacks(self.target,true),{}if a then self.resolvedStacks=a;self:attach()local c;for i=1,#a do c=a[i]\
b[i]=c[2][c[1]]end end\
if self.target then\
local c=Titanium.getClass(self.target.__type).getRegistry().constructor.argumentTypes;self.propertyType=c[self.property]end;self.resolvedStacks,self.cachedValues=a,b\
if a then self:solve()end end",
["QueryLexer.ti"]="class\"QueryLexer\"extends\"Lexer\"\
function QueryLexer:tokenize()if\
self.stream:find\"^%s\"and not self.inCondition then\
self:pushToken{type=\"QUERY_SEPERATOR\"}end\
local a=self:trimStream()\
if self.inCondition then self:tokenizeCondition(a)elseif a:find\"^~\"then\
self:pushToken{type=\"QUERY_TYPEOF\",value=self:consumePattern\"^~\"}elseif a:find\"^%b[]\"then\
self:pushToken{type=\"QUERY_COND_OPEN\"}self:consume(1)self.inCondition=true elseif a:find\"^%,\"then\
self:pushToken{type=\"QUERY_END\",value=self:consumePattern\"^%,\"}elseif a:find\"^>\"then\
self:pushToken{type=\"QUERY_DIRECT_PREFIX\",value=self:consumePattern\"^>\"}elseif a:find\"^#[^%s%.#%[%,]*\"then\
self:pushToken{type=\"QUERY_ID\",value=self:consumePattern\"^#([^%s%.#%[]*)\"}elseif a:find\"^%.[^%s#%[%,]*\"then\
self:pushToken{type=\"QUERY_CLASS\",value=self:consumePattern\"^%.([^%s%.#%[]*)\"}elseif a:find\"^[^,%s#%.%[]*\"then\
self:pushToken{type=\"QUERY_TYPE\",value=self:consumePattern\"^[^,%s#%.%[]*\"}else\
self:throw(\"Unexpected block '\"..a:match(\"(.-)%s\")..\"'\")end end\
function QueryLexer:tokenizeCondition(a)local b=a:sub(1,1)\
if a:find\"%b[]\"then\
self:throw(\"Nested condition found '\"..\
tostring(a:match\"%b[]\")..\"'\")elseif a:find\"^%b''\"or a:find'^%b\"\"'then local c=self:consumePattern(b==\"'\"and\"^%b''\"or'^%b\"\"'):sub(2,\
-2)if c:find\"%b''\"or\
c:find'%b\"\"'then\
self:throw(\"Nested string found inside '\"..tostring(c)..\"'\")end\
self:pushToken{type=\"QUERY_COND_STRING_ENTITY\",value=c}elseif a:find\"^%w+\"then\
self:pushToken{type=\"QUERY_COND_ENTITY\",value=self:consumePattern\"^%w+\"}elseif a:find\"^%,\"then\
self:pushToken{type=\"QUERY_COND_SEPERATOR\"}self:consume(1)elseif a:find\"^[%p~]+\"then\
self:pushToken{type=\"QUERY_COND_SYMBOL\",value=self:consumePattern\"^[%p~]+\"}elseif a:find\"^%]\"then\
self:pushToken{type=\"QUERY_COND_CLOSE\"}self:consume(1)self.inCondition=false else\
self:throw(\
\"Invalid condition syntax. Expected property near '\"..tostring(a:match\"%S*\")..\"'\")end end",
["MActivatable.ti"]="class\"MActivatable\"\
abstract(){active=false,activeColour=colours.white,activeBackgroundColour=colours.lightBlue}\
function MActivatable:MActivatable()if Titanium.mixesIn(self,\"MThemeable\")then\
self:register(\"active\",\"activeColour\",\"activeBackgroundColour\")end end;function MActivatable:setActive(a)local b=self.raw;if b.active==a then return end;b.active=a\
self:queueAreaReset()end\
configureConstructor{argumentTypes={active=\"boolean\",activeColour=\"colour\",activeBackgroundColour=\"colour\"}}\
alias{activeColor=\"activeColour\",activeBackgroundColor=\"activeBackgroundColour\"}",
["Node.ti"]="class\"Node\"abstract()extends\"Component\"mixin\"MThemeable\"\
mixin\"MCallbackManager\"\
mixin\"MProjectable\"{static={eventMatrix={mouse_click=\"onMouseClick\",mouse_drag=\"onMouseDrag\",mouse_up=\"onMouseUp\",mouse_scroll=\"onMouseScroll\",key=\"onKeyDown\",key_up=\"onKeyUp\",char=\"onChar\"},anyMatrix={MOUSE=\"onMouse\",KEY=\"onKey\"}},disabledColour=128,disabledBackgroundColour=256,allowMouse=false,allowKey=false,allowChar=false,useAnyCallbacks=false,enabled=true,parentEnabled=true,visible=true,needsRedraw=true,parent=false,consumeWhenDisabled=true,Z=1}\
function Node:__init__()\
self:register(\"X\",\"Y\",\"colour\",\"backgroundColour\",\"enabled\",\"visible\",\"disabledColour\",\"disabledBackgroundColour\")self:super()if not self.canvas then\
self.raw.canvas=NodeCanvas(self)end end;function Node:__postInit__()self:hook()end\
function Node:remove()\
if not self.parent then return end;self.parent:removeNode(self)end\
function Node:setParentEnabled(a)self.parentEnabled=a;self.changed=true end\
function Node:setNeedsRedraw(a)self.needsRedraw=a;if a and self.parent then\
self.parent.needsRedraw=a end end;function Node:setEnabled(a)self.enabled=a;self.changed=true end\
function Node:getEnabled()if\
not self.parentEnabled then return false end;return self.enabled end\
function Node:setParent(a)self.parent=a;self.changed=true;if a then self.parentEnabled=\
Titanium.typeOf(a,\"Application\")or a.enabled\
self:resolveProjector()end end;function Node:setVisible(a)self.visible=a;self.changed=true;if not a then\
self:queueAreaReset()end end\
function Node:setApplication(a)\
if\
self.application then self.parent:removeNode(self)end;self.application=a;self:resolveProjector()self.changed=true end\
function Node:setChanged(a)self.changed=a\
if a then local b=self.parent\
if b then\
if not b.changed then b.changed=true end;local c,d=b.nodes\
if c then local _a,aa=self.X,self.Y\
local ba,ca=_a+self.width,aa+self.height;local da=self.Z\
for i=1,#c do d=c[i]\
if\
d~=self and not d.needsRedraw and d.Z>=da and\
not(d.X+d.width-1 <_a or d.X>ba or\
d.Y+d.height-1 <aa or d.Y>ca)then d.needsRedraw=true end end end end;self.needsRedraw=true end end\
function Node:handle(a)local b,c,d=a.main,a.sub,false;local _a,aa=a.handled,self.enabled;if self.projector then\
self.resolvedProjector:handleEvent(a)\
if not self.mirrorProjector and not a.projectorOrigin then return end end\
if\
b==\"MOUSE\"then\
if self.allowMouse then\
d=a.isWithin and a:withinParent(self)or false\
if d and not aa and self.consumeWhenDisabled then a.handled=true end else return end elseif(b==\"KEY\"and not self.allowKey)or\
(b==\"CHAR\"and not self.allowChar)then return end;if not aa then return end\
local ba=Node.eventMatrix[a.name]or\"onEvent\"if self:can(ba)then self[ba](self,a,_a,d)end;if\
self.useAnyCallbacks then local ca=Node.anyMatrix[b]if self:can(ca)then\
self[ca](self,a,_a,d)end end;return\
true end\
function Node:getAbsolutePosition(a)local b=self.parent\
if b then if a and b==a then return-1 +b.X+self.X,\
-1 +b.Y+self.Y end\
local c,d=self.parent:getAbsolutePosition()return-1 +c+self.X,-1 +d+self.Y else return self.X,self.Y end end\
function Node:animate(...)if not self.application then return end;return\
self.application:addAnimation(Tween(self,...))end\
function Node:updateZ()if not self.parent then return end\
local a,b=self.parent.nodes,self.Z\
for i=1,#a do\
if a[i]==self then\
while true do local c,d=a[i-1],a[i+1]\
if c and c.Z>b then\
a[i],a[i-1]=a[i-1],self;i=i-1 elseif d and d.Z<b then a[i],a[i+1]=a[i+1],self;i=i+1 else break end end;self.changed=true;break end end end;function Node:setZ(a)self.Z=a;self:updateZ()end\
configureConstructor{argumentTypes={enabled=\"boolean\",visible=\"boolean\",disabledColour=\"colour\",disabledBackgroundColour=\"colour\",consumeWhenDisabled=\"boolean\",Z=\"number\",allowMouse=\"boolean\",allowChar=\"boolean\",allowKey=\"boolean\"}}",
["Projector.ti"]="class\"Projector\"\
extends\"Component\"{static={modes={}},application=false,target=false,mode=false,mirrors={},name=false}function Projector:__init__(...)self:resolve(...)\
self.canvas=TermCanvas(self)end\
function Projector:updateDisplay()\
if not self.mode then return\
error\"Failed to update projector display. No mode has been set on the Projector\"elseif not self.target then return\
error\"Failed to update projector display. No target has been set on the Projector\"end;local a=Projector.static.modes[self.mode]if not\
self.resolvedTarget then\
self.resolvedTarget=\
a.targetResolver and a.targetResolver(self,self.target)or self.target end\
local b,c,d=self.canvas,self.mirrors;b:clear()for i=1,#c do d=c[i]\
d.canvas:drawTo(b,d.projectX or d.X,d.projectY or d.Y)end;a.draw(self)end\
function Projector:handleEvent(a)if not self.mode then\
return error\"Failed to handle event. No mode has been set on the Projector\"end\
local b=Projector.static.modes[self.mode].eventDispatcher;if b then b(self,a)end end\
function Projector:setTarget(a)self.target=a;self.resolvedTarget=nil end;function Projector:attachMirror(a)local b=self.mirrors\
for i=1,#b do if b[i]==a then return end end;b[#b+1]=a end;function Projector:detachMirror(a)\
local b=self.mirrors\
for i=1,#b do if b[i]==a then return table.remove(b,i)end end end\
function Projector:setMode(a)\
local b=Projector.modes[a]\
if not b then return\
error(\"Projector mode '\"..tostring(a)..\" is invalid (doesn't exist)\")end;self.mode=a;self.resolvedTarget=nil;if type(b.init)==\"function\"then\
b.init(self)end end\
function Projector.static.registerMode(a)\
if not type(a)==\"table\"then return\
error\"Failed to register projector mode. Expected argument table (config)\"elseif not(type(a.mode)==\"string\"and\
type(a.draw)==\"function\")then return\
error\"Failed to register projector mode. Expected config table to contain 'mode (string)' and 'draw (function)' keys\"elseif\
Projector.modes[mode]then return\
error(\"Failed to register projector mode. Mode '\"..\
tostring(mode)..\"' has already been registered\")end;Projector.modes[a.mode]=a end\
configureConstructor({orderedArguments={\"name\",\"mode\",\"target\"},requiredArguments=true,argumentTypes={name=\"string\",mode=\"string\"},useProxy={\"mode\"}},true)",
["MCallbackManager.ti"]="class\"MCallbackManager\"abstract(){callbacks={}}\
function MCallbackManager:on(a,b,c)\
if\
\
not(type(a)==\"string\"and type(b)==\"function\")or(c and type(c)~=\"string\")then return\
error\"Expected string, function, [string]\"end;local d=self.callbacks;if not d[a]then d[a]={}end\
table.insert(d[a],{b,c})return self end\
function MCallbackManager:off(a,b)\
if b then local c=self.callbacks[a]\
if c then for i=#c,1,-1 do if c[i][2]==b then\
table.remove(c,i)end end end else self.callbacks[a]=nil end;return self end\
function MCallbackManager:executeCallbacks(a,...)local b=self.callbacks[a]if b then for i=1,#b do\
b[i][1](self,...)end end end\
function MCallbackManager:canCallback(a)local b=self.callbacks[a]return b and#b>0 end",
["Checkbox.ti"]="class\"Checkbox\"extends\"Node\"mixin\"MActivatable\"\
mixin\"MTogglable\"{checkedMark=\"x\",uncheckedMark=\" \",allowMouse=true}function Checkbox:__init__(...)self:resolve(...)self:super()\
self:register(\"checkedMark\",\"uncheckedMark\")end\
function Checkbox:onMouseClick(a,b,c)if not b then\
self.active=c;if c then a.handled=true end end end\
function Checkbox:onMouseUp(a,b,c)if not b and c and self.active then self:toggle(a,b,c)\
a.handled=true end;self.active=false end\
function Checkbox:onLabelClicked(a,b,c,d)self:toggle(b,c,d,a)b.handled=true end\
function Checkbox:draw(a)local b=self.raw\
if b.changed or a then local c,d,_a=self.toggled\
if not self.enabled then\
d,_a=b.disabledColour,b.disabledBackgroundColour elseif self.active then d,_a=b.activeColour,b.activeBackgroundColour elseif c then\
d,_a=b.toggledColour,b.toggledBackgroundColour end\
b.canvas:drawPoint(1,1,c and b.checkedMark or b.uncheckedMark,d,_a)b.changed=false end end\
configureConstructor({orderedArguments={\"X\",\"Y\"},argumentTypes={checkedMark=\"string\",uncheckedMark=\"string\"}},true,true)",
["MNodeContainer.ti"]="\
local function b(c,d)d:queueAreaReset()d.application=nil;d.parent=nil;if c.focusedNode==d then\
d.focused=false end;d:executeCallbacks\"remove\"c.changed=true\
c:clearCollatedNodes()end;class\"MNodeContainer\"abstract(){nodes={}}\
function MNodeContainer:addNode(c)\
if\
not Titanium.typeOf(c,\"Node\",true)then return\
error(\"Cannot add '\"..tostring(c)..\
\"' as Node on '\"..tostring(self)..\"'\")end;c.parent=self\
if Titanium.typeOf(self,\"Application\",true)then c.application=self\
self.needsThemeUpdate=true else\
if Titanium.typeOf(self.application,\"Application\",true)then\
c.application=self.application;self.application.needsThemeUpdate=true end end;self.changed=true;self:clearCollatedNodes()\
table.insert(self.nodes,c)c:retrieveThemes()c:refreshDynamicValues()\
c:updateZ()if c.focused then c:focus()end;return c end\
function MNodeContainer:removeNode(c)local d=type(c)==\"string\"\
if not d and not\
Titanium.typeOf(c,\"Node\",true)then return\
error(\"Cannot perform search for node using target '\"..tostring(c)..\
\"' to remove.\")end;local _a,aa,ba=self.nodes,nil;for i=1,#_a do aa=_a[i]\
if\
(d and aa.id==c)or(not d and aa==c)then table.remove(_a,i)b(self,aa)return true,aa end end;return false end\
function MNodeContainer:clearNodes()local c=self.nodes;for i=#c,1,-1 do b(self,c[i])\
table.remove(c,i)end end\
function MNodeContainer:getNode(c,d)\
local _a,aa=d and self.collatedNodes or self.nodes;for i=1,#_a do aa=_a[i]if aa.id==c then return aa end end end\
function MNodeContainer:isMouseColliding(c)\
local d,_a,aa=c.X-self.X+1,c.Y-self.Y+1,self.nodes\
for i=1,#aa do local ba=aa[i]local ca,da=ba.X,ba.Y\
if ba.visible and d>=ca and\
d<=ca+ba.width-1 and _a>=da and\
_a<=da+ba.height-1 then return true end end;return false end;function MNodeContainer:query(c)return NodeQuery(self,c)end\
function MNodeContainer:clearCollatedNodes()\
self.collatedNodes=false;local c=self.parent;if c then c:clearCollatedNodes()end end\
function MNodeContainer:getCollatedNodes()\
if not self.collatedNodes or\
#self.collatedNodes==0 then self:collate()end;return self.collatedNodes end\
function MNodeContainer:collate(c)local d=c or{}local _a,aa=self.nodes\
for i=1,#_a do aa=_a[i]d[#d+1]=aa\
local ba=aa.collatedNodes;if ba then for i=1,#ba do d[#d+1]=ba[i]end end end;self.collatedNodes=d end\
function MNodeContainer:setEnabled(c)self.super:setEnabled(c)\
if self.parentEnabled then\
local d=self.nodes;for i=1,#d do d[i].parentEnabled=c end end end\
function MNodeContainer:setParentEnabled(c)self.super:setParentEnabled(c)\
local d,_a=self.enabled,self.nodes;for i=1,#_a do _a[i].parentEnabled=d end end\
function MNodeContainer:setApplication(c)if self.super.setApplication then\
self.super:setApplication(c)else self.application=c end\
local d=self.nodes;for i=1,#d do if d[i]then d[i].application=c end end end\
function MNodeContainer:setBackgroundColour(c)\
self.super:setBackgroundColour(c)local d=self.nodes;for i=1,#d do d[i].needsRedraw=true end end\
function MNodeContainer:redrawArea(c,d,_a,aa,ba,ca)d=d>0 and d or 1;c=c>0 and c or 1;if d+aa-1 >\
self.height then aa=self.height-d+1 end;if c+_a-1 >\
self.width then _a=self.width-c+1 end;if\
not self.canvas then return end;self.canvas:clearArea(c,d,_a,aa)\
local da,_b,ab,bb=self.nodes\
for i=1,#da do _b=da[i]ab,bb=_b.X+ (ba or 0),_b.Y+ (ca or 0)if not(\
\
ab+_b.width-1 <c or ab>c+_a or bb+_b.height-1 <d or bb>d+aa)then\
_b.needsRedraw=true end end;local cb=self.parent;if cb then\
cb:redrawArea(self.X+c-1,self.Y+d-1,_a,aa)end end\
function MNodeContainer:importFromTML(c)TML.fromFile(self,c)self.changed=true end\
function MNodeContainer:replaceWithTML(c)local d,_a=self.nodes;for i=#d,1,-1 do _a=d[i]_a.parent=nil\
_a.application=nil;table.remove(d,i)end\
self:importFromTML(c)end",
["MThemeable.ti"]="\
local function d(ba,ca,da)local _b=ca.ambiguous and Titanium.typeOf(ba,ca.type)or\
ba.__type==ca.type;if(ca.type==\
\"*\"or not ca.type or _b)and da then\
return true end\
if\
\
(ca.type and not _b and ca.type~=\"*\")or(ca.id and ba.id~=ca.id)or(ca.classes and not\
ba:hasClass(ca.classes))then return false end;return true end;local function _a(ba,ca,da,_b)\
for i=ca,#ba do local ab=ba[i]if d(ab,da,_b)then return true,i end end;return false end\
local function aa(ba,ca,da)\
local _b=QueryParser(ca).query[1]local ab,bb=ba,{}\
while true do local db=ab.parent;if db then bb[#bb+1]=db;ab=db else break end end;if not d(ba,_b[#_b],da)then return false end;local cb=1\
for i=#_b-1,1,-1 do\
local db=_b[i]\
if db.direct then if d(bb[cb],db,da)then cb=cb+1 else return false end else\
local _c,ac=_a(bb,cb,db,da)if _c then cb=cb+ac else return false end end end;return true end;class\"MThemeable\"\
abstract(){isUpdating=false,hooked=false,properties={},classes={},applicableRules={},rules={},mainValues={},defaultValues={}}\
function MThemeable:register(...)\
if self.hooked then return\
error\"Cannot register new properties while hooked. Unhook the theme handler before registering new properties\"end;local ba={...}\
for i=1,#ba do self.properties[ba[i]]=true end end\
function MThemeable:unregister(...)\
if self.hooked then return\
error\"Cannot unregister properties while hooked. Unhook the theme handler before unregistering properties\"end;local ba={...}\
for i=1,#ba do self.properties[ba[i]]=nil end end\
function MThemeable:hook()if self.hooked then\
return error\"Failed to hook theme handler. Already hooked\"end\
for ba in pairs(self.properties)do\
self:watchProperty(ba,function(ca,da,_b)if\
self.isUpdating then return end;self.mainValues[ba]=_b;return\
self:fetchPropertyValue(ba)end,\
\"THEME_HOOK_\"..self.__ID)\
self[self.__resolved[ba]and\"mainValues\"or\"defaultValues\"][ba]=self[ba]end\
self:on(\"dynamic-instance-set\",function(ba,ca)if not ba.isUpdating and ca.property then\
ba.mainValues[ca.property]=ca end end)\
self:on(\"dynamic-instance-unset\",function(ba,ca,da)if\
not ba.isUpdating and ba.mainValues[ca]==da then ba.mainValues[ca]=nil end end)self.hooked=true end\
function MThemeable:unhook()if not self.hooked then\
return error\"Failed to unhook theme handler. Already unhooked\"end\
self:unwatchProperty(\"*\",\"THEME_HOOK_\"..self.__ID)self:off\"dynamic-instance-set\"self:off\"dynamic-instance-unset\"\
self.hooked=false end\
function MThemeable:fetchPropertyValue(ba)local ca=self.mainValues[ba]local da=ca~=nil\
local _b,ab,bb=self.applicableRules;for i=1,#_b do ab=_b[i]\
if ab.property==ba and(not da or ab.important)then\
ca=ab.value;bb=ab;if ab.important then da=true end end end;return ca,bb end\
function MThemeable:updateProperty(ba)\
if not self.properties[ba]then return\
error(\"Failed to update property '\"..\
tostring(ba)..\"'. Property not registered\")end;local ca,da=self:fetchPropertyValue(ba)self.isUpdating=true\
if ca~=nil then\
if\
Titanium.typeOf(ca,\"DynamicValue\",true)then self:setDynamicValue(ca,true)elseif da and da.isDynamic then\
self:setDynamicValue(DynamicValue(self,ba,ca),true)else self[ba]=ca end else self[ba]=self.defaultValues[ba]end;self.isUpdating=false end\
function MThemeable:retrieveThemes(ba)if not ba then self.rules={}end;if not self.application then\
return false end;local ca,da\
local _b,ab=self.rules,self.application.rules;if not ab then return end\
for cb,db in pairs{ab.ANY,ab[self.__type]}do local _c=1\
for ac,bc in\
pairs(db)do\
if aa(self,ac,true)then if not _b[ac]then _b[ac]={}end;local cc,dc=_b[ac]\
for i=1,#bc do\
dc=bc[i]\
if dc.computeType then\
if not da then\
local _d=Titanium.getClass(self.__type).getRegistry()da=_d.alias;local ad=_d.constructor\
if ad then ca=ad.argumentTypes or{}else ca={}end end\
cc[#cc+1]={property=dc.property,important=dc.important,value=XMLParser.convertArgType(dc.value,ca[da[dc.property]or dc.property])}else cc[#cc+1]=dc end end end end end;self:filterThemes()local bb=self.nodes;if bb then for i=1,#bb do\
bb[i]:retrieveThemes(ba)end end end\
function MThemeable:filterThemes()local ba={}\
for ca,da in pairs(self.rules)do if aa(self,ca)then for i=1,#da do\
ba[#ba+1]=da[i]end end end;self.applicableRules=ba;self:updateProperties()end\
function MThemeable:updateProperties()for ba in pairs(self.properties)do\
self:updateProperty(ba)end end\
function MThemeable:addClass(ba)self.classes[ba]=true;self:filterThemes()end\
function MThemeable:removeClass(ba)self.classes[ba]=nil;self:filterThemes()end;function MThemeable:setClass(ba,ca)self.classes[ba]=ca and true or nil\
self:filterThemes()end\
function MThemeable:hasClass(ba)\
if\
type(ba)==\"string\"then return self.classes[ba]elseif type(ba)==\"table\"then for i=1,#ba do if\
not self.classes[ba[i]]then return false end end;return true else return\
error(\
\"Invalid target '\"..tostring(ba)..\"' for class check\")end end",
["MInteractable.ti"]="class\"MInteractable\"\
abstract(){static={properties={move={\"X\",\"Y\"},resize={\"width\",\"height\"}},callbacks={move={\"onPickup\",\"onDrop\"}}},mouse=false}\
function MInteractable:updateMouse(a,b,c)\
if not a and self.mouse then\
local d=MInteractable.static.callbacks[self.mouse[1]]if d then self:executeCallbacks(d[2])end\
self.mouse=false else self.mouse={a,b,c}\
local d=MInteractable.static.callbacks[a]if d then self:executeCallbacks(d[1],b,c)end end end\
function MInteractable:handleMouseDrag(a,b,c)local d=self.mouse;if not d or b then return end\
local _a=MInteractable.static.properties[d[1]]if not _a then return end\
self[_a[1]],self[_a[2]]=a.X-d[2]+1,a.Y-d[3]+1;a.handled=true end",
["Thread.ti"]="class\"Thread\"\
mixin\"MCallbackManager\"{running=false,func=false,co=false,filter=false,exception=false,crashSilently=false,titaniumEvents=false}\
function Thread:__init__(...)self:resolve(...)self:start()end;function Thread:start()self.co=coroutine.create(self.func)\
self.running=true;self.filter=false end;function Thread:stop()\
self.running=false end\
function Thread:filterHandle(a)if self.titaniumEvents then self:handle(a)else\
self:handle(unpack(a.data))end end\
function Thread:handle(...)if not self.running then return false end\
local a,b,c,d,_a,aa=self.titaniumEvents,self.filter,select(1,...),self.co\
if a then if not b or(c:is(b)or c:is(\"terminate\"))then\
_a,aa=coroutine.resume(d,c)else return end else\
if not b or\
(c==b or c==\"terminate\")then _a,aa=coroutine.resume(d,...)else return end end\
if _a then\
if coroutine.status(d)==\"dead\"then self.running=false end;self.filter=aa else self.exception=aa;self.running=false;if\
not self.crashSilently then\
error(tostring(self)..\" coroutine exception: \"..tostring(aa))end end end\
function Thread:setRunning(a)self.running=a;if not a then\
self:executeCallbacks(\"finish\",self.exception)end end\
configureConstructor{orderedArguments={\"func\",\"titaniumEvents\",\"crashSilently\",\"id\"},requiredArguments={\"func\"}}",
["Class.lua"]="local c_a,d_a,_aa,aaa={},{}\
local baa={static=true,super=true,__type=true,isCompiled=true,compile=true}local caa\
local daa=setmetatable({},{__index=function(_ab,aab)_ab[aab]=\"get\"..\
aab:sub(1,1):upper()..aab:sub(2)return _ab[aab]end})\
local _ba=setmetatable({},{__index=function(_ab,aab)\
_ab[aab]=\"set\"..aab:sub(1,1):upper()..aab:sub(2)return _ab[aab]end})local aba={}for i=0,15 do aba[2 ^i]=true end\
local bba=\"\\nPlease report this via GitHub @ hbomb79/Titanium\"local cba=\"Failed to %s to %s\\n\"\
local dba=\"No class is currently being built. Declare a class before invoking '%s'\"\
local function _ca(...)return error(table.concat({...},\"\\n\"),2)end;local function aca(_ab)\
return\
type(_ab)==\"string\"and type(c_a[_ab])==\"table\"and type(d_a[_ab])==\"table\"end\
local function bca(_ab,aab)if not\
Titanium.isClass(_ab)then return false end;if\
aab and not _ab:isCompiled()then _ab:compile()end;return true end\
local function cca(...)\
if type(aaa)==\"table\"or type(_aa)==\"table\"then\
if\
not(aaa and _aa)then\
_ca(\"Failed to validate currently building class objects\",\"The 'currentClass' and 'currentRegistry' variables are not both set\\n\",\"currentClass: \"..\
tostring(_aa),\"currentRegistry: \"..tostring(aaa),bba)end;return true end;if# ({...})>0 then return _ca(...)else return false end end\
local function dca(_ab)\
if aca(_ab)then return c_a[_ab]elseif caa then local aab,bab=_aa,aaa;_aa,aaa=nil,nil;caa(_ab)\
local cab=c_a[_ab]if not bca(cab,true)then\
_ca(\"Failed to load missing class '\".._ab..\"'.\\n\",\
\"The missing class loader failed to load class '\".._ab..\"'.\\n\")end\
_aa,aaa=aab,bab;return cab else\
_ca(\"Class '\".._ab..\"' not found\")end end\
local function _da(_ab)\
if type(_ab)==\"table\"then local aab={}\
for bab,cab in next,_ab,nil do aab[_da(bab)]=_da(cab)end;return aab else return _ab end end\
local function ada(_ab)\
if type(_ab)==\"table\"then\
if _ab.static then\
if type(_ab.static)~=\"table\"then\
_ca(\"Invalid entity found in trailing property table\",\
\"Expected type 'table' for entity 'static'. Found: \"..tostring(_ab.static),\"\\nThe 'static' entity is for storing static variables, refactor your class declaration.\")end;local cab,dab=aaa.static,aaa.ownedStatics\
for _bb,abb in pairs(_ab.static)do\
if baa[_bb]then\
_ca(\
\"Failed to set static key '\".._bb..\"' on building class '\"..aaa.type..\"'\",\
\"'\".._bb..\"' is reserved by Titanium for internal processes.\")end;cab[_bb]=abb\
dab[_bb]=type(abb)==\"nil\"and nil or true end;_ab.static=nil end;local aab,bab=aaa.keys,aaa.ownedKeys\
for cab,dab in pairs(_ab)do aab[cab]=dab;bab[cab]=\
type(dab)==\"nil\"and nil or true end elseif type(_ab)~=\"nil\"then\
_ca(\"Invalid trailing entity caught\\n\",\"An invalid object was caught trailing the class declaration for '\"..\
aaa.type..\"'.\\n\",\"Object: '\"..tostring(_ab)..\"' (\"..\
type(_ab)..\")\"..\"\\n\",\"Expected [tbl | nil]\")end end;local function bda(_ab,aab)\
return function(bab,...)local cab=bab:setSuper(aab)local dab={_ab(...)}bab.super=cab;return\
unpack(dab)end end\
local function cda(_ab)\
local aab,bab={},{},{}\
local function cab(dab,_bb)local abb={}local bbb=dab.__type;local cbb=d_a[bbb]\
for dbb,_cb in pairs(cbb.keys)do\
if not baa[dbb]then\
local acb=_cb\
if type(_cb)==\"function\"then\
abb[dbb]=function(bcb,...)local ccb=bcb:setSuper(_bb+1)\
local dcb={_cb(bcb,...)}bcb.super=ccb;return unpack(dcb)end;acb=abb[dbb]end;aab[dbb]=acb end end\
for dbb,_cb in pairs(aab)do if type(_cb)==\"function\"and not abb[dbb]then\
abb[dbb]=_cb end end;bab[_bb]={abb,cbb}end;for id=#_ab,1,-1 do cab(_ab[id],id)end\
return aab,\
function(dab)local _bb,abb={}\
local function bbb(dbb,_cb)\
local acb,bcb,ccb=bab[_cb],{},{}local dcb,_db=acb[1],acb[2]bcb.__type=_db.type\
local adb,bdb,cdb,ddb,__c=_db.raw,_db.ownedKeys,{}\
function ccb:__tostring()return\
\"[\".._db.type..\"] Super #\"..\
_cb..\" of '\"..dab.__type..\"' instance\"end;function ccb:__newindex(a_c,b_c)if not abb and a_c==\"super\"then __c=b_c;return end\
_ca(\"Cannot set keys on super. Illegal action.\")end\
function ccb:__index(a_c)\
ddb=dcb[a_c]\
if ddb then if not cdb[a_c]then\
cdb[a_c]=(function(b_c,...)return ddb(dab,...)end)end;return cdb[a_c]else\
if a_c==\"super\"then return __c else return\
_ca(\
\"Cannot lookup value for key '\"..a_c..\"' on super\",\"Only functions can be accessed from supers.\")end end end\
function ccb:__call(a_c,...)local b_c=self.__init__;if type(b_c)==\"function\"then return b_c(self,...)else\
_ca(\"Failed to execute super constructor. __init__ method not found\")end end;setmetatable(bcb,ccb)return bcb end;local cbb=_bb\
for id=1,#_ab do cbb.super=bbb(_ab[id],id)cbb=cbb.super end;martixReady=true;return _bb end end\
local function dda(_ab,aab)\
if type(_ab)==\"table\"and type(aab)==\"table\"then local bab=_da(_ab)or\
_ca(\"Invalid base table for merging.\")\
if\
#aab==0 and next(aab)then for cab,dab in pairs(aab)do bab[cab]=dab end elseif#aab>0 then for i=1,#aab do\
table.insert(bab,i,aab[i])end end;return bab end;return aab==nil and _ab or aab end\
local __b={\"orderedArguments\",\"requiredArguments\",\"argumentTypes\",\"useProxy\"}\
local function a_b(_ab)local aab={}local bab,cab=_ab.constructor,aaa.constructor\
if not cab and bab then\
aaa.constructor=bab;return elseif cab and not bab then bab={}elseif not cab and not bab then return end;local dab\
for i=1,#__b do dab=__b[i]if not\
( (dab==\"orderedArguments\"and cab.clearOrdered)or(\
dab==\"requiredArguments\"and cab.clearRequired))then\
cab[dab]=dda(bab[dab],cab[dab])end end end\
local function b_b()\
cca(\"Cannot compile current class.\",\"No class is being built at time of call. Declare a class be invoking 'compileCurrent'\")local _ab,aab,bab=aaa.ownedKeys,aaa.ownedStatics,aaa.allMixins\
local cab=aaa.constructor\
for bbb in pairs(aaa.mixins)do bab[bbb]=true;local cbb=d_a[bbb]\
local dbb={{cbb.keys,aaa.keys,_ab},{cbb.static,aaa.static,aab},{cbb.alias,aaa.alias,aaa.alias}}\
for i=1,#dbb do local acb,bcb,ccb=dbb[i][1],dbb[i][2],dbb[i][3]for dcb,_db in pairs(acb)do if\
not ccb[dcb]then bcb[dcb]=_db end end end;local _cb=cbb.constructor\
if _cb then\
if _cb.clearOrdered then cab.orderedArguments=nil end;if _cb.clearRequired then cab.requiredArguments=nil end;local acb\
for i=1,#__b do\
acb=__b[i]cab[acb]=dda(cab[acb],_cb and _cb[acb])end;cab.tmlContent=cab.tmlContent or _cb.tmlContent end end;local dab\
if aaa.super then local bbb={}local cbb,dbb,_cb=aaa.super.target;while cbb do dbb=dca(cbb,true)bbb[\
#bbb+1]=dbb;_cb=d_a[cbb].super\
cbb=_cb and _cb.target or false end\
dab,aaa.super.matrix=cda(bbb)local acb=aaa.alias\
for bcb,ccb in pairs(d_a[bbb[1].__type].alias)do if acb[bcb]==\
nil then acb[bcb]=ccb end end\
for bcb in pairs(d_a[bbb[1].__type].allMixins)do bab[bcb]=true end;a_b(d_a[bbb[1].__type])end;local _bb,abb={},{}\
for bbb,cbb in pairs(aaa.keys)do if type(cbb)==\"function\"then _bb[bbb]=true\
abb[bbb]=bda(cbb,1)else abb[bbb]=cbb end end\
if dab then\
for bbb,cbb in pairs(dab)do if not abb[bbb]then\
if type(cbb)==\"function\"then _bb[bbb]=true;abb[bbb]=function(dbb,...)return\
cbb(...)end else abb[bbb]=cbb end end end end;aaa.initialWrappers=_bb;aaa.initialKeys=abb;aaa.compiled=true;aaa=nil;_aa=nil end\
local function c_b(_ab,...)if not aca(_ab)then\
_ca(\"Failed to spawn class instance of '\"..tostring(_ab)..\"'\",\
\"A class entity named '\"..tostring(_ab)..\"' doesn't exist.\")end\
local aab,bab=c_a[_ab],d_a[_ab]\
if bab.abstract or not bab.compiled then\
_ca(\"Failed to instantiate class '\"..bab.type..\"'\",\
\"Class '\"..bab.type..\
\"' \".. (bab.abstract and\"is abstract. Cannot instantiate abstract class.\"or\
\"has not been compiled. Cannot instantiate.\"))end;local cab,dab=_da(bab.initialWrappers),{}\
local _bb=_da(bab.initialKeys)local abb=bab.alias;local bbb=string.sub(tostring(_bb),8)local cbb={}local function dbb(a_c,b_c)\
while\
a_c.super do cbb[b_c]=a_c.super;a_c=a_c.super;b_c=b_c+1 end end\
local _cb,acb={raw=_bb,__type=_ab,__instance=true,__ID=bbb},{__metatable={}}local bcb,ccb,dcb,_db={},true,{},true\
function acb:__index(a_c)local b_c=abb[a_c]or a_c;local c_c=daa[b_c]\
if\
ccb and not bcb[b_c]and cab[c_c]then bcb[b_c]=true\
local d_c=self[c_c](self)bcb[b_c]=nil;return d_c elseif cab[b_c]then\
if not dab[b_c]then dab[b_c]=function(...)\
return _bb[b_c](self,...)end end;return dab[b_c]else return _bb[b_c]end end\
function acb:__newindex(a_c,b_c)local c_c=abb[a_c]or a_c;local d_c=_ba[c_c]\
if\
_db and not dcb[c_c]and cab[d_c]then dcb[c_c]=true;self[d_c](self,b_c)dcb[c_c]=\
nil elseif type(b_c)==\"function\"and _db then cab[c_c]=true\
_bb[c_c]=bda(b_c,1)else cab[c_c]=nil;_bb[c_c]=b_c end end;function acb:__tostring()\
return\"[Instance] \".._ab..\" (\"..bbb..\")\"end;if bab.super then\
_cb.super=bab.super.matrix(_cb).super;dbb(_cb,1)end;local adb;function _cb:setSuper(a_c)\
adb,_cb.super=_cb.super,cbb[a_c]return adb end\
local function bdb(a_c,b_c)_db=false;_cb[a_c]=b_c;_db=true end;local cdb;local ddb={}\
function _cb:resolve(...)if cdb then return false end;local a_c,b_c={...},bab.constructor;if\
not b_c then\
_ca(\"Failed to resolve \"..\
tostring(instance)..\" constructor arguments. No configuration has been set via 'configureConstructor'.\")end\
local c_c,d_c,_ac,aac=b_c.requiredArguments,b_c.orderedArguments,\
b_c.argumentTypes or{},b_c.useProxy or{}local bac={}\
if c_c then\
local bbc=type(c_c)==\"table\"and c_c or d_c;for i=1,#bbc do bac[bbc[i]]=true end end;local cac={}for i=1,#d_c do cac[d_c[i]]=i end\
local dac,_bc=type(aac)==\"boolean\"and aac,{}\
if not dac then for i=1,#aac do _bc[aac[i]]=true end end\
local function abc(bbc,cbc,dbc)local _cc=_ac[cbc]\
if _cc==\"colour\"or _cc==\"color\"then _cc=\"number\"end\
if _cc and _cc~=\"ANY\"and type(dbc)~=_cc then\
return\
_ca(\"Failed to resolve '\"..\
tostring(_ab)..\
\"' constructor arguments. Invalid type for argument '\"..cbc..\
\"'. Type \".._ac[cbc]..\" expected, \"..\
type(dbc)..\" was received.\")end;ddb[cbc],bac[cbc]=true,nil;if dac or _bc[cbc]then self[cbc]=dbc else\
bdb(cbc,dbc)end end\
for bbc,cbc in pairs(a_c)do\
if d_c[bbc]then abc(bbc,d_c[bbc],cbc)elseif type(cbc)==\"table\"then for dbc,_cc in\
pairs(cbc)do abc(cac[dbc],dbc,_cc)end else return\
_ca(\"Failed to resolve '\"..\
tostring(_ab)..\
\"' constructor arguments. Invalid argument found at ordered position \"..bbc..\".\")end end\
if next(bac)then local bbc,cbc=\"\"\
local function dbc(_cc)bbc=bbc..\"- \".._cc..\"\\n\"end\
return\
_ca(\"Failed to resolve '\"..\
tostring(_ab)..\
\"' constructor arguments. The following required arguments were not provided:\\n\\n\"..\
(function()\
bbc=\"Ordered:\\n\"\
for i=1,#d_c do cbc=d_c[i]if bac[cbc]then dbc(cbc..\" [#\"..i..\"]\")bac[cbc]=\
nil end end;if next(bac)then bbc=bbc..\"\\nTrailing:\\n\"\
for _cc,acc in pairs(bac)do dbc(_cc)end end;return bbc end)())end;cdb=true;return true end;_cb.__resolved=ddb\
function _cb:can(a_c)return cab[a_c]or false end;local __c={__index=true,__newindex=true}\
function _cb:setMetaMethod(a_c,b_c)\
if type(a_c)~=\"string\"then\
_ca(\
\"Failed to set metamethod '\"..tostring(a_c)..\"'\",\"Expected string for argument #1, got '\"..\
tostring(a_c)..\"' of type \"..type(a_c))elseif type(b_c)~=\"function\"then\
_ca(\"Failed to set metamethod '\"..tostring(a_c)..\"'\",\
\"Expected function for argument #2, got '\"..tostring(b_c)..\"' of type \"..type(b_c))end;a_c=\"__\"..a_c;if __c[a_c]then\
_ca(\"Failed to set metamethod '\"..tostring(a_c)..\"'\",\"Metamethod locked\")end;acb[a_c]=b_c end\
function _cb:lockMetaMethod(a_c)if type(a_c)~=\"string\"then\
_ca(\"Failed to lock metamethod '\"..tostring(a_c)..\"'\",\
\"Expected string, got '\"..tostring(a_c)..\"' of type \"..type(a_c))end;__c[\
\"__\"..a_c]=true end;setmetatable(_cb,acb)if type(_cb.__init__)==\"function\"then\
_cb:__init__(...)end\
for a_c in pairs(bab.allMixins)do if\
type(_cb[a_c])==\"function\"then _cb[a_c](_cb)end end;if type(_cb.__postInit__)==\"function\"then\
_cb:__postInit__(...)end;return _cb end\
function class(_ab)\
if cca()then\
_ca(\"Failed to declare class '\"..tostring(_ab)..\"'\",\"A new class cannot be declared until the currently building class has been compiled.\",\
\"\\nCompile '\"..\
tostring(aaa.type)..\"' before declaring '\"..tostring(_ab)..\"'\")end;local function aab(_cb)\
_ca(\"Failed to declare class '\"..tostring(_ab)..\"'\\n\",string.format(\"Class name %s is not valid. %s\",tostring(_ab),_cb))end\
if\
type(_ab)~=\"string\"then aab\"Class names must be a string\"elseif not _ab:find\"%a\"then\
aab\"No alphabetic characters could be found\"elseif _ab:find\"%d\"then aab\"Class names cannot contain digits\"elseif c_a[_ab]then\
aab\"A class with that name already exists\"elseif baa[_ab]then\
aab(\"'\".._ab..\"' is reserved for Titanium processes\")else local _cb=_ab:sub(1,1)if _cb~=_cb:upper()then\
aab\"Class names must begin with an uppercase character\"end end\
local bab={type=_ab,static={},keys={},ownedStatics={},ownedKeys={},initialWrappers={},initialKeys={},mixins={},allMixins={},alias={},constructor={},super=false,compiled=false,abstract=false}local cab={__metatable={}}function cab:__tostring()\
return\
(bab.compiled and\"[Compiled] \"or\"\")..\"Class '\".._ab..\"'\"end\
local dab,_bb=bab.keys,bab.ownedKeys;local abb,bbb=bab.static,bab.ownedStatics\
function cab:__newindex(_cb,acb)\
if bab.compiled then\
_ca(\"Failed to set key on class base.\",\"\",\"This class base is compiled, once a class base is compiled new keys cannot be added to it\",\
\"\\nPerhaps you meant to set the static key '\".._ab..\".static.\".._cb..\"' instead.\")end;dab[_cb]=acb\
_bb[_cb]=type(acb)==\"nil\"and nil or true end\
function cab:__index(_cb)\
if _bb[_cb]then\
_ca(\"Access to key '\".._cb..\"' denied.\",\"Instance keys cannot be accessed from a class base, regardless of compiled state\",\
\
bab.ownedStatics[_cb]and\"\\nPerhaps you meant to access the static variable '\"..\
_ab..\".static.\".._cb..\"' instead\"or nil)elseif bbb[_cb]then return abb[_cb]end end;function cab:__call(...)return c_b(_ab,...)end;local cbb={__index=abb}function cbb:__newindex(_cb,acb)\
abb[_cb]=acb\
bbb[_cb]=type(acb)==\"nil\"and nil or true end;local dbb={__type=_ab}\
dbb.static=setmetatable({},cbb)dbb.compile=b_b;function dbb:isCompiled()return bab.compiled end;function dbb:getRegistry()return\
bab end;setmetatable(dbb,cab)aaa=bab\
d_a[_ab]=bab;_aa=dbb;c_a[_ab]=dbb;_G[_ab]=dbb;return ada end\
function extends(_ab)\
cca(string.format(cba,\"extend\",\"target class '\"..tostring(_ab)..\"'\"),\"\",string.format(dba,\"extends\"))aaa.super={target=_ab}return ada end\
function mixin(_ab)if type(_ab)~=\"string\"then\
_ca(\"Invalid mixin target '\"..tostring(_ab)..\"'\")end\
cca(string.format(cba,\"mixin\",\"target class '\".._ab..\"'\"),string.format(dba,\"mixin\"))local aab=aaa.mixins;if aab[_ab]then\
_ca(\
string.format(cba,\"mixin class '\".._ab..\"'\",\"class '\"..aaa.type)\"'\".._ab..\"' has already been mixed in to this target class.\")end;if not\
dca(_ab,true)then\
_ca(string.format(cba,\"mixin class '\".._ab..\"'\",\"class '\"..aaa.type),\
\"The mixin class '\".._ab..\"' failed to load\")end\
aab[_ab]=true;return ada end\
function abstract()\
cca(\"Failed to enforce abstract class policy\\n\",string.format(dba,\"abstract\"))aaa.abstract=true;return ada end\
function alias(_ab)local aab=\"Failed to implement alias targets\\n\"\
cca(aab,string.format(dba,\"alias\"))\
local bab=type(_ab)==\"table\"and _ab or\
(type(_ab)==\"string\"and\
(\
type(_G[_ab])==\"table\"and _G[_ab]or _ca(aab,\"Failed to find '\"..\
tostring(_ab)..\"' table in global environment.\"))or\
_ca(aab,\
\"Expected type table as target, got '\"..tostring(_ab)..\"' of type \"..type(_ab)))local cab=aaa.alias;for dab,_bb in pairs(bab)do cab[dab]=_bb end;return ada end\
function configureConstructor(_ab,aab,bab)\
cca(\"Failed to configure class constructor\\n\",string.format(dba,\"configureConstructor\"))if type(_ab)~=\"table\"then\
_ca(\"Failed to configure class constructor\\n\",\"Expected type 'table' as first argument\")end\
local cab={clearOrdered=aab or nil,clearRequired=bab or nil}for dab,_bb in pairs(_ab)do cab[dab]=_bb end;aaa.constructor=cab;return ada end;Titanium={}function Titanium.getGetterName(_ab)return daa[_ab]end;function Titanium.getSetterName(_ab)return\
_ba[_ab]end\
function Titanium.getClass(_ab)return c_a[_ab]end;function Titanium.getClasses()return c_a end\
function Titanium.isClass(_ab)return\
type(_ab)==\"table\"and\
type(_ab.__type)==\"string\"and aca(_ab.__type)end;function Titanium.isInstance(_ab)\
return Titanium.isClass(_ab)and _ab.__instance end\
function Titanium.typeOf(_ab,aab,bab)if\
not\
Titanium.isClass(_ab)or(bab and not Titanium.isInstance(_ab))then return false end\
local cab=d_a[_ab.__type]return\
cab.type==aab or(cab.super and\
Titanium.typeOf(c_a[cab.super.target],aab))or false end\
function Titanium.mixesIn(_ab,aab)\
if not Titanium.isClass(_ab)then return false end;return d_a[_ab.__type].allMixins[aab]end\
function Titanium.setClassLoader(_ab)if type(_ab)~=\"function\"then\
_ca(\"Failed to set class loader\",\"Value '\"..tostring(_ab)..\
\"' is invalid, expected function\")end;caa=_ab end;local d_b={\"class\",\"extends\",\"alias\",\"mixin\"}\
function Titanium.preprocess(_ab)local aab\
for i=1,#d_b\
do aab=d_b[i]for bab in _ab:gmatch(aab..\" ([_%a][_%w]*)%s\")do\
_ab=_ab:gsub(aab..\" \"..bab,\
aab..\" \\\"\"..bab..\"\\\"\")end end;for bab in _ab:gmatch(\"abstract class (\\\".[^%s]+\\\")\")do\
_ab=_ab:gsub(\"abstract class \"..bab,\"class \"..\
bab..\" abstract()\")end;return _ab end",
["XMLLexer.ti"]="class\"XMLLexer\"\
extends\"Lexer\"{openTag=false,definingAttribute=false,currentAttribute=false}\
function XMLLexer:consumeComment()local a=self.stream;local b=a:find(\"%-%-%>\",4)if b then\
self.stream=a:sub(b+3)else self.stream=\"\"end end\
function XMLLexer:tokenize()self:trimStream()\
local a,b,c,d=self:trimStream(),self.openTag,self.currentAttribute,self.definingAttribute;local _a=a:sub(1,1)\
if a:find\"^<(%w+)\"then\
self:pushToken({type=\"XML_OPEN\",value=self:consumePattern\"^<(%w+)\"})self.openTag=true elseif a:find\"^</(%w+)>\"then\
self:pushToken({type=\"XML_END\",value=self:consumePattern\"^</(%w+)>\"})self.openTag=false elseif a:find\"^/>\"then\
self:pushToken({type=\"XML_END_CLOSE\"})self:consume(2)self.openTag=false elseif a:find\"^%<%!%-%-\"then\
self:consumeComment()elseif b and a:find\"^%w+\"then\
self:pushToken({type=d and\"XML_ATTRIBUTE_VALUE\"or\"XML_ATTRIBUTE\",value=self:consumePattern\"^%w+\"})if not d then self.currentAttribute=true;return end elseif\
not b and a:find\"^([^<]+)\"then local aa=self:consumePattern\"^([^<]+)\"\
local ba=select(2,aa:gsub(\"\\n\",\"\"))if ba then self:newline(ba)end\
self:pushToken({type=\"XML_CONTENT\",value=aa})elseif _a==\"=\"then\
self:pushToken({type=\"XML_ASSIGNMENT\",value=\"=\"})self:consume(1)if c then self.definingAttribute=true end\
return elseif _a==\"'\"or _a==\"\\\"\"then\
self:pushToken({type=d and\"XML_STRING_ATTRIBUTE_VALUE\"or\"XML_STRING\",value=self:consumeString(_a)})elseif _a==\">\"then self:pushToken({type=\"XML_CLOSE\"})\
self.openTag=false;self:consume(1)else\
self:throw(\"Unexpected block '\"..a:match(\"(.-)%s\")..\"'\")end;if self.currentAttribute then self.currentAttribute=false end;if\
self.definingAttribute then self.definingAttribute=false end end",
["Page.ti"]="class\"Page\"extends\"ScrollContainer\"\
function Page:setParent(a)if\
Titanium.typeOf(a,\"PageContainer\",true)then self:linkProperties(a,\"width\",\"height\")else\
self:unlinkProperties(a,\"width\",\"height\")end\
self.super:setParent(a)end;function Page:updatePosition()\
self.X=self.parent.width* (self.position-1)+1 end;function Page:setPosition(a)self.position=a;self.isPositionTemporary=\
nil end\
function Page:getAbsolutePosition(a)\
local b,c=self.parent,self.application\
if b then if a and b==a then\
return-1 +b.X+self.X-b.scroll,-1 +b.Y+self.Y end\
local d,_a=self.parent:getAbsolutePosition()return-1 +d+self.X-b.scroll,-1 +_a+self.Y else return self.X,\
self.Y end end\
configureConstructor{orderedArguments={\"id\"},argumentTypes={id=\"string\",position=\"number\"},requiredArguments={\"id\"}}",
["MDynamic.ti"]="class\"MDynamic\"abstract(){dynamicValues={}}\
function MDynamic:setDynamicValue(a,b)\
if\
not Titanium.typeOf(a,\"DynamicValue\",true)then return\
error\"Failed to set dynamic value. Expected DynamicValue instance as argument #2\"elseif a.target~=self then return\
error\"Failed to set dynamic value. DynamicValue instance provided belongs to another instance (target doesn't match this instance)\"end;local c=a.property\
if self.dynamicValues[c]then\
if b then\
self.dynamicValues[c]:detach()else return\
error(\"Failed to add dynamic value for property '\"..\
c..\"'. A dynamic value for this instance already exists\")end end;self.dynamicValues[c]=a;a:refresh()\
self:executeCallbacks(\"dynamic-instance-set\",a)end\
function MDynamic:removeDynamicValue(a)local b=self.dynamicValues;local c=b[a]if c then c:detach()b[a]=nil\
self:executeCallbacks(\"dynamic-instance-unset\",a,c)return true end;return false end;function MDynamic:detachDynamicValues()\
for a,b in pairs(self.dynamicValues)do b:detach()end end;function MDynamic:detachDynamicValue(a)\
local b=self.dynamicValues[a]if b then b:detach()end end\
function MDynamic:refreshDynamicValues(a)for b,c in\
pairs(self.dynamicValues)do c:refresh()end\
if not a and self.collatedNodes then\
local b=self.collatedNodes;for i=1,#b do b[i]:refreshDynamicValues()end end end;function MDynamic:refreshDynamicValue(a)local b=self.dynamicValues[a]\
if b then b:attach()end end",
["OverlayContainer.ti"]="class\"OverlayContainer\"\
extends\"Container\"{shader=\"greyscale\",backgroundColour=1}\
function OverlayContainer:__init__(...)self:resolve(...)self:super()\
self.transparent=true;self.consumeAll=false;self.canvas.onlyShadeBottom=true end;function OverlayContainer:__postInit__()self.super:__postInit__()\
self.colour=0 end\
function OverlayContainer:handle(a)if not\
self.super.super:handle(a)then return end;local b\
if a.main==\"MOUSE\"then\
b=a:clone(self)b.isWithin=a:withinParent(self)end;self:shipEvent(b or a)\
if b and b.isWithin then if not b.handled then\
self:executeCallbacks\"miss\"end;a.handled=true end;return true end",
["Window.ti"]="class\"Window\"extends\"Container\"mixin\"MFocusable\"\
mixin\"MInteractable\"{static={proxyMethods={\"addNode\",\"removeNode\",\"getNode\",\"query\",\"clearNodes\"}},titleBar=true,titleBarColour=256,titleBarBackgroundColour=128,closeable=true,closeButtonChar=\"\\7\",closeButtonColour=16384,resizeable=true,resizeButtonChar=\"/\",resizeButtonColour=256,moveable=true,shadow=true,shadowColour=128,transparent=true,passiveFocus=true}\
function Window:__init__(...)self:resolve(...)self:super()\
self.titleBarContent=self:addNode(Container():set{id=\"titlebar\",width=\"$parent.width - ( parent.shadow and 1 or 0 )\",backgroundColour=\"$parent.titleBarBackgroundColour\",colour=\"$not parent.enabled and parent.disabledColour or parent.titleBarColour\",visible=\"$parent.titleBar\",enabled=\"$self.visible\"})\
self.titleBarTitle=self.titleBarContent:addNode(Label(\"\")):set(\"id\",\"title\")\
local a=self.titleBarContent:addNode(Button(\"\"):set(\"X\",\"$parent.width\"))\
a:set{backgroundColour=\"$parent.parent.closeButtonBackgroundColour\",colour=\"$parent.parent.closeButtonColour\",text=\"$parent.parent.closeButtonChar\",visible=\"$parent.parent.closeable\",enabled=\"$self.visible\",id=\"close\",width=1}\
a:on(\"trigger\",function()self:remove()end)\
self.content=self:addNode(ScrollContainer():set{Y=\"$parent.titleBar and 2 or 1\",width=\"$parent.width - ( parent.shadow and 1 or 0 )\",height=\"$parent.height - ( parent.titleBar and 1 or 0 ) - ( parent.shadow and 1 or 0 )\",backgroundColour=\"$parent.enabled and ( parent.focused and parent.focusedBackgroundColour ) or ( not parent.enabled and parent.disabledBackgroundColour ) or parent.backgroundColour\",colour=\"$parent.enabled and ( parent.focused and parent.focusedColour ) or ( not parent.enabled and parent.disabledColour ) or parent.colour\",id=\"content\"})\
for c,d in pairs(Window.static.proxyMethods)do\
self[d]=function(_a,...)return\
_a.content[d](_a.content,...)end\
self[d..\"Raw\"]=function(_a,...)return _a.super[d](_a,...)end end\
self:on(\"remove\",function()self:executeCallbacks\"close\"end)\
self:watchProperty(\"width\",function(c,d,_a)return self:updateWidth(_a)end,\"WINDOW_MIN_MAX_WIDTH_CHECK\")\
self:watchProperty(\"height\",function(c,d,_a)return self:updateHeight(_a)end,\"WINDOW_MIN_MAX_HEIGHT_CHECK\")end\
function Window:__postInit__()if not self.resizeButtonBackgroundColour then\
self.resizeButtonBackgroundColour=\"$self.content.backgroundColour\"end\
self.consumeAll=false;self.super:__postInit__()end\
function Window:onMouseClick(a,b,c)\
if c then\
if not b and a.button==1 then self:focus()\
self:executeCallbacks\"windowFocus\"local d,_a=a.X-self.X+1,a.Y-self.Y+1\
if\
\
self.moveable and _a==1 and(d>=1 and d<=\
self.titleBarContent.width- (self.closeable and 1 or 0))then self:updateMouse(\"move\",d,_a)a.handled=true elseif\
self.resizeable and\
_a==\
self.content.height+ (self.titleBar and 1 or 0)and d==self.content.width then\
self:updateMouse(\"resize\",a.X-self.width+1,a.Y-self.height+1)a.handled=true end end else self:unfocus()self:executeCallbacks\"windowUnfocus\"end end;function Window:onMouseUp(a,b,c)self.mouse=false end;function Window:onMouseDrag(a,b,c)\
self:handleMouseDrag(a,b,c)end\
function Window:updateTitle()\
local a,b=self.title,\
self.titleBarContent.width- (self.closeable and 3 or 2)\
self.titleBarTitle.text=a and#a>b and\
a:sub(1,math.max(1,b-2))..\"..\"or a or\"\"end\
function Window:updateWidth(a)a=a or self.width;a=\
self.minWidth and math.max(a,self.minWidth)or a;return\
math.max(self.maxWidth and\
math.min(a,self.maxWidth)or a,(self.shadow and 4 or 3))end\
function Window:updateHeight(a)a=a or self.height;a=self.minHeight and\
math.max(a,self.minHeight)or a\
return math.max(\
self.maxHeight and math.min(a,self.maxHeight)or a,(\
self.titleBar and 4 or 3))end\
function Window:draw(a,...)\
if a or self.changed then self.super:draw(a,...)\
if self.shadow then\
local b=self.canvas\
b:drawBox(self.width,2,1,self.height-2,self.shadowColour)\
b:drawBox(3,self.height,self.width-2,1,self.shadowColour)end\
if self.resizeable then\
self.canvas:drawPoint(self.content.width,self.content.height+ (\
self.titleBar and 1 or 0),self.resizeButtonChar,self.resizeButtonColour,self.resizeButtonBackgroundColour)end end end;function Window:setWidth(a)\
self.super:setWidth(self:updateWidth(a))self:updateTitle()end;function Window:setMinWidth(a)\
self.minWidth=a;self:updateWidth()end;function Window:setMaxWidth(a)\
self.maxWidth=a;self:updateWidth()end;function Window:setHeight(a)\
self.super:setHeight(self:updateHeight(a))end;function Window:setMinHeight(a)self.minHeight=a\
self:updateHeight()end;function Window:setMaxHeight(a)self.maxHeight=a\
self:updateHeight()end;function Window:setTitle(a)self.title=a\
self:updateTitle()end\
function Window:setShadow(a)self.shadow=a;self.changed=true end\
function Window:setShadowColour(a)self.shadowColour=a;self.changed=true end\
configureConstructor{argumentTypes={title=\"string\",titleBar=\"boolean\",titleBarColour=\"colour\",titleBarBackgroundColour=\"colour\",closeable=\"boolean\",closeButtonChar=\"string\",closeButtonColour=\"colour\",closeButtonBackgroundColour=\"colour\",resizeable=\"boolean\",resizeButtonChar=\"string\",resizeButtonColour=\"colour\",resizeButtonBackgroundColour=\"colour\",moveable=\"boolean\",minWidth=\"number\",minHeight=\"number\",maxWidth=\"number\",maxHeight=\"number\",shadow=\"boolean\",shadowColour=\"colour\"}}",
["EditableTextContainer.ti"]="local b=string.sub;class\"EditableTextContainer\"\
extends\"TextContainer\"{allowKey=true,allowChar=true}\
function EditableTextContainer:wrapText(c)self.super:wrapText(c-1)end\
function EditableTextContainer:insertContent(c,d,_a)\
if self.selection then self:removeContent()end;local aa=self.text\
self.text=b(aa,1,self.position- (_a or 0))..c..b(aa,\
self.position+ (d or 1))self.position=self.position+#c end\
function EditableTextContainer:removeContent(c,d)c=c or 1;local _a=self.text\
if self.selection then\
self.text=b(_a,1,\
math.min(self.selection,self.position)-c)..b(_a,\
math.max(self.selection,self.position)+ (d or 1))\
self.position=math.min(self.position,self.selection)-1;self.selection=false else\
if self.position==0 and c>0 then return end;self.text=b(_a,1,self.position-c)..\
b(_a,self.position+ (d or 1))self.position=\
self.position-c end end\
function EditableTextContainer:onKeyDown(c,d)\
if d or not self.focused then return end\
local _a,aa,ba,ca=c.keyName,self.lineConfig.lines,self.position,(self.selection or self.position)\
local da=self.application:isPressed(keys.leftShift)or\
self.application:isPressed(keys.rightShift)local _b\
if _a==\"up\"or _a==\"down\"then\
local ab=aa[da and self.cache.selY or self.cache.y]\
if not self.cache.tX then self.cache.tX=\
(da and ca or ba)-ab[2]+ab[5]-1 end;_b=self.cache.tX end\
if _a==\"up\"then\
local ab=aa[(da and self.cache.selY or self.cache.y)-1]if not ab then return end\
self[da and\"selection\"or\"position\"]=math.min(\
ab[2]+self.cache.tX-ab[5]+1,ab[3])elseif _a==\"down\"then\
local ab=aa[(da and self.cache.selY or self.cache.y)+1]if not ab then return end\
self[da and\"selection\"or\"position\"]=math.min(\
ab[2]+self.cache.tX-ab[5]+1,ab[3]-1)elseif _a==\"left\"then if da then self.selection=ca-1 else\
self.position=math.min(ba,ca)-1 end elseif _a==\"right\"then\
if da then self.selection=ca+1 else self.position=math.max(ba,\
ca-1)+1 end elseif _a==\"backspace\"then\
self:removeContent((da and\
self.position-aa[self.cache.y][2]or 0)+1)elseif _a==\"enter\"then self:insertContent\"\\n\"elseif _a==\"home\"then self[da and\"selection\"or\"position\"]=\
aa[self.cache.y][2]-1 elseif _a==\"end\"then\
self[da and\"selection\"or\"position\"]=\
aa[self.cache.y][3]- (aa[self.cache.y+1]and 1 or-1)end;self.cache.tX=_b or self.cache.tX end;function EditableTextContainer:onChar(c,d)if d or not self.focused then return end\
self:insertContent(c.char)end\
function EditableTextContainer:setSelection(...)\
self.super:setSelection(...)self.cache.tX=false end;function EditableTextContainer:setPosition(...)self.super:setPosition(...)\
self.cache.tX=false end\
function EditableTextContainer:getCaretInfo()\
if\
not(self.cache.x and self.cache.y)then return false end\
local c,d=self.cache.x-self.xScroll,self.cache.y-self.yScroll;if\
c<0 or c>self.width or d<1 or d>self.height then return false end\
local _a,aa=self:getAbsolutePosition()\
return self.focused and not self.selection and true,c+_a-1,d+\
aa-1,self.focusedColour or self.colour end",
["MAnimationManager.ti"]="class\"MAnimationManager\"\
abstract(){animations={},animationTimer=false,time=false}\
function MAnimationManager:updateAnimations()local a=os.clock()-self.time\
local b,c=self.animations;for i=#b,1,-1 do c=b[i]\
if c:update(a)then if type(c.promise)==\"function\"then\
c:promise(self)end;self:removeAnimation(c)end end\
self.timer=false;if#b>0 then self:restartAnimationTimer()end end\
function MAnimationManager:addAnimation(a)\
if not Titanium.typeOf(a,\"Tween\",true)then return\
error(\
\"Failed to add animation to manager. '\"..tostring(a)..\"' is invalid, Tween instance expected\")end;self:removeAnimation(a.name)\
table.insert(self.animations,a)\
if not self.timer then self:restartAnimationTimer()end;return a end\
function MAnimationManager:removeAnimation(a)local b\
if type(a)==\"string\"then b=true elseif not\
Titanium.typeOf(a,\"Tween\",true)then return\
error(\"Failed to remove animation from manager. '\"..\
tostring(a)..\"' is invalid, Tween instance expected\")end;local c=self.animations\
for i=1,#c do if\
(b and c[i].name==a)or(not b and c[i]==a)then return table.remove(c,i)end end end\
function MAnimationManager:restartAnimationTimer(a)if self.timer then\
os.cancelTimer(self.timer)end;self.time=os.clock()\
self.timer=os.startTimer(\
type(a)==\"number\"and a or.05)end",
["Parser.ti"]="class\"Parser\"abstract(){position=0,tokens={}}\
function Parser:__init__(a)\
if\
type(a)~=\"table\"then return error\"Failed to parse. Invalid tokens\"end;self.tokens=a;self:parse()end\
function Parser:getCurrentToken()return self.tokens[self.position]end;function Parser:peek(a)\
return self.tokens[self.position+ (a or 1)]end\
function Parser:testAdjacent(a,b,c,d,_a,aa)\
local ba,ca,da,_b=false,not a,false,not b\
local function ab(bb,cb)if not bb then return not aa end\
if type(cb)==\"table\"then for i=1,#cb do if bb.type==cb[i]then\
return true end end else return bb.type==cb end end\
if a then ba=self:peek(-1 - (d or 0))ca=ab(ba,a)end\
if b then da=self:peek(1 + (_a or 0))_b=ab(da,b)end\
return(c and(_b or ca)or(not c and _b and ca)),ba,da end;function Parser:stepForward(a)self.position=self.position+ (a or 1)return\
self:getCurrentToken()end\
function Parser:throw(a,b)local c=b or\
self:getCurrentToken()if not c then\
return error(\"Parser (\"..tostring(self.__type)..\
\") Error: \"..a,2)end;return\
error(\"Parser (\"..tostring(self.__type)..\
\
\") Error. Line \"..c.line..\", char \"..c.char..\": \"..a,2)end",
["MFocusable.ti"]="class\"MFocusable\"\
abstract(){focused=false,passiveFocus=false}\
function MFocusable:MFocusable()if Titanium.mixesIn(self,\"MThemeable\")then\
self:register(\"focused\",\"focusedColour\",\"focusedBackgroundColour\")end end\
function MFocusable:setEnabled(a)self.super:setEnabled(a)if\
not a and self.focused then self:unfocus()end end;function MFocusable:setFocused(a)local b=self.raw;if b.focused==a then return end\
self.changed=true;self.focused=a end\
function MFocusable:focus()if\
not self.enabled then return end\
if\
self.application and not self.passiveFocus then self.application:focusNode(self)end;self.focused=true end\
function MFocusable:unfocus()if self.application and not self.passiveFocus then\
self.application:unfocusNode(self)end;self.focused=false end\
configureConstructor{argumentTypes={focusedBackgroundColour=\"colour\",focusedColour=\"colour\",focused=\"boolean\"}}\
alias{focusedColor=\"focusedColour\",focusedBackgroundColor=\"focusedBackgroundColour\"}",
["RedirectCanvas.ti"]="local _a,aa=string.len,string.sub;local ba=term.isColour()local function ca(da)if\
not ba and(da~=1 or\
da~=32768 or da~=256 or da~=128)then error\"Colour not supported\"end;return\
true end\
class\"RedirectCanvas\"extends\"NodeCanvas\"function RedirectCanvas:__init__(...)self:resetTerm()\
self:super(...)end\
function RedirectCanvas:resetTerm()\
self.tX,self.tY,self.tColour,self.tBackgroundColour,self.tCursor=1,1,1,32768,false;self:clear(32768,true)end\
function RedirectCanvas:getTerminalRedirect()local da={}\
function da.write(_b)_b=tostring(_b)\
local ab,bb,cb,db=self.tColour,self.tBackgroundColour,self.tX,self.tY;local _c,ac=self.buffer,self.width* (db-1)+cb;for i=1,math.min(_a(_b),\
self.width-cb+1)do _c[ac]={aa(_b,i,i),ab,bb}\
ac=ac+1 end;self.tX=cb+_a(_b)end\
function da.blit(_b,ab,bb)if _a(_b)~=_a(ab)or _a(_b)~=_a(bb)then return\
error\"blit arguments must be the same length\"end\
local cb,db=self.tX,TermCanvas.static.hex\
local _c,ac=self.buffer,self.width* (self.tY-1)+cb;for i=1,math.min(_a(_b),self.width-cb+1)do\
_c[ac]={aa(_b,i,i),db[aa(ab,i,i)],db[aa(bb,i,i)]}ac=ac+1 end\
self.tX=cb+_a(_b)end\
function da.clear()self:clear(self.tBackgroundColour,true)end\
function da.clearLine()local _b={\" \",self.tColour,self.tBackgroundColour}local ab,bb=self.buffer,\
self.width* (self.tY-1)\
for i=1,self.width do ab[bb]=_b;bb=bb+1 end end;function da.getCursorPos()return self.tX,self.tY end;function da.setCursorPos(_b,ab)\
self.tX,self.tY=math.floor(_b),math.floor(ab)end\
function da.getSize()return self.width,self.height end;function da.setCursorBlink(_b)self.tCursor=_b end;function da.setTextColour(_b)if ca(_b)then\
self.tColour=_b end end;function da.getTextColour()\
return self.tColour end;function da.setBackgroundColour(_b)\
if ca(_b)then self.tBackgroundColour=_b end end;function da.getBackgroundColour()\
return self.tBackgroundColour end\
function da.scroll(_b)\
local ab,bb,cb=self.width*_b,self.buffer,_b<0\
local db,_c=self.width*self.height,{\" \",self.tColour,self.tBackgroundColour}\
for i=cb and db or 1,cb and 1 or db,cb and-1 or 1 do bb[i]=bb[i+ab]or _c end end;function da.isColour()return ba end;da.isColor=da.isColour\
da.setBackgroundColor=da.setBackgroundColour;da.setTextColor=da.setTextColour\
da.getBackgroundColor=da.getBackgroundColour;da.getTextColor=da.getTextColour;return da end\
function RedirectCanvas:clear(da,_b)local ab=da or self.tBackgroundColour\
local bb,cb={\" \",ab,ab},self.buffer;for index=1,self.width*self.height do\
if not cb[index]or _b then cb[index]=bb end end end",
["MouseEvent.ti"]="local c,d=string.sub,string.upper;class\"MouseEvent\"\
extends\"Event\"{main=\"MOUSE\",isWithin=true}\
function MouseEvent:__init__(_a,aa,ba,ca,da)self.name=_a;self.button=aa;self.X=ba;self.Y=ca;self.sub=da or\
d(c(_a,7))self.data={_a,aa,ba,ca}end;function MouseEvent:within(_a,aa,ba,ca)local da,_b=self.X,self.Y\
return\
da>=_a and _b>=aa and da<=-1 +_a+ba and _b<=-1 +aa+ca end;function MouseEvent:withinParent(_a)\
return\
self.isWithin and self:within(_a.X,_a.Y,_a.width,_a.height)end\
function MouseEvent:clone(_a)\
local aa=MouseEvent(self.name,self.button,\
self.X-_a.X+1,self.Y-_a.Y+1,self.sub)aa.handled=self.handled;aa.isWithin=self.isWithin;aa.setHandled=function(ba,ca)ba.handled=ca\
self.handled=ca end;return aa end",
["Tween.ti"]="\
class\"Tween\"{static={easing={}},object=false,property=false,initial=false,final=false,duration=0,clock=0}\
function Tween:__init__(...)self:resolve(...)\
if\
not Titanium.isInstance(self.object)then return\
error(\"Argument 'object' for tween must be a Titanium instance. '\"..\
tostring(self.object)..\"' is not a Titanium instance.\")end;local a=self.easing or\"linear\"\
if type(a)==\"string\"then\
self.easing=\
Tween.static.easing[a]or\
error(\"Easing type '\"..tostring(a)..\"' could not be found in 'Tween.static.easing'.\")elseif type(a)==\"function\"then self.easing=a else return\
error\"Tween easing invalid. Must be a function to be invoked or name of easing type\"end;self.initial=self.object[self.property]self.clock=0 end\
function Tween:performEasing()\
self.object[self.property]=math.floor(self.easing(self.clock,self.initial,\
self.final-self.initial,self.duration)+.5)end\
function Tween:update(a)return self:setClock(self.clock+a)end;function Tween:reset()return self:setClock(0)end\
function Tween:setClock(a)\
if a<=0 then\
self.clock=0 elseif a>=self.duration then self.clock=self.duration else self.clock=a end;self:performEasing()return self.clock>=self.duration end\
function Tween.static.addEasing(a,b)if type(b)~=\"function\"then\
return error\"Easing function must be of type 'function'\"end\
Tween.static.easing[a]=b;return Tween end\
configureConstructor{orderedArguments={\"object\",\"name\",\"property\",\"final\",\"duration\",\"easing\",\"promise\"},requiredArguments={\"object\",\"name\",\"property\",\"final\",\"duration\"},argumentTypes={name=\"string\",property=\"string\",final=\"number\",duration=\"number\",promise=\"function\"}}",
["Component.ti"]="class\"Component\"abstract()\
mixin\"MPropertyManager\"{width=1,height=1,X=1,Y=1,changed=true,backgroundChar=\" \",shader=false,shadeText=true,shadeBackground=true}\
function Component:__init__()local a,b,c=self.shadeText,self.shadeBackground,self.shader\
self.shadeText=\
a==\"true\"and true or(a~=\"false\"and a)or false\
self.shadeBackground=b==\"true\"and true or(b~=\"false\"and b)or false\
self.shader=c==\"true\"and true or(c~=\"false\"and c)or false;local function d(_a,aa,ba)return\
ba==\"true\"and true or(ba~=\"false\"and ba)or false end\
self:watchProperty(\"shadeText\",d)self:watchProperty(\"shadeBackground\",d)\
self:watchProperty(\"shader\",d)end\
function Component:queueAreaReset()local a=self.parent;if a then\
a:redrawArea(self.X,self.Y,self.width,self.height)end;self.changed=true end\
function Component:set(a,b)\
if type(a)==\"string\"then self[a]=b elseif type(a)==\"table\"then for c,d in pairs(a)do\
self[c]=d end else return error\"Expected table or string\"end;return self end\
function Component:setX(a)self:queueAreaReset()self.X=math.ceil(a)end\
function Component:setY(a)self:queueAreaReset()self.Y=math.ceil(a)end\
function Component:setWidth(a)self:queueAreaReset()a=math.ceil(a)\
self.width=a;self.canvas.width=a end\
function Component:setHeight(a)self:queueAreaReset()a=math.ceil(a)\
self.height=a;self.canvas.height=a end\
function Component:setColour(a)self.colour=a;self.canvas.colour=a;self.changed=true end\
function Component:setBackgroundColour(a)self.backgroundColour=a\
self.canvas.backgroundColour=a;self.changed=true end;function Component:setTransparent(a)self.transparent=a;self.canvas.transparent=a\
self.changed=true end;function Component:setBackgroundChar(a)if\
a==\"nil\"then a=nil end;self.backgroundChar=a;self.canvas.backgroundChar=a\
self.changed=true end\
function Component:setBackgroundTextColour(a)\
self.backgroundTextColour=a;self.canvas.backgroundTextColour=a;self.changed=true end\
configureConstructor{orderedArguments={\"X\",\"Y\",\"width\",\"height\"},argumentTypes={X=\"number\",Y=\"number\",width=\"number\",height=\"number\",colour=\"colour\",backgroundColour=\"colour\",backgroundTextColour=\"colour\",transparent=\"boolean\",shader=\"ANY\",shadeText=\"ANY\",shadeBackground=\"ANY\"}}\
alias{color=\"colour\",backgroundColor=\"backgroundColour\"}",
["MTextDisplay.ti"]="\
local aa,ba,ca,da,_b=string.len,string.find,string.sub,string.gsub,string.match;class\"MTextDisplay\"\
abstract(){lineConfig={lines=false,alignedLines=false,offsetY=0},verticalPadding=0,horizontalPadding=0,verticalAlign=\"top\",horizontalAlign=\"left\",includeNewlines=false}\
function MTextDisplay:MTextDisplay()if Titanium.mixesIn(self,\"MThemeable\")then\
self:register(\"text\",\"verticalAlign\",\"horizontalAlign\",\"verticalPadding\",\"horizontalPadding\")end end\
function MTextDisplay:wrapText(ab)local bb,cb,db=self.text,ab or self.width,{}local _c,ac=self.horizontalAlign,cb/\
2;if cb==0 then return end;local bc=1\
while bb and aa(bb)>0 do\
local cc,dc,_d=ca(bb,1,cb)local ad=bc;local bd\
if ba(cc,\"\\n\")then dc,_d=_b(bb,\"(.-\\n)(.*)$\")bc=bc+aa(dc)if\
_d==\"\"then bd=true end elseif aa(bb)<=cb then dc=bb;bc=bc+aa(bb)else\
local dd,__a=ba(cc,\"%s[%S]*$\")\
dc=dd and da(ca(bb,1,dd-1),\"%s+$\",\"\")or cc;_d=dd and ca(bb,dd+1)or ca(bb,cb+1)local a_a=dd and\
_b(ca(bb,1,dd-1),\"%s+$\")\
bc=bc+aa(dc)+ (a_a and#a_a or 1)end;local cd=0;if _c==\"centre\"then cd=math.floor(ac- (#dc/2)+.5)elseif _c==\
\"right\"then cd=cb-#dc+1 end;db[#db+1],bb={dc,ad,\
bc-1,#db+1,cd<1 and 1 or cd},_d;if bd then\
db[\
#db+1]={\"\",bc,bc,#db+1,\
_c==\"centre\"and ac or(_c==\"right\"and cb)or 0}end end;self.lineConfig.lines=db end\
function MTextDisplay:drawText(ab,bb)local cb=self.lineConfig.lines;if not cb then\
self:wrapText()cb=self.lineConfig.lines end\
local db,_c=self.verticalPadding,self.horizontalPadding;local ac,bc=db,_c;local cc,dc=self.verticalAlign,self.horizontalAlign\
local _d,ad=self.width,self.height\
if cc==\"centre\"then\
ac=math.floor((ad/2)- (#cb/2)+.5)+db elseif cc==\"bottom\"then ac=ad-#cb-db end;local bd,cd=self.canvas\
for i=1,#cb do local dd,__a=cb[i],_c;local a_a=dd[1]if dc==\"centre\"then __a=math.floor(_d/2 - (\
#a_a/2)+.5)elseif dc==\"right\"then __a=\
_d-#a_a-_c+1 end;bd:drawTextLine(\
__a+1,i+ac,a_a,bb,ab)end end;function MTextDisplay:setText(ab)if ab==self.text then return end;self.changed=true\
self.text=ab end\
configureConstructor{argumentTypes={verticalPadding=\"number\",horizontalPadding=\"number\",verticalAlign=\"string\",horizontalAlign=\"string\",text=\"string\"},tmlContent=\"text\"}",
["MTogglable.ti"]="class\"MTogglable\"\
abstract(){toggled=false,toggledColour=colours.red,toggledBackgroundColour=colours.white}\
function MTogglable:MTogglable()if Titanium.mixesIn(self,\"MThemeable\")then\
self:register(\"toggled\",\"toggledColour\",\"toggledBackgroundColour\")end end;function MTogglable:toggle(...)\
self:setToggled(not self.toggled,...)end;function MTogglable:setToggled(a,...)\
if self.toggled~=a then\
self.raw.toggled=a;self.changed=true;self:executeCallbacks(\"toggle\",...)end end\
configureConstructor{argumentTypes={toggled=\"boolean\",toggledColour=\"colour\",toggledBackgroundColour=\"colour\"}}\
alias{toggledColor=\"toggledColour\",toggledBackgroundColor=\"toggledBackgroundColour\"}",
["MPropertyManager.ti"]="class\"MPropertyManager\"abstract()\
mixin\"MDynamic\"{watching={},foreignWatchers={},links={}}\
function MPropertyManager:MPropertyManager()\
local a=Titanium.getClass(self.__type):getRegistry().constructor;if not(a or a.argumentTypes)then return end\
for b in\
pairs(a.argumentTypes)do local c=Titanium.getSetterName(b)local d=self.raw[c]\
self[c]=function(_a,aa)\
if\
type(aa)==\"string\"then local ba,ca=aa:match\"^(%%*)%$(.*)$\"if ba and#ba%2 ==0 then\
self:setDynamicValue(DynamicValue(self,b,ca,function(da,_b,ab,bb)\
_b[c](_b,bb)da.manualSetter=nil end),true)return end end;aa=self:updateWatchers(b,aa)\
if d then d(self,_a,aa)else self[b]=aa end end end\
if Titanium.mixesIn(self,\"MCallbackManager\")then\
self:on(\"remove\",function(b)\
self:unwatchForeignProperty\"*\"self:unwatchProperty(\"*\",false,true)end)end end\
function MPropertyManager:updateWatchers(a,b)local function c(d)local _a=self.watching[d]\
if _a then for i=1,#_a do\
local aa=_a[i][1](self,d,b)if aa~=nil then b=aa end end end end;if a==\"*\"then for d in\
pairs(self.watching)do c(d)end else c(a)end;return b end\
function MPropertyManager:watchForeignProperty(a,b,c,d)\
if b==self then return\
error\"Target object is not foreign. Select a foreign object or use :watchProperty\"end;if not self.foreignWatchers[a]then\
self.foreignWatchers[a]={}end\
table.insert(self.foreignWatchers[a],b)b:watchProperty(a,c,d,self)end\
function MPropertyManager:unwatchForeignProperty(a,b,c)\
local function d(_a)local aa=self.foreignWatchers[_a]if aa then\
for i=#aa,1,-1 do if\
not b or aa[i]==b then aa[i]:unwatchProperty(_a,c,true)\
table.remove(aa,i)end end end end\
if a==\"*\"then for _a in pairs(self.foreignWatchers)do d(_a)end else d(a)end end\
function MPropertyManager:destroyForeignLink(a,b)local c=self.foreignWatchers[a]\
if not c then return end\
for i=#c,1,-1 do if c[i]==b then table.remove(c,i)end end end\
function MPropertyManager:watchProperty(a,b,c,d)\
if c then self:unwatchProperty(a,c)end\
if not self.watching[a]then self.watching[a]={}end;table.insert(self.watching[a],{b,c,d})end\
function MPropertyManager:unwatchProperty(a,b,c,d)\
local function _a(aa)local ba=self.watching[aa]\
if ba then\
for i=#ba,1,-1 do\
if(not b or\
ba[i][2]==b)and\
(c and ba[i][3]or(not c and not ba[i][3]))then if c and not d then\
ba[i][3]:destroyForeignLink(aa,self)end;table.remove(ba,i)end end end end\
if a==\"*\"then for aa in pairs(self.watching)do _a(aa)end else _a(a)end end\
function MPropertyManager:linkProperties(a,...)\
local b,c=self.links,\"Failed to link foreign property '\"..\
tostring(foreignProperty)..\
\
\"' from '\"..tostring(a)..\
\"' to local property '\"..tostring(localProperty)..\
\"'. A %s already exists for this local property, remove that link before linking\"\
local function d(aa,ba)ba=ba or aa\
if self.links[ba]then return error(c:format\"link\")elseif\
self.dynamicValues[ba]then return error(c:format\"dynamic link\")end\
self:watchForeignProperty(aa,a,function(ca,da,_b)self[ba]=_b end,\"PROPERTY_LINK_\"..self.__ID)b[ba],self[ba]=a,a[aa]end;local _a={...}for i=1,#_a do local aa=_a[i]\
if type(aa)==\"table\"then d(aa[1],aa[2])else d(aa)end end;return self end\
function MPropertyManager:unlinkProperties(a,...)local b,c,d={...},self.links,self.dynamicValues\
for i=1,#b do\
local _a=b[i]\
if not self:removeDynamicValue(_a)then\
self:unwatchForeignProperty(_a,a,\"PROPERTY_LINK_\"..self.__ID)if c[_a]==a then c[_a]=nil end end end;return self end",
["XMLParser.ti"]="class\"XMLParser\"\
extends\"Parser\"{tokens=false,tree=false}\
function XMLParser:__init__(a)local b=XMLLexer(a)self:super(b.tokens)end\
function XMLParser:parse()local a,b,c={{}},false,self:stepForward()local d,_a\
while c do\
if _a then\
if\
c.type==\
\"XML_ATTRIBUTE_VALUE\"or c.type==\"XML_STRING_ATTRIBUTE_VALUE\"then b.arguments[_a]=c.value;_a=false else\
self:throw(\"Unexpected \"..c.type..\
\". Expected attribute value following XML_ASSIGNMENT token.\")end else\
if c.type==\"XML_OPEN\"then if d then\
self:throw\"Unexpected XML_OPEN token. Expected XML attributes or end of tag.\"end;d=true\
b={type=c.value,arguments={}}table.insert(a,b)elseif c.type==\"XML_END\"then local aa=table.remove(a)\
b=a[#a]\
if not b then\
self:throw(\"Nothing to close with XML_END of type '\"..c.value..\"'\")elseif aa.type~=c.value then\
self:throw(\"Tried to close \"..aa.type..\
\" with XML_END of type '\"..c.value..\"'\")end;if not b.children then b.children={}end\
table.insert(b.children,aa)elseif c.type==\"XML_END_CLOSE\"then b=a[#a-1]if not b then\
self:throw(\"Unexpected XML_END_CLOSE tag (/>)\")end\
if not b.children then b.children={}end;table.insert(b.children,table.remove(a))elseif c.type==\
\"XML_CLOSE\"then d=false elseif c.type==\"XML_ATTRIBUTE\"then local aa=self:stepForward()\
if\
aa.type==\"XML_ASSIGNMENT\"then _a=c.value else b.arguments[c.value]=true;self.position=\
self.position-1 end elseif c.type==\"XML_CONTENT\"then if not b.type then\
self:throw(\"Unexpected XML_CONTENT. Invalid content: \"..c.value)end;b.content=c.value else self:throw(\"Unexpected \"..\
c.type)end end\
if c.type==\"XML_END\"or c.type==\"XML_END_CLOSE\"then d=false end;c=self:stepForward()end\
if d then\
self:throw(\"Expected '\"..tostring(b.type)..\"' tag close, but found none\")elseif b and b.type then\
self:throw(\"Expected ending tag for '\"..b.type..\"', but found none\")end;self.tree=a[1].children or{}end\
function XMLParser.static.convertArgType(a,b)if b==\"ANY\"then return a end;local c=type(a)if\
not b or not a or c==b then return a end\
if b==\"string\"then return tostring(a)elseif\
b==\"number\"then\
return tonumber(a)and math.ceil(tonumber(a))or\
error(\
\"Failed to cast argument to number. Value: \"..tostring(a)..\" is not a valid number\")elseif b==\"boolean\"then\
if a==\"true\"then return true elseif a==\"false\"then return false else return\
error(\"Failed to cast argument to boolean. Value: \"..\
tostring(a)..\" is not a valid boolean (true or false)\")end elseif b==\"colour\"or b==\"color\"then\
if a==\"transparent\"or a==\"trans\"then return 0 end\
return tonumber(a)or colours[a]or colors[a]or\
error(\
\"Failed to cast argument to colour (number). Value: \"..tostring(a)..\" is not a valid colour\")else return\
error(\"Failed to cast argument. Unknown target type '\"..tostring(b)..\"'\")end end",
["Slider.ti"]="class\"Slider\"\
extends\"Container\"{trackCharacter=_CC_SPECIAL_CHAR_SUPPORT and\"\\140\"or\"-\",trackColour=128,slideCharacter=\" \",slideBackgroundColour=colours.cyan,value=1}\
function Slider:__init__(...)self:super(...)\
self:register(\"value\",\"trackCharacter\",\"trackColour\",\"slideCharacter\",\"slideBackgroundColour\")\
self.track=self:addNode(Label(self.trackCharacter:rep(self.width))):set(\"colour\",\"$parent.trackColour\")\
self.slide=self:addNode(Button(self.slideCharacter)):set{backgroundColour=\"$parent.slideBackgroundColour\",X=\"$parent.value\",width=1}end\
function Slider:onMouseDrag(a,b,c)local d=self.slide;if b or not d.active then return end\
local _a=math.max(1,math.min(\
a.X-self.X+1,self.width))self.value=_a;self:executeCallbacks(\"change\",_a)\
a.handled=true end;function Slider:onMouseClick(a,b,c)\
if c and not b then self.value=a.X-self.X+1 end end;function Slider:setWidth(a)\
self.super:setWidth(a)\
self.track.text=self.trackCharacter:rep(self.width)end\
function Slider:setTrackCharacter(a)\
self.trackCharacter=a;self.track.text=a:rep(self.width)end\
configureConstructor{argumentTypes={trackCharacter=\"string\",trackColour=\"colour\",slideCharacter=\"string\",slideBackgroundColour=\"colour\",value=\"number\"}}",
["versionCheck.lua"]="if _HOST then _CC_SPECIAL_CHAR_SUPPORT=true end",
["Image.ti"]="local function b(c)return c:match\".+%.(.-)$\"or\"\"end\
class\"Image\"\
extends\"Node\"{static={imageParsers={}},path=false}\
function Image:__init__(...)self:super()self:resolve(...)end\
function Image:parseImage()local c=self.path\
if type(c)~=\"string\"then return\
error(\"Failed to parse image, path '\"..tostring(c)..\
\"' is invalid\")elseif\
not fs.exists(c)or fs.isDir(c)then return\
error(\"Failed to parse image, path '\"..c..\"' is invalid and cannot be opened for parsing\")end;local d=b(c)\
if not Image.imageParsers[d]then return\
error(\"Failed to parse image, no image parser exists for \"..\
(\
d==\"\"and\"'no ext'\"or\"'.\"..d..\"'\")..\" files for '\"..c..\"'\")end;local _a=fs.open(c,\"r\")local aa=_a.readAll()_a.close()\
local ba,ca,da=Image.imageParsers[d](aa)\
for y=1,ca do local _b=(y-1)*ba;for x=1,ba do local ab=_b+x\
self.canvas.buffer[ab]=da[ab]or{\" \"}end end;self.width,self.height=ba,ca;self.changed=true end;function Image:draw()end\
function Image:setPath(c)self.path=c;self:parseImage()end\
function Image.static.setImageParser(c,d)if\
type(c)~=\"string\"or type(d)~=\"function\"then\
return error\"Failed to set image parser. Invalid arguments, expected string, function\"end\
Image.static.imageParsers[c]=d;return Image end\
configureConstructor{orderedArguments={\"path\"},requiredArguments={\"path\"},useProxy={\"path\"},argumentTypes={path=\"string\"}}",
["DynamicEqLexer.ti"]="class\"DynamicEqLexer\"extends\"Lexer\"\
function DynamicEqLexer:lexNumber()\
local a=self:trimStream()local b,c=a:match\"^%d*%.?%d+(e)([-+]?%d*)\"\
if b and b~=\"\"then\
if c and c~=\"\"then\
self:pushToken{type=\"NUMBER\",value=self:consumePattern\"^%d*%.?%d+e[-+]?%d*\"}return true else self:throw\"Invalid number. Expected digit after 'e'\"end elseif a:find\"^%d*%.?%d+\"then\
self:pushToken{type=\"NUMBER\",value=self:consumePattern\"^%d*%.?%d+\"}return true end end\
function DynamicEqLexer:tokenize()local a=self:trimStream()local b=a:sub(1,1)\
if\
a:find\"^%b{}\"then\
self:pushToken{type=\"QUERY\",value=self:consumePattern\"^%b{}\"}elseif not self:lexNumber()then\
if b==\"'\"or b=='\"'then\
self:pushToken{type=\"STRING\",value=self:consumeString(b),surroundedBy=b}elseif a:find\"^and%s\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^and\",binary=true}elseif a:find\"^or%s\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^or\",binary=true}elseif a:find\"^not%s\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^not\",unary=true}elseif a:find\"^[#]\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^[#]\",unary=true}elseif a:find\"^[/%*%%]\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^[/%*%%]\",binary=true}elseif a:find\"^%.%.\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^%.%.\",binary=true}elseif a:find\"^%=%=\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^%=%=\",binary=true}elseif a:find\"^%>\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^%>\",binary=true}elseif a:find\"^%<\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^%<\",binary=true}elseif a:find\"^[%+%-]\"then\
self:pushToken{type=\"OPERATOR\",value=self:consumePattern\"^[%+%-]\",ambiguos=true}elseif a:find\"^[%(%)]\"then\
self:pushToken{type=\"PAREN\",value=self:consumePattern\"^[%(%)]\"}elseif a:find\"^%.\"then\
self:pushToken{type=\"DOT\",value=self:consumePattern\"^%.\"}elseif a:find\"^%w+\"then\
self:pushToken{type=\"NAME\",value=self:consumePattern\"^%w+\"}else\
self:throw(\"Unexpected block '\".. (a:match(\"%S+\")or\"\")..\"'\")end end end",
["TermCanvas.ti"]="local c=table.concat;local d={}for i=0,15 do d[2 ^i]=(\"%x\"):format(i)d[(\"%x\"):format(i)]=\
2 ^i end;class\"TermCanvas\"\
extends\"Canvas\"{static={hex=d}}\
function TermCanvas:draw(_a,aa,ba,ca)local da=self.owner;local _b,ab=self.buffer,self.last\
local bb,cb,db,_c=da.X,da.Y-1,self.width,self.height\
local ac,bc,cc,dc=self.colour,self.backgroundChar,self.backgroundTextColour,self.backgroundColour;local _d,ad=self:getShaders(aa,ba,ca)local function bd(a_a,b_a)\
if b_a then return d[b_a[a_a]]end;return d[a_a]end;local cd,dd,__a=1\
for y=1,_c do local a_a\
for x=1,db do\
dd,__a=_b[cd],ab[cd]\
if _a or not __a or\
(dd[1]~=__a[1]or dd[2]~=__a[2]or dd[3]~=__a[3])then a_a=true;cd=cd- (x-1)break end;cd=cd+1 end\
if a_a then local b_a,c_a,d_a,_aa={},{},{}\
for x=1,db do _aa=_b[cd]ab[cd]=_aa\
local aaa,baa,caa=_aa[1],_aa[2],_aa[3]\
if aa then\
c_a[x]=bd(\
aaa and(\
type(baa)==\"number\"and baa~=0 and baa or ac or 1)or cc or 1,_d)\
d_a[x]=bd(\
type(caa)==\"number\"and caa~=0 and caa or dc or 32768,ad)else\
c_a[x]=d[\
aaa and(\
type(baa)==\"number\"and baa~=0 and baa or ac or 1)or cc or 1]\
d_a[x]=d[\
type(caa)==\"number\"and caa~=0 and caa or dc or 32768]end;b_a[x]=aaa or bc or\" \"cd=cd+1 end;term.setCursorPos(bb,y+cb)\
term.blit(c(b_a),c(c_a),c(d_a))end end end",
["Canvas.ti"]="local d,_a=table.insert,table.remove\
local function aa(ba,ca,da,_b)\
local ab=ba>ca and 1 -ca or 1;local bb=ca+da>_b and _b-ca or da;return ab,bb end;class\"Canvas\"\
abstract(){static={shaders={}},buffer={},last={},width=51,height=19,backgroundColour=32768,colour=1,transparent=false}\
function Canvas:__init__(ba)\
self.raw.owner=Titanium.isInstance(ba)and ba or\
error(\
\"Invalid argument for Canvas. Expected instance owner, got '\"..tostring(ba)..\"'\")self.raw.width=ba.raw.width;self.raw.height=ba.raw.height\
self.raw.colour=ba.raw.colour;self.raw.backgroundChar=ba.raw.backgroundChar;if\
self.raw.backgroundChar==\"nil\"then self.raw.backgroundChar=nil end\
self.raw.backgroundTextColour=ba.raw.backgroundTextColour;self.raw.backgroundColour=ba.raw.backgroundColour\
self.raw.transparent=ba.raw.transparent;self:clear()end\
function Canvas:clear(ba)\
local ca,da={not self.transparent and self.backgroundChar,\
self.transparent and 0 or self.colour,self.transparent and 0 or ba or\
self.backgroundColour},self.buffer;for index=1,self.width*self.height do da[index]=ca end end\
function Canvas:clearArea(ba,ca,da,_b,ab)\
local bb,cb,db=ca>0 and ca-1 or 0,ba>0 and ba-1 or 0,self.width\
local _c,ac={not self.transparent and self.backgroundChar,self.colour,\
self.transparent and 0 or ab or self.backgroundColour},self.buffer;local bc,cc=db-cb,self.height;local dc=bc<da and bc or da;for y=0,-1 + (_b<cc and _b or\
cc)do local _d=cb+ (y+bb)*db\
for x=1,dc do ac[_d+x]=_c end end end\
function Canvas:setTransparent(ba)self.transparent=ba;self:clear()end;function Canvas:setColour(ba)self.colour=ba;self:clear()end;function Canvas:setBackgroundColour(ba)\
self.backgroundColour=ba;self:clear()end;function Canvas:setBackgroundChar(ba)\
self.backgroundChar=ba;self:clear()end\
function Canvas:setWidth(ba)\
local ca={not\
self.transparent and self.backgroundChar,self.colour,self.transparent and 0 or\
colour or self.backgroundColour}local da,_b,ab=self.width,self.height,self.buffer;while ba>da do for rowIndex=1,_b do\
d(ab,(da+1)*rowIndex,ca)end;da=da+1 end\
while ba<da do da=\
da-1;for rowIndex=1,_b do _a(ab,da*rowIndex)end end;self.width=ba end\
function Canvas:setHeight(ba)\
local ca={not self.transparent and self.backgroundChar,self.colour,\
self.transparent and 0 or colour or self.backgroundColour}local da,_b,ab=self.width,self.height,self.buffer;while ba>_b do\
for i=1,da do ab[#ab+1]=ca end;_b=_b+1 end;while ba<_b do for i=1,da do ab[#ab]=nil end\
_b=_b-1 end;self.height=ba end\
function Canvas:drawTo(ba,ca,da,_b,ab,bb)local cb=self.onlyShadeBottom;local db=self.bottomLayer\
local _c=ca-1 or 0;local ac=da-1 or 0;local cc,dc=self.raw,ba.raw\
local _d,ad,bd=cc.width,cc.height,cc.buffer;local cd,dd,__a=dc.width,dc.height,dc.buffer\
local a_a,b_a,c_a=cc.colour,cc.backgroundColour,cc.backgroundTextColour;local d_a,_aa=aa(1,_c,_d,cd)local aaa,baa=self:getShaders(_b,ab,bb)local function caa(_da,ada)if ada then return\
ada[_da]end;return _da end\
local daa,_ba,aba,bba,cba,dba,_ca,aca,bca,cca,dca=0,_c+ (ac*cd)\
for y=1,ad do local _da=y+ac\
if _da>=1 and _da<=dd then\
for x=d_a,_aa do aba=bd[daa+x]bba,cba,dba,dca=aba[1],aba[2],aba[3],\
_ba+x;_ca=__a[dca]aca,bca,cca=_ca[1],_ca[2],_ca[3]\
if\
bba and(cba and cba~=0)and(dba and dba~=0)then\
__a[dca]=\
(not _b or cb)and aba or{bba,caa(cba,aaa),caa(dba,baa)}elseif\
not bba and cba==0 and dba==0 and aca and bca~=0 and cca~=0 then\
__a[dca]=\
_b and{db or aca,caa(bca or a_a or 32768,aaa),caa(\
cca or b_a or 1,baa)}or _ca else local ada,bda,cda=bba or aca,cba or a_a,dba or b_a\
if not bba then bda=c_a or bca end\
if not _b or cb then\
__a[dca]={ada,bda==0 and bca or bda,cda==0 and cca or cda}else\
__a[dca]={ada,caa(bda==0 and bca or bda,aaa),caa(cda==0 and cca or cda,baa)}end end end elseif _da>dd then break end;daa=daa+_d;_ba=_ba+cd end end\
function Canvas:getShaders(ba,ca,da)local _b=Canvas.static.shaders\
return ca and\
_b[ca~=true and ca or ba]or false,da and\
_b[da~=true and da or ba]or false end\
function Canvas.static.registerShader(ba,ca)\
if not\
(type(ba)==\"string\"and type(ca)==\"table\")then return\
error(\"Failed to register shader. Expected string, table; got \"..type(ba)..\", \"..\
type(ca)..\"'\")elseif\
Canvas.static.shaders[ba]then return\
error(\"Failed to register shader '\"..tostring(ba)..\"'. Shader already registered\")end;Canvas.static.shaders[ba]=ca end",
["Button.ti"]="class\"Button\"extends\"Node\"mixin\"MTextDisplay\"\
mixin\"MActivatable\"{allowMouse=true,buttonLock=1}function Button:__init__(...)self:resolve(...)self:super()\
self:register(\"width\",\"height\",\"buttonLock\")end;function Button:onMouseClick(a,b,c)\
if\
not b and c and(\
self.buttonLock==0 or a.button==self.buttonLock)then self.active,a.handled=true,true end end\
function Button:onMouseUp(a,b,c)if\
c and not b and self.active then a.handled=true\
self:executeCallbacks\"trigger\"end;self.active=false end\
function Button:draw(a)local b=self.raw\
if b.changed or a then local c,d\
if not self.enabled then\
d,c=b.disabledBackgroundColour,b.disabledColour elseif self.active then d,c=b.activeBackgroundColour,b.activeColour end;b.canvas:clear(d)self:drawText(d,c)b.changed=false end end;function Button:setText(a)if self.text==a then return end;self.text=a;self.changed=true\
self:wrapText()end;function Button:setWidth(a)\
self.super:setWidth(a)self:wrapText()end\
configureConstructor{orderedArguments={\"text\"},requiredArguments={\"text\"},argumentTypes={buttonLock=\"number\"}}",
["PageContainer.ti"]="class\"PageContainer\"\
extends\"Container\"{scroll=0,animationDuration=0.25,animationEasing=\"outQuad\",customAnimation=false,selectedPage=false}\
function PageContainer:draw(a,b,c)if not self.selectedPage then\
self.canvas:drawTextLine(1,1,\"No page selected\",16384,1)else\
return self.super:draw(a,(b or 0)-self.scroll,c)end end\
function PageContainer:handle(a)\
if not self.super.super:handle(a)then return end;local b;if a.main==\"MOUSE\"then b=a:clone(self)b.X=b.X+self.scroll\
b.isWithin=\
b.isWithin and a:withinParent(self)or false end\
self:shipEvent(b or a)if b and b.isWithin and(self.consumeAll or b.handled)then\
a.handled=true end;return true end\
function PageContainer:selectPage(a,b)local c=self:getPage(a)self.selectedPage=c\
if type(b)==\
\"function\"then return b(self.currentPage,c)elseif self.customAnimation then return\
self.customAnimation(self.currentPage,c)end\
self:animate(self.__ID..\"_PAGE_CONTAINER_SELECTION\",\"scroll\",c.X-1,self.animationDuration,self.animationEasing)end\
function PageContainer:updatePagePositions()local a,b=self.nodes,{}\
for i=1,#a do local d=a[i]local _a=d.position;if _a and not\
d.isPositionTemporary then b[_a]=true end end;local c=0\
for i=1,#a do local d=a[i]\
if not d.position or d.isPositionTemporary then\
repeat c=c+1 until not b[c]d.isPositionTemporary=true;d.raw.position=c end;d:updatePosition()end end\
function PageContainer:addNode(a)\
if Titanium.typeOf(a,\"Page\",true)then local b=self.pageIndexes\
if\
self:getPage(a.id)then return\
error(\"Cannot add page '\"..\
tostring(a)..\"'. Another page with the same ID already exists inside this PageContainer\")end;self.super:addNode(a)\
self:updatePagePositions()return a end;return\
error(\"Only 'Page' nodes can be added as direct children of 'PageContainer' nodes, '\"..tostring(a)..\"' is invalid\")end;function PageContainer:addPage(a)return self:addNode(a)end;function PageContainer:getPage(...)return\
self:getNode(...)end;function PageContainer:removePage(...)return\
self:removeNode(...)end;function PageContainer:redrawArea(a,b,c,d)\
self.super:redrawArea(\
a-self.scroll,b,c,d,-self.scroll)end;function PageContainer:setScroll(a)\
self.scroll=a;self.changed=true\
self:redrawArea(1,1,self.width,self.height)end\
function PageContainer:setWidth(a)\
self.super:setWidth(a)self:updatePagePositions()if self.selectedPage then self.scroll=\
self.selectedPage.X-1 end end\
function PageContainer:setHeight(a)self.super:setHeight(a)\
self:updatePagePositions()\
if self.selectedPage then self.scroll=self.selectedPage.X-1 end end\
configureConstructor{argumentTypes={animationDuration=\"number\",animationEasing=\"string\",customAnimation=\"function\",selectedPage=\"string\"}}",
["ScrollContainer.ti"]="class\"ScrollContainer\"\
extends\"Container\"{cache={},xScroll=0,yScroll=0,xScrollAllowed=true,yScrollAllowed=true,propagateMouse=true,trayColour=256,scrollbarColour=128,activeScrollbarColour=colours.cyan,mouse={selected=false,origin=false}}\
function ScrollContainer:__init__(...)\
self:register(\"scrollbarColour\",\"activeScrollbarColour\",\"trayColour\")self:super(...)end\
function ScrollContainer:onMouseClick(a,b,c)if b or not c then return end\
local d,_a,aa=self.cache,self.mouse;local ba,ca=a.X-self.X+1,a.Y-self.Y+1\
if d.yScrollActive and\
ba==self.width and ca<=d.displayHeight then aa=\"y\"elseif\
\
d.xScrollActive and ca==self.height and ba<=d.displayWidth then aa=\"x\"else return end\
local da=self[\"set\"..aa:upper()..\"Scroll\"]\
local _b,ab=d[aa..\"ScrollPosition\"],d[aa..\"ScrollSize\"]\
local bb,cb=d[\"content\".. (aa==\"x\"and\"Width\"or\"Height\")],d[\
\"display\".. (aa==\"x\"and\"Width\"or\"Height\")]local db=aa==\"x\"and ba or ca\
if db<_b then\
a.handled=da(self,math.floor(bb* (db/cb)-.5))elseif db>=_b and db<=_b+ab-1 then\
_a.selected,_a.origin=aa==\"x\"and\"h\"or\"v\",db-_b+1 elseif db>_b+ab-1 then\
a.handled=da(self,math.floor(bb* ( (db-ab+1)/cb)-.5))end;self:cacheScrollbarPosition()self.changed=true end\
function ScrollContainer:onMouseScroll(a,b,c)local d,_a=self.cache,self.application\
if b or not c or not(d.xScrollActive or\
d.yScrollActive)then return end\
local aa=(d.xScrollActive and(not d.yScrollActive or(_a:isPressed(keys.leftShift)or\
_a:isPressed(keys.rightShift))))\
a.handled=self[\"set\".. (aa and\"X\"or\"Y\")..\"Scroll\"](self,self[(\
aa and\"x\"or\"y\")..\"Scroll\"]+a.button)self:cacheScrollbarPosition()end\
function ScrollContainer:onMouseUp(a,b,c)if self.mouse.selected then self.mouse.selected=false\
self.changed=true end end\
function ScrollContainer:onMouseDrag(a,b,c)local d,_a=self.mouse,self.cache;if b or not d.selected then\
return end;local aa=d.selected==\"v\"local ba=aa and\"Y\"or\"X\"local ca=aa and\
\"Height\"or\"Width\"\
a.handled=self[\"set\"..ba..\"Scroll\"](self,math.floor(_a[\
\"content\"..ca]* ( ( (a[ba]-self[ba]+1)-d.origin)/\
_a[\"display\"..ca])-.5))end;function ScrollContainer:addNode(a,...)self.super:addNode(a,...)\
self:cacheContent()return a end\
function ScrollContainer:handle(a)\
local b=self.cache;local c\
if not self.super.super:handle(a)then return end\
if\
self.projector and not self.mirrorProjector and not a.projectorOrigin then self.resolvedProjector:handleEvent(a)return end\
if a.main==\"MOUSE\"then\
if\
(not b.yScrollActive or(a.X-self.X+1)~=self.width)and\
(not b.xScrollActive or(a.Y-self.Y+1)~=self.height)then c=a:clone(self)\
c.isWithin=\
c.isWithin and a:withinParent(self)or false;c.Y=c.Y+self.yScroll;c.X=c.X+self.xScroll end else c=a end;if c then self:shipEvent(c)end\
if c and c.isWithin and\
(self.consumeAll or c.handled)then a.handled=true end end\
function ScrollContainer:isNodeInBounds(a,b,c)\
local d,_a=a.X-self.xScroll,a.Y-self.yScroll\
return not\
( (d+a.width)<1 or d> (b or self.width)or _a>\
(c or self.height)or(_a+a.height)<1)end;function ScrollContainer:draw(a)\
if self.changed or a then\
self.super:draw(a,-self.xScroll,-self.yScroll)self:drawScrollbars()end end\
function ScrollContainer:drawScrollbars()\
local a,b=self.cache,self.canvas;local c,d=a.xScrollActive,a.yScrollActive\
if c then\
b:drawBox(1,self.height,a.displayWidth,1,self.trayColour)\
b:drawBox(a.xScrollPosition,self.height,a.xScrollSize,1,\
self.mouse.selected==\"h\"and self.activeScrollbarColour or self.scrollbarColour)end\
if d then\
b:drawBox(self.width,1,1,a.displayHeight,self.trayColour)\
b:drawBox(self.width,a.yScrollPosition,1,a.yScrollSize,\
self.mouse.selected==\"v\"and self.activeScrollbarColour or self.scrollbarColour)end;if d and c then\
b:drawPoint(self.width,self.height,\" \",1,self.trayColour)end end;function ScrollContainer:redrawArea(a,b,c,d)\
self.super:redrawArea(a,b,c,d,-self.xScroll,-self.yScroll)end\
function ScrollContainer:setYScroll(a)\
local b,c=self.yScroll,self.cache\
self.yScroll=math.max(0,math.min(c.contentHeight-c.displayHeight,a))self:cacheScrollbarPosition()if(not self.propagateMouse)or b~=\
self.yScroll then return true end end\
function ScrollContainer:setXScroll(a)local b,c=self.xScroll,self.cache\
self.xScroll=math.max(0,math.min(\
c.contentWidth-c.displayWidth,a))self:cacheScrollbarPosition()if(not self.propagateMouse)or b~=\
self.xScroll then return true end end\
function ScrollContainer:setHeight(a)self.super:setHeight(a)\
self:cacheContent()local b=self.cache\
self.yScroll=math.max(0,math.min(b.contentHeight-b.displayHeight,self.yScroll))end\
function ScrollContainer:setWidth(a)self.super:setWidth(a)\
self:cacheContent()local b=self.cache\
self.xScroll=math.max(0,math.min(b.contentWidth-b.displayWidth,self.xScroll))end\
function ScrollContainer:cacheContent()self:cacheContentSize()\
self:cacheActiveScrollbars()local a=self.cache\
self.xScroll,self.yScroll=math.max(0,math.min(a.contentWidth-a.displayWidth,self.xScroll)),math.max(0,math.min(\
a.contentHeight-a.displayHeight,self.yScroll))end\
function ScrollContainer:cacheContentSize()local a,b=0,0;local c,d=self.nodes\
for i=1,#c do d=c[i]\
a=math.max(d.X+d.width-1,a)b=math.max(d.Y+d.height-1,b)end;self.cache.contentWidth,self.cache.contentHeight=a,b end\
function ScrollContainer:cacheDisplaySize(a)local b=self.cache\
b.displayWidth,b.displayHeight=self.width- (\
b.yScrollActive and 1 or 0),self.height-\
(b.xScrollActive and 1 or 0)if not a then self:cacheScrollbarSize()end end\
function ScrollContainer:cacheActiveScrollbars()local a=self.cache\
local b,c,d,_a=a.contentWidth,a.contentHeight,self.width,self.height;local aa,ba=self.xScrollAllowed,self.yScrollAllowed;local ca,da;if\
(b>d and aa)or(c>_a and ba)then a.xScrollActive,a.yScrollActive=b>d-1 and aa,c>_a-1 and ba else\
a.xScrollActive,a.yScrollActive=false,false end\
self:cacheDisplaySize()end\
function ScrollContainer:cacheScrollbarSize()local a=self.cache\
a.xScrollSize,a.yScrollSize=math.floor(a.displayWidth* (\
a.displayWidth/a.contentWidth)+.5),math.floor(\
a.displayHeight* (a.displayHeight/a.contentHeight)+.5)self:cacheScrollbarPosition()end\
function ScrollContainer:cacheScrollbarPosition()local a=self.cache\
a.xScrollPosition,a.yScrollPosition=math.ceil(self.xScroll/\
a.contentWidth*a.displayWidth+.5),math.ceil(\
self.yScroll/a.contentHeight*a.displayHeight+.5)self.changed=true\
self:redrawArea(1,1,self.width,self.height)end\
configureConstructor{argumentTypes={scrollbarColour=\"colour\",activeScrollbarColour=\"colour\",xScrollAllowed=\"boolean\",yScrollAllowed=\"boolean\"}}",
["Lexer.ti"]="class\"Lexer\"\
abstract(){static={escapeChars={a=\"\\a\",b=\"\\b\",f=\"\\f\",n=\"\\n\",r=\"\\r\",t=\"\\t\",v=\"\\v\"}},stream=false,tokens={},line=1,char=1}\
function Lexer:__init__(a,b)\
if type(a)~=\"string\"then return\
error\"Failed to initialise Lexer instance. Invalid stream paramater passed (expected string)\"end;self.stream=a;if not b then self:formTokens()end end\
function Lexer:formTokens()while self.stream and self.stream:find\"%S\"do\
self:tokenize()end end;function Lexer:pushToken(a)local b=self.tokens;a.char=self.char;a.line=self.line\
b[#b+1]=a end\
function Lexer:consume(a)local b=self.stream;self.stream=b:sub(\
a+1)self.char=self.char+a;return content end;function Lexer:consumePattern(a,b)local c=self.stream:match(a)\
self:consume(\
select(2,self.stream:find(a))+ (b or 0))return c end\
function Lexer:consumeString(a)\
local b,c=self.stream\
if b:find(a,2)then local d,_a,aa={}\
for i=2,#b do _a=b:sub(i,i)\
if aa then\
d[#d+1]=Lexer.escapeChars[_a]or _a;aa=false elseif _a==\"\\\\\"then aa=true elseif _a==a then self:consume(i)\
return table.concat(d)else d[#d+1]=_a end end end\
self:throw(\"Failed to lex stream. Expected string end (\"..a..\")\")end\
function Lexer:trimStream()local a=self.stream;local b=a:match(\"^(\\n+)\")if b then\
self:newline(#b)end;local c=select(2,a:find\"^%s*%S\")\
self.stream=a:sub(c)self.char=self.char+c-1;return self.stream end\
function Lexer:newline(a)self.line=self.line+ (a or 1)self.char=0 end\
function Lexer:throw(a)\
self.exception=\"Lexer (\"..tostring(self.__type)..\
\") Exception at line '\"..self.line..\"', char '\"..self.char..\
\"': \"..a;return error(self.exception)end",
["NodeCanvas.ti"]="local b=string.sub;class\"NodeCanvas\"extends\"Canvas\"\
function NodeCanvas:drawPoint(c,d,_a,aa,ba)\
if\
#_a>1 then return error\"drawPoint can only draw one character\"end\
self.buffer[(self.width* (d-1))+c]={_a,aa or self.colour,ba or\
self.backgroundColour}end\
function NodeCanvas:drawTextLine(c,d,_a,aa,ba)\
local ca,da=aa or self.colour,ba or self.backgroundColour;local _b,ab=self.buffer,(self.width* (d-1))+c;for i=1,#_a do\
_b[-1 +ab+i]={b(_a,i,i),ca,da}end end\
function NodeCanvas:drawBox(c,d,_a,aa,ba,ca,da)\
local _b,ab=da or self.colour,ba or self.backgroundColour;local bb=self.buffer;local cb={ca or\" \",_b,ab}for y=math.max(0,d),d+aa-1 do\
for x=math.max(1,c),\
c+_a-1 do bb[(self.width* (y-1))+x]=cb end end end",
["Label.ti"]="class\"Label\"extends\"Node\"\
mixin\"MTextDisplay\"{labelFor=false,allowMouse=true,active=false}\
function Label:__init__(...)self:resolve(...)self.raw.width=#self.text\
self:super()self:register\"text\"\
self:watchProperty(\"text\",function(a,b,c)a.width=#c end)end;function Label:onMouseClick(a,b,c)\
self.active=self.labelFor and c and not b end\
function Label:onMouseUp(a,b,c)\
if not self.labelFor then return end\
local d=self.application:getNode(self.labelFor,true)if self.active and not b and c and d:can\"onLabelClicked\"then\
d:onLabelClicked(self,a,b,c)end;self.active=false end\
function Label:draw(a)local b=self.raw;if b.changed or a then\
b.canvas:drawTextLine(1,1,b.text)b.changed=false end end\
configureConstructor({orderedArguments={\"text\",\"X\",\"Y\"},requiredArguments={\"text\"},argumentTypes={text=\"string\"}},true)",
["Container.ti"]="class\"Container\"extends\"Node\"\
mixin\"MNodeContainer\"{allowMouse=true,allowKey=true,allowChar=true,consumeAll=true}\
function Container:__init__(...)self:resolve(...)local a=self.nodes;self.nodes={}\
if\
type(a)==\"table\"then for i=1,#a do self:addNode(a[i])end end;self:register(\"width\",\"height\")self:super()end\
function Container:isNodeInBounds(a,b,c)local d,_a=a.X,a.Y;return\
not(\
(d+a.width)<1 or d> (b or self.width)or _a> (c or self.height)or\
(_a+a.height)<1)end\
function Container:draw(a,b,c)\
if self.changed or a then local d=self.canvas\
local _a,aa=self.width,self.height;local ba,ca=self.nodes;local da,_b=b or 0,c or 0\
for i=1,#ba do ca=ba[i]\
if a or\
(ca.needsRedraw and ca.visible)then local ab,bb,cb=ca.shader,ca.shadeText,ca.shadeBackground\
ca:draw(a)\
if ca.projector then if ca.mirrorProjector then\
ca.canvas:drawTo(d,ca.X+da,ca.Y+_b,ab,bb,cb)end\
ca.resolvedProjector.changed=true else\
ca.canvas:drawTo(d,ca.X+da,ca.Y+_b,ab,bb,cb)end;ca.needsRedraw=false end end;self.changed=false end end\
function Container:handle(a)if not self.super:handle(a)then return end\
local b\
if a.main==\"MOUSE\"then b=a:clone(self)b.isWithin=\
b.isWithin and a:withinParent(self)or false end;self:shipEvent(b or a)\
if b and b.isWithin and\
(self.consumeAll or b.handled)then a.handled=true end;return true end;function Container:shipEvent(a)local b=self.nodes\
for i=#b,1,-1 do if b[i]then b[i]:handle(a)end end end\
function Container:setWidth(a)\
self.super:setWidth(a)local b=self.nodes;for i=1,#b do b[i].needsRedraw=true end end\
function Container:setHeight(a)self.super:setHeight(a)local b=self.nodes;for i=1,#b do\
b[i].needsRedraw=true end end\
configureConstructor({orderedArguments={\"X\",\"Y\",\"width\",\"height\",\"nodes\",\"backgroundColour\"},argumentTypes={nodes=\"table\",consumeAll=\"boolean\"}},true)",
}
local scriptFiles = {
["versionCheck.lua"]=true,
["Titanium.lua"]=true,
["Class.lua"]=true,
}
local preLoad = {
[1]="versionCheck.lua",
}
local loaded = {}
local function loadFile( name, verify )
    if loaded[ name ] then return end

    local content = files[ name ]
    if content then
        local output, err = loadstring( content, name )
        if not output or err then return error( "Failed to load Lua chunk. File '"..name.."' has a syntax error: "..tostring( err ), 0 ) end

        local ok, err = pcall( output )
        if not ok or err then return error( "Failed to execute Lua chunk. File '"..name.."' crashed: "..tostring( err ), 0 ) end

        if verify then
            local className = name:gsub( "%..*", "" )
            local class = Titanium.getClass( className )

            if class then
                if not class:isCompiled() then class:compile() end
            else return error( "File '"..name.."' failed to create class '"..className.."'" ) end
        end

        loaded[ name ] = true
    else return error("Failed to load Titanium. File '"..tostring( name ).."' cannot be found.") end
end

-- Load our class file
loadFile( "Class.lua" )

Titanium.setClassLoader(function( name )
    local fName = name..".ti"

    if not files[ fName ] then
        return error("Failed to find file '"..fName..", to load missing class '"..name.."'.", 3)
    else
        loadFile( fName, true )
    end
end)

-- Load any files specified by our config file
for i = 1, #preLoad do loadFile( preLoad[ i ], not scriptFiles[ preLoad[ i ] ] ) end

-- Load all class files
for name in pairs( files ) do if not scriptFiles[ name ] then
    loadFile( name, true )
end end

-- Load all script files
for name in pairs( scriptFiles ) do loadFile( name, false ) end
