(function() {
	navigator.id.watch({
		loggedInEmail: currentUser,
		onlogin: function(assertion) {
			// TODO: perhaps show progress screen or something while verifying login
			console.log("login initiated");
			$.ajax({
				type: 'POST',
				url: '/auth/login',
				data: {assertion: assertion},
				success: function(res, status, xhr) { console.log("login succeeded, reloading"); window.location.reload(); },
				error: function(res, status, xhr) { console.log("failure"); console.log(res); alert("login failure " + res); }
			});
		},
		onlogout: function() {
			console.log("logout initiated");
			$.ajax({
				type: 'POST',
				url: '/auth/logout',
				success: function(res, status, xhr) { console.log("logout succeeded, reloading"); window.location.reload(); },
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
