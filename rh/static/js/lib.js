// requestAnimationFrame polyfill
(function() {
    var lastTime = 0;
    var vendors = ['webkit', 'moz'];
    for(var x = 0; x < vendors.length && !window.requestAnimationFrame; ++x) {
        window.requestAnimationFrame = window[vendors[x]+'RequestAnimationFrame'];
        window.cancelAnimationFrame =
          window[vendors[x]+'CancelAnimationFrame'] || window[vendors[x]+'CancelRequestAnimationFrame'];
    }

    if (!window.requestAnimationFrame)
        window.requestAnimationFrame = function(callback, element) {
            var currTime = new Date().getTime();
            var timeToCall = Math.max(0, 16 - (currTime - lastTime));
            var id = window.setTimeout(function() { callback(currTime + timeToCall); },
              timeToCall);
            lastTime = currTime + timeToCall;
            return id;
        };

    if (!window.cancelAnimationFrame)
        window.cancelAnimationFrame = function(id) {
            clearTimeout(id);
        };
}());


(function() {
if (!window.devicePixelRatio)
    window.devicePixelRatio = 1.0
}());


(function () {

if (typeof window.Element === "undefined" || "classList" in document.documentElement) return;

var prototype = Array.prototype,
    push = prototype.push,
    splice = prototype.splice,
    join = prototype.join;

function DOMTokenList(el) {
  this.el = el;
  // The className needs to be trimmed and split on whitespace
  // to retrieve a list of classes.
  var classes = el.className.replace(/^\s+|\s+$/g,'').split(/\s+/);
  for (var i = 0; i < classes.length; i++) {
    push.call(this, classes[i]);
  }
};

DOMTokenList.prototype = {
  add: function(token) {
    if(this.contains(token)) return;
    push.call(this, token);
    this.el.className = this.toString();
  },
  contains: function(token) {
    return this.el.className.indexOf(token) != -1;
  },
  item: function(index) {
    return this[index] || null;
  },
  remove: function(token) {
    if (!this.contains(token)) return;
    for (var i = 0; i < this.length; i++) {
      if (this[i] == token) break;
    }
    splice.call(this, i, 1);
    this.el.className = this.toString();
  },
  toString: function() {
    return join.call(this, ' ');
  },
  toggle: function(token) {
    if (!this.contains(token)) {
      this.add(token);
    } else {
      this.remove(token);
    }

    return this.contains(token);
  }
};

window.DOMTokenList = DOMTokenList;

function defineElementGetter (obj, prop, getter) {
    if (Object.defineProperty) {
        Object.defineProperty(obj, prop,{
            get : getter
        });
    } else {
        obj.__defineGetter__(prop, getter);
    }
}

defineElementGetter(Element.prototype, 'classList', function () {
  return new DOMTokenList(this);
});

})();


// BECAUSE IE 9

/*!
 * History API JavaScript Library v4.1.12
 *
 * Support: IE6+, FF3+, Opera 9+, Safari, Chrome and other
 *
 * Copyright 2011-2014, Dmitrii Pakhtinov ( spb.piksel@gmail.com )
 *
 * http://spb-piksel.ru/
 *
 * Dual licensed under the MIT and GPL licenses:
 *   http://www.opensource.org/licenses/mit-license.php
 *   http://www.gnu.org/licenses/gpl.html
 *
 * Update: 2014-06-29 20:56
 */
