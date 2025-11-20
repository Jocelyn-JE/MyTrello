# MyTrello

A Trello-like project management application built with Flutter (frontend) and Node.js/Express (backend), featuring real-time collaboration through WebSockets and a PostgreSQL database.

## ✨ Features

- **User Authentication**: Secure user registration and login with JWT tokens
- **Cross-Platform Support**:
  - Web application (Flutter Web)
  - Android mobile app (Flutter Android)
- **Real-time Updates**: WebSocket integration for live collaboration — see [WebSocket protocol](docs/websocket_protocol.md)
- **RESTful API**: Well-documented API with Swagger/OpenAPI specification
- **Database Management**: PostgreSQL with Prisma ORM
- **Containerized Deployment**: Docker and Docker Compose setup
- **Testing**: Test coverage with Jest

## 🏗️ Architecture

```text
MyTrello/
├── frontend/         # Flutter application (Web & Android)
├── server/           # Node.js/Express backend API
├── docs/             # API documentation (Swagger)
├── output/           # Built Android APK files
├── .env.example      # Example environment variables
└── docker-compose.yaml
```

### Tech Stack

**Frontend:**

- Flutter/Dart for both web and mobile

**Backend:**

- Node.js / TypeScript
- WebSocket Express
- Prisma ORM
- PostgreSQL
- JWT Authentication
- bcryptjs for password hashing

**DevOps:**

- Docker & Docker Compose
- GitHub Actions for CI/CD
- Jest for testing
- ESLint & Prettier for code quality
- Swagger/OpenAPI documentation

## 📋 Prerequisites

- **Docker & Docker Compose** (recommended)
- **Node.js** (v16 or higher)
- **Flutter SDK** (latest stable version)
- **PostgreSQL** (if running without Docker)

## 🚀 Quick Start

### Using Docker Compose (Recommended)

1. **Clone the repository:**

   ```bash
   git clone https://github.com/Jocelyn-JE/MyTrello.git
   cd MyTrello
   ```

2. **Create environment file:**

   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Start all services:**

   ```bash
   docker-compose up -d
   ```

4. **Access the application:**
   - **Web Frontend**: <http://localhost:${FRONTEND_PORT}>
   - **API Backend**: <http://localhost:${BACKEND_PORT}>
   - **API Documentation**: <http://localhost:${BACKEND_PORT}/api-docs>

### Manual Setup

#### Backend Setup

1. **Navigate to server directory:**

   ```bash
   cd server
   ```

2. **Install dependencies:**

   ```bash
   npm install
   ```

3. **Set up environment variables:**

   ```bash
   cp .env.example .env
   # Configure DATABASE_URL and other variables
   ```

4. **Run database migrations:**

   ```bash
   npx prisma migrate dev --name init
   ```

5. **Start the server:**

   ```bash
   npm start
   ```

#### Frontend Setup

1. **Navigate to frontend directory:**

   ```bash
   cd frontend
   ```

2. **Install Flutter dependencies:**

   ```bash
   flutter pub get
   ```

3. **Run the web application:**

   ```bash
   flutter run -d chrome
   ```

4. **Build Android APK:**

   ```bash
   flutter build apk --release
   ```

## 🔧 Development

### Running Tests

**Backend tests:**

```bash
cd server
npm test
```

**Frontend tests:**

```bash
cd frontend
flutter test
```

### Code Quality

**Backend linting:**

```bash
cd server
npm run lint
```

**Frontend analysis:**

```bash
cd frontend
flutter analyze
```

### Database Management

**Generate Prisma client:**

```bash
cd server
npx prisma generate
```

**Reset database:**

```bash
cd server
npx prisma migrate reset
```

## 📱 Mobile Development

### Android

The project includes Docker support for building Android APKs:

```bash
docker-compose up android-frontend
```

The built APK will be available in the `output/` directory.

### Development on Device

1. Connect your Android device or start an emulator
2. Enable USB debugging
3. Run:

   ```bash
   cd frontend
   flutter run
   ```

## 🌐 API Documentation

The API is fully documented using Swagger/OpenAPI 3.1.

Access the interactive documentation at:

```text
http://localhost:${BACKEND_PORT}/api-docs
```

## 🔒 Environment Variables

Create a `.env` file in the root directory by copying `.env.example` and filling in the required values in the example.

## 👤 Author

Jocelyn JEAN-ELIE

- GitHub: [@Jocelyn-JE](https://github.com/Jocelyn-JE)

## 🐛 Issues

If you encounter any issues, please report them on the [GitHub Issues](https://github.com/Jocelyn-JE/MyTrello/issues) page.

## 📚 Additional Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Express.js Guide](https://expressjs.com/)
- [Prisma Documentation](https://www.prisma.io/docs/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
