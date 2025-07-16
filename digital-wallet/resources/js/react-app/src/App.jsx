import { useState, useEffect } from 'react';
import './App.css'; 

function App() {
  const [apiMessage, setApiMessage] = useState('Loading message from Laravel...');
  const [error, setError] = useState(null);

  useEffect(() => {

    const apiUrl = 'http://digital-wallet.test/api/welcome';

    fetch(apiUrl)
      .then(response => {
        if (!response.ok) {
          throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
      })
      .then(data => {
        setApiMessage(data.message); 
      })
      .catch(error => {
        console.error("There was an error fetching the API message:", error);
        setError("Failed to load message from Laravel: " + error.message);
        setApiMessage("Error connecting to Laravel API."); 
      });
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>Digital Wallet App</h1>
        <p>
          Message from Laravel Backend:
        </p>
        {error ? (
          <p style={{ color: 'red' }}>{error}</p>
        ) : (
          <p><strong>{apiMessage}</strong></p>
        )}
        <p>
        </p>
      </header>
    </div>
  );
}

export default App;