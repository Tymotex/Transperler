<template>
	<div class="code-container relative">
		<prism-editor
			class="code-editor rounded-md overflow-auto"
			v-model="code"
			:highlight="highlighter"
			line-numbers
			@input="handleTyping"
		></prism-editor>
		<div class="absolute bottom-0 p-4 w-full">
			<div class="bg-gray-600 bg-opacity-50 rounded-md p-4">Fuck</div>
		</div>
	</div>
</template>

<script lang="ts">
import { PrismEditor } from 'vue-prism-editor';
import axios from 'axios';
import { highlight, languages } from 'prismjs';
import 'vue-prism-editor/dist/prismeditor.min.css';
import 'prismjs/components/prism-bash';
import 'prismjs/themes/prism-twilight.css';
import { defineComponent } from 'vue';

export default defineComponent({
	components: {
		PrismEditor,
	},
	props: {
		initShSourceCode: String,
	},
	data() {
		return { code: this.initShSourceCode };
	},
	methods: {
		highlighter(code: string) {
			return highlight(code, languages.bash, 'bash');
		},
		handleTyping(code: string) {
			this.code = code;
			this.transpile();
		},
		async transpile() {
			try {
				const res = await axios.post('http://localhost:8080/transpiler', {
					shSourceCode: this.code,
				});
				this.$emit('transpiled', this.code, res.data.plOutput);
			} catch (err) {
				console.log(err);
			}
		},
	},
	emits: ['transpiled'],
	mounted() {
		// Forcefully remove accessibility outline on code editor.
		document.querySelectorAll('textarea').forEach((e) => (e.style.outline = 'none'));
	},
});
</script>

<style scoped>
.code-container {
	width: 500px;
}

.code-editor {
	background: #2d2d2d;
	color: #ccc;

	font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
	font-size: 14px;
	line-height: 1.5;
	padding: 5px;
	height: 500px !important;
	max-height: 500px !important;
}
</style>
