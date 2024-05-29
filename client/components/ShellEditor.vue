<template>
	<div class="code-container relative">
		<EditorLabel :handleCopyButtonClick="copyToClipboard" text="🐚 input.sh"></EditorLabel>
		<prism-editor
			class="code-editor overflow-auto rounded-b-md rounded-t-0"
			v-model="code"
			:highlight="highlighter"
			line-numbers
			@input="handleTyping"
		></prism-editor>
		<!-- <div v-if="isTranspiling">TRANSPILING</div> -->
	</div>
</template>

<script lang="ts">
import { PrismEditor } from 'vue-prism-editor';
import axios from 'axios';
import { highlight, languages } from 'prismjs';
import 'vue-prism-editor/dist/prismeditor.min.css';
import 'prismjs/components/prism-bash';
import { defineComponent } from 'vue';
import { BASE_URL } from '~/constants/api-routes';

export default defineComponent({
	components: {
		PrismEditor,
	},
	props: {
		initShSourceCode: String,
		isTranspiling: Boolean,
	},
	data() {
		return { code: this.initShSourceCode, typingTimeoutRef: undefined } as {
			code: string;
			typingTimeoutRef: any;
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
			clearTimeout(this.typingTimeoutRef);
			if (!this.isPendingTranspiling) {
				this.$emit('updateIsPendingTranspiling', true);
			}
			this.typingTimeoutRef = setTimeout(() => {
				if (!this.isTranspiling) {
					this.$emit('updateIsTranspiling', true);
				}
				this.$emit('updateIsPendingTranspiling', false);
				this.shellAnalysis()
					.then(() => {
						// If the shell source code is valid, then proceed with
						// transpilation.
						this.transpile().finally(() => {
							this.$emit('updateIsTranspiling', false);
						});
					})
					.catch((err) => {
						console.log(err);
					})
					.finally(() => {});
			}, 1250);
		},
		async shellAnalysis() {
			let res: any;
			try {
				res = await axios.post(`${BASE_URL}/shell-analysis`, {
					shSourceCode: this.code,
				});
			} catch (err) {
				this.$emit('shellError', "The server isn't responding, sorry :(");
			}
			if (res.data.status !== 'success') {
				this.$emit('shellError', res.data.message);
				throw Error('Shell static analyser reported invalid code.');
			} else {
				this.$emit('shellError', '');
			}
		},
		async transpile() {
			try {
				const res = await axios.post(`${BASE_URL}/transpiler`, {
					shSourceCode: this.code,
				});
				this.$emit('transpiled', this.code, res.data.plOutput);
			} catch (err) {
				console.log(err);
			}
		},
		copyToClipboard() {
			navigator.clipboard.writeText(this.code);
		},
	},
	emits: ['transpiled', 'shellError', 'updateIsTranspiling', 'updateIsPendingTranspiling'],
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
	height: 720px !important;
	max-height: 720px !important;
}
</style>
