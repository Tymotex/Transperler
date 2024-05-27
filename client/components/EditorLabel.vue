<template>
	<div class="editor-label rounded-t-md">{{ text }}</div>
</template>

<script lang="ts">
import { defineComponent } from 'vue';

export default defineComponent({
	props: {
		text: String,
	},
	data() {
		return {
			text: this.text,
		};
	},
});
</script>

<style scoped lang="scss">
.editor-label {
	background: #1c1c2d;
	font-family: Consolas, monospace;
	font-size: 12px;
	padding: 4px 8px 4px 8px;
}
</style>
