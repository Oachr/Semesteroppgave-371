!function($){var e=function(e,t){this.init(e,t)};e.prototype={constructor:e,init:function(e,t){var o=this.$element=$(e);this.options=$.extend({},$.fn.checkbox.defaults,t),o.before(this.options.template),this.setState()},setState:function(){var e=this.$element,t=e.closest(".checkbox");e.prop("disabled")&&t.addClass("disabled"),e.prop("checked")&&t.addClass("checked")},toggle:function(){var e="checked",t=this.$element,o=t.closest(".checkbox"),a=t.prop(e),c=$.Event("toggle");0==t.prop("disabled")&&(o.toggleClass(e)&&a?t.removeAttr(e):t.prop(e,e),t.trigger(c).trigger("change"))},setCheck:function(e){var t="disabled",o="checked",a=this.$element,c=a.closest(".checkbox"),s="check"==e,n=$.Event(e);c[s?"addClass":"removeClass"](o)&&s?a.prop(o,o):a.removeAttr(o),a.trigger(n).trigger("change")}};var t=$.fn.checkbox;$.fn.checkbox=function(t){return this.each(function(){var o=$(this),a=o.data("checkbox"),c=$.extend({},$.fn.checkbox.defaults,o.data(),"object"==typeof t&&t);a||o.data("checkbox",a=new e(this,c)),"toggle"==t&&a.toggle(),"check"==t||"uncheck"==t?a.setCheck(t):t&&a.setState()})},$.fn.checkbox.defaults={template:'<span class="icons"><span class="first-icon fa fa-square fa-base"></span><span class="second-icon fa fa-check-square fa-base"></span></span>'},$.fn.checkbox.noConflict=function(){return $.fn.checkbox=t,this},$(document).on("click.checkbox.data-api","[data-toggle^=checkbox], .checkbox",function(e){var t=$(e.target);"A"!=e.target.tagName&&(e&&e.preventDefault()&&e.stopPropagation(),t.hasClass("checkbox")||(t=t.closest(".checkbox")),t.find(":checkbox").checkbox("toggle"))}),$(function(){$('input[type="checkbox"]').each(function(){var e=$(this);e.checkbox()})})}(window.jQuery),!function($){var e=function(e,t){this.init(e,t)};e.prototype={constructor:e,init:function(e,t){var o=this.$element=$(e);this.options=$.extend({},$.fn.radio.defaults,t),o.before(this.options.template),this.setState()},setState:function(){var e=this.$element,t=e.closest(".radio");e.prop("disabled")&&t.addClass("disabled"),e.prop("checked")&&t.addClass("checked")},toggle:function(){var e="disabled",t="checked",o=this.$element,a=o.prop(t),c=o.closest(".radio"),s=o.closest("form").length?o.closest("form"):o.closest("body"),n=s.find(':radio[name="'+o.attr("name")+'"]'),i=$.Event("toggle");0==o.prop(e)&&(n.not(o).each(function(){var o=$(this),a=$(this).closest(".radio");0==o.prop(e)&&a.removeClass(t)&&o.removeAttr(t).trigger("change")}),0==a&&c.addClass(t)&&o.prop(t,!0),o.trigger(i),a!==o.prop(t)&&o.trigger("change"))},setCheck:function(e){var t="checked",o=this.$element,a=o.closest(".radio"),c="check"==e,s=o.prop(t),n=o.closest("form").length?o.closest("form"):o.closest("body"),i=n.find(':radio[name="'+o.attr("name")+'"]'),r=$.Event(e);i.not(o).each(function(){var e=$(this),o=$(this).closest(".radio");o.removeClass(t)&&e.removeAttr(t)}),a[c?"addClass":"removeClass"](t)&&c?o.prop(t,t):o.removeAttr(t),o.trigger(r),s!==o.prop(t)&&o.trigger("change")}};var t=$.fn.radio;$.fn.radio=function(t){return this.each(function(){var o=$(this),a=o.data("radio"),c=$.extend({},$.fn.radio.defaults,o.data(),"object"==typeof t&&t);a||o.data("radio",a=new e(this,c)),"toggle"==t&&a.toggle(),"check"==t||"uncheck"==t?a.setCheck(t):t&&a.setState()})},$.fn.radio.defaults={template:'<span class="icons"><span class="first-icon fa fa-circle-o fa-base"></span><span class="second-icon fa fa-dot-circle-o fa-base"></span></span>'},$.fn.radio.noConflict=function(){return $.fn.radio=t,this},$(document).on("click.radio.data-api","[data-toggle^=radio], .radio",function(e){var t=$(e.target);e&&e.preventDefault()&&e.stopPropagation(),t.hasClass("radio")||(t=t.closest(".radio")),t.find(":radio").radio("toggle")}),$(function(){$('input[type="radio"]').each(function(){var e=$(this);e.radio()})})}(window.jQuery);