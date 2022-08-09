<template>
	<div class="code-container relative">
		<prism-editor
			:class="{
				'code-editor': true,
				'rounded-md': true,
				'overflow-auto': true,
				blurred: error,
			}"
			v-model="code"
			:highlight="highlighter"
			line-numbers
			readonly
		></prism-editor>
		<div v-if="error" class="absolute p-4 w-full top-1/2 transform -translate-y-1/2">
			<div class="bg-red-500 bg-opacity-50 rounded-md p-4 max-h-56 overflow-auto">
				<p class="mb-2">❌ Shell Script Issue.</p>
				<pre class="p-4 text-sm text-gray-400 overflow-auto">{{ error }}</pre>
			</div>
		</div>
	</div>
</template>

<script lang="ts">
// import Prism Editor
import { PrismEditor } from 'vue-prism-editor';

import { highlight, languages } from 'prismjs';
import 'prismjs/components/prism-perl';
import 'prism-themes/themes/prism-material-dark.css';

import { defineComponent } from 'vue';

export default defineComponent({
	components: {
		PrismEditor,
	},
	props: {
		plOutput: String,
		errMessage: String,
	},
	data() {
		return {
			code: this.plOutput,
			error: this.errMessage,
		};
	},
	methods: {
		highlighter(code: string) {
			return highlight(code, languages.perl, 'perl');
		},
	},
	watch: {
		plOutput(newPlOutput) {
			this.code = newPlOutput;
		},
		errMessage(newErrMessage) {
			this.error = newErrMessage;
		},
	},
});
</script>

<style scoped lang="scss">
.code-container {
	width: 500px;
	animation: fadeIn 2s ease-out 0s;
}

.code-editor {
	background: #262030;
	box-shadow: rgba(0, 0, 0, 0.24) 0px 3px 8px;
	color: #ccc;

	font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
	font-size: 14px;
	line-height: 1.5;
	padding: 5px;
	height: 500px !important;
	max-height: 500px !important;
}
</style>

<style>
.blurred pre {
	opacity: 0.2 !important;
	text-shadow: 0 0 5px rgba(255, 255, 255, 0.5) !important;
}
</style>
