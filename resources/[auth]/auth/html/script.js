(function () {
    const container = document.getElementById('auth-container');
    const loginForm = document.getElementById('login-form');
    const registerForm = document.getElementById('register-form');
    const messageEl = document.getElementById('message');
    const tabs = document.querySelectorAll('.tab');

    tabs.forEach(function (tab) {
        tab.addEventListener('click', function () {
            var target = this.dataset.tab;
            tabs.forEach(function (t) { t.classList.remove('active'); });
            this.classList.add('active');

            hideMessage();

            if (target === 'login') {
                loginForm.classList.remove('hidden');
                registerForm.classList.add('hidden');
            } else {
                loginForm.classList.add('hidden');
                registerForm.classList.remove('hidden');
            }
        }.bind(tab));
    });

    function showMessage(text, type) {
        messageEl.textContent = text;
        messageEl.className = 'message ' + type;
    }

    function hideMessage() {
        messageEl.className = 'message hidden';
    }

    function setSubmitDisabled(form, disabled) {
        var btn = form.querySelector('.btn-submit');
        btn.disabled = disabled;
    }

    loginForm.addEventListener('submit', function (e) {
        e.preventDefault();
        hideMessage();

        var username = document.getElementById('login-username').value.trim();
        var password = document.getElementById('login-password').value;

        if (!username || !password) {
            showMessage('Completează toate câmpurile.', 'error');
            return;
        }

        setSubmitDisabled(loginForm, true);

        fetch('https://auth/login', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username: username, password: password })
        }).then(function (res) { return res.json(); })
          .then(function (data) {
              if (data.success) {
                  showMessage(data.message, 'success');
              } else {
                  showMessage(data.message, 'error');
                  setSubmitDisabled(loginForm, false);
              }
          }).catch(function () {
              setSubmitDisabled(loginForm, false);
          });
    });

    registerForm.addEventListener('submit', function (e) {
        e.preventDefault();
        hideMessage();

        var username = document.getElementById('reg-username').value.trim();
        var email = document.getElementById('reg-email').value.trim();
        var password = document.getElementById('reg-password').value;
        var confirm = document.getElementById('reg-confirm').value;

        if (!password || !confirm) {
            showMessage('Completează câmpurile obligatorii.', 'error');
            return;
        }

        if (password !== confirm) {
            showMessage('Parolele nu se potrivesc.', 'error');
            return;
        }

        if (password.length < 6) {
            showMessage('Parola trebuie să aibă minim 6 caractere.', 'error');
            return;
        }

        if (username && username.length < 3) {
            showMessage('Username-ul trebuie să aibă minim 3 caractere.', 'error');
            return;
        }

        setSubmitDisabled(registerForm, true);

        fetch('https://auth/register', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                username: username,
                email: email || null,
                password: password,
                confirmPassword: confirm
            })
        }).then(function (res) { return res.json(); })
          .then(function (data) {
              if (data.success) {
                  showMessage(data.message, 'success');
              } else {
                  showMessage(data.message, 'error');
                  setSubmitDisabled(registerForm, false);
              }
          }).catch(function () {
              setSubmitDisabled(registerForm, false);
          });
    });

    window.addEventListener('message', function (event) {
        var data = event.data;

        if (data.action === 'show') {
            container.classList.remove('hidden');
        } else if (data.action === 'hide') {
            container.classList.add('hidden');
        }
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            e.preventDefault();
        }
    });
})();
