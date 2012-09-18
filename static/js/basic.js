if(typeof(console) === 'undefined') {
	// so that we can have console.log statements in production
	var console = {};
	console.log = console.error = console.info = console.debug = console.warn =
		console.trace = console.dir = console.dirxml = console.group =
		console.groupEnd = console.time = console.timeEnd = console.assert =
		console.profile = function() {};
}
(function($) {
	$(document).ajaxError(function(e, xhr, settings, error) {
		console.log("ajax error!");
		console.log(e);
		console.log(xhr);
		console.log(settings);
		console.log(error);
		alert('ajax error!');
	});
	$.ajaxSetup({
		beforeSend: function(xhr) {
			var token = $('meta[name="_csrf"]').attr('content');
			xhr.setRequestHeader('X_CSRF_TOKEN', token);
		}
	});
})(jQuery);
