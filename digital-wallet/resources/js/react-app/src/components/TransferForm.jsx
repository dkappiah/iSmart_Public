import React, { useState } from 'react';
import apiClient, { getCsrfToken } from '../api';

function TransferForm({ onTransferSuccess, currentBalance }) {
  const [recipientEmail, setRecipientEmail] = useState('');
  const [amount, setAmount] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(null);
  const [successMessage, setSuccessMessage] = useState(null);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    setSuccessMessage(null);

    if (!recipientEmail || !amount || parseFloat(amount) <= 0) {
      setError('Please enter a valid recipient email and an amount greater than zero.');
      setLoading(false);
      return;
    }

    const transferAmount = parseFloat(amount);

    if (currentBalance < transferAmount) {
      setError('Insufficient funds. Your current balance is $' + currentBalance.toFixed(2) + '.');
      setLoading(false);
      return;
    }

    try {
      await getCsrfToken(); 

      const response = await apiClient.post('/wallet/transfer', {
        recipient_email: recipientEmail,
        amount: transferAmount,
      });

      setSuccessMessage(response.data.message);
      setRecipientEmail(''); 
      setAmount('');

      
      if (onTransferSuccess) {
        onTransferSuccess(response.data.new_balance);
      }

      console.log('Transfer successful:', response.data);

    } catch (err) {
      console.error('Transfer error:', err);
      if (err.response && err.response.data && err.response.data.errors) {
       
        setError(Object.values(err.response.data.errors).flat().join('\n'));
      } else if (err.response && err.response.data && err.response.data.message) {
        
        setError(err.response.data.message);
      } else {
        setError('An unexpected error occurred during transfer.');
      }
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="transfer-section">
      <h2>Transfer Funds</h2>
      {error && <p className="error-message" style={{ color: 'red', whiteSpace: 'pre-line' }}>{error}</p>}
      {successMessage && <p className="success-message" style={{ color: 'green' }}>{successMessage}</p>}

      <form onSubmit={handleSubmit} className="wallet-form">
        <div>
          <label htmlFor="recipientEmail">Recipient Email:</label>
          <input
            type="email"
            id="recipientEmail"
            value={recipientEmail}
            onChange={(e) => setRecipientEmail(e.target.value)}
            required
            disabled={loading}
          />
        </div>
        <div>
          <label htmlFor="transferAmount">Amount:</label>
          <input type="number" id="transferAmount" value={amount} onChange={(e) => setAmount(e.target.value)} required disabled={loading}/>
        </div>
        <button type="submit" disabled={loading}>
          {loading ? 'Transferring...' : 'Transfer Funds'}
        </button>
      </form>
    </div>
  );
}

export default TransferForm;