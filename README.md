# Trippify 🌍✈️

> A modern, full-featured travel planning and collaboration platform built with Flutter, Firebase, and Supabase.

[![Flutter](https://img.shields.io/badge/Flutter-3.29.3-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![Supabase](https://img.shields.io/badge/Supabase-Latest-3ECF8E?logo=supabase)](https://supabase.com)

## 🎯 Project Overview

Trippify is a comprehensive travel planning application that enables users to create, manage, and collaborate on trips with friends. Built with clean architecture principles and modern Flutter best practices, it showcases advanced mobile development skills including real-time messaging, state management, multi-platform support, and internationalization.

<img width="2160" height="1080" alt="trippify_3" src="https://github.com/user-attachments/assets/02d3cfa8-def0-46cd-9dc3-9ce6fe904d6c" />

### Key Highlights
- 🏗️ **Clean Architecture** with separation of concerns
- 🔄 **Real-time Features** using Firebase Firestore streams
- 🎨 **Modern UI/UX** with light/dark mode support
- 🌐 **Internationalization** supporting 4 languages with dynamic switching
- 📱 **Cross-platform** (iOS & Android)
- 🔐 **Secure** authentication and data management
- 🛡️ **Robust Error Handling** with custom exception management
- 🎯 **Advanced State Management** with Provider pattern

## ✨ Features Showcase

### 1. Trip Management System
- **Create Trips**: Rich form with image upload, dates, location, and description
- **Trip Details**: Beautiful detail page with all trip information
- **Search & Filter**: Real-time search across trips
- **CRUD Operations**: Full create, read, update, delete functionality
- **Image Upload**: Integration with Supabase Storage for trip photos

### 2. Real-Time Group Chat
- **Auto-Created Chatrooms**: Automatically created when trip is created
- **Real-Time Messaging**: Firebase Firestore streams for instant updates
- **User Identification**: Shows sender names and timestamps
- **Smart Formatting**: Time-based message formatting (time/yesterday/days ago)
- **Member Management**: Auto-add members to chat when they join trip

### 3. Social Features
- **Friend System**: Send, accept, and reject friend requests
- **User Search**: Find users by email to add as friends
- **Friend Management**: View friends list and remove friends
- **Trip Invitations**: Invite friends to join specific trips
- **Notifications**: Badge indicators for pending requests

### 4. User Experience
- **Profile Management**: Edit display name, phone, view email
- **Theme Toggle**: Switch between light and dark modes with persistence
- **Multi-Language**: Support for English, Spanish, German, Italian with runtime switching
- **Subscription Plans**: Premium tier with feature comparison
- **Responsive Design**: Adapts to different screen sizes
- **Splash Screen**: Beautiful loading experience with app initialization
- **Bottom Navigation**: Intuitive tab-based navigation system

## 🏛️ Technical Architecture

### Design Pattern
```
Presentation Layer (UI)
        ↓
ViewModels (Business Logic)
        ↓
Repositories (Data Access)
        ↓
Firebase/Supabase (Backend)
```

### State Management
- **Provider**: For global state management
- **ChangeNotifier**: Reactive state updates
- **Consumer/Selector**: Efficient widget rebuilds
- **GetIt**: Dependency injection for repositories
- **BaseViewmodel**: Common state management pattern
- **Custom Error Handling**: AppException for consistent error management

### Data Flow
1. User interacts with UI
2. ViewModel processes business logic (inherits from BaseViewmodel)
3. Repository handles data operations
4. Firebase/Supabase stores/retrieves data
5. UI updates reactively via Provider
6. Custom error handling with AppException
7. Environment configuration via .env files

## 🛠️ Technologies Used

### Core
- **Flutter 3.29.3** - UI framework
- **Dart 3.7.2** - Programming language
- **Provider 6.1.5+** - State management
- **GetIt 8.2.0** - Dependency injection

### Backend Services
- **Firebase Authentication 6.1.0** - User auth
- **Cloud Firestore 6.0.2** - NoSQL database
- **Supabase Storage 2.8.0** - Image storage
- **Firebase Streams** - Real-time updates

### UI/UX
- **flutter_screenutil 5.9.0** - Responsive design
- **google_fonts 6.3.2** - Typography
- **flutter_svg 2.2.1** - Vector graphics
- **lottie 3.3.1** - Animations
- **image_picker 1.1.2** - Photo selection

### Localization
- **flutter_localizations** - Framework support
- **intl** - Internationalization
- **ARB files** - Translation management
- **Runtime Language Switching** - Dynamic language changes

## 📊 Database Schema

### Firestore Collections

#### trips
Stores all trip information including metadata, members, and images.

#### users
User profiles with display names, emails, and preferences.

#### chatrooms
Group chat metadata linked to trips with member lists.

#### messages
Individual chat messages with timestamps and read status.

#### friendRequests
Pending, accepted, and rejected friend requests.

#### friendships
Active friendships between users.

#### tripInvitations
Invitations to join specific trips.

## 🎨 Design System

### Color Palette
- **Primary**: Deep Navy (#0F172A) - Professional, trustworthy
- **Secondary**: Vibrant Blue (#3B82F6) - Action, interaction
- **Accents**: Teal, Orange, Purple, Pink - Visual interest
- **Neutrals**: Comprehensive gray scale - Hierarchy

### UI Components
- **Cards**: Rounded corners, shadows, glassmorphism
- **Buttons**: Gradient backgrounds, clear states
- **Forms**: Consistent styling, validation feedback
- **Navigation**: Bottom nav with smooth transitions

### Responsive Design
- Uses `flutter_screenutil` for consistent sizing
- Adapts to different screen sizes
- Maintains aspect ratios
- Proper spacing and padding

## 🚀 Key Features Implementation

### Real-Time Chat
```dart
Stream<List<ChatMessageModel>> getMessages({required String chatroomId}) {
  return _firestore
      .collection('messages')
      .where('chatroomId', isEqualTo: chatroomId)
      .orderBy('timestamp', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(...).toList());
}
```

### Base Viewmodel Pattern
```dart
abstract class BaseViewmodel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
```

### Theme Management
```dart
class ThemeViewmodel extends ChangeNotifier {
  bool _isDarkMode = true;
  
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _savePreference();
    notifyListeners();
  }
}
```

### Image Upload
```dart
static Future<String> uploadImage({
  required String filePath,
  required String fileName,
}) async {
  final file = File(filePath);
  final path = 'trip-images/${DateTime.now().millisecondsSinceEpoch}_$fileName';
  await client.storage.from('trip-images').upload(path, file);
  return client.storage.from('trip-images').getPublicUrl(path);
}
```

### Custom Error Handling
```dart
class AppException implements Exception {
  final String message;
  final String? code;
  
  AppException(this.message, [this.code]);
  
  @override
  String toString() => 'AppException: $message';
}
```

## 📱 Screenshots

### Light Mode
- Clean, modern interface
- High contrast for readability
- Professional appearance

### Dark Mode
- Deep navy backgrounds
- Reduced eye strain
- Premium feel

## 🧪 Testing

### Manual Testing
- All CRUD operations verified
- Real-time features tested
- Cross-platform compatibility checked
- Theme switching validated
- Localization tested for all languages
- Error handling scenarios tested
- Form validation verified
- Image upload functionality tested

## 🔮 Future Enhancements

- [ ] Push notifications for messages and invitations
- [ ] Trip itinerary planning with timeline
- [ ] Expense splitting and tracking
- [ ] Photo gallery for trips
- [ ] Map integration for locations
- [ ] Calendar sync
- [ ] Export trip details as PDF
- [ ] Social media sharing
- [ ] Payment gateway integration for subscriptions

## 📚 Learning Outcomes

This project demonstrates proficiency in:
- ✅ Clean Architecture and SOLID principles
- ✅ State management with Provider
- ✅ Real-time data synchronization
- ✅ Firebase integration (Auth, Firestore)
- ✅ Supabase Storage implementation
- ✅ Complex UI/UX design
- ✅ Form validation and error handling
- ✅ Internationalization (i18n) with runtime switching
- ✅ Theme management with persistence
- ✅ Responsive design
- ✅ Dependency injection with GetIt
- ✅ Repository pattern
- ✅ Stream-based programming
- ✅ Image handling and optimization
- ✅ Custom exception handling
- ✅ Environment configuration
- ✅ Base class patterns for code reusability

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Supabase for storage solutions
- Open-source community for packages

---

**Note**: This is a portfolio project demonstrating advanced Flutter development skills. For production deployment, additional security measures, testing, and optimizations would be implemented.
