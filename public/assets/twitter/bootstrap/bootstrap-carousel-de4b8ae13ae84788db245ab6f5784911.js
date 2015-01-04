/* ==========================================================
 * bootstrap-carousel.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#carousel
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
!function(t){"use strict";var e=function(e,n){this.$element=t(e),this.options=n,this.options.slide&&this.slide(this.options.slide),"hover"==this.options.pause&&this.$element.on("mouseenter",t.proxy(this.pause,this)).on("mouseleave",t.proxy(this.cycle,this))};e.prototype={cycle:function(e){return e||(this.paused=!1),this.options.interval&&!this.paused&&(this.interval=setInterval(t.proxy(this.next,this),this.options.interval)),this},to:function(e){var n=this.$element.find(".item.active"),i=n.parent().children(),r=i.index(n),o=this;if(!(e>i.length-1||0>e))return this.sliding?this.$element.one("slid",function(){o.to(e)}):r==e?this.pause().cycle():this.slide(e>r?"next":"prev",t(i[e]))},pause:function(e){return e||(this.paused=!0),this.$element.find(".next, .prev").length&&t.support.transition.end&&(this.$element.trigger(t.support.transition.end),this.cycle()),clearInterval(this.interval),this.interval=null,this},next:function(){return this.sliding?void 0:this.slide("next")},prev:function(){return this.sliding?void 0:this.slide("prev")},slide:function(e,n){var i,r=this.$element.find(".item.active"),o=n||r[e](),s=this.interval,a="next"==e?"left":"right",l="next"==e?"first":"last",u=this;if(this.sliding=!0,s&&this.pause(),o=o.length?o:this.$element.find(".item")[l](),i=t.Event("slide",{relatedTarget:o[0]}),!o.hasClass("active")){if(t.support.transition&&this.$element.hasClass("slide")){if(this.$element.trigger(i),i.isDefaultPrevented())return;o.addClass(e),o[0].offsetWidth,r.addClass(a),o.addClass(a),this.$element.one(t.support.transition.end,function(){o.removeClass([e,a].join(" ")).addClass("active"),r.removeClass(["active",a].join(" ")),u.sliding=!1,setTimeout(function(){u.$element.trigger("slid")},0)})}else{if(this.$element.trigger(i),i.isDefaultPrevented())return;r.removeClass("active"),o.addClass("active"),this.sliding=!1,this.$element.trigger("slid")}return s&&this.cycle(),this}}},t.fn.carousel=function(n){return this.each(function(){var i=t(this),r=i.data("carousel"),o=t.extend({},t.fn.carousel.defaults,"object"==typeof n&&n),s="string"==typeof n?n:o.slide;r||i.data("carousel",r=new e(this,o)),"number"==typeof n?r.to(n):s?r[s]():o.interval&&r.cycle()})},t.fn.carousel.defaults={interval:5e3,pause:"hover"},t.fn.carousel.Constructor=e,t(document).on("click.carousel.data-api","[data-slide]",function(e){var n,i=t(this),r=t(i.attr("data-target")||(n=i.attr("href"))&&n.replace(/.*(?=#[^\s]+$)/,"")),o=t.extend({},r.data(),i.data());r.carousel(o),e.preventDefault()})}(window.jQuery);