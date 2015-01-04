/* =============================================================
 * bootstrap-collapse.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#collapse
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
 * ============================================================ */
!function(t){"use strict";var e=function(e,n){this.$element=t(e),this.options=t.extend({},t.fn.collapse.defaults,n),this.options.parent&&(this.$parent=t(this.options.parent)),this.options.toggle&&this.toggle()};e.prototype={constructor:e,dimension:function(){var t=this.$element.hasClass("width");return t?"width":"height"},show:function(){var e,n,i,r;if(!this.transitioning){if(e=this.dimension(),n=t.camelCase(["scroll",e].join("-")),i=this.$parent&&this.$parent.find("> .accordion-group > .in"),i&&i.length){if(r=i.data("collapse"),r&&r.transitioning)return;i.collapse("hide"),r||i.data("collapse",null)}this.$element[e](0),this.transition("addClass",t.Event("show"),"shown"),t.support.transition&&this.$element[e](this.$element[0][n])}},hide:function(){var e;this.transitioning||(e=this.dimension(),this.reset(this.$element[e]()),this.transition("removeClass",t.Event("hide"),"hidden"),this.$element[e](0))},reset:function(t){var e=this.dimension();return this.$element.removeClass("collapse")[e](t||"auto")[0].offsetWidth,this.$element[null!==t?"addClass":"removeClass"]("collapse"),this},transition:function(e,n,i){var r=this,o=function(){"show"==n.type&&r.reset(),r.transitioning=0,r.$element.trigger(i)};this.$element.trigger(n),n.isDefaultPrevented()||(this.transitioning=1,this.$element[e]("in"),t.support.transition&&this.$element.hasClass("collapse")?this.$element.one(t.support.transition.end,o):o())},toggle:function(){this[this.$element.hasClass("in")?"hide":"show"]()}},t.fn.collapse=function(n){return this.each(function(){var i=t(this),r=i.data("collapse"),o="object"==typeof n&&n;r||i.data("collapse",r=new e(this,o)),"string"==typeof n&&r[n]()})},t.fn.collapse.defaults={toggle:!0},t.fn.collapse.Constructor=e,t(document).on("click.collapse.data-api","[data-toggle=collapse]",function(e){var n,i=t(this),r=i.attr("data-target")||e.preventDefault()||(n=i.attr("href"))&&n.replace(/.*(?=#[^\s]+$)/,""),o=t(r).data("collapse")?"toggle":i.data();i[t(r).hasClass("in")?"addClass":"removeClass"]("collapsed"),t(r).collapse(o)})}(window.jQuery);