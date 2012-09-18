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
