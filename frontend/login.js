(function () {
    const AUTH_STORAGE_KEY = "dsms_admin_auth";
    const SESSION_HOURS = 8;

    const loginForm = document.getElementById("loginForm");
    const errorEl = document.getElementById("loginError");

    function getAuthSession() {
        const raw = localStorage.getItem(AUTH_STORAGE_KEY);
        if (!raw) {
            return null;
        }

        try {
            const session = JSON.parse(raw);
            if (!session || !session.expiresAt) {
                return null;
            }

            if (Date.now() > Number(session.expiresAt)) {
                localStorage.removeItem(AUTH_STORAGE_KEY);
                return null;
            }

            return session;
        } catch (_error) {
            localStorage.removeItem(AUTH_STORAGE_KEY);
            return null;
        }
    }

    const existingSession = getAuthSession();
    if (existingSession) {
        window.location.href = "index.html";
        return;
    }

    loginForm.addEventListener("submit", function (event) {
        event.preventDefault();

        const username = document.getElementById("username").value.trim();
        const password = document.getElementById("password").value;

        if (username !== "admin" || password !== "admin123") {
            errorEl.textContent = "Invalid username or password.";
            return;
        }

        const expiresAt = Date.now() + (SESSION_HOURS * 60 * 60 * 1000);
        localStorage.setItem(
            AUTH_STORAGE_KEY,
            JSON.stringify({
                username: username,
                loginAt: Date.now(),
                expiresAt: expiresAt
            })
        );

        window.location.href = "index.html";
    });
})();
