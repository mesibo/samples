exports.mesibo_init = function(token, app_id, listener) {
	var api = new Mesibo();

	api.addListener(listener);
	api.setAppName(app_id);
	api.setAccessToken(token);
	api.setDatabase("mesibo");
	api.start();
	return api;
}

