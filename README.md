# CGSO Construction Inventory

CGSO Construction Inventory is a warehouse inventory system for managing construction materials. It is built using **AngularJS** as a Single Page Application (SPA) within a **Ruby on Rails** application. The frontend communicates with the backend using **AJAX requests**.

## Features
- Inventory tracking of construction materials
- User authentication with **Sorcery**
- Pagination with **will_paginate**
- Reports and PDF generation using **Prawn**
- RESTful API endpoints for frontend-backend communication

## Prerequisites
Ensure you have the following installed:
- **Ruby 2.2.4** (Version specified in the Gemfile)
- **Rails 4.2.4**
- **Bundler**
- **PostgreSQL** (For production database)
- **SQLite3** (For development database)

## Samples Images
<img src="https://github.com/gitChang/cgso-construction-inventory/blob/main/app/assets/images/sample/construction-13.png" alt="Purchase Order" height="400">
![Alt text](assets/images/sample/construction-15.png)
![Alt text](assets/images/sample/construction-11.png)
![Alt text](assets/images/sample/construction-17.png)
![Alt text](assets/images/sample/construction-9.png)


## Installation

### Setup
1. **Clone the repository**
   ```bash
   git clone git@github.com:gitChang/cgso-construction-inventory.git
   cd cgso-construction-inventory
   ```

2. **Install dependencies**
   ```bash
   bundle install
   ```

3. **Set up the database**
   ```bash
   rake db:create db:migrate db:seed
   ```

4. **Start the Rails server**
   ```bash
   rails server -b 0.0.0.0 -p 3000
   ```

## Usage
- Access the application at `http://localhost:3000`.
- The frontend uses **AngularJS** and makes **AJAX requests** to the Rails backend.
- Ensure the backend is running for full functionality.

## Deployment
### Production Setup (Heroku)
1. Use **PostgreSQL** as the production database
2. **Unicorn** is used as the production web server
3. Ensure environment variables are configured for **Rails 12factor** support

## Troubleshooting
- If you encounter issues with dependencies, try running:
  ```bash
  bundle update  # For backend dependencies
  ```
- Ensure PostgreSQL is running before starting the Rails server.

## License
This project is licensed under the APACHE 2.0.

---

Let me know if you need further modifications! 🚀

