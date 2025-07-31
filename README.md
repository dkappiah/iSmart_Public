# Mini Wallet Web Application

A Java/JSP-based web wallet that simulates basic digital wallet operations: registration, login, add funds, transfer, and transaction history.

## Features

- User registration and login (with validation)
- Dashboard with wallet balance
- Add funds to wallet
- Transfer funds to other users
- View transaction history
- Responsive UI with dark mode toggle
- Session-based authentication
- MySQL database integration

## Tech Stack

- Java 17, JSP, Servlets
- MySQL (see `database/schema.sql`)
- Apache Tomcat (tested on 10.x)
- Ant for build/deployment (`build.xml`)
- JSTL, CSS, basic JS

## Project Structure

```
src/                    # Java source code (controllers, models, DAO, utils)
WebContent/             # JSPs, static assets, partials, WEB-INF
  pages/                # Main JSP pages (login, register, dashboard, etc.)
  partials/             # Shared header/footer
  css/, js/, images/    # Static assets
database/schema.sql     # MySQL schema
docs/                   # Use cases, UI wireframes
build.xml               # Ant build file
```

## Setup & Deployment

1. **Database:**

   - Import `database/schema.sql` into your MySQL server.

2. **Configure DB Connection:**

   - Edit `src/com/yourcompany/wallet/util/DBConnection.java` with your DB credentials.

3. **Build & Deploy:**

   - Run:
     ```
     ant clean
     ant compile
     ant war
     ```
   - Deploy `juma_wallet.war` to your Tomcat `webapps/` directory.

4. **Access the App:**
   - Visit `http://localhost:8080/juma_wallet/`

## Documentation

- User stories: `docs/use-cases.md`
- UI wireframes: `docs/ui-design/ui-wireframes.md`
