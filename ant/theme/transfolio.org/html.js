
// set functions here will unplug the ones declared in the doc
// window.onload=init;
/*
var bugRiddenCrashPronePieceOfJunk = (
	navigator.userAgent.indexOf('MSIE 5') != -1
	&&
	navigator.userAgent.indexOf('Mac') != -1
);
*/
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
Simulate the css position:fixed property for IE
Should be deprecated

assume we have a header, side, and footer object
in our case, div with id
*/

function fixed() {
	if (!document.all) return;
    if (document.side) side.style.pixelTop=document.body.scrollTop+100; 
    if (!document.footer) return;
    footer.style.display='none'; 
	footer.style.bottom='0px'; 
	footer.style.display=''; 
}

/*
Fit character size to width of screen
Prepare the fixed() simulate for IE
Means, set position:absolute to the fixed elements
*/

function init(width) {
    if (!width) width=80;
	fit(width);
	if (!document.all) return;
// 	if (header.style) header.style.position='absolute';
	if (document.side) if (document.side.style) side.style.position='absolute';
	if (document.footer) if (document.footer.style) footer.style.position='absolute';
	window.onscroll=fixed;
}

/*
Maintain a fixed number of character on the width of the window

*/

// normal pixel height
var fontSizeNormal=16;
// mini pixel height
var fontSizeMini=12;
var widthDefault=80;
if ( document.getElementById && !document.all ) var fontSizeNormal=12; // may be mozilla

function fit(ex) {

  // fit char size  
  var width;
  if (false);
  else if (document.body && document.body.offsetWidth) width=document.body.offsetWidth;
  else if (document.body && document.body.clientWidth) width=document.body.clientWidth;
  else if (window.innerWidth) width= window.innerWidth;
  else return false;


  if (!ex) var ex=widthDefault;
  // default ratio between ex and em 
  fontSizeFit=Math.floor((width/ex)*1.2);
  fontSizeFit=(fontSizeFit < fontSizeMini)?fontSizeMini:fontSizeFit;
  //ratio=Math.round ( fontSizeFit / fontSizeNormal  * 100);
  // set a minimum ratio under which the page may be unreadable
  //ratio=(ratio < 50)?50:ratio;
  // don't work
  // window.fontSizeNormal=25;

  if(document && document.body && document.body.style) document.body.style.fontSize=fontSizeFit+"px";
  else if (!document.getElementById) return true;
  // work around for moz in case of XML transformed
  else if(document.getElementById("body")) { 
    o=document.getElementById("body");
    if(!o.style) return false;
    o.style.fontSize=fontSizeFit+"px";
  }

  
  // alert(document.getElementById("body"));
}


