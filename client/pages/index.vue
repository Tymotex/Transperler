<template>
	<div class="container" v-bind:class="attachThemeClass">
		<h1>Transperler</h1>
		<div class="bg-green-200">Homepage</div>
		<DarkModeToggler />
	</div>
</template>

<script lang="ts">
import Vue from 'vue';
import DarkModeToggler from '~/components/DarkModeToggler.vue';
import { themeStore } from '~/store';

export default Vue.extend({
	name: 'IndexPage',
	components: { DarkModeToggler },
	computed: {
		isDarkMode() {
			return themeStore.isDarkMode;
		},
	},
	methods: {
		attachThemeClass() {
			if (this.isDarkMode) return 'dark';
		},
	},
});
</script>
