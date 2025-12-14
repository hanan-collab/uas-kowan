document.getElementById('registerButton').addEventListener('click', register);
document.getElementById('loginButton').addEventListener('click', login);

function showMessage(message, isError = false) {
    const messageElement = document.getElementById('message');
    messageElement.textContent = message;
    messageElement.style.color = isError ? 'red' : 'green';
}

async function register() {
    const username = document.getElementById('username').value;

    try {
        const response = await fetch('/api/passkey/registerStart', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username: username })
        });

        if (!response.ok) {
            throw new Error('User already exists or failed to get registration options from server');
        }

        const options = await response.json();
        const attestationResponse = await SimpleWebAuthnBrowser.startRegistration(options);

        const verificationResponse = await fetch('/api/passkey/registerFinish', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(attestationResponse)
        });

        if (verificationResponse.ok) {
            showMessage('Registration successful');
        } else {
            showMessage('Registration failed', true);
        }
    } catch (error) {
        showMessage('Error: ' + error.message, true);
    }
}

async function login() {
    const username = document.getElementById('username').value;

    try {
        const response = await fetch('/api/passkey/loginStart', {
            method: 'POST', headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ username: username })
        });

        if (!response.ok) {
            throw new Error('Failed to get login options from server');
        }

        const options = await response.json();
        const assertionResponse = await SimpleWebAuthnBrowser.startAuthentication(options);

        const verificationResponse = await fetch('/api/passkey/loginFinish', {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify(assertionResponse)
        });

        if (verificationResponse.ok) {
            const data = await verificationResponse.json();

            // Save token to localStorage
            localStorage.setItem('authToken', data.token);
            localStorage.setItem('username', data.user.username);

            showMessage('Login successful. Redirecting...', false);

            // Redirect ke halaman circle calculator setelah 1 detik
            setTimeout(() => {
                window.location.href = '/circle.html';
            }, 1000);
        } else {
            showMessage('Login failed', true);
        }
    } catch (error) {
        showMessage('Error: ' + error.message, true);
    }
}