<template>
	<footer class="max-w-md mx-auto text-center mt-5">
		<p class="mb-2"><strong>At a glance...</strong></p>
		<ul class="quick-info-list text-gray-300">
			<li>
				Supports most of the control structures and builtin commands in the POSIX Shell
				standard.
			</li>
			<li>Aims to preserve comments and indentation in the Shell source code.</li>
			<li>
				Built with <strong>Vue.js</strong> and <strong>Nuxt.js</strong>. See the
				<a href="https://github.com/Tymotex/Transperler" class="text-blue-200 underline"
					>repository here</a
				>.
			</li>
		</ul>
		<p class="mt-8 text-gray-400">
			Liked this? See more random software engineering projects at
			<a href="https://timz.dev" class="underline" target="_blank" rel="noopener noreferrer"
				>timz.dev</a
			>! 🤓
		</p>
		<p class="font-light text-gray-600 text-sm my-2">&copy; Tim Zhang 2024</p>
	</footer>
</template>

<style scoped lang="scss">
.quick-info-list {
	text-align: left;
	list-style-type: circle;
	padding-left: 24px;
}
</style>
