/* ========================================================
 * bootstrap-tab.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#tabs
 * ========================================================
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
 * ======================================================== */
!function(t){"use strict";var e=function(e){this.element=t(e)};e.prototype={constructor:e,show:function(){var e,n,i,r=this.element,o=r.closest("ul:not(.dropdown-menu)"),s=r.attr("data-target");s||(s=r.attr("href"),s=s&&s.replace(/.*(?=#[^\s]*$)/,"")),r.parent("li").hasClass("active")||(e=o.find(".active:last a")[0],i=t.Event("show",{relatedTarget:e}),r.trigger(i),i.isDefaultPrevented()||(n=t(s),this.activate(r.parent("li"),o),this.activate(n,n.parent(),function(){r.trigger({type:"shown",relatedTarget:e})})))},activate:function(e,n,i){function r(){o.removeClass("active").find("> .dropdown-menu > .active").removeClass("active"),e.addClass("active"),s?(e[0].offsetWidth,e.addClass("in")):e.removeClass("fade"),e.parent(".dropdown-menu")&&e.closest("li.dropdown").addClass("active"),i&&i()}var o=n.find("> .active"),s=i&&t.support.transition&&o.hasClass("fade");s?o.one(t.support.transition.end,r):r(),o.removeClass("in")}},t.fn.tab=function(n){return this.each(function(){var i=t(this),r=i.data("tab");r||i.data("tab",r=new e(this)),"string"==typeof n&&r[n]()})},t.fn.tab.Constructor=e,t(document).on("click.tab.data-api",'[data-toggle="tab"], [data-toggle="pill"]',function(e){e.preventDefault(),t(this).tab("show")})}(window.jQuery);