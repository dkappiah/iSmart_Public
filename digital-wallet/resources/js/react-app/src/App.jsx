import { useState, useEffect } from 'react';
import apiClient, { getCsrfToken } from './api'; 
import './css/App.css'; 
import RegisterForm from './components/RegisterForm';
import LoginForm from './components/LoginForm';
import ForgotPasswordForm from './components/ForgotPasswordForm';
import DepositForm from './components/DepositForm';
import TransferForm from './components/TransferForm';
import TransactionHistory from './components/TransactionHistory';

function App() {
  const [user, setUser] = useState(null); 
  const [loadingUser, setLoadingUser] = useState(true); 
  const [error, setError] = useState(null); 
  const [activeFeature, setActiveFeature] = useState('deposit');
  const [authView, setAuthView] = useState('login');

  
  useEffect(() => {
    const checkAuth = async () => {
      try {
        const response = await apiClient.get('/user'); 
        setUser(response.data);
        console.log('User already authenticated:', response.data);
      } catch (err) {
        console.log('No user authenticated or session expired:', err.response?.status);
        setUser(null);
      } finally {
        setLoadingUser(false);
      }
    };
    checkAuth();
  }, []);

  const handleAuthSuccess = (userData) => {
    setUser(userData);
    console.log('Authentication successful, user set:', userData);
    setError(null); 
  };

  const handleLogout = async () => {
    setError(null);
    try {
      await getCsrfToken(); 
      await apiClient.post('/logout');
      setUser(null); 
      console.log('Logged out successfully.');
    } catch (err) {
      console.error('Logout error:', err);
      setError('Failed to log out.');
    }
  };

  if (loadingUser) {
    return <div className="App"><p>Loading application...</p></div>;
  }

  return (
    <div className="App">
      <header className="App-header">
        <h1>Digital Wallet App</h1>
        {user ? (
          <div className="dashboard">
        <h2>Welcome, {user.name}!</h2>
        <p>Your Balance: ${user.balance ? user.balance.toFixed(2) : '0.00'}</p>

        <div className="actions">
            <button onClick={() => setActiveFeature('deposit')}>
              Add Funds
            </button>
            <button onClick={() => setActiveFeature('transfer')}>
              Transfer Funds
            </button>
            <button onClick={() => setActiveFeature('history')}>
                View History
            </button>
        </div>

        <div className="wallet-features">
            {activeFeature === 'deposit' && (
                <DepositForm
                    onDepositSuccess={(newBalance) => setUser(prevUser => ({ ...prevUser, balance: newBalance }))}
                    currentBalance={user.balance} 
                />
            )}
            {activeFeature === 'transfer' && (
                <TransferForm
                    onTransferSuccess={(newBalance) => setUser(prevUser => ({ ...prevUser, balance: newBalance }))}
                    currentBalance={user.balance} 
                />
            )}

            {activeFeature === 'history' && (
                <TransactionHistory/>
            )}
            
        </div>

        <button onClick={handleLogout} className="logout-button">Logout</button>
    </div>
) : (
          <div className="auth-section">
            {error && <p className="error-message" style={{ color: 'red' }}>{error}</p>}

            {authView === 'login' && (
              <div className="login-view">
                  <LoginForm onAuthSuccess={handleAuthSuccess} onForgotPassword={() => setAuthView('forgot-password')} />
                  <p className="form-toggle-text"> Forgot password? &nbsp;
                    <button type="button" onClick={() => setAuthView('forgot-password')} className="inline-link-button">
                        Click here!
                    </button>
                  </p>
                  <p className="form-toggle-text">
                      Don't have an account? &nbsp;
                      <button onClick={() => setAuthView('register')}>Register here.</button>
                  </p>
              </div>
            )}

            {authView === 'register' && (
              <div className="register-view"> 
                  <RegisterForm onAuthSuccess={handleAuthSuccess} />
                  <p className="form-toggle-text">
                      Already have an account? 
                      <button onClick={() => setAuthView('login')}> Login here. </button>
                  </p>
              </div>
            )}

            {authView === 'forgot-password' && (
              <ForgotPasswordForm onBackToLogin={() => setAuthView('login')} />
            )}
          </div>
        )}
      </header>
    </div>
  );
}

export default App;