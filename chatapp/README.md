# Chat Application

A real-time chat application built with modern web technologies that allows users to communicate seamlessly.

## Features

- Real-time messaging
- User authentication and authorization
- Profile management
- Group chat functionality
- Message history
- Online/offline status indicators
- File sharing capabilities
- Message notifications

## Tech Stack

### Frontend
- React.js - Frontend framework
- Material-UI - UI component library
- Socket.io-client - Real-time communication
- Axios - HTTP client
- React Router - Navigation
- Redux/Context API - State management

### Backend
- Node.js - Runtime environment
- Express.js - Web framework
- MongoDB - Database
- Socket.io - Real-time communication
- JWT - Authentication
- Bcrypt - Password hashing

## Project Structure

```
chatapp/
├── client/                 # Frontend React application
│   ├── src/
│   │   ├── components/    # Reusable UI components
│   │   ├── pages/        # Page components
│   │   ├── context/      # Context providers
│   │   ├── reducers/     # State management
│   │   └── utils/        # Utility functions
│   └── public/           # Static assets
└── server/               # Backend Node.js application
    ├── config/          # Configuration files
    ├── controllers/     # Route controllers
    ├── middleware/      # Custom middleware
    ├── models/         # Database models
    └── routes/         # API routes
```

## Getting Started

### Prerequisites
- Node.js (v14 or higher)
- MongoDB
- npm or yarn

### Installation

1. Clone the repository
```bash
git clone [repository-url]
```

2. Install backend dependencies
```bash
cd server
npm install
```

3. Install frontend dependencies
```bash
cd client
npm install
```

4. Set up environment variables
Create a `.env` file in the server directory with the following variables:
```
PORT=5000
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
```

5. Start the development servers

Backend:
```bash
cd server
npm run dev
```

Frontend:
```bash
cd client
npm start
```

## API Endpoints

### Authentication
- POST /api/auth/register - Register a new user
- POST /api/auth/login - User login
- GET /api/auth/verify - Verify user token

### Users
- GET /api/users - Get all users
- GET /api/users/:id - Get user by ID
- PUT /api/users/:id - Update user profile
- DELETE /api/users/:id - Delete user

### Messages
- GET /api/messages - Get messages
- POST /api/messages - Send message
- DELETE /api/messages/:id - Delete message

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
