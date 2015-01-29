/* ==========================================================
 * bootstrap-affix.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#affix
 * ==========================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */
!function(t){"use strict";var e=function(e,n){this.options=t.extend({},t.fn.affix.defaults,n),this.$window=t(window).on("scroll.affix.data-api",t.proxy(this.checkPosition,this)).on("click.affix.data-api",t.proxy(function(){setTimeout(t.proxy(this.checkPosition,this),1)},this)),this.$element=t(e),this.checkPosition()};e.prototype.checkPosition=function(){if(this.$element.is(":visible")){var e,n=t(document).height(),i=this.$window.scrollTop(),r=this.$element.offset(),o=this.options.offset,s=o.bottom,a=o.top,l="affix affix-top affix-bottom";"object"!=typeof o&&(s=a=o),"function"==typeof a&&(a=o.top()),"function"==typeof s&&(s=o.bottom()),e=null!=this.unpin&&i+this.unpin<=r.top?!1:null!=s&&r.top+this.$element.height()>=n-s?"bottom":null!=a&&a>=i?"top":!1,this.affixed!==e&&(this.affixed=e,this.unpin="bottom"==e?r.top-i:null,this.$element.removeClass(l).addClass("affix"+(e?"-"+e:"")))}},t.fn.affix=function(n){return this.each(function(){var i=t(this),r=i.data("affix"),o="object"==typeof n&&n;r||i.data("affix",r=new e(this,o)),"string"==typeof n&&r[n]()})},t.fn.affix.Constructor=e,t.fn.affix.defaults={offset:0},t(window).on("load",function(){t('[data-spy="affix"]').each(function(){var e=t(this),n=e.data();n.offset=n.offset||{},n.offsetBottom&&(n.offset.bottom=n.offsetBottom),n.offsetTop&&(n.offset.top=n.offsetTop),e.affix(n)})})}(window.jQuery);