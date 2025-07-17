import { useState, useEffect } from 'react';
import apiClient, { getCsrfToken } from './api'; 
import RegisterForm from './components/RegisterForm';
import LoginForm from './components/LoginForm';
import DepositForm from './components/DepositForm';
import './css/App.css'; 

function App() {
  const [user, setUser] = useState(null); 
  const [loadingUser, setLoadingUser] = useState(true); 
  const [apiMessage, setApiMessage] = useState(''); 
  const [error, setError] = useState(null); 


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
              <button onClick={() => console.log('Deposit Clicked')}>Add Funds</button> {/* Placeholder for now */}
              <button onClick={() => console.log('Transfer Clicked')}>Transfer Funds</button> {/* Placeholder for now */}
              <button onClick={() => console.log('History Clicked')}>View History</button> {/* Placeholder for now */}
            </div>

        <div className="wallet-features">
            <DepositForm
                onDepositSuccess={(newBalance) => setUser(prevUser => ({ ...prevUser, balance: newBalance }))}
            />
            
        </div>
            <button onClick={handleLogout}>Logout</button>
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