<template>
	<div class="code-container">
		<prism-editor
			class="my-editor"
			v-model="code"
			:highlight="highlighter"
			line-numbers
			readonly
		></prism-editor>
	</div>
</template>

<script lang="ts">
// import Prism Editor
import { PrismEditor } from 'vue-prism-editor';
import 'vue-prism-editor/dist/prismeditor.min.css'; // import the styles somewhere

import { highlight, languages } from 'prismjs';
import 'prismjs/components/prism-perl';
import 'prismjs/themes/prism-twilight.css';
import { defineComponent } from 'vue';

export default defineComponent({
	components: {
		PrismEditor,
	},
	props: {
		plOutput: String,
	},
	data() {
		return {
			code: this.plOutput,
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
	},
});
</script>

<style scoped>
.code-container {
	width: 500px;
}

.my-editor {
	background: #2d2d2d;
	color: #ccc;

	font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
	font-size: 14px;
	line-height: 1.5;
	padding: 5px;
}

.prism-editor__textarea:focus {
	outline: none;
}
</style>
