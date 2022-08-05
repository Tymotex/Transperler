import { Module, VuexModule, Mutation } from 'vuex-module-decorators';

@Module({
	name: 'theme',
	stateFactory: true,
	namespaced: true,
})
class Theme extends VuexModule {
	DARK_MODE = 'dark-mode';
	darkMode = true;

	@Mutation
	toggleDarkMode(override: boolean | undefined) {
		this.darkMode = override !== undefined ? override : !this.darkMode;
		window.localStorage.setItem(this.DARK_MODE, this.darkMode ? 'true' : 'false');
	}

	get isDarkMode() {
		return this.darkMode;
	}
}

export default Theme;
