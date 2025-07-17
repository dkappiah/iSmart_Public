import React, { useState } from 'react';
import apiClient, { getCsrfToken } from '../api';

function DepositForm({ onDepositSuccess }) {
  const [amount, setAmount] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [successMessage, setSuccessMessage] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccessMessage(null);

    if (!amount || parseFloat(amount) <= 0) {
      setError('Please enter a valid amount greater than zero.');
      setLoading(false);
      return;
    }

    try {
      await getCsrfToken(); 

      const response = await apiClient.post('/wallet/deposit', {
        amount: parseFloat(amount), 
      });

      setSuccessMessage(response.data.message);
      setAmount(''); 

      if (onDepositSuccess) {
        onDepositSuccess(response.data.new_balance);
      }

      console.log('Deposit successful:', response.data);

    } catch (err) {
      console.error('Deposit error:', err);
      if (err.response && err.response.data && err.response.data.errors) {
        
        setError(Object.values(err.response.data.errors).flat().join('\n'));
      } else if (err.response && err.response.data && err.response.data.message) {
        
        setError(err.response.data.message);
      } else {
        setError('An unexpected error occurred during deposit.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="deposit-section">
      {error && <p className="error-message" style={{ color: 'red', whiteSpace: 'pre-line' }}>{error}</p>}
      {successMessage && <p className="success-message" style={{ color: 'green' }}>{successMessage}</p>}

      <form onSubmit={handleSubmit} className="wallet-form"> 
        <div>
          <label htmlFor="depositAmount">Amount:</label>
          <input type="number" id="depositAmount" value={amount} onChange={(e) => setAmount(e.target.value)} required disabled={loading}/>
        </div>
        <button type="submit" disabled={loading}>
          {loading ? 'Adding Funds...' : 'Add Funds'}
        </button>
      </form>
    </div>
  );
}

export default DepositForm;