<template>
	<div class="root-page">
		<div class="background min-h-screen w-screen fixed"></div>
		<div class="flex flex-col gap-y-10 h-screen justify-between">
			<div>
				<Header />
				<div class="flex flex-wrap justify-center flex-row gap-x-2 gap-y-2">
					<ShellEditor
						@transpiled="handleTranspiled"
						:initShSourceCode="shSourceCode"
						@shellError="handleShellErrors"
					/>
					<PerlOutput :plOutput="plOutput" :errMessage="errMessage" />
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
			shSourceCode: `#!/bin/sh

# → Start typing!


# Some examples of what you can transpile:
myVal=42
if test $myVal -eq 42; then
    echo 42!
fi

for i in 2 4 6; do
    echo $i
done

grep -i "hi" bar.txt

foo=1
case $foo in
    1)
        echo "Hello world"
        ;;
    2) 
        echo "Goodbye world"
        ;;
esac
`,
			plOutput: `#!/usr/bin/perl

# → Start typing!


# Some examples of what you can transpile:
$myVal = 42;
if ($myVal == 42) {
    print "42!\\n";
}

for $i (2, 4, 6) {
    print "$i\\n";
}

system("grep -i "hi" bar.txt");

$foo = 1;
if ($foo eq 1) {
    print "Hello world\\n";
}
elsif ($foo eq 2) {
    print "Goodbye world\\n";
}
`,
			errMessage: '',
		};
	},
	methods: {
		handleTranspiled(shSourceCode: string, plOutput: string) {
			this.plOutput = plOutput;
		},
		handleShellErrors(errMessage: string) {
			this.errMessage = errMessage;
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
