<template>
	<div class="code-container relative">
		<EditorLabel text="⚪ output.pl"></EditorLabel>
		<prism-editor
			:class="{
				'code-editor': true,
				'rounded-b-md': true,
				'rounded-t-0': true,
				'overflow-auto': true,
				blurred: error || isTranspiling || isPendingTranspiling,
			}"
			v-model="code"
			:highlight="highlighter"
			line-numbers
			readonly
		></prism-editor>
		<div class="loading-spinner">
			<p v-if="isPendingTranspiling">Waiting...</p>
			<p v-if="isTranspiling">Transpiling...</p>
		</div>
		<div
			v-if="error"
			class="error-popup absolute p-4 w-full top-1/2 transform -translate-y-1/2"
		>
			<div class="bg-red-500 bg-opacity-80 rounded-md p-4 max-h-56 overflow-auto">
				<p>Shell Script Issue.</p>
				<pre class="text-sm text-gray-400 overflow-auto">{{ error }}</pre>
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
		isPendingTranspiling: Boolean,
		isTranspiling: Boolean,
	},
	data() {
		return {
			code: this.plOutput,
			error: this.errMessage,
			isTranspiling: this.isTranspiling,
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
.editor-label {
	background: #191927;
}

.code-container {
	width: 500px;
}

.code-editor {
	background: #262030;
	box-shadow: rgba(0, 0, 0, 0.24) 0px 3px 8px;
	color: #ccc;

	font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
	font-size: 14px;
	line-height: 1.5;
	padding: 5px;
	height: 720px !important;
	max-height: 720px !important;
}
.error-popup {
	pre {
		font-size: 10px;
		white-space: pre-wrap;
		line-height: normal;
	}
}
.loading-spinner {
	position: absolute;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
}
</style>

<style>
.blurred pre {
	opacity: 0.2 !important;
	text-shadow: 0 0 5px rgba(255, 255, 255, 0.5) !important;
	transition: all 100ms ease-in-out;
}
</style>
