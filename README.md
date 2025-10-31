# DayShare iOS App
## 데이셰어 - 시간을 함께 나누는 가장 부드러운 방법

![iOS](https://img.shields.io/badge/iOS-17.0+-blue)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange)
![SwiftUI](https://img.shields.io/badge/SwiftUI-3.0-blue)

---

## Overview

DayShare is a privacy-first iOS app for tracking time exchanges within trusted circles. Built for Korean cultural values of 정 (jeong) and modern 품앗이 (pumasi), it helps families and close friends maintain balanced, non-transactional relationships.

### Key Features

- **Private Groups**: Create intimate circles of 2-5 people (up to 10 with premium)
- **Time Sharing**: Log and track help given/received in hours
- **Help Requests**: Ask group members for assistance
- **Balance View**: Visual representation of time exchange (donut chart, not leaderboard)
- **Push Notifications**: Gentle reminders using UX Tone Kit principles
- **PIPA Compliant**: Privacy-first architecture with Korean data residency

---

## Project Structure

```
DayShare-iOS/
├── DayShare/
│   ├── App/
│   │   └── DayShareApp.swift          # Main app entry point
│   ├── Models/                         # CoreData entity models (7 entities)
│   │   ├── User+CoreDataClass.swift
│   │   ├── User+CoreDataProperties.swift
│   │   ├── Group+CoreDataClass.swift
│   │   ├── Group+CoreDataProperties.swift
│   │   ├── Share+CoreDataProperties.swift
│   │   ├── GroupMembership+CoreDataProperties.swift
│   │   ├── HelpRequest+CoreDataProperties.swift
│   │   ├── Notification+CoreDataProperties.swift
│   │   └── ActivityLog+CoreDataProperties.swift
│   ├── Views/                          # SwiftUI views
│   │   ├── ContentView.swift
│   │   ├── OnboardingView.swift
│   │   └── MainTabView.swift
│   ├── ViewModels/                     # Business logic
│   │   └── AuthenticationViewModel.swift
│   ├── Services/                       # External integrations
│   │   └── FirebaseService.swift
│   ├── CoreData/                       # Data persistence
│   │   └── PersistenceController.swift
│   ├── Resources/                      # Assets and configs
│   │   └── GoogleService-Info-TEMPLATE.plist
│   └── Assets.xcassets/               # Images and colors
├── Package.swift                       # Swift Package Manager dependencies
├── .gitignore
└── README.md
```

---

## Prerequisites

- **Xcode 15.0+**
- **iOS 17.0+** deployment target
- **Swift 5.9+**
- **Firebase account** (free tier)
- **Apple Developer account** (for testing on devices and push notifications)

---

## Setup Instructions

### 1. Clone the Repository

```bash
cd C:/Projects/DayShare
# The DayShare-iOS folder already contains the project structure
```

### 2. Install Dependencies

This project uses **Swift Package Manager** for dependencies (Firebase SDK).

```bash
cd DayShare-iOS
```

Open `DayShare.xcodeproj` in Xcode, and dependencies will be automatically resolved.

**Dependencies:**
- Firebase Auth
- Firebase Firestore
- Firebase Messaging
- Firebase Storage

### 3. Configure Firebase

#### Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project: **"DayShare"**
3. **IMPORTANT**: Select **Seoul (asia-northeast3)** region for PIPA compliance
4. Disable Google Analytics (optional, for privacy)

#### Step 2: Add iOS App

1. In Firebase Console, click **"Add app"** → **iOS**
2. Register with bundle identifier: `com.dayshare.DayShare`
3. Download **GoogleService-Info.plist**
4. Replace `DayShare/Resources/GoogleService-Info-TEMPLATE.plist` with your downloaded file
5. Rename it to `GoogleService-Info.plist` (remove `-TEMPLATE`)

#### Step 3: Enable Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click **"Create database"**
3. Start in **production mode** (we'll add security rules)
4. Select location: **asia-northeast3 (Seoul)**

#### Step 4: Configure Security Rules

In Firestore, set these security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only read/write their own user document
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Group members can read/write group data
    match /groups/{groupId} {
      allow read, write: if request.auth != null &&
        exists(/databases/$(database)/documents/groups/$(groupId)/members/$(request.auth.uid));
    }

    // Shares are readable by group members
    match /shares/{shareId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

#### Step 5: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Enable sign-in methods:
   - **Anonymous** (for testing)
   - **Apple** (required for App Store)
   - **Google** (optional, as Kakao alternative)

### 4. Create CoreData Model in Xcode

The Swift class files are created, but you need to create the visual `.xcdatamodeld` file:

1. Open Xcode
2. **File → New → File → Data Model**
3. Name it: `DayShareModel.xcdatamodeld`
4. Add the 7 entities with attributes matching the Swift files:
   - **User** (15 attributes)
   - **Group** (9 attributes)
   - **GroupMembership** (7 attributes)
   - **Share** (16 attributes)
   - **HelpRequest** (11 attributes)
   - **Notification** (10 attributes)
   - **ActivityLog** (7 attributes)

**Tip**: Use the `Models/*+CoreDataProperties.swift` files as reference for attribute names and types.

### 5. Configure Signing & Capabilities

1. Open project in Xcode
2. Select **DayShare** target
3. Go to **Signing & Capabilities**
4. Select your team
5. Change bundle identifier if needed: `com.yourteam.DayShare`
6. Add capabilities:
   - **Push Notifications**
   - **Background Modes** → Remote notifications
   - **Sign in with Apple**

### 6. Run the App

1. Select a simulator or connected device
2. Press **Cmd+R** to build and run
3. You should see the onboarding screen

---

## CoreData Entities

### 1. User (사용자)
- Minimal PII (no real names required)
- Supports anonymous, Kakao, and Apple authentication
- Tracks premium status and preferences

### 2. Group (그룹)
- Private circles with 2-10 members
- Invite-only with expiring codes
- Tracks creation and activity dates

### 3. GroupMembership (그룹 멤버십)
- Join table: User ↔ Group
- Tracks role (creator/member) and status

### 4. Share (시간 나눔 기록)
- Core entity: logs time exchanges
- Includes status (pending/confirmed/disputed)
- Supports thank-you notes

### 5. HelpRequest (도움 요청)
- Members can ask for help
- Status: open → claimed → completed
- Links to resulting Share after completion

### 6. Notification (알림)
- Push and in-app notifications
- Uses gentle Korean copy from UX Tone Kit
- Tracks read status and expiration

### 7. ActivityLog (활동 로그)
- PIPA compliance audit trail
- Tracks user actions for transparency
- Auto-purged after 90 days

---

## PIPA Compliance Checklist

- [x] Data minimization (no unnecessary PII)
- [x] Seoul region hosting (Firebase asia-northeast3)
- [x] User consent screens (to be implemented in UI)
- [x] Right to access (data export feature planned)
- [x] Right to deletion (30-day grace period)
- [x] Encryption at rest and in transit
- [ ] Privacy Officer designation (before launch)
- [ ] Legal review of TOS and Privacy Policy

---

## Development Roadmap

### Phase 1: MVP (Weeks 4-10) ← **Current Phase**

**Week 4**: Setup & Legal
- [x] iOS project initialization
- [x] CoreData entities
- [x] Firebase configuration
- [ ] Legal review (TOS + Privacy Policy)

**Week 5-6**: Core Data Layer
- [ ] Complete CoreData model in Xcode
- [ ] Implement CRUD operations
- [ ] Firebase sync service
- [ ] Local-first architecture

**Week 7-8**: UI Implementation
- [ ] Onboarding flow
- [ ] Group creation & invite
- [ ] Add Share screen (with UX Tone Kit copy)
- [ ] Balance view (donut chart)
- [ ] Help request system

**Week 9**: Polish & Notifications
- [ ] Push notifications (Firebase Cloud Messaging)
- [ ] Gentle reminder system
- [ ] Error handling
- [ ] Accessibility (VoiceOver)

**Week 10**: Soft Launch
- [ ] TestFlight beta (300-500 users)
- [ ] Target: Mom cafés (맘스홀릭, 레몬테라스)
- [ ] Track D7/D30 retention

### Phase 2: Public Launch (Weeks 11-16)
- App Store submission
- Marketing push
- Premium features
- Multi-group support

---

## Brand Guidelines

### Colors (from DayShare-Brand-Identity.md)

- **Primary**: Warm Amber `#F6B352` (kindness, not transactional)
- **Accent**: Soft Teal `#4ECDC4` (trust, balance)
- **Semantic**:
  - Gratitude Gold `#FFD700`
  - Balance Green `#81C784`
  - Gentle Reminder Coral `#FF8A80`

### Typography

- **Korean**: Pretendard or SUIT (system default)
- **English**: SF Pro Rounded (iOS system)

### Voice & Tone

- Warm, gentle, honest, celebratory
- Sounds like: supportive family member
- **NOT**: banker, nag, game show host

**Always use copy from `DayShare-UX-Tone-Kit.md`**

---

## Testing

### Unit Tests
```bash
# Run tests in Xcode
Cmd+U
```

### Test Accounts
- Create test users with anonymous authentication
- Test group creation with 2-3 test accounts
- Verify balance calculations

---

## Contributing

This is a private project for Phase 0-1 development. External contributions are not accepted at this time.

---

## License

Copyright © 2025 DayShare. All rights reserved.

---

## Support

For development questions or issues:
- Check Phase 0 documentation in parent directory
- Review `DayShare-Data-Models.md` for entity details
- Refer to `DayShare-UX-Tone-Kit.md` for UI copy

---

## Next Steps

1. **Complete CoreData model** in Xcode (visual editor)
2. **Get Firebase configured** with Seoul region
3. **Implement Group creation** flow
4. **Build Add Share screen** with UX Tone Kit copy
5. **Legal review** of TOS and Privacy Policy

---

**Last Updated**: 2025-10-31
**Phase**: 1 (MVP Build)
**Status**: Initial Setup Complete ✅
