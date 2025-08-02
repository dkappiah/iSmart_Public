// src/components/ForgotPasswordForm.jsx
import React, { useState } from 'react';

function ForgotPasswordForm({ onBackToLogin }) {
    const [email, setEmail] = useState('');
    const [message, setMessage] = useState('');
    const [error, setError] = useState('');

    const handleSubmit = async (e) => {
        e.preventDefault();
        setMessage('');
        setError('');

        try {
            const response = {
                data: { message: "Password reset link sent." }
            };
            setMessage(response.data.message);

        } catch (err) {
            console.error("Forgot password error:", err);
            setError("Failed to process request");
        }
    };

    return (
        <div>
            <form onSubmit={handleSubmit} classname="auth-form">
                <h3>Forgot Password?</h3>
                <p>Enter your email to receive a password reset link.</p>
                    <div>
                        <label>Email Address</label>
                        <input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required/>
                    </div>
                    <button type="submit">Send Reset Link</button>
            </form>
            {message && <p className="success-message">{message}</p>}
            {error && <p className="error-message" style={{color: 'red'}}>{error}</p>}

            <p>
                <button onClick={onBackToLogin} className="forgot-password-button">
                    Back to Login
                </button>
            </p>
        </div>
    );
}

export default ForgotPasswordForm;