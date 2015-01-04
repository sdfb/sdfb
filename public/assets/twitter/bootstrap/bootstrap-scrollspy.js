/* =============================================================
 * bootstrap-scrollspy.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#scrollspy
 * =============================================================
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
 * ============================================================== */
!function(t){"use strict";function e(e,n){var i,r=t.proxy(this.process,this),o=t(t(e).is("body")?window:e);this.options=t.extend({},t.fn.scrollspy.defaults,n),this.$scrollElement=o.on("scroll.scroll-spy.data-api",r),this.selector=(this.options.target||(i=t(e).attr("href"))&&i.replace(/.*(?=#[^\s]+$)/,"")||"")+" .nav li > a",this.$body=t("body"),this.refresh(),this.process()}e.prototype={constructor:e,refresh:function(){var e,n=this;this.offsets=t([]),this.targets=t([]),e=this.$body.find(this.selector).map(function(){var e=t(this),n=e.data("target")||e.attr("href"),i=/^#\w/.test(n)&&t(n);return i&&i.length&&[[i.position().top,n]]||null}).sort(function(t,e){return t[0]-e[0]}).each(function(){n.offsets.push(this[0]),n.targets.push(this[1])})},process:function(){var t,e=this.$scrollElement.scrollTop()+this.options.offset,n=this.$scrollElement[0].scrollHeight||this.$body[0].scrollHeight,i=n-this.$scrollElement.height(),r=this.offsets,o=this.targets,s=this.activeTarget;if(e>=i)return s!=(t=o.last()[0])&&this.activate(t);for(t=r.length;t--;)s!=o[t]&&e>=r[t]&&(!r[t+1]||e<=r[t+1])&&this.activate(o[t])},activate:function(e){var n,i;this.activeTarget=e,t(this.selector).parent(".active").removeClass("active"),i=this.selector+'[data-target="'+e+'"],'+this.selector+'[href="'+e+'"]',n=t(i).parent("li").addClass("active"),n.parent(".dropdown-menu").length&&(n=n.closest("li.dropdown").addClass("active")),n.trigger("activate")}},t.fn.scrollspy=function(n){return this.each(function(){var i=t(this),r=i.data("scrollspy"),o="object"==typeof n&&n;r||i.data("scrollspy",r=new e(this,o)),"string"==typeof n&&r[n]()})},t.fn.scrollspy.Constructor=e,t.fn.scrollspy.defaults={offset:10},t(window).on("load",function(){t('[data-spy="scroll"]').each(function(){var e=t(this);e.scrollspy(e.data())})})}(window.jQuery);