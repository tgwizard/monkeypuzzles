(function() {
	navigator.id.watch({
		loggedInEmail: currentUser,
		onlogin: function(assertion) {
			$.ajax({
				type: 'POST',
				url: '/auth/login',
				data: {assertion: assertion},
				success: function(res, status, xhr) { window.location.reload(); },
				error: function(res, status, xhr) { console.log("failure"); console.log(res); alert("login failure " + res); }
			});
		},
		onlogout: function() {
			$.ajax({
				type: 'POST',
				url: '/auth/logout',
				success: function(res, status, xhr) { window.location.reload(); },
				error: function(res, status, xhr) { console.log("failure"); console.log(res); alert("logout failure " + res); }
			});
		}
	});

	$(document).ready(function() {
		$('a.login').click(function() {
			navigator.id.request();
			return false;
		});
		$('a.logout').click(function() {
			navigator.id.logout();
			return false;
		});
	});
})();
