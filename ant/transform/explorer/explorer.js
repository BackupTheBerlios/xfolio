/*
Explorer methods

  var height;
  if (document.body && document.body.offsetHeight) height=document.body.offsetHeight;
  else if (document.body && document.body.clientHeight) height=document.body.clientHeight;
  else if (window.innerHeight) height= window.innerHeight;

*/

/*
TODO, find a way to put this in frame
*/

function explorerInit() {
  
  if (!document.getElementById) return false; 
  var dir=document.getElementById("dir");
  if (!dir) return false;
  
  dir.links=dir.getElementsByTagName('A');
  if(dir.links.length == 0) dir.links=dir.getElementsByTagName('a');
  var i=0;
  // set index of 
  while(dir.links[i]) {
    dir.links[i].index=i;
    dir.links[i].onkeydown=explorerKeyDown;
    dir.links[i].onmouseover=explorerMouseOver;
    dir.links[i].onclick=explorerLinkClick;
    i++;
  }
}

function explorerLinkClick() {
  // in case of IE ()
  if (document.all ) event.cancelBubble = true;
}

function expand(button, action) {
  if (!document.getElementById) return false; 
  if (!button || !button.id) return false;
  id=button.id;
  var o=document.getElementById(id+'-');
  if (!o || !o.style) return false;
  if (!action) if (o.style.display == "") action="close"
  else if (!action) action="open";
  if (action == "open") o.style.display="";
  else if (action == "close") o.style.display="none";
  else o.style.display=(o.style.display == 'none')?'':'none';
  if(button.className) button.className=action;
  // in case of IE 
  if (document.all ) event.cancelBubble = true;
  return false;
}




function explorerMouseOver(e, o) {
  if (!o) o=this;
  o.focus();
}

function goLang(select) {
  var s=new String(window.location); 
  var lang=select.options[select.selectedIndex].text;
  var sharp="";
  var query="";
  if (s.indexOf('#') != -1) {
    sharp=s.substring(s.indexOf('#'));
    s=s.substring(0,s.indexOf('#')) ;
  }
  if (s.indexOf('?') != -1) {
    query=s.substring(s.indexOf('?'));
    s=s.substring(0,s.indexOf('?')) ;
  }
  if( s.lastIndexOf('.') - s.search(/_..\./) == 3) s=s.replace(/_..\./, '.');
  s=s.substring(0, s.lastIndexOf('.')) + '_'+lang + s.substring(s.lastIndexOf('.')); 
  window.location=s+query+sharp;
}

function getKey(e) {
  if (document.all) e = window.event;
  if(!e)return;
  if (e.keyCode) return e.keyCode;
  else if (e.which) return e.which;
  else return;
}

function explorerKeyDown(e, o) {
  if(!o) o=this;
  key=getKey(e);
  if (!document.getElementById) return false; 
  var dir=document.getElementById("dir");
  if (!dir || !dir.links) return false;
  // previous
  if (key==38) {
    if (o.index == 0) return;
    previous=dir.links[o.index - 1];
    while (previous && previous.index > 0 && !isVisible(previous)) {
      previous=dir.links[previous.index - 1];
    }
    if (!previous || !isVisible(previous)) return;
    previous.focus();
    return false;
  }
  // next
  else if (key==40) {
    if (o.index == dir.links.length - 1) return;
    next=dir.links[o.index + 1];
    while (next && !isVisible(next) && next.index < dir.links.length - 2 ) {
      next=dir.links[next.index + 1];
    }
    if (!next || !isVisible(next)) return;
    next.focus();
    return false;
  }
  // open
  else if (key==39) {
    if (o.parentNode) expand(o.parentNode, "open"); 
  }
  // close
  else if (key==37) {
    if (o.parentNode) expand(o.parentNode, "close"); 
  }
  // page up
  else if(key==33) {
    diff=10;
    if (o.index - diff < 0) return;
    previous=dir.links[o.index - diff];
    while (previous && previous.index > 0 && !isVisible(previous)) {
      previous=dir.links[previous.index - 1];
    }
    if (!previous || !isVisible(previous)) return;
    previous.focus();
    return false;
  }
  // page down
  else if(key==34) {
    diff=10;
    if (o.index + diff > dir.links.length - 1) return;
    next=dir.links[o.index + diff];
    while (next && !isVisible(next) && next.index < dir.links.length - 2 ) {
      next=dir.links[next.index + 1];
    }
    if (!next || !isVisible(next)) return;
    next.focus();
    return false;
  }
  
}

function isVisible (o) {
  while (o && o.style) {
    if (o.style.display == "none") return false;
    o=o.parentNode;
  }
  return true;
}

/*
get properties of an object
for debug
*/
function props(o) {
   var result = ""
   var a=new Array();
   var i=0
   for (var prop in o) {
      a[i]= prop  + "\t"; // + " = " + o[prop]
      i++;
   }
   a.sort();
   return a;
}

/*
      <frameset cols="25%,*" frameborder="1" border="1" framespacing="2">
         <frame src="./toc.xhtml" name="navigation" frameborder="yes" scrolling="auto"/>
         <frame src="./index" name="article" frameborder="yes" scrolling="auto"/>
      </frameset>

A try to write a frameset in XSL transformation, don't work

var frameset = document.createElement('frameset');
frameset.setAttribute("cols", "25%,*");
frameset.setAttribute("frameborder", "1");
frameset.setAttribute("border", "1");
frameset.setAttribute("framespacing", "2");

// left frame
var append=document.createElement('frame');
append.setAttribute("src", "");
append.setAttribute("name", "left");
append.setAttribute("scrolling", "auto");
append.setAttribute("frameborder", "yes");
frameset.appendChild(append);

// right frame
var append=document.createElement('frame');
append.setAttribute("src", "index.xhtml");
append.setAttribute("name", "right");
append.setAttribute("scrolling", "auto");
append.setAttribute("frameborder", "yes");
frameset.appendChild(append);

var html=document.documentElement;
var body=html.getElementsByTagName('body')[0];

while(body.firstChild) {
  body.removeChild(body.firstChild);
}
var h1=document.createElement('H1');
h1.appendData("Coucou");
body.appendChild(h1);

while(body.firstChild) {
  body.removeChild(body.firstChild);
}

while(html.firstChild) {
  html.removeChild(html.firstChild);
}

html.appendChild( frameset);
*/


