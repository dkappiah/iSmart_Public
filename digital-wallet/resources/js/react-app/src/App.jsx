import { useState, useEffect } from 'react';
import apiClient, { getCsrfToken } from './api'; 
import './css/App.css'; 
import RegisterForm from './components/RegisterForm';
import LoginForm from './components/LoginForm';
import DepositForm from './components/DepositForm';
import TransferForm from './components/TransferForm';
import TransactionHistory from './components/TransactionHistory';

function App() {
  const [user, setUser] = useState(null); 
  const [loadingUser, setLoadingUser] = useState(true); 
  const [apiMessage, setApiMessage] = useState(null); 
  const [error, setError] = useState(null); 
  const [activeFeature, setActiveFeature] = useState('deposit');


  useEffect(() => {
    const fetchWelcomeMessage = async () => {
      try {
        const response = await apiClient.get('/welcome');
        setApiMessage(response.data.message);
      } catch (err) {
        console.error("Error fetching welcome message:", err);
        setApiMessage("Error connecting to Laravel API for welcome message.");
      }
    };
    fetchWelcomeMessage();
  }, []);

  
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
        <p>Laravel API Status: <strong>{apiMessage}</strong></p>

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
            <h2>Authentication</h2>
            {error && <p className="error-message" style={{ color: 'red' }}>{error}</p>}
            <div>
                <LoginForm onAuthSuccess={handleAuthSuccess} />
                <RegisterForm onAuthSuccess={handleAuthSuccess} />
            </div>
          </div>
        )}
      </header>
    </div>
  );
}

export default App;