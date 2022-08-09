export const BASE_URL =
	process.env.NODE_ENV === 'production' ? process.env.PROD_API_URL : process.env.DEV_API_URL;

if (!BASE_URL) {
	alert('No BASE_URL has been set.');
}
