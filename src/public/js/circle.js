// Check if user is authenticated on page load
window.addEventListener('DOMContentLoaded', () => {
    const token = localStorage.getItem('authToken');
    if (!token) {
        showCircleMessage('Please login first', true);
        setTimeout(() => {
            window.location.href = '/';
        }, 2000);
    } else {
        const username = localStorage.getItem('username');
        if (username) {
            showCircleMessage(`Welcome, ${username}!`, false);
        }
    }
});

function showCircleMessage(message, isError = false) {
    const messageElement = document.getElementById('circleMessage');
    messageElement.textContent = message;
    messageElement.style.color = isError ? 'red' : 'green';
}

async function calculateCircle() {
    const radius = document.getElementById('radius').value;
    const token = localStorage.getItem('authToken');

    if (!radius || radius <= 0) {
        showCircleMessage('Please enter a valid radius', true);
        return;
    }

    if (!token) {
        showCircleMessage('Authentication required. Redirecting to login...', true);
        setTimeout(() => {
            window.location.href = '/';
        }, 2000);
        return;
    }

    try {
        const response = await fetch('/api/passkey/circle/calculate', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({ radius: parseFloat(radius) })
        });

        if (response.status === 401) {
            showCircleMessage('Session expired. Redirecting to login...', true);
            localStorage.removeItem('authToken');
            localStorage.removeItem('username');
            setTimeout(() => {
                window.location.href = '/';
            }, 2000);
            return;
        }

        if (response.ok) {
            const result = await response.json();
            document.getElementById('circleResult').innerHTML = `
                <h3>Results:</h3>
                <p><strong>Radius:</strong> ${result.radius}</p>
                <p><strong>Area:</strong> ${result.area}</p>
                <p><strong>Circumference:</strong> ${result.circumference}</p>
            `;
            showCircleMessage('Calculation successful', false);
        } else {
            showCircleMessage('Calculation failed', true);
        }
    } catch (error) {
        showCircleMessage('Error: ' + error.message, true);
    }
}

function logout() {
    localStorage.removeItem('authToken');
    localStorage.removeItem('username');
    window.location.href = '/';
}

document.getElementById('calculateButton').addEventListener('click', calculateCircle);
document.getElementById('logoutButton').addEventListener('click', logout);