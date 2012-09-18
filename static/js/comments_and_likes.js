(function($) {
	$(document).ready(function() {
		$('form.comment').submit(function() {
			url = $(this).attr('action');
			content = $(this).find('[name="content"]').val();
			$.ajax({
				type: 'POST',
				url: url,
				data: {content: content},
				success: function(res, status, xhr) {
					if (res.status == 'ok') {
						console.log("comment post succeeded, reloading");
						window.location.reload();
					} else {
						alert(res.error);
					}
				}
			});
			return false;
		});
	});
})(jQuery);
