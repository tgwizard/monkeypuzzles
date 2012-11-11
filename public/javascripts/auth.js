(function($) {

	showSettings = function(options) {
		$('#modal').modal({
			remote: '/auth/settings'
		});
	};
	saveSettings = function(e) {
		modal = $(this).closest('.modal');
		console.log("will save settings");
		e.preventDefault();
		var username = modal.find('[name="username"]').val();
		var use_gravatar = modal.find('[name="use_gravatar"]').is(':checked');
		$.ajax({
			type: 'POST',
			url: '/auth/settings',
			data: {username: username, use_gravatar: use_gravatar},
			success: function(res) {
				if (res.status == 'ok') {
					window.location.reload();
				} else {
					console.log(res.error);
					alert(res.error);
				}
			}
		});
	};

	onLoginSuccess = function(res, status, xhr) {
		console.log("login succeeded");
		if (res.show_settings) {
			console.log("showing settings");
			showSettings({newUser: true});
		} else {
			console.log("reloading");
			window.location.reload();
		}
	};

	navigator.id.watch({
		loggedInUser: currentUser,
		onlogin: function(assertion) {
			// TODO: perhaps show progress screen or something while verifying login
			console.log("login initiated");
			$.ajax({
				type: 'POST',
				url: '/auth/login',
				data: {assertion: assertion},
				success: onLoginSuccess,
				error: function(res, status, xhr) { console.log("login failure"); }
			});
		},
		onlogout: function() {
			console.log("logout initiated");
			$.ajax({
				type: 'POST',
				url: '/auth/logout',
				success: function(res, status, xhr) { console.log("logout succeeded, reloading"); window.location.reload(); },
				error: function(res, status, xhr) { console.log("logout failure"); }
			});
		}
	});

	$(document).ready(function() {
		$('a.login').click(function(e) {
			navigator.id.request({siteName: 'monkeypuzzles'});
			e.preventDefault();
		});
		$('a.logout').click(function(e) {
			navigator.id.logout();
			e.preventDefault();
		});
		$('a.settings-link').click(function(e) {
			showSettings({newUser: false});
			e.preventDefault();
		});
		$("#modal .btn-primary").click(function(e) {
      $(this).closest("#modal").find("form").submit();
      e.preventDefault();
    });
    $("#modal").on('shown', function() {
      $("#modal").find("form").on('submit', saveSettings);
    });
	});
})(jQuery);
