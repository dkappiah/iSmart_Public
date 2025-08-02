import React, { useState, useEffect } from 'react';
import apiClient, { getCsrfToken } from '../api'; 

function TransactionHistory() {
  const [transactions, setTransactions] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);

  useEffect(() => {
    const fetchTransactions = async () => {
      setLoading(true);
      setError(null);
      try {
        await getCsrfToken(); 
        const response = await apiClient.get('/wallet/transactions');
        setTransactions(response.data.transactions);
        console.log('Fetched transactions:', response.data.transactions);
      } catch (err) {
        console.error('Error fetching transactions:', err);
        if (err.response && err.response.data && err.response.data.message) {
          setError(err.response.data.message);
        } else {
          setError('Failed to fetch transaction history.');
        }
      } finally {
        setLoading(false);
      }
    };

    fetchTransactions();
    }, []); 

  if (loading) {
    return <div className="history-section">Loading transactions...</div>;
  }

  if (error) {
    return <div className="history-section error-message">{error}</div>;
  }

  return (
    <div className="history-section">
      {transactions.length === 0 ? (
        <p>No transactions found yet.</p>
      ) : (
        <table className="transactions">
          <thead>
            <tr>
              <th>Day</th>
              <th>Time</th>
              <th>Type</th>
              <th>Description</th>
              <th>Amount</th>
            </tr>
          </thead>
          <tbody>
            {transactions.map((transaction) => (
              <tr key={transaction.id}>
                <td>{transaction.day}</td>
                <td>{transaction.time}</td>
                <td>{transaction.type}</td>
                <td>{transaction.description}</td>
                <td
                  className={transaction.type.includes('debit') ? 'amount-sent' : 'amount-received'}
                >
                  {transaction.type.includes('debit') ? '-' : '+'}$
                  {parseFloat(transaction.amount).toFixed(2)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </div>
  );
}

export default TransactionHistory;