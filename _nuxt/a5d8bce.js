(window.webpackJsonp=window.webpackJsonp||[]).push([[4,2],{294:function(e,t,o){"use strict";o.r(t);var n=o(1),r=o(203),l=Object(n.b)({computed:{isDarkMode:function(){return r.themeStore.isDarkMode}},methods:{handleToggleDarkMode:function(){r.themeStore.toggleDarkMode()}},mounted:function(){this.handleToggleDarkMode("true"===window.localStorage.getItem(r.themeStore.DARK_MODE))},components:{}}),d=o(52),component=Object(d.a)(l,(function(){var e=this,t=e._self._c;e._self._setupProxy;return t("button",{on:{click:e.handleToggleDarkMode}},[e.isDarkMode?t("span",{staticClass:"text-gray-900 dark:text-gray-100"},[e._v("☀️")]):t("span",{staticClass:"text-gray-900 dark:text-gray-100"},[e._v("🌙")])])}),[],!1,null,null,null);t.default=component.exports},298:function(e,t,o){"use strict";o.r(t);var n=o(1),r=o(294),l=o(203),d=n.a.extend({name:"IndexPage",components:{DarkModeToggler:r.default},computed:{isDarkMode:function(){return l.themeStore.isDarkMode}},methods:{attachThemeClass:function(){if(this.isDarkMode)return"dark"}}}),c=o(52),component=Object(c.a)(d,(function(){var e=this,t=e._self._c;e._self._setupProxy;return t("div",{staticClass:"container",class:e.attachThemeClass},[t("h1",[e._v("Transperler")]),e._v(" "),t("div",{staticClass:"bg-green-200"},[e._v("Homepage")]),e._v(" "),t("DarkModeToggler")],1)}),[],!1,null,null,null);t.default=component.exports;installComponents(component,{DarkModeToggler:o(294).default})}}]);