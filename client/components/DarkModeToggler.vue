<template>
	<button @click="handleToggleDarkMode">
		<span v-if="isDarkMode" class="text-gray-900 dark:text-gray-100">☀️</span>
		<span v-else class="text-gray-900 dark:text-gray-100">🌙</span>
	</button>
</template>

<script>
import { defineComponent } from 'vue';
import { themeStore } from '~/store';

export default defineComponent({
	computed: {
		isDarkMode() {
			return themeStore.isDarkMode;
		},
	},
	methods: {
		handleToggleDarkMode() {
			themeStore.toggleDarkMode();
		},
	},
	mounted() {
		// Initialise dark mode based on whether the user had it active in a
		// previous session.
		this.handleToggleDarkMode(window.localStorage.getItem(themeStore.DARK_MODE) === 'true');
	},
	components: {
		// Make the vue-awesome icon component available through <v-icon>.
		// 'v-icon': Icon,
	},
});
</script>
