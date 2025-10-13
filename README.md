# Trippify 🌍✈️

> A modern, full-featured travel planning and collaboration platform built with Flutter, Firebase, and Supabase.

[![Flutter](https://img.shields.io/badge/Flutter-3.7.2+-02569B?logo=flutter)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-FFCA28?logo=firebase)](https://firebase.google.com)
[![Supabase](https://img.shields.io/badge/Supabase-Latest-3ECF8E?logo=supabase)](https://supabase.com)

## 🎯 Project Overview

Trippify is a comprehensive travel planning application that enables users to create, manage, and collaborate on trips with friends. Built with clean architecture principles and modern Flutter best practices, it showcases advanced mobile development skills including real-time messaging, state management, and multi-platform support.

### Key Highlights
- 🏗️ **Clean Architecture** with separation of concerns
- 🔄 **Real-time Features** using Firebase Firestore streams
- 🎨 **Modern UI/UX** with light/dark mode support
- 🌐 **Internationalization** supporting 4 languages
- 📱 **Cross-platform** (iOS & Android)
- 🔐 **Secure** authentication and data management

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
- **Theme Toggle**: Switch between light and dark modes
- **Multi-Language**: Support for English, Spanish, German, Italian
- **Subscription Plans**: Premium tier with feature comparison
- **Responsive Design**: Adapts to different screen sizes

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

### Data Flow
1. User interacts with UI
2. ViewModel processes business logic
3. Repository handles data operations
4. Firebase/Supabase stores/retrieves data
5. UI updates reactively via Provider

## 🛠️ Technologies Used

### Core
- **Flutter 3.7.2+** - UI framework
- **Dart** - Programming language
- **Provider** - State management
- **GetIt** - Dependency injection

### Backend Services
- **Firebase Authentication** - User auth
- **Cloud Firestore** - NoSQL database
- **Supabase Storage** - Image storage
- **Firebase Streams** - Real-time updates

### UI/UX
- **flutter_screenutil** - Responsive design
- **google_fonts** - Typography
- **flutter_svg** - Vector graphics
- **lottie** - Animations
- **image_picker** - Photo selection

### Localization
- **flutter_localizations** - Framework support
- **intl** - Internationalization
- **ARB files** - Translation management

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
- ✅ Internationalization (i18n)
- ✅ Theme management
- ✅ Responsive design
- ✅ Dependency injection
- ✅ Repository pattern
- ✅ Stream-based programming
- ✅ Image handling and optimization

## 🤝 Connect

**Portfolio**: [Your Portfolio URL]  
**LinkedIn**: [Your LinkedIn]  
**GitHub**: [Your GitHub]  
**Email**: [Your Email]

---

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- Supabase for storage solutions
- Open-source community for packages

---

**Note**: This is a portfolio project demonstrating advanced Flutter development skills. For production deployment, additional security measures, testing, and optimizations would be implemented.
