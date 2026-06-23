function containsVulgar(input) {
    var leetMap = {'0':'o','1':'i','3':'e','4':'a','5':'s','7':'t','@':'a','$':'s','!':'i'};
    var s = input.toLowerCase();
    s = s.replace(/[013457@$!]/g, function(c) { return leetMap[c] || c; });
    s = s.replace(/(.)\1+/g, '$1');

    var sVowel = s.replace(/[aeiou]/g, '*');

    var vulgar = [
        'pula','pule','pulei','pulan','pulica',
        'coaie','coae','coaiele',
        'pizda','pizde','pizdei','pizdulica',
        'muie','muist','muista',
        'fut','fute','futu','futui','futut','futi',
        'cacat','kkt',
        'cur','curva','curve',
        'sugipula','sugpula','sugipl','sugpl',
        'mata','mati','matii',
        'plm','mortii','mortilor',
        'sloboz','labagiu','laba','labari',
        'bulangiu','bulangi','poponar','poponari',
        'retardat','retardata','handicapat','handicapata',
        'idiot','idiota','imbecil','imbecila',
        'cretina','cretin',
        'rahat'
    ];

    for (var i = 0; i < vulgar.length; i++) {
        if (s.indexOf(vulgar[i]) !== -1) return true;
        if (vulgar[i].length >= 4) {
            var vNorm = vulgar[i].replace(/[aeiou]/g, '*');
            if (sVowel.indexOf(vNorm) !== -1) return true;
        }
    }
    return false;
}

(function () {
    var container = document.getElementById('auth-container');
    var loginForm = document.getElementById('login-form');
    var registerForm = document.getElementById('register-form');
    var messageEl = document.getElementById('message');
    var switchToRegister = document.getElementById('switch-to-register');
    var switchToLogin = document.getElementById('switch-to-login');
    var loginDisplayName = document.getElementById('login-display-name');
    var loginUsername = document.getElementById('login-username');

    var playerHasAccount = false;

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

    function showLogin(username) {
        hideMessage();
        loginForm.classList.remove('hidden');
        registerForm.classList.add('hidden');
        if (username) {
            loginDisplayName.textContent = username;
            loginUsername.value = username;
        }
    }

    function showRegister() {
        hideMessage();
        registerForm.classList.remove('hidden');
        loginForm.classList.add('hidden');
        if (playerHasAccount) {
            switchToLogin.classList.remove('hidden');
        }
    }

    switchToRegister.addEventListener('click', function () {
        showRegister();
    });

    switchToLogin.addEventListener('click', function () {
        showLogin(loginUsername.value);
    });

    loginForm.addEventListener('submit', function (e) {
        e.preventDefault();
        hideMessage();

        var username = loginUsername.value.trim();
        var password = document.getElementById('login-password').value;

        if (!username || !password) {
            showMessage('Completeaza toate campurile.', 'error');
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

        if (!username || !password || !confirm) {
            showMessage('Completeaza campurile obligatorii.', 'error');
            return;
        }

        if (username.length < 3) {
            showMessage('Username-ul trebuie sa aiba minim 3 caractere.', 'error');
            return;
        }

        if (!/^[a-zA-Z0-9_.]+$/.test(username)) {
            showMessage('Username-ul poate contine doar litere, cifre, underscore si punct.', 'error');
            return;
        }

        if (containsVulgar(username)) {
            showMessage('Username-ul contine cuvinte nepermise.', 'error');
            return;
        }

        if (password !== confirm) {
            showMessage('Parolele nu se potrivesc.', 'error');
            return;
        }

        if (password.length < 6) {
            showMessage('Parola trebuie sa aiba minim 6 caractere.', 'error');
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

    var chatContainer = document.getElementById('chat-container');
    var chatMessages = document.getElementById('chat-messages');
    var chatInput = document.getElementById('chat-input');
    var chatIsOpen = false;
    var chatHistory = [];
    var historyIndex = -1;
    var cachedInput = '';

    function capitalize(str) {
        if (!str) return str;
        return str.charAt(0).toUpperCase() + str.slice(1);
    }

    function getTimeString() {
        var now = new Date();
        var h = now.getHours().toString();
        var m = now.getMinutes().toString();
        if (h.length < 2) h = '0' + h;
        if (m.length < 2) m = '0' + m;
        return h + ':' + m;
    }

    function openChat() {
        chatIsOpen = true;
        chatContainer.classList.remove('chat-closed');
        chatInput.focus();
        setTimeout(function () { chatInput.focus(); }, 50);
        setTimeout(function () { chatInput.focus(); }, 200);
    }

    function closeChat() {
        chatIsOpen = false;
        chatContainer.classList.add('chat-closed');
        chatInput.value = '';
    }

    function addChatMessage(username, message) {
        var el = document.createElement('div');
        el.className = 'chat-msg';
        el.innerHTML = '<span class="chat-time">[' + getTimeString() + ']</span> ' +
            '<span class="chat-name">' + escapeHtml(username) + ':</span> ' +
            '<span class="chat-text">' + escapeHtml(capitalize(message)) + '</span>';
        chatMessages.appendChild(el);

        while (chatMessages.children.length > 50) {
            chatMessages.removeChild(chatMessages.firstChild);
        }

        chatMessages.scrollTop = chatMessages.scrollHeight;

        chatContainer.style.opacity = '1';
    }

    function escapeHtml(str) {
        var div = document.createElement('div');
        div.textContent = str;
        return div.innerHTML;
    }

    chatInput.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') {
            e.preventDefault();
            var msg = chatInput.value.trim();
            if (msg) {
                fetch('https://auth/chatMessage', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: msg })
                });
                chatHistory.push(msg);
                if (chatHistory.length > 50) chatHistory.shift();
            }
            chatInput.value = '';
            historyIndex = -1;
            cachedInput = '';
        } else if (e.key === 'Escape') {
            e.preventDefault();
            historyIndex = -1;
            cachedInput = '';
            closeChat();
            fetch('https://auth/chatClose', { method: 'POST' });
        } else if (e.key === 'ArrowUp') {
            e.preventDefault();
            if (chatHistory.length === 0) return;
            if (historyIndex === -1) {
                cachedInput = chatInput.value;
                historyIndex = chatHistory.length - 1;
            } else if (historyIndex > 0) {
                historyIndex--;
            }
            chatInput.value = chatHistory[historyIndex];
        } else if (e.key === 'ArrowDown') {
            e.preventDefault();
            if (historyIndex === -1) return;
            if (historyIndex < chatHistory.length - 1) {
                historyIndex++;
                chatInput.value = chatHistory[historyIndex];
            } else {
                historyIndex = -1;
                chatInput.value = cachedInput;
            }
        }
    });

    window.addEventListener('message', function (event) {
        var data = event.data;

        if (data.action === 'showLogin') {
            playerHasAccount = true;
            container.classList.remove('hidden');
            showLogin(data.username);
        } else if (data.action === 'showRegister') {
            playerHasAccount = false;
            container.classList.remove('hidden');
            showRegister();
        } else if (data.action === 'hide') {
            container.classList.add('hidden');
        } else if (data.action === 'message') {
            showMessage(data.text, data.type);
        } else if (data.action === 'chatMessage') {
            addChatMessage(data.username, data.message);
        } else if (data.action === 'chatOpen') {
            openChat();
        } else if (data.action === 'forceReload') {
            window.location.href = window.location.pathname + '?v=' + Date.now();
        }
    });

    document.addEventListener('keydown', function (e) {
        if (chatIsOpen && (e.key === 't' || e.key === 'T') && document.activeElement !== chatInput) {
            e.preventDefault();
            chatInput.focus();
            return;
        }
        if (e.key === 'Escape') {
            e.preventDefault();
            if (chatIsOpen) {
                closeChat();
                fetch('https://auth/chatClose', { method: 'POST' });
            }
        }
        if (chatIsOpen && e.key === 'Enter' && document.activeElement !== chatInput) {
            e.preventDefault();
            var msg = chatInput.value.trim();
            if (msg) {
                fetch('https://auth/chatMessage', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ message: msg })
                });
                chatHistory.push(msg);
                if (chatHistory.length > 50) chatHistory.shift();
            }
            chatInput.value = '';
            historyIndex = -1;
            cachedInput = '';
        }
    });
})();
