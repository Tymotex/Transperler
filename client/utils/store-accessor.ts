// See: https://github.com/championswimmer/vuex-module-decorators.
import { Store } from 'vuex';
import { getModule } from 'vuex-module-decorators';
import theme from '~/store/theme';

let themeStore: theme;

function initialiseStores(store: Store<any>): void {
	themeStore = getModule(theme, store);
}

export { initialiseStores, themeStore };
