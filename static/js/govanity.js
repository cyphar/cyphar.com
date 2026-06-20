/*
 * Deep-link a human visitor from a vanity import URL to the exact package page
 * on pkg.go.dev, after a short delay so the "Redirecting to ..." message is
 * visible. `go get` / proxy.golang.org never run this -- they read the
 * go-import/go-source meta tags directly.
 */
(function () {
	// Let a curious human who appended ?go-get=1 still see the raw page.
	if (new URLSearchParams(location.search).has("go-get")) {
		return;
	}
	var DELAY_MS = 2000;
	// Use the import domain (cyphar.com), not location.host (www.cyphar.com).
	var target = "https://pkg.go.dev/cyphar.com" + location.pathname.replace(/\/+$/, "");

	function start() {
		// Point the on-page link at the exact destination. The static page only
		// knows the module root; this corrects it for sub-package URLs.
		var link = document.getElementById("govanity-target");
		if (link) {
			link.href = target;
			link.textContent = target.replace(/^https:\/\//, "");
		}
		setTimeout(function () { location.replace(target); }, DELAY_MS);
	}

	if (document.readyState === "loading") {
		document.addEventListener("DOMContentLoaded", start);
	} else {
		start();
	}
})();
