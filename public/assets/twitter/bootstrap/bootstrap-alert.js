/* ==========================================================
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
!function(t){"use strict";var e='[data-dismiss="alert"]',n=function(n){t(n).on("click",e,this.close)};n.prototype.close=function(e){function n(){i.trigger("closed").remove()}var i,r=t(this),o=r.attr("data-target");o||(o=r.attr("href"),o=o&&o.replace(/.*(?=#[^\s]*$)/,"")),i=t(o),e&&e.preventDefault(),i.length||(i=r.hasClass("alert")?r:r.parent()),i.trigger(e=t.Event("close")),e.isDefaultPrevented()||(i.removeClass("in"),t.support.transition&&i.hasClass("fade")?i.on(t.support.transition.end,n):n())},t.fn.alert=function(e){return this.each(function(){var i=t(this),r=i.data("alert");r||i.data("alert",r=new n(this)),"string"==typeof e&&r[e].call(i)})},t.fn.alert.Constructor=n,t(document).on("click.alert.data-api",e,n.prototype.close)}(window.jQuery);