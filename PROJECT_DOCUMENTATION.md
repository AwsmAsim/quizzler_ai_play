# Quizzler - Flutter Quiz Application

Quizzler is a Flutter-based quiz application that allows users to create, participate in, and manage quizzes. The application integrates with Firebase for authentication and data storage, providing a seamless quiz experience.

## Project Structure

The project follows a structured architecture to maintain separation of concerns and improve maintainability. Here's an overview of the main directories and their purposes:

### Root Directory

- **android/**: Contains Android-specific configuration files and code
- **ios/**: Contains iOS-specific configuration files and code
- **assets/**: Contains application resources like images and fonts
- **lib/**: Contains the main Dart code for the application
- **test/**: Contains test files for the application
- **web/**: Contains web-specific configuration files
- **linux/**, **macos/**, **windows/**: Platform-specific code for desktop targets

### Lib Directory (Core Application Code)

The `lib` directory contains the main application code organized into several subdirectories:

#### Controllers

Controllers manage the application's business logic and state:

- **auth_controller.dart**: Manages user authentication using Firebase Auth, including email/password, Google, and Apple sign-in methods
- **contest_quiz_controller.dart**: Manages quiz contests and participation
- **generate_questions_controller.dart**: Handles the generation of quiz questions
- **theme_controller.dart**: Manages application theme settings

#### Models

Models define the data structures used throughout the application:

- **answer_result.dart**: Represents the result of an answered question
- **class_model.dart**: Defines class/group structures for organizing quizzes
- **mcq_model.dart**: Represents multiple-choice questions
- **option_model.dart**: Defines options for multiple-choice questions
- **question_model.dart**: Base model for quiz questions
- **user_model.dart**: Represents user data and preferences

#### Services

Services handle external API interactions and data processing:

- **auth_service.dart**: Provides authentication services using Firebase
- **firebase_service.dart**: Initializes and configures Firebase services
- **firestore_service.dart**: Handles Firestore database operations
- **generate_question_service.dart**: Service for generating quiz questions

#### Utils

Utility functions and helper classes:

- **constants.dart**: Application-wide constants
- **custom_snackbar.dart**: Custom snackbar implementation
- **smooth_navigator.dart**: Custom navigation utilities
- **theme/**: Theme-related utilities and configurations

#### Views

UI components and screens:

- **contest_quiz_page.dart**: Screen for participating in quiz contests
- **generated_questions_page.dart**: Displays generated questions
- **home_page.dart**: Main home screen
- **login_options_page.dart**: Displays login options (email, Google, Apple)
- **login_page.dart**: Email login screen
- **login_screen.dart**: Main login screen
- **mcq_edit_screen.dart**: Screen for editing multiple-choice questions
- **question_generator_form.dart**: Form for generating questions
- **questions_list_page.dart**: Displays a list of questions
- **questions_screen.dart**: Screen for viewing and answering questions
- **quiz_completed_screen.dart**: Shown when a quiz is completed
- **quiz_participation_mode.dart**: Screen for selecting quiz participation mode
- **signup_page.dart**: User registration screen
- **waiting_screen.dart**: Loading/waiting screen
- **widgets/**: Reusable UI components

### Assets Directory

The `assets` directory contains resources used by the application:

#### Fonts

- **Cairo/**: Cairo font family files
- **Poppins/**: Poppins font family files

#### Images

Various image assets used in the application:

- Logo images
- Authentication provider logos (Google, Apple)
- UI elements and icons

## Key Configuration Files

### pubspec.yaml

The `pubspec.yaml` file defines the project's dependencies and configuration:

- **Dependencies**: Flutter SDK, Firebase packages, UI libraries, etc.
- **Assets**: Configuration for image and font assets
- **Environment**: Dart SDK version requirements

Key dependencies include:

- **firebase_core**, **firebase_auth**, **cloud_firestore**: Firebase integration
- **get**: State management and dependency injection
- **google_sign_in**, **sign_in_with_apple**: Third-party authentication
- **google_fonts**: Typography and font management
- **syncfusion_flutter_charts**: Data visualization

## Application Features

### Authentication

The application supports multiple authentication methods:

- Email and password authentication
- Google Sign-In
- Apple Sign-In
- Anonymous authentication

### Quiz Management

Users can:

- Create quizzes with custom questions
- Generate questions based on topics and difficulty levels
- Participate in quizzes created by others
- View quiz results and statistics

### User Profile

The application maintains user profiles with:

- Display name and profile picture
- Quiz history and performance
- Personal information (optional)

## Architecture

The application follows the GetX pattern for state management and dependency injection, with a clear separation between:

- **Controllers**: Business logic and state management
- **Views**: UI components and screens
- **Models**: Data structures and entities
- **Services**: External API interactions and data processing

This architecture promotes maintainability, testability, and scalability of the application.

## Getting Started

To run the application:

1. Ensure Flutter is installed and configured
2. Clone the repository
3. Run `flutter pub get` to install dependencies
4. Configure Firebase for your environment
5. Run `flutter run` to launch the application

For more information on Flutter development, refer to the [Flutter documentation](https://docs.flutter.dev/).