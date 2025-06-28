# Quizzler AI Play

Welcome to **Quizzler AI Play**, the ultimate AI-powered quiz app designed for trivia lovers and competitive players. This app is all about having fun with friends—challenge them or players worldwide in real-time multiplayer quizzes. With endless AI-generated questions, there’s always something new to test your wits.

## 📸 App Mockups

| Mockup 1 | Mockup 2 | Mockup 3 |
| :---: | :---: | :---: |
| <img src="/Users/apple/StudioProjects/quizzler_copy/mockups/mockup-1.png" width="200"> | <img src="/Users/apple/StudioProjects/quizzler_copy/mockups/mockup-2.png" width="200"> | <img src="/Users/apple/StudioProjects/quizzler_copy/mockups/mockup-3.png" width="200"> |
| Mockup 5 | Mockup 6 | Mockup 7 |
| <img src="/Users/apple/StudioProjects/quizzler_copy/mockups/mockup-5.png" width="200"> | <img src="/Users/apple/StudioProjects/quizzler_copy/mockups/mockup-6.png" width="200"> | <img src="/Users/apple/StudioProjects/quizzler_copy/mockups/mockup-7.png" width="200"> |


## ✨ Key Features

- **AI-Generated Quizzes:** Fresh and unique every time—generate your own with 100 coins reset daily.
- **Multiplayer Mode:** Take on friends or global players in exciting quiz battles.
- **Leaderboards:** Answer correctly to climb the ranks and show off your trivia skills—no coins for answers, just glory!
- **Daily Coins:** Use your 100 daily coins to create custom quizzes or explore new categories.
- **Sleek Design:** Enjoy a clean, distraction-free interface built for quiz fun.

## 🛠️ Technical Stack

This project is built with a modern and robust tech stack to ensure a high-quality, scalable, and maintainable application.

### Frontend

- **[Flutter](https://flutter.dev/):** The app is built using the Flutter framework, allowing for a single codebase that runs on both iOS and Android.
- **[GetX](https://pub.dev/packages/get):** Used for state management, dependency injection, and navigation, providing a lightweight and powerful solution for managing the app's architecture.
- **[Google Fonts](https://pub.dev/packages/google_fonts):** For beautiful and consistent typography.
- **[Syncfusion Flutter Charts](https://pub.dev/packages/syncfusion_flutter_charts):** To visualize quiz analytics and user performance.

### Backend

- **[Firebase](https://firebase.google.com/):** The backend is powered by Firebase, providing a suite of tools for authentication, database, and analytics.
  - **[Firebase Authentication](https://firebase.google.com/docs/auth):** For secure user authentication with support for email/password, Google Sign-In, and Apple Sign-In.
  - **[Cloud Firestore](https://firebase.google.com/docs/firestore):** A NoSQL database for storing user data, quiz content, and game state in real-time.
  - **[Firebase Analytics](https://firebase.google.com/docs/analytics):** To gather insights into user behavior and app performance.

### AI Integration

- **[OpenAI API](https://beta.openai.com/docs/):** The AI-powered quiz generation is handled by the OpenAI API, which creates unique and engaging questions based on user-defined parameters.

## 🏗️ Architecture

The app follows the **Model-View-Controller (MVC)** architecture to separate concerns and ensure a clean and organized codebase.

- **Model:** Represents the data and business logic of the application. Includes classes like `UserModel`, `Question`, and `MCQ`.
- **View:** The UI of the application, which is built using Flutter widgets. The views are responsible for displaying the data from the models and capturing user input.
- **Controller:** Acts as an intermediary between the Model and the View. It handles user input, updates the model, and notifies the view of any changes.

## 🚀 Getting Started

To get a local copy up and running, follow these simple steps.

### Prerequisites

- Flutter SDK: Make sure you have the Flutter SDK installed. You can find instructions [here](https://flutter.dev/docs/get-started/install).
- Firebase Project: Create a Firebase project and add your `google-services.json` (for Android) and `GoogleService-Info.plist` (for iOS) files to the appropriate directories.

### Installation

1.  Clone the repo
    ```sh
    git clone https://github.com/your_username/quizzler_ai_play.git
    ```
2.  Install packages
    ```sh
    flutter pub get
    ```
3.  Run the app
    ```sh
    flutter run
    ```

## 📂 Project Structure

The project is organized into the following directories:

- **`lib/`**: Contains the main source code for the application.
  - **`controller/`**: Contains the controllers for the MVC architecture.
  - **`model/`**: Contains the data models for the application.
  - **`view/`**: Contains the UI widgets and screens.
  - **`service/`**: Contains services for interacting with external APIs like Firebase and OpenAI.
  - **`utils/`**: Contains utility classes and constants.
- **`assets/`**: Contains static assets like images and fonts.
- **`test/`**: Contains unit and widget tests.

## 🤝 Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.