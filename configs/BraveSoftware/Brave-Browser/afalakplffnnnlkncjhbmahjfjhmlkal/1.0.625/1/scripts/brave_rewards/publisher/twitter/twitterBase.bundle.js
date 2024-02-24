(()=>{"use strict";const e="mnojpmjdmbbfmejpflffifhffcmidifd";let t=null;const r=()=>t,n=()=>"complete"===document.readyState&&"visible"===document.visibilityState,s=["authorization","x-csrf-token","x-guest-token"],a=/[; ]_twitter_sess=([^\s;]*)/;let i=null,o={};const u=e=>{if(!e)return null;const t=e.match(a);return t?unescape(t[1]):null},c=()=>o,l=()=>o.authorization&&(o["x-csrf-token"]&&o["x-twitter-auth-type"]||o["x-csrf-token"]&&o["x-guest-token"]),d="twitter",m="twitter.com",p=["https://api.twitter.com/1.1/*"],h=["requestHeaders","extraHeaders"];let f=0;const g=new class{constructor(e){this.values=new Map,this.maxEntries=e}get(e){if(!e)return null;const t=this.values.get(e);return t?(this.values.delete(e),this.values.set(e,t),t):null}put(e,t){if(this.values.size>=this.maxEntries){const e=this.values.keys().next().value;this.values.delete(e)}this.values.set(e,t)}}(128),v=(e,t)=>{if(!e||!t)return;const n=t.id_str,s=`${d}#channel:${n}`,a=e,i=(m=e,(l=d)&&m?`${l}_${m}`:""),o=t.profile_image_url_https.replace("_normal",""),u=((e,t)=>e?t?`https://twitter.com/intent/user?user_id=${t}&screen_name=${e}`:`https://twitter.com/${e}/`:"")(e,n),c=r();var l,m;c&&c.postMessage({type:"SavePublisherVisit",mediaType:d,data:{url:u,publisherKey:s,publisherName:a,mediaKey:i,favIconUrl:o}})},w=e=>{const t=(e=>{const t=new URLSearchParams(e.search);if(!t)return"";const r=t.get("screen_name");if(r)return unescape(r);if(!e.pathname)return"";const n=e.pathname.split("/").filter((e=>e));return n&&0!==n.length?n[0]:""})(e);if(!t)return;const n=g.get(t);n?v(t,n):(async e=>e?((e,t)=>new Promise(((n,s)=>{if(!e||!t)return void s(new Error("Invalid parameters"));if(!l())return void s(new Error("Missing auth headers"));const a=r();if(!a)return void s(new Error("Invalid port"));if(0!==f&&Date.now()-f<3e3)return void s(new Error("Ignoring API request due to network throttle"));f=Date.now();const i=c();a.postMessage({type:"OnAPIRequest",mediaType:d,data:{name:e,url:t,init:{credentials:"include",headers:{...i},referrerPolicy:"no-referrer-when-downgrade",method:"GET",redirect:"follow"}}}),a.onMessage.addListener((function t(r){if(a){if(!r||!r.data)return a.onMessage.removeListener(t),void s(new Error("Invalid message"));if("OnAPIResponse"===r.type){if(!r.data.name||!r.data.response&&!r.data.error)return a.onMessage.removeListener(t),void s(new Error("Invalid message"));if(r.data.name===e){if(a.onMessage.removeListener(t),r.data.error)return void s(new Error(r.data.error));n(r.data.response)}}}else s(new Error("Invalid port"))}))})))("GetUserDetails",`https://api.twitter.com/1.1/users/show.json?screen_name=${e}`):Promise.reject(new Error("Invalid parameters")))(t).then((e=>{g.put(t,e),v(t,e)})).catch((e=>{console.error(`Failed to fetch user details for ${t}: ${e.message}`)}))},y=()=>{const e=new URL(location.href);(e=>{if(["/","/about","/home","/login","/logout","/messages","/privacy","/search","/settings","/tos"].includes(e))return!0;const t=["/account/","/compose/","/explore","/hashtag/","/i/","/messages/","/notifications","/settings/","/who_to_follow/","/?login","/?logout"];for(const r of t)if(e.startsWith(r))return!0;return!1})(e.pathname)?(()=>{const e=`https://${m}`,t=m,n=m,s=r();s&&s.postMessage({type:"SavePublisherVisit",mediaType:"",data:{url:e,publisherKey:t,publisherName:n,mediaKey:"",favIconUrl:""}})})():w(e)};let b=!1,x=!1;const E=(e,t)=>{e===d&&t&&t.requestHeaders&&(e=>{if(!e)return!1;let t={};for(const r of e)if("Cookie"===r.name){const e=u(r.value);e!==i&&(i=e,t={})}else(s.includes(r.name)||r.name.startsWith("x-twitter-"))&&(t[r.name]=r.value);return"yes"!==t["x-twitter-active-user"]&&(t["x-twitter-active-user"]="yes"),!((e,t)=>{const r=Object.getOwnPropertyNames(e),n=Object.getOwnPropertyNames(t);if(r.length!==n.length)return!1;for(let n=0;n<r.length;n++){const s=r[n];if(e[s]!==t[s])return!1}return!0})(o,t)&&(o=t,!0)})(t.requestHeaders)&&y()},I=e=>{e&&e.url&&y()};var M;chrome.extension.inIncognitoContext||(M=e=>{e?(n()?y():document.addEventListener("readystatechange",(function(){n()&&y()})),document.addEventListener("visibilitychange",(function(){"visible"===document.visibilityState&&y()})),((e,t,n,s)=>{if(x)return;x=!0;const a=r();a&&(a.postMessage({type:"RegisterOnSendHeadersWebRequest",mediaType:e,data:{urlPatterns:t,extra:n}}),a.onMessage.addListener((function(e){e.data&&"OnSendHeadersWebRequest"===e.type&&s(e.mediaType,e.data.details)})))})(d,p,h,E),((e,t)=>{if(b)return;b=!0;const n=r();n&&(n.postMessage({type:"RegisterOnUpdatedTab",mediaType:e}),n.onMessage.addListener((function(e){e.data&&"OnUpdatedTab"===e.type&&t(e.data.changeInfo)})))})(d,I)):console.error("Failed to initialize communications port")},t?M(!0):(chrome.runtime.sendMessage(e,{type:"SupportsGreaselion"},(function(r){!chrome.runtime.lastError&&r&&r.supported&&(t=chrome.runtime.connect(e,{name:"Greaselion"}),M(!0))})),setTimeout((()=>{t||(t=chrome.runtime.connect("jidkidbbcafjabdphckchenhfomhnfma",{name:"Greaselion"}),M(!0))}),100)),console.info("Greaselion script loaded: twitterBase.ts"))})();