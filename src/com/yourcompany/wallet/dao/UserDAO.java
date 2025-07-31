package com.yourcompany.wallet.dao;

import com.yourcompany.wallet.model.User;
import com.yourcompany.wallet.util.DBConnection;

import java.sql.*;

public class UserDAO {
    public java.util.List<com.yourcompany.wallet.model.Transaction> getTransactionsForUser(int userId) {
        java.util.List<com.yourcompany.wallet.model.Transaction> transactions = new java.util.ArrayList<>();
        String sql = "SELECT t.*, u.username AS related_user FROM transactions t LEFT JOIN users u ON t.related_user_id = u.id WHERE t.user_id = ? ORDER BY t.date DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            while (rs.next()) {
                com.yourcompany.wallet.model.Transaction tx = new com.yourcompany.wallet.model.Transaction();
                tx.setDate(rs.getTimestamp("date"));
                tx.setType(rs.getString("type"));
                tx.setAmount(rs.getDouble("amount"));
                tx.setStatus(rs.getString("status"));
                tx.setRelatedUser(rs.getString("related_user"));
                transactions.add(tx);
            }
        } catch (SQLException e) {
            System.out.println("getTransactionsForUser error: " + e.getMessage());
            e.printStackTrace();
        }
        return transactions;
    }

    public boolean register(User user) {
        String sql = "INSERT INTO users (username, email, password) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPassword());
            stmt.executeUpdate();
            return true;
        } catch (SQLException e) {
            System.out.println("Register Error: " + e.getMessage());
            return false;
        }
    } 

    public User login(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ? AND password = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, email);
            stmt.setString(2, password);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                User u = new User();
                u.setId(rs.getInt("id"));
                u.setUsername(rs.getString("username"));
                u.setEmail(rs.getString("email"));
                u.setBalance(rs.getDouble("balance"));
                return u;
            }
        } catch (SQLException e) {
            System.out.println("Login Error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public boolean emailExists(String email) {
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement("SELECT id FROM users WHERE email = ?")) {
            stmt.setString(1, email);
            ResultSet rs = stmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            return false;
        }
    }
    public double getUserBalance(int userId) {
        String sql = "SELECT balance FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getDouble("balance");
            }
        } catch (SQLException e) {
            System.out.println("Balance fetch error: " + e.getMessage());
            e.printStackTrace();
        }
        return 0.0;
    }

    public User getUserById(int userId) {
        String sql = "SELECT * FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, userId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                User user = new User();
                user.setId(rs.getInt("id"));
                user.setUsername(rs.getString("username"));
                user.setEmail(rs.getString("email"));
                user.setBalance(rs.getDouble("balance"));
                // Add more fields if needed
                return user;
            }
        } catch (SQLException e) {
            System.out.println("getUserById error: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }
public boolean addFunds(int userId, double amount) {
    String sql1 = "UPDATE users SET balance = balance + ? WHERE id = ?";
    String sql2 = "INSERT INTO transactions (user_id, type, amount, status) VALUES (?, 'add', ?, 'success')";

    try (Connection conn = DBConnection.getConnection()) {
        conn.setAutoCommit(false);

        try (PreparedStatement stmt1 = conn.prepareStatement(sql1);
             PreparedStatement stmt2 = conn.prepareStatement(sql2)) {

            stmt1.setDouble(1, amount);
            stmt1.setInt(2, userId);
            stmt1.executeUpdate();

            stmt2.setInt(1, userId);
            stmt2.setDouble(2, amount);
            stmt2.executeUpdate();

            conn.commit();
            return true;
        } catch (SQLException e) {
            conn.rollback();
            System.out.println("Add funds failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
        } catch (SQLException ex) {
            System.out.println("DB error: " + ex.getMessage());
            ex.printStackTrace();
            return false;
    }
}
    /**
     * Transfer funds from one user to another by username.
     * Prints simulated email notifications on success.
     * @param senderId The user ID of the sender
     * @param recipientUsername The username of the recipient
     * @param amount The amount to transfer
     * @return true if successful, false otherwise
     */
    public boolean transferFunds(int senderId, String recipientUsername, double amount) {
        String getRecipientSql = "SELECT id FROM users WHERE username = ?";
        String deductSql = "UPDATE users SET balance = balance - ? WHERE id = ? AND balance >= ?";
        String addSql = "UPDATE users SET balance = balance + ? WHERE id = ?";
        String txSql = "INSERT INTO transactions (user_id, type, amount, status, related_user_id) VALUES (?, 'transfer', ?, 'success', ?)";
        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false);
            int recipientId = -1;
            // Find recipient ID
            try (PreparedStatement getRecipientStmt = conn.prepareStatement(getRecipientSql)) {
                getRecipientStmt.setString(1, recipientUsername);
                ResultSet rs = getRecipientStmt.executeQuery();
                if (rs.next()) {
                    recipientId = rs.getInt("id");
                } else {
                    System.out.println("Recipient not found");
                    return false;
                }
            }
            // Deduct from sender
            try (PreparedStatement deductStmt = conn.prepareStatement(deductSql)) {
                deductStmt.setDouble(1, amount);
                deductStmt.setInt(2, senderId);
                deductStmt.setDouble(3, amount);
                int updated = deductStmt.executeUpdate();
                if (updated == 0) {
                    System.out.println("Insufficient funds");
                    conn.rollback();
                    return false;
                }
            }
            // Add to recipient
            try (PreparedStatement addStmt = conn.prepareStatement(addSql)) {
                addStmt.setDouble(1, amount);
                addStmt.setInt(2, recipientId);
                addStmt.executeUpdate();
            }
            // Insert transactions for both users
            try (PreparedStatement txStmt = conn.prepareStatement(txSql)) {
                // Sender transaction
                txStmt.setInt(1, senderId);
                txStmt.setDouble(2, amount);
                txStmt.setInt(3, recipientId);
                txStmt.executeUpdate();
                // Recipient transaction
                txStmt.setInt(1, recipientId);
                txStmt.setDouble(2, amount);
                txStmt.setInt(3, senderId);
                txStmt.executeUpdate();
            }
            conn.commit();
            // Simulated email notifications
            System.out.println("\uD83D\uDCE8 Simulated Email: You have sent $" + amount + " to " + recipientUsername);
            System.out.println("\uD83D\uDCE8 Simulated Email: You have received $" + amount + " from user ID: " + senderId);
            return true;
        } catch (SQLException e) {
            System.out.println("Transfer failed: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean updatePasswordByEmail(String email, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, newPassword);
            stmt.setString(2, email);
            int rows = stmt.executeUpdate();
            return rows > 0;
        } catch (SQLException e) {
            System.out.println("Password update error: " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}


