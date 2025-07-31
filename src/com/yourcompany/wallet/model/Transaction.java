package com.yourcompany.wallet.model;

import java.sql.Timestamp;

public class Transaction {
    private int id;
    private String type;
    private double amount;
    private String status;
    private Timestamp date;
    private String relatedUser;

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public double getAmount() { return amount; }
    public void setAmount(double amount) { this.amount = amount; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getDate() { return date; }
    public void setDate(Timestamp date) { this.date = date; }

    public String getRelatedUser() { return relatedUser; }
    public void setRelatedUser(String relatedUser) { this.relatedUser = relatedUser; }
}
 