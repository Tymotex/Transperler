<template>
	<div class="code-container relative">
		<prism-editor
			class="code-editor rounded-md overflow-auto"
			v-model="code"
			:highlight="highlighter"
			line-numbers
			@input="handleTyping"
		></prism-editor>
	</div>
</template>

<script lang="ts">
import { PrismEditor } from 'vue-prism-editor';
import axios from 'axios';
import { highlight, languages } from 'prismjs';
import 'vue-prism-editor/dist/prismeditor.min.css';
import 'prismjs/components/prism-bash';
import { defineComponent } from 'vue';

export default defineComponent({
	components: {
		PrismEditor,
	},
	props: {
		initShSourceCode: String,
	},
	data() {
		return { code: this.initShSourceCode, typingTimer: undefined } as {
			code: string;
			typingTimer: any;
		};
	},
	methods: {
		highlighter(code: string) {
			return highlight(code, languages.bash, 'bash');
		},
		handleTyping(code: string) {
			this.code = code;

			// Attempt transpilation 1 second after the user has finished
			// typing.
			// Source: https://stackoverflow.com/questions/59711470/how-to-do-submit-form-after-user-stop-typing-in-vuejs2.
			clearTimeout(this.typingTimer);
			this.typingTimer = setTimeout(() => {
				this.shellAnalysis()
					.then(() => {
						// If the shell source code is valid, then proceed with
						// transpilation.
						this.transpile();
					})
					.catch((_) => {});
			}, 1000);
		},
		async shellAnalysis() {
			const res = await axios.post('http://localhost:8080/shell-analysis', {
				shSourceCode: this.code,
			});
			if (res.data.status !== 'success') {
				this.$emit('shellError', res.data.message);
				throw Error('Shell static analyser reported invalid code.');
			} else {
				this.$emit('shellError', '');
			}
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
	emits: ['transpiled', 'shellError'],
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
	color: #ccc;
	background: #262030;
	box-shadow: rgba(0, 0, 0, 0.24) 0px 3px 8px;

	font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
	font-size: 14px;
	line-height: 1.5;
	padding: 5px;
	height: 500px !important;
	max-height: 500px !important;
}
</style>
