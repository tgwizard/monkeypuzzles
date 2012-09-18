(function($) {
	$(document).ready(function() {
		$('form.comment').submit(function() {
			console.log('posting comment');
			var url = $(this).attr('action');
			var content = $(this).find('[name="content"]').val();
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

		$('a.like, a.unlike').click(function() {
			var tag = $(this);
			var url = $(this).attr('href');
			var action = $(this).data('action');
			console.log('posting ' + action);
			$.ajax({
				type: 'POST',
				url: url,
				data: {action: action},
				success: function(res, status, xhr) {
					if (res.status == 'ok') {
						console.log("like succeeded");

						var container = tag.closest('.likes');
						container.find('.num-likes').html(res.num_likes);
						container.find('.like').toggle(res.action != 'like');
						container.find('.unlike').toggle(res.action != 'unlike');
					} else {
						alert(res.error);
					}
				}
			});
			return false;
		});
	});
})(jQuery);
