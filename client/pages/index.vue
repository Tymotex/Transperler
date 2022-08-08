<template>
	<div class="root-page">
		<div class="background min-h-screen w-screen fixed"></div>
		<div class="flex flex-col gap-y-10 h-screen justify-between">
			<div>
				<Header />
				<div class="flex flex-wrap justify-center flex-row gap-x-2 gap-y-2">
					<ShellEditor @transpiled="handleTranspiled" :initShSourceCode="shSourceCode" />
					<PerlOutput :plOutput="plOutput" />
				</div>
			</div>
			<Footer />
		</div>
	</div>
</template>

<script lang="ts">
import Vue from 'vue';

export default Vue.extend({
	name: 'IndexPage',
	data() {
		return {
			shSourceCode: '#!/bin/sh\n\necho "Hello world"\n',
			plOutput: '#!/usr/bin/perl\n\nprint "Hello world\\n"\n',
		};
	},
	methods: {
		handleTranspiled(shSourceCode: string, plOutput: string) {
			this.plOutput = plOutput;
			console.log('SETTING:', plOutput);
		},
	},
});
</script>

<style>
@import url('https://fonts.googleapis.com/css2?family=Quicksand:wght@300;400;700&display=swap');
/* ===== Scrollbar CSS ===== */
/* Firefox */
* {
	scrollbar-width: auto;
	scrollbar-color: #9a8989 #403535;
}

/* Chrome, Edge, and Safari */
*::-webkit-scrollbar {
	width: 6px;
}

*::-webkit-scrollbar-track {
	background: #403535;
}

*::-webkit-scrollbar-thumb {
	background-color: #9a8989;
	border-radius: 10px;
	border: 3px none #ffffff;
}
</style>
<style scoped>
.background {
	background-image: linear-gradient(to top, #09203f 0%, #2e5572 100%);
	z-index: -10;
}
.root-page {
	height: 100%;
	min-height: 100vh;
	width: 100vw;
	font-family: 'Quicksand', sans-serif;
	color: #eeeeee;
}
</style>
