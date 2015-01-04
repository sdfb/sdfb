/* ============================================================
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
!function(t){"use strict";function e(){t(i).each(function(){n(t(this)).removeClass("open")})}function n(e){var n,i=e.attr("data-target");return i||(i=e.attr("href"),i=i&&/#/.test(i)&&i.replace(/.*(?=#[^\s]*$)/,"")),n=t(i),n.length||(n=e.parent()),n}var i="[data-toggle=dropdown]",r=function(e){var n=t(e).on("click.dropdown.data-api",this.toggle);t("html").on("click.dropdown.data-api",function(){n.parent().removeClass("open")})};r.prototype={constructor:r,toggle:function(){var i,r,o=t(this);if(!o.is(".disabled, :disabled"))return i=n(o),r=i.hasClass("open"),e(),r||(i.toggleClass("open"),o.focus()),!1},keydown:function(e){var i,r,o,s,a;if(/(38|40|27)/.test(e.keyCode)&&(i=t(this),e.preventDefault(),e.stopPropagation(),!i.is(".disabled, :disabled"))){if(o=n(i),s=o.hasClass("open"),!s||s&&27==e.keyCode)return i.click();r=t("[role=menu] li:not(.divider) a",o),r.length&&(a=r.index(r.filter(":focus")),38==e.keyCode&&a>0&&a--,40==e.keyCode&&a<r.length-1&&a++,~a||(a=0),r.eq(a).focus())}}},t.fn.dropdown=function(e){return this.each(function(){var n=t(this),i=n.data("dropdown");i||n.data("dropdown",i=new r(this)),"string"==typeof e&&i[e].call(n)})},t.fn.dropdown.Constructor=r,t(document).on("click.dropdown.data-api touchstart.dropdown.data-api",e).on("click.dropdown touchstart.dropdown.data-api",".dropdown form",function(t){t.stopPropagation()}).on("click.dropdown.data-api touchstart.dropdown.data-api",i,r.prototype.toggle).on("keydown.dropdown.data-api touchstart.dropdown.data-api",i+", [role=menu]",r.prototype.keydown)}(window.jQuery);