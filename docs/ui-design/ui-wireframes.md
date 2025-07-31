//UI Wireframes Using Mermaid.js

graph TD
    A[Login Page] --> B[Wallet Dashboard]
    B --> C[Add Funds]
    B --> D[Transfer Funds]
    B --> E[Transaction History]
    A --> F[Register Page]
    F --> A

graph TD
    subgraph Login Page
        A[📄 login.jsp]
        A --> B[Email Input]
        A --> C[Password Input]
        A --> D[Login Button] 
        A --> E[Link to Register]
        A --> F[Mock Password Recovery]
    end


graph TD
    subgraph Register Page
        A[📄 register.jsp]
        A --> B[Username Input]
        A --> C[Email Input]
        A --> D[Password Input]
        A --> E[Confirm Password Input]
        A --> F[Register Button]
        A --> G[Back to Login]
    end


graph TD
    subgraph Wallet Dashboard
        A[📄 dashboard.jsp]
        A --> B[Header: Wallet Balance]
        A --> C[Button: Add Funds]
        A --> D[Button: Transfer Funds]
        A --> E[Button: View History]
        A --> F[Logout Button]
    end


graph TD
    subgraph Add Funds Page
        A[📄 add-funds.jsp]
        A --> B[Amount Input]
        A --> C[Add Funds Button]
        A --> D[Success/Error Message]
        A --> E[Back to Dashboard]
    end


graph TD
    subgraph Transfer Funds Page. 
        A[📄 transfer.jsp]
        A --> B[Recipient Email Input]
        A --> C[Amount Input]
        A --> D[Transfer Button]
        A --> E[Error: Insufficient Balance]
        A --> F[Back to Dashboard]
    end


graph TD
    subgraph History Page
        A[📄 history.jsp]
        A --> B[Transaction Table]
        B --> C[Columns: Date, Type, Amount, Status]
        A --> D[Back to Dashboard]
    end