(function(P){"function"===typeof define&&define.amd?define("object"!==typeof document||"loading"!==document.readyState?[]:"html5-history-api",P):P()})(function(){var j=!0,k=null,m=!1;function Q(a,b){var c=e.history!==n;c&&(e.history=n);a.apply(n,b);c&&(e.history=l)}function J(){}function h(a,b,c){if(a!=k&&""!==a&&!b){var b=h(),d=g.getElementsByTagName("base")[0];!c&&d&&d.getAttribute("href")&&(d.href=d.href,b=h(d.href,k,j));c=b.e;d=b.h;a=""+a;a=/^(?:\w+\:)?\/\//.test(a)?0===a.indexOf("/")?d+a:a:d+"//"+b.g+(0===a.indexOf("/")?a:0===a.indexOf("?")?c+a:0===a.indexOf("#")?c+b.f+a:c.replace(/[^\/]+$/g,"")+a)}else if(a=b?a:f.href,!s||c)a=a.replace(/^[^#]*/,"")||"#",a=f.protocol.replace(/:.*$|$/,
":")+"//"+f.host+i.basepath+a.replace(RegExp("^#[/]?(?:"+i.type+")?"),"");R.href=a;var a=/(?:(\w+\:))?(?:\/\/(?:[^@]*@)?([^\/:\?#]+)(?::([0-9]+))?)?([^\?#]*)(?:(\?[^#]+)|\?)?(?:(#.*))?/.exec(R.href),b=a[2]+(a[3]?":"+a[3]:""),c=a[4]||"/",d=a[5]||"",e="#"===a[6]?"":a[6]||"",p=c+d+e,v=c.replace(RegExp("^"+i.basepath,"i"),i.type)+d;return{a:a[1]+"//"+b+p,h:a[1],g:b,i:a[2],k:a[3]||"",e:c,f:d,b:e,c:p,j:v,d:v+e}}function aa(){var a;try{a=e.sessionStorage,a.setItem(E+"t","1"),a.removeItem(E+"t")}catch(b){a=
{getItem:function(a){a=g.cookie.split(a+"=");return 1<a.length&&a.pop().split(";").shift()||"null"},setItem:function(a){var b={};if(b[f.href]=l.state)g.cookie=a+"="+t.stringify(b)}}}try{q=t.parse(a.getItem(E))||{}}catch(c){q={}}w(x+"unload",function(){a.setItem(E,t.stringify(q))},m)}function y(a,b,c,d){var f=0;c||(c={set:J},f=1);var g=!c.set,v=!c.get,K={configurable:j,set:function(){g=1},get:function(){v=1}};try{C(a,b,K),a[b]=a[b],C(a,b,c)}catch(ha){}if(!g||!v)if(a.__defineGetter__&&(a.__defineGetter__(b,
K.get),a.__defineSetter__(b,K.set),a[b]=a[b],c.get&&a.__defineGetter__(b,c.get),c.set&&a.__defineSetter__(b,c.set)),!g||!v){if(f)return m;if(a===e){try{var ba=a[b];a[b]=k}catch(ia){}if("execScript"in e)e.execScript("Public "+b,"VBScript"),e.execScript("var "+b+";","JavaScript");else try{C(a,b,{value:J})}catch(l){}a[b]=ba}else try{try{var h=F.create(a);C(F.getPrototypeOf(h)===a?h:a,b,c);for(var i in a)"function"===typeof a[i]&&(h[i]=a[i].bind(a));try{d.call(h,h,a)}catch(n){}a=h}catch(o){C(a.constructor.prototype,
b,c)}}catch(q){return m}}return a}function ca(a,b,c){c=c||{};a=a===L?f:a;c.set=c.set||function(c){a[b]=c};c.get=c.get||function(){return a[b]};return c}function G(a,b){var c=(""+("string"===typeof a?a:a.type)).replace(/^on/,""),d=z[c];if(d){b="string"===typeof a?b:a;if(b.target==k)for(var f=["target","currentTarget","srcElement","type"];a=f.pop();)b=y(b,a,{get:"type"===a?function(){return c}:function(){return e}});(("popstate"===c?e.onpopstate:e.onhashchange)||J).call(e,b);for(var f=0,g=d.length;f<
g;f++)d[f].call(e,b);return j}return da(a,b)}function S(){var a=g.createEvent?g.createEvent("Event"):g.createEventObject();a.initEvent?a.initEvent("popstate",m,m):a.type="popstate";a.state=l.state;G(a)}function u(a,b,c,e){s?A=f.href:(0===o&&(o=2),b=h(b,2===o&&-1!==(""+b).indexOf("#")),b.c!==h().c&&(A=e,c?f.replace("#"+b.d):f.hash=b.d));!H&&a&&(q[f.href]=a);D=m}function M(a){var b=A;A=f.href;if(b){T!==f.href&&S();var a=a||e.event,b=h(b,j),c=h();a.oldURL||(a.oldURL=b.a,a.newURL=c.a);b.b!==c.b&&G(a)}}
function U(a){setTimeout(function(){w("popstate",function(a){T=f.href;H||(a=y(a,"state",{get:function(){return l.state}}));G(a)},m)},0);!s&&a!==j&&"location"in l&&(V(r.hash),D&&(D=m,S()))}function ea(a){var a=a||e.event,b;a:{for(b=a.target||a.srcElement;b;){if("A"===b.nodeName)break a;b=b.parentNode}b=void 0}var c="defaultPrevented"in a?a.defaultPrevented:a.returnValue===m;b&&"A"===b.nodeName&&!c&&(c=h(),b=h(b.getAttribute("href",2)),c.a.split("#").shift()===b.a.split("#").shift()&&b.b&&(c.b!==b.b&&
(r.hash=b.b),V(b.b),a.preventDefault?a.preventDefault():a.returnValue=m))}function V(a){var b=g.getElementById(a=(a||"").replace(/^#/,""));b&&b.id===a&&"A"===b.nodeName&&(a=b.getBoundingClientRect(),e.scrollTo(I.scrollLeft||0,a.top+(I.scrollTop||0)-(I.clientTop||0)))}function fa(){function a(a){var b=[],d="VBHistoryClass"+(new Date).getTime()+c++,f=["Class "+d],g;for(g in a)if(a.hasOwnProperty(g)){var h=a[g];h&&(h.get||h.set)?(h.get&&f.push("Public "+("_"===g?"Default ":"")+"Property Get ["+g+"]",
"Call VBCVal([(accessors)].["+g+"].get.call(me),["+g+"])","End Property"),h.set&&f.push("Public Property Let ["+g+"](val)",h="Call [(accessors)].["+g+"].set.call(me,val)\nEnd Property","Public Property Set ["+g+"](val)",h)):(b.push(g),f.push("Public ["+g+"]"))}f.push("Private [(accessors)]","Private Sub Class_Initialize()","Set [(accessors)]="+d+"FactoryJS()","End Sub","End Class","Function "+d+"Factory()","Set "+d+"Factory=New "+d,"End Function");e.execScript(f.join("\n"),"VBScript");e[d+"FactoryJS"]=
function(){return a};d=e[d+"Factory"]();for(f=0;f<b.length;f++)d[b[f]]=a[b[f]];return d}function b(a){var b=/[\\"\u0000-\u001f\u007f-\u009f\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]/g,c={"\u0008":"\\b","\t":"\\t","\n":"\\n","\u000c":"\\f","\r":"\\r",'"':'\\"',"\\":"\\\\"};return b.test(a)?'"'+a.replace(b,function(a){return a in c?c[a]:"\\u"+("0000"+a.charCodeAt(0).toString(16)).slice(-4)})+'"':'"'+a+'"'}var c=e.eval&&eval("/*@cc_on 1;@*/");if(c&&
!(g.documentMode&&7<g.documentMode)){var d=y,i=h().a,p=g.createElement("iframe");p.src="javascript:true;";p=I.firstChild.appendChild(p).contentWindow;e.execScript("Public history\nFunction VBCVal(o,r) If IsObject(o) Then Set r=o Else r=o End If End Function","VBScript");r={_:{get:L.toString}};l={back:n.back,forward:n.forward,go:n.go,emulate:k,_:{get:function(){return"[object History]"}}};t={parse:function(a){try{return(new Function("","return "+a))()}catch(b){return k}},stringify:function(a){var c=
(typeof a).charCodeAt(2);if(114===c)a=b(a);else if(109===c)a=isFinite(a)?""+a:"null";else if(111===c||108===c)a=""+a;else if(106===c)if(a){var d=(c="[object Array]"===F.prototype.toString.call(a))?"[":"{";if(c)for(var e=0;e<a.length;e++)d+=(0==e?"":",")+t.stringify(a[e]);else for(e in a)a.hasOwnProperty(e)&&(d+=(1==d.length?"":",")+b(e)+":"+t.stringify(a[e]));a=d+(c?"]":"}")}else a="null";else a="void 0";return a}};u=function(a,b,c,d,e){var g=p.document;0===o&&(o=2);b=h(b,2===o&&-1!==(""+b).indexOf("#"));
D=m;if(b.c===h().c&&!e)a&&(q[f.href]=a);else{A=d;if(c)p.lfirst?(history.back(),u(a,b.a,0,d,1)):f.replace("#"+b.d);else if(b.a!=i||e)p.lfirst?e&&(e=0,a=q[f.href]):(p.lfirst=1,u(a,i,0,d,1)),g.open(),g.write('<script>lfirst=1;parent.location.hash="'+b.d.replace(/"/g,'\\"')+'";<\/script>'),g.close();!e&&a&&(q[f.href]=a)}};y=function(b,c,f,g){d.apply(this,arguments)||(b===r?r[c]=f:b===l?(l[c]=f,"state"===c&&(r=a(r),e.history=l=a(l),e.execScript("var history = window.history;","JavaScript"))):b[c]=f.get&&
f.get());return b};setInterval(function(){var a=h().a;if(a!=i){var b=g.createEventObject();b.oldURL=i;b.newURL=i=a;b.type="hashchange";M(b)}},100);e.JSON=t}}var e=("object"===typeof window?window:this)||{};if(!e.history||"emulate"in e.history)return e.history;var g=e.document,I=g.documentElement,F=e.Object,t=e.JSON,f=e.location,n=e.history,l=n,N=n.pushState,W=n.replaceState,s=!!N,H="state"in n,C=F.defineProperty,r=y({},"t")?{}:g.createElement("a"),x="",O=e.addEventListener?"addEventListener":(x="on")&&
"attachEvent",X=e.removeEventListener?"removeEventListener":"detachEvent",Y=e.dispatchEvent?"dispatchEvent":"fireEvent",w=e[O],Z=e[X],da=e[Y],i={basepath:"/",redirect:0,type:"/"},E="__historyAPI__",R=g.createElement("a"),A=f.href,T="",D=m,o=0,q={},z={},B=g.title,ga={onhashchange:k,onpopstate:k},$={setup:function(a,b,c){i.basepath=(""+(a==k?i.basepath:a)).replace(/(?:^|\/)[^\/]*$/,"/");i.type=b==k?i.type:b;i.redirect=c==k?i.redirect:!!c},redirect:function(a,b){l.setup(b,a);b=i.basepath;if(e.top==e.self){var c=
h(k,m,j).c,d=f.pathname+f.search;s?(d=d.replace(/([^\/])$/,"$1/"),c!=b&&RegExp("^"+b+"$","i").test(d)&&f.replace(c)):d!=b&&(d=d.replace(/([^\/])\?/,"$1/?"),RegExp("^"+b,"i").test(d)&&f.replace(b+"#"+d.replace(RegExp("^"+b,"i"),i.type)+f.hash))}},pushState:function(a,b,c){var d=g.title;B!=k&&(g.title=B);N&&Q(N,arguments);u(a,c);g.title=d;B=b},replaceState:function(a,b,c){var d=g.title;B!=k&&(g.title=B);delete q[f.href];W&&Q(W,arguments);u(a,c,j);g.title=d;B=b},location:{set:function(a){0===o&&(o=1);
e.location=a},get:function(){0===o&&(o=1);return s?f:r}},state:{get:function(){return q[f.href]||k}}},L={assign:function(a){0===(""+a).indexOf("#")?u(k,a):f.assign(a)},reload:function(){f.reload()},replace:function(a){0===(""+a).indexOf("#")?u(k,a,j):f.replace(a)},toString:function(){return this.href},href:{get:function(){return h().a}},protocol:k,host:k,hostname:k,port:k,pathname:{get:function(){return h().e}},search:{get:function(){return h().f}},hash:{set:function(a){u(k,(""+a).replace(/^(#|)/,
"#"),m,A)},get:function(){return h().b}}};if(function(){var a=g.getElementsByTagName("script"),a=(a[a.length-1]||{}).src||"";(-1!==a.indexOf("?")?a.split("?").pop():"").replace(/(\w+)(?:=([^&]*))?/g,function(a,b,c){i[b]=(c||"").replace(/^(0|false)$/,"")});fa();w(x+"hashchange",M,m);var b=[L,r,ga,e,$,l];H&&delete $.state;for(var c=0;c<b.length;c+=2)for(var d in b[c])if(b[c].hasOwnProperty(d))if("function"===typeof b[c][d])b[c+1][d]=b[c][d];else{a=ca(b[c],d,b[c][d]);if(!y(b[c+1],d,a,function(a,d){if(d===
l)e.history=l=b[c+1]=a}))return Z(x+"hashchange",M,m),m;b[c+1]===e&&(z[d]=z[d.substr(2)]=[])}l.setup();i.redirect&&l.redirect();!H&&t&&aa();if(!s)g[O](x+"click",ea,m);"complete"===g.readyState?U(j):(!s&&h().c!==i.basepath&&(D=j),w(x+"load",U,m));return j}())return l.emulate=!s,e[O]=function(a,b,c){a in z?z[a].push(b):3<arguments.length?w(a,b,c,arguments[3]):w(a,b,c)},e[X]=function(a,b,c){var d=z[a];if(d)for(a=d.length;a--;){if(d[a]===b){d.splice(a,1);break}}else Z(a,b,c)},e[Y]=G,l});