/* ===================================================
 * bootstrap-transition.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#transitions
 * ===================================================
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
!function(t){"use strict";t(function(){t.support.transition=function(){var t=function(){var t,e=document.createElement("bootstrap"),n={WebkitTransition:"webkitTransitionEnd",MozTransition:"transitionend",OTransition:"oTransitionEnd otransitionend",transition:"transitionend"};for(t in n)if(void 0!==e.style[t])return n[t]}();return t&&{end:t}}()})}(window.jQuery),/* ==========================================================
 * bootstrap-alert.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#alerts
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
!function(t){"use strict";var e='[data-dismiss="alert"]',n=function(n){t(n).on("click",e,this.close)};n.prototype.close=function(e){function n(){i.trigger("closed").remove()}var i,r=t(this),o=r.attr("data-target");o||(o=r.attr("href"),o=o&&o.replace(/.*(?=#[^\s]*$)/,"")),i=t(o),e&&e.preventDefault(),i.length||(i=r.hasClass("alert")?r:r.parent()),i.trigger(e=t.Event("close")),e.isDefaultPrevented()||(i.removeClass("in"),t.support.transition&&i.hasClass("fade")?i.on(t.support.transition.end,n):n())},t.fn.alert=function(e){return this.each(function(){var i=t(this),r=i.data("alert");r||i.data("alert",r=new n(this)),"string"==typeof e&&r[e].call(i)})},t.fn.alert.Constructor=n,t(document).on("click.alert.data-api",e,n.prototype.close)}(window.jQuery),/* =========================================================
 * bootstrap-modal.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#modals
 * =========================================================
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
 * ========================================================= */
!function(t){"use strict";var e=function(e,n){this.options=n,this.$element=t(e).delegate('[data-dismiss="modal"]',"click.dismiss.modal",t.proxy(this.hide,this)),this.options.remote&&this.$element.find(".modal-body").load(this.options.remote)};e.prototype={constructor:e,toggle:function(){return this[this.isShown?"hide":"show"]()},show:function(){var e=this,n=t.Event("show");this.$element.trigger(n),this.isShown||n.isDefaultPrevented()||(this.isShown=!0,this.escape(),this.backdrop(function(){var n=t.support.transition&&e.$element.hasClass("fade");e.$element.parent().length||e.$element.appendTo(document.body),e.$element.show(),n&&e.$element[0].offsetWidth,e.$element.addClass("in").attr("aria-hidden",!1),e.enforceFocus(),n?e.$element.one(t.support.transition.end,function(){e.$element.focus().trigger("shown")}):e.$element.focus().trigger("shown")}))},hide:function(e){e&&e.preventDefault();e=t.Event("hide"),this.$element.trigger(e),this.isShown&&!e.isDefaultPrevented()&&(this.isShown=!1,this.escape(),t(document).off("focusin.modal"),this.$element.removeClass("in").attr("aria-hidden",!0),t.support.transition&&this.$element.hasClass("fade")?this.hideWithTransition():this.hideModal())},enforceFocus:function(){var e=this;t(document).on("focusin.modal",function(t){e.$element[0]===t.target||e.$element.has(t.target).length||e.$element.focus()})},escape:function(){var t=this;this.isShown&&this.options.keyboard?this.$element.on("keyup.dismiss.modal",function(e){27==e.which&&t.hide()}):this.isShown||this.$element.off("keyup.dismiss.modal")},hideWithTransition:function(){var e=this,n=setTimeout(function(){e.$element.off(t.support.transition.end),e.hideModal()},500);this.$element.one(t.support.transition.end,function(){clearTimeout(n),e.hideModal()})},hideModal:function(){this.$element.hide().trigger("hidden"),this.backdrop()},removeBackdrop:function(){this.$backdrop.remove(),this.$backdrop=null},backdrop:function(e){var n=this.$element.hasClass("fade")?"fade":"";if(this.isShown&&this.options.backdrop){var i=t.support.transition&&n;this.$backdrop=t('<div class="modal-backdrop '+n+'" />').appendTo(document.body),this.$backdrop.click("static"==this.options.backdrop?t.proxy(this.$element[0].focus,this.$element[0]):t.proxy(this.hide,this)),i&&this.$backdrop[0].offsetWidth,this.$backdrop.addClass("in"),i?this.$backdrop.one(t.support.transition.end,e):e()}else!this.isShown&&this.$backdrop?(this.$backdrop.removeClass("in"),t.support.transition&&this.$element.hasClass("fade")?this.$backdrop.one(t.support.transition.end,t.proxy(this.removeBackdrop,this)):this.removeBackdrop()):e&&e()}},t.fn.modal=function(n){return this.each(function(){var i=t(this),r=i.data("modal"),o=t.extend({},t.fn.modal.defaults,i.data(),"object"==typeof n&&n);r||i.data("modal",r=new e(this,o)),"string"==typeof n?r[n]():o.show&&r.show()})},t.fn.modal.defaults={backdrop:!0,keyboard:!0,show:!0},t.fn.modal.Constructor=e,t(document).on("click.modal.data-api",'[data-toggle="modal"]',function(e){var n=t(this),i=n.attr("href"),r=t(n.attr("data-target")||i&&i.replace(/.*(?=#[^\s]+$)/,"")),o=r.data("modal")?"toggle":t.extend({remote:!/#/.test(i)&&i},r.data(),n.data());e.preventDefault(),r.modal(o).one("hide",function(){n.focus()})})}(window.jQuery),/* ============================================================
 * bootstrap-dropdown.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#dropdowns
 * ============================================================
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
!function(t){"use strict";function e(){t(i).each(function(){n(t(this)).removeClass("open")})}function n(e){var n,i=e.attr("data-target");return i||(i=e.attr("href"),i=i&&/#/.test(i)&&i.replace(/.*(?=#[^\s]*$)/,"")),n=t(i),n.length||(n=e.parent()),n}var i="[data-toggle=dropdown]",r=function(e){var n=t(e).on("click.dropdown.data-api",this.toggle);t("html").on("click.dropdown.data-api",function(){n.parent().removeClass("open")})};r.prototype={constructor:r,toggle:function(){var i,r,o=t(this);if(!o.is(".disabled, :disabled"))return i=n(o),r=i.hasClass("open"),e(),r||(i.toggleClass("open"),o.focus()),!1},keydown:function(e){var i,r,o,s,a;if(/(38|40|27)/.test(e.keyCode)&&(i=t(this),e.preventDefault(),e.stopPropagation(),!i.is(".disabled, :disabled"))){if(o=n(i),s=o.hasClass("open"),!s||s&&27==e.keyCode)return i.click();r=t("[role=menu] li:not(.divider) a",o),r.length&&(a=r.index(r.filter(":focus")),38==e.keyCode&&a>0&&a--,40==e.keyCode&&a<r.length-1&&a++,~a||(a=0),r.eq(a).focus())}}},t.fn.dropdown=function(e){return this.each(function(){var n=t(this),i=n.data("dropdown");i||n.data("dropdown",i=new r(this)),"string"==typeof e&&i[e].call(n)})},t.fn.dropdown.Constructor=r,t(document).on("click.dropdown.data-api touchstart.dropdown.data-api",e).on("click.dropdown touchstart.dropdown.data-api",".dropdown form",function(t){t.stopPropagation()}).on("click.dropdown.data-api touchstart.dropdown.data-api",i,r.prototype.toggle).on("keydown.dropdown.data-api touchstart.dropdown.data-api",i+", [role=menu]",r.prototype.keydown)}(window.jQuery),/* =============================================================
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
!function(t){"use strict";function e(e,n){var i,r=t.proxy(this.process,this),o=t(t(e).is("body")?window:e);this.options=t.extend({},t.fn.scrollspy.defaults,n),this.$scrollElement=o.on("scroll.scroll-spy.data-api",r),this.selector=(this.options.target||(i=t(e).attr("href"))&&i.replace(/.*(?=#[^\s]+$)/,"")||"")+" .nav li > a",this.$body=t("body"),this.refresh(),this.process()}e.prototype={constructor:e,refresh:function(){var e,n=this;this.offsets=t([]),this.targets=t([]),e=this.$body.find(this.selector).map(function(){var e=t(this),n=e.data("target")||e.attr("href"),i=/^#\w/.test(n)&&t(n);return i&&i.length&&[[i.position().top,n]]||null}).sort(function(t,e){return t[0]-e[0]}).each(function(){n.offsets.push(this[0]),n.targets.push(this[1])})},process:function(){var t,e=this.$scrollElement.scrollTop()+this.options.offset,n=this.$scrollElement[0].scrollHeight||this.$body[0].scrollHeight,i=n-this.$scrollElement.height(),r=this.offsets,o=this.targets,s=this.activeTarget;if(e>=i)return s!=(t=o.last()[0])&&this.activate(t);for(t=r.length;t--;)s!=o[t]&&e>=r[t]&&(!r[t+1]||e<=r[t+1])&&this.activate(o[t])},activate:function(e){var n,i;this.activeTarget=e,t(this.selector).parent(".active").removeClass("active"),i=this.selector+'[data-target="'+e+'"],'+this.selector+'[href="'+e+'"]',n=t(i).parent("li").addClass("active"),n.parent(".dropdown-menu").length&&(n=n.closest("li.dropdown").addClass("active")),n.trigger("activate")}},t.fn.scrollspy=function(n){return this.each(function(){var i=t(this),r=i.data("scrollspy"),o="object"==typeof n&&n;r||i.data("scrollspy",r=new e(this,o)),"string"==typeof n&&r[n]()})},t.fn.scrollspy.Constructor=e,t.fn.scrollspy.defaults={offset:10},t(window).on("load",function(){t('[data-spy="scroll"]').each(function(){var e=t(this);e.scrollspy(e.data())})})}(window.jQuery),/* ========================================================
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
!function(t){"use strict";var e=function(e){this.element=t(e)};e.prototype={constructor:e,show:function(){var e,n,i,r=this.element,o=r.closest("ul:not(.dropdown-menu)"),s=r.attr("data-target");s||(s=r.attr("href"),s=s&&s.replace(/.*(?=#[^\s]*$)/,"")),r.parent("li").hasClass("active")||(e=o.find(".active:last a")[0],i=t.Event("show",{relatedTarget:e}),r.trigger(i),i.isDefaultPrevented()||(n=t(s),this.activate(r.parent("li"),o),this.activate(n,n.parent(),function(){r.trigger({type:"shown",relatedTarget:e})})))},activate:function(e,n,i){function r(){o.removeClass("active").find("> .dropdown-menu > .active").removeClass("active"),e.addClass("active"),s?(e[0].offsetWidth,e.addClass("in")):e.removeClass("fade"),e.parent(".dropdown-menu")&&e.closest("li.dropdown").addClass("active"),i&&i()}var o=n.find("> .active"),s=i&&t.support.transition&&o.hasClass("fade");s?o.one(t.support.transition.end,r):r(),o.removeClass("in")}},t.fn.tab=function(n){return this.each(function(){var i=t(this),r=i.data("tab");r||i.data("tab",r=new e(this)),"string"==typeof n&&r[n]()})},t.fn.tab.Constructor=e,t(document).on("click.tab.data-api",'[data-toggle="tab"], [data-toggle="pill"]',function(e){e.preventDefault(),t(this).tab("show")})}(window.jQuery),/* ===========================================================
 * bootstrap-tooltip.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#tooltips
 * Inspired by the original jQuery.tipsy by Jason Frame
 * ===========================================================
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
!function(t){"use strict";var e=function(t,e){this.init("tooltip",t,e)};e.prototype={constructor:e,init:function(e,n,i){var r,o;this.type=e,this.$element=t(n),this.options=this.getOptions(i),this.enabled=!0,"click"==this.options.trigger?this.$element.on("click."+this.type,this.options.selector,t.proxy(this.toggle,this)):"manual"!=this.options.trigger&&(r="hover"==this.options.trigger?"mouseenter":"focus",o="hover"==this.options.trigger?"mouseleave":"blur",this.$element.on(r+"."+this.type,this.options.selector,t.proxy(this.enter,this)),this.$element.on(o+"."+this.type,this.options.selector,t.proxy(this.leave,this))),this.options.selector?this._options=t.extend({},this.options,{trigger:"manual",selector:""}):this.fixTitle()},getOptions:function(e){return e=t.extend({},t.fn[this.type].defaults,e,this.$element.data()),e.delay&&"number"==typeof e.delay&&(e.delay={show:e.delay,hide:e.delay}),e},enter:function(e){var n=t(e.currentTarget)[this.type](this._options).data(this.type);return n.options.delay&&n.options.delay.show?(clearTimeout(this.timeout),n.hoverState="in",void(this.timeout=setTimeout(function(){"in"==n.hoverState&&n.show()},n.options.delay.show))):n.show()},leave:function(e){var n=t(e.currentTarget)[this.type](this._options).data(this.type);return this.timeout&&clearTimeout(this.timeout),n.options.delay&&n.options.delay.hide?(n.hoverState="out",void(this.timeout=setTimeout(function(){"out"==n.hoverState&&n.hide()},n.options.delay.hide))):n.hide()},show:function(){var t,e,n,i,r,o,s;if(this.hasContent()&&this.enabled){switch(t=this.tip(),this.setContent(),this.options.animation&&t.addClass("fade"),o="function"==typeof this.options.placement?this.options.placement.call(this,t[0],this.$element[0]):this.options.placement,e=/in/.test(o),t.detach().css({top:0,left:0,display:"block"}).insertAfter(this.$element),n=this.getPosition(e),i=t[0].offsetWidth,r=t[0].offsetHeight,e?o.split(" ")[1]:o){case"bottom":s={top:n.top+n.height,left:n.left+n.width/2-i/2};break;case"top":s={top:n.top-r,left:n.left+n.width/2-i/2};break;case"left":s={top:n.top+n.height/2-r/2,left:n.left-i};break;case"right":s={top:n.top+n.height/2-r/2,left:n.left+n.width}}t.offset(s).addClass(o).addClass("in")}},setContent:function(){var t=this.tip(),e=this.getTitle();t.find(".tooltip-inner")[this.options.html?"html":"text"](e),t.removeClass("fade in top bottom left right")},hide:function(){function e(){var e=setTimeout(function(){n.off(t.support.transition.end).detach()},500);n.one(t.support.transition.end,function(){clearTimeout(e),n.detach()})}var n=this.tip();return n.removeClass("in"),t.support.transition&&this.$tip.hasClass("fade")?e():n.detach(),this},fixTitle:function(){var t=this.$element;(t.attr("title")||"string"!=typeof t.attr("data-original-title"))&&t.attr("data-original-title",t.attr("title")||"").removeAttr("title")},hasContent:function(){return this.getTitle()},getPosition:function(e){return t.extend({},e?{top:0,left:0}:this.$element.offset(),{width:this.$element[0].offsetWidth,height:this.$element[0].offsetHeight})},getTitle:function(){var t,e=this.$element,n=this.options;return t=e.attr("data-original-title")||("function"==typeof n.title?n.title.call(e[0]):n.title)},tip:function(){return this.$tip=this.$tip||t(this.options.template)},validate:function(){this.$element[0].parentNode||(this.hide(),this.$element=null,this.options=null)},enable:function(){this.enabled=!0},disable:function(){this.enabled=!1},toggleEnabled:function(){this.enabled=!this.enabled},toggle:function(e){var n=t(e.currentTarget)[this.type](this._options).data(this.type);n[n.tip().hasClass("in")?"hide":"show"]()},destroy:function(){this.hide().$element.off("."+this.type).removeData(this.type)}},t.fn.tooltip=function(n){return this.each(function(){var i=t(this),r=i.data("tooltip"),o="object"==typeof n&&n;r||i.data("tooltip",r=new e(this,o)),"string"==typeof n&&r[n]()})},t.fn.tooltip.Constructor=e,t.fn.tooltip.defaults={animation:!0,placement:"top",selector:!1,template:'<div class="tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>',trigger:"hover",title:"",delay:0,html:!1}}(window.jQuery),/* ===========================================================
 * bootstrap-popover.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#popovers
 * ===========================================================
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
 * =========================================================== */
!function(t){"use strict";var e=function(t,e){this.init("popover",t,e)};e.prototype=t.extend({},t.fn.tooltip.Constructor.prototype,{constructor:e,setContent:function(){var t=this.tip(),e=this.getTitle(),n=this.getContent();t.find(".popover-title")[this.options.html?"html":"text"](e),t.find(".popover-content > *")[this.options.html?"html":"text"](n),t.removeClass("fade top bottom left right in")},hasContent:function(){return this.getTitle()||this.getContent()},getContent:function(){var t,e=this.$element,n=this.options;return t=e.attr("data-content")||("function"==typeof n.content?n.content.call(e[0]):n.content)},tip:function(){return this.$tip||(this.$tip=t(this.options.template)),this.$tip},destroy:function(){this.hide().$element.off("."+this.type).removeData(this.type)}}),t.fn.popover=function(n){return this.each(function(){var i=t(this),r=i.data("popover"),o="object"==typeof n&&n;r||i.data("popover",r=new e(this,o)),"string"==typeof n&&r[n]()})},t.fn.popover.Constructor=e,t.fn.popover.defaults=t.extend({},t.fn.tooltip.defaults,{placement:"right",trigger:"click",content:"",template:'<div class="popover"><div class="arrow"></div><div class="popover-inner"><h3 class="popover-title"></h3><div class="popover-content"><p></p></div></div></div>'})}(window.jQuery),/* ============================================================
 * bootstrap-button.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#buttons
 * ============================================================
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
!function(t){"use strict";var e=function(e,n){this.$element=t(e),this.options=t.extend({},t.fn.button.defaults,n)};e.prototype.setState=function(t){var e="disabled",n=this.$element,i=n.data(),r=n.is("input")?"val":"html";t+="Text",i.resetText||n.data("resetText",n[r]()),n[r](i[t]||this.options[t]),setTimeout(function(){"loadingText"==t?n.addClass(e).attr(e,e):n.removeClass(e).removeAttr(e)},0)},e.prototype.toggle=function(){var t=this.$element.closest('[data-toggle="buttons-radio"]');t&&t.find(".active").removeClass("active"),this.$element.toggleClass("active")},t.fn.button=function(n){return this.each(function(){var i=t(this),r=i.data("button"),o="object"==typeof n&&n;r||i.data("button",r=new e(this,o)),"toggle"==n?r.toggle():n&&r.setState(n)})},t.fn.button.defaults={loadingText:"loading..."},t.fn.button.Constructor=e,t(document).on("click.button.data-api","[data-toggle^=button]",function(e){var n=t(e.target);n.hasClass("btn")||(n=n.closest(".btn")),n.button("toggle")})}(window.jQuery),/* =============================================================
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
!function(t){"use strict";var e=function(e,n){this.$element=t(e),this.options=t.extend({},t.fn.collapse.defaults,n),this.options.parent&&(this.$parent=t(this.options.parent)),this.options.toggle&&this.toggle()};e.prototype={constructor:e,dimension:function(){var t=this.$element.hasClass("width");return t?"width":"height"},show:function(){var e,n,i,r;if(!this.transitioning){if(e=this.dimension(),n=t.camelCase(["scroll",e].join("-")),i=this.$parent&&this.$parent.find("> .accordion-group > .in"),i&&i.length){if(r=i.data("collapse"),r&&r.transitioning)return;i.collapse("hide"),r||i.data("collapse",null)}this.$element[e](0),this.transition("addClass",t.Event("show"),"shown"),t.support.transition&&this.$element[e](this.$element[0][n])}},hide:function(){var e;this.transitioning||(e=this.dimension(),this.reset(this.$element[e]()),this.transition("removeClass",t.Event("hide"),"hidden"),this.$element[e](0))},reset:function(t){var e=this.dimension();return this.$element.removeClass("collapse")[e](t||"auto")[0].offsetWidth,this.$element[null!==t?"addClass":"removeClass"]("collapse"),this},transition:function(e,n,i){var r=this,o=function(){"show"==n.type&&r.reset(),r.transitioning=0,r.$element.trigger(i)};this.$element.trigger(n),n.isDefaultPrevented()||(this.transitioning=1,this.$element[e]("in"),t.support.transition&&this.$element.hasClass("collapse")?this.$element.one(t.support.transition.end,o):o())},toggle:function(){this[this.$element.hasClass("in")?"hide":"show"]()}},t.fn.collapse=function(n){return this.each(function(){var i=t(this),r=i.data("collapse"),o="object"==typeof n&&n;r||i.data("collapse",r=new e(this,o)),"string"==typeof n&&r[n]()})},t.fn.collapse.defaults={toggle:!0},t.fn.collapse.Constructor=e,t(document).on("click.collapse.data-api","[data-toggle=collapse]",function(e){var n,i=t(this),r=i.attr("data-target")||e.preventDefault()||(n=i.attr("href"))&&n.replace(/.*(?=#[^\s]+$)/,""),o=t(r).data("collapse")?"toggle":i.data();i[t(r).hasClass("in")?"addClass":"removeClass"]("collapsed"),t(r).collapse(o)})}(window.jQuery),/* ==========================================================
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
!function(t){"use strict";var e=function(e,n){this.$element=t(e),this.options=n,this.options.slide&&this.slide(this.options.slide),"hover"==this.options.pause&&this.$element.on("mouseenter",t.proxy(this.pause,this)).on("mouseleave",t.proxy(this.cycle,this))};e.prototype={cycle:function(e){return e||(this.paused=!1),this.options.interval&&!this.paused&&(this.interval=setInterval(t.proxy(this.next,this),this.options.interval)),this},to:function(e){var n=this.$element.find(".item.active"),i=n.parent().children(),r=i.index(n),o=this;if(!(e>i.length-1||0>e))return this.sliding?this.$element.one("slid",function(){o.to(e)}):r==e?this.pause().cycle():this.slide(e>r?"next":"prev",t(i[e]))},pause:function(e){return e||(this.paused=!0),this.$element.find(".next, .prev").length&&t.support.transition.end&&(this.$element.trigger(t.support.transition.end),this.cycle()),clearInterval(this.interval),this.interval=null,this},next:function(){return this.sliding?void 0:this.slide("next")},prev:function(){return this.sliding?void 0:this.slide("prev")},slide:function(e,n){var i,r=this.$element.find(".item.active"),o=n||r[e](),s=this.interval,a="next"==e?"left":"right",l="next"==e?"first":"last",u=this;if(this.sliding=!0,s&&this.pause(),o=o.length?o:this.$element.find(".item")[l](),i=t.Event("slide",{relatedTarget:o[0]}),!o.hasClass("active")){if(t.support.transition&&this.$element.hasClass("slide")){if(this.$element.trigger(i),i.isDefaultPrevented())return;o.addClass(e),o[0].offsetWidth,r.addClass(a),o.addClass(a),this.$element.one(t.support.transition.end,function(){o.removeClass([e,a].join(" ")).addClass("active"),r.removeClass(["active",a].join(" ")),u.sliding=!1,setTimeout(function(){u.$element.trigger("slid")},0)})}else{if(this.$element.trigger(i),i.isDefaultPrevented())return;r.removeClass("active"),o.addClass("active"),this.sliding=!1,this.$element.trigger("slid")}return s&&this.cycle(),this}}},t.fn.carousel=function(n){return this.each(function(){var i=t(this),r=i.data("carousel"),o=t.extend({},t.fn.carousel.defaults,"object"==typeof n&&n),s="string"==typeof n?n:o.slide;r||i.data("carousel",r=new e(this,o)),"number"==typeof n?r.to(n):s?r[s]():o.interval&&r.cycle()})},t.fn.carousel.defaults={interval:5e3,pause:"hover"},t.fn.carousel.Constructor=e,t(document).on("click.carousel.data-api","[data-slide]",function(e){var n,i=t(this),r=t(i.attr("data-target")||(n=i.attr("href"))&&n.replace(/.*(?=#[^\s]+$)/,"")),o=t.extend({},r.data(),i.data());r.carousel(o),e.preventDefault()})}(window.jQuery),/* =============================================================
 * bootstrap-typeahead.js v2.2.1
 * http://twitter.github.com/bootstrap/javascript.html#typeahead
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
!function(t){"use strict";var e=function(e,n){this.$element=t(e),this.options=t.extend({},t.fn.typeahead.defaults,n),this.matcher=this.options.matcher||this.matcher,this.sorter=this.options.sorter||this.sorter,this.highlighter=this.options.highlighter||this.highlighter,this.updater=this.options.updater||this.updater,this.$menu=t(this.options.menu).appendTo("body"),this.source=this.options.source,this.shown=!1,this.listen()};e.prototype={constructor:e,select:function(){var t=this.$menu.find(".active").attr("data-value");return this.$element.val(this.updater(t)).change(),this.hide()},updater:function(t){return t},show:function(){var e=t.extend({},this.$element.offset(),{height:this.$element[0].offsetHeight});return this.$menu.css({top:e.top+e.height,left:e.left}),this.$menu.show(),this.shown=!0,this},hide:function(){return this.$menu.hide(),this.shown=!1,this},lookup:function(){var e;return this.query=this.$element.val(),!this.query||this.query.length<this.options.minLength?this.shown?this.hide():this:(e=t.isFunction(this.source)?this.source(this.query,t.proxy(this.process,this)):this.source,e?this.process(e):this)},process:function(e){var n=this;return e=t.grep(e,function(t){return n.matcher(t)}),e=this.sorter(e),e.length?this.render(e.slice(0,this.options.items)).show():this.shown?this.hide():this},matcher:function(t){return~t.toLowerCase().indexOf(this.query.toLowerCase())},sorter:function(t){for(var e,n=[],i=[],r=[];e=t.shift();)e.toLowerCase().indexOf(this.query.toLowerCase())?~e.indexOf(this.query)?i.push(e):r.push(e):n.push(e);return n.concat(i,r)},highlighter:function(t){var e=this.query.replace(/[\-\[\]{}()*+?.,\\\^$|#\s]/g,"\\$&");return t.replace(new RegExp("("+e+")","ig"),function(t,e){return"<strong>"+e+"</strong>"})},render:function(e){var n=this;return e=t(e).map(function(e,i){return e=t(n.options.item).attr("data-value",i),e.find("a").html(n.highlighter(i)),e[0]}),e.first().addClass("active"),this.$menu.html(e),this},next:function(){var e=this.$menu.find(".active").removeClass("active"),n=e.next();n.length||(n=t(this.$menu.find("li")[0])),n.addClass("active")},prev:function(){var t=this.$menu.find(".active").removeClass("active"),e=t.prev();e.length||(e=this.$menu.find("li").last()),e.addClass("active")},listen:function(){this.$element.on("blur",t.proxy(this.blur,this)).on("keypress",t.proxy(this.keypress,this)).on("keyup",t.proxy(this.keyup,this)),this.eventSupported("keydown")&&this.$element.on("keydown",t.proxy(this.keydown,this)),this.$menu.on("click",t.proxy(this.click,this)).on("mouseenter","li",t.proxy(this.mouseenter,this))},eventSupported:function(t){var e=t in this.$element;return e||(this.$element.setAttribute(t,"return;"),e="function"==typeof this.$element[t]),e},move:function(t){if(this.shown){switch(t.keyCode){case 9:case 13:case 27:t.preventDefault();break;case 38:t.preventDefault(),this.prev();break;case 40:t.preventDefault(),this.next()}t.stopPropagation()}},keydown:function(e){this.suppressKeyPressRepeat=!~t.inArray(e.keyCode,[40,38,9,13,27]),this.move(e)},keypress:function(t){this.suppressKeyPressRepeat||this.move(t)},keyup:function(t){switch(t.keyCode){case 40:case 38:case 16:case 17:case 18:break;case 9:case 13:if(!this.shown)return;this.select();break;case 27:if(!this.shown)return;this.hide();break;default:this.lookup()}t.stopPropagation(),t.preventDefault()},blur:function(){var t=this;setTimeout(function(){t.hide()},150)},click:function(t){t.stopPropagation(),t.preventDefault(),this.select()},mouseenter:function(e){this.$menu.find(".active").removeClass("active"),t(e.currentTarget).addClass("active")}},t.fn.typeahead=function(n){return this.each(function(){var i=t(this),r=i.data("typeahead"),o="object"==typeof n&&n;r||i.data("typeahead",r=new e(this,o)),"string"==typeof n&&r[n]()})},t.fn.typeahead.defaults={source:[],items:8,menu:'<ul class="typeahead dropdown-menu"></ul>',item:'<li><a href="#"></a></li>',minLength:1},t.fn.typeahead.Constructor=e,t(document).on("focus.typeahead.data-api",'[data-provide="typeahead"]',function(e){var n=t(this);n.data("typeahead")||(e.preventDefault(),n.typeahead(n.data()))})}(window.jQuery),/* ==========================================================
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