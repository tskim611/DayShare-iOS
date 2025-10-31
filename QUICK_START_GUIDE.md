# Quick Start Guide - Xcode Setup
## Get DayShare Running in 30 Minutes

**Current Status**: You have 38 Swift files ready to go!
**Goal**: Build and run the app in Xcode with sample data

---

## Prerequisites Checklist

Before starting, make sure you have:
- [ ] **macOS 13.0+** (Ventura or later)
- [ ] **Xcode 15.0+** installed from App Store
- [ ] **Apple ID** (free account works)
- [ ] **This folder**: `C:\Projects\DayShare\DayShare-iOS\`

---

## Step 1: Create Xcode Project (10 minutes)

### 1.1 Open Xcode
1. Open **Xcode** from Applications
2. Click **"Create New Project"** or **File → New → Project**

### 1.2 Choose Template
1. Select **iOS** tab at the top
2. Choose **App** template
3. Click **Next**

### 1.3 Configure Project
Fill in these **exact** values:

| Field | Value |
|-------|-------|
| **Product Name** | `DayShare` |
| **Team** | Select your Apple ID |
| **Organization Identifier** | `com.dayshare` |
| **Bundle Identifier** | `com.dayshare.DayShare` |
| **Interface** | **SwiftUI** ✓ |
| **Language** | **Swift** ✓ |
| **Storage** | **Core Data** ✓ (IMPORTANT!) |
| **Include Tests** | ✓ (optional) |

Click **Next**

### 1.4 Choose Save Location
1. **DO NOT** save inside `DayShare-iOS` folder
2. Create new folder: `C:\Projects\DayShare\DayShare-Xcode`
3. Save there
4. **Uncheck** "Create Git repository" (we already have one)

---

## Step 2: Copy Files to Xcode Project (5 minutes)

### 2.1 Close Xcode Temporarily
- Close Xcode (Cmd+Q)

### 2.2 Copy All Swift Files
In Finder/File Explorer:

```
FROM: C:\Projects\DayShare\DayShare-iOS\DayShare\
TO:   C:\Projects\DayShare\DayShare-Xcode\DayShare\
```

**Copy these folders** (overwrite when asked):
- ✅ `App/` (contains DayShareApp.swift)
- ✅ `Models/` (all 8 files)
- ✅ `ViewModels/` (all 4 files)
- ✅ `Views/` (all 16 files including subfolders)
- ✅ `Services/` (all 3 files)
- ✅ `Utilities/` (all 3 files)
- ✅ `Extensions/` (all 2 files)
- ✅ `CoreData/` (PersistenceController.swift)

**Also copy**:
- ✅ `Resources/GoogleService-Info-TEMPLATE.plist`
- ✅ `Info.plist`

### 2.3 Reopen Xcode
- Open `DayShare.xcodeproj` in Xcode

---

## Step 3: Add Files to Project (5 minutes)

### 3.1 Delete Auto-Generated Files
In Xcode Project Navigator (left sidebar):
1. Right-click on `ContentView.swift` (the old one)
2. Choose **"Delete"** → **"Move to Trash"**
3. Do the same for auto-generated `DayShareApp.swift`

### 3.2 Add New Files
1. Right-click on **DayShare** folder (top level, blue icon)
2. Choose **"Add Files to DayShare"**
3. Navigate to `C:\Projects\DayShare\DayShare-Xcode\DayShare\`
4. Select **ALL** the folders you copied:
   - App
   - Models
   - ViewModels
   - Views
   - Services
   - Utilities
   - Extensions
   - CoreData
   - Resources

5. **Check these options**:
   - ✅ **"Copy items if needed"**
   - ✅ **"Create groups"** (not folder references)
   - ✅ **Add to targets: DayShare**

6. Click **"Add"**

### 3.3 Verify Files Added
In Project Navigator, you should see folder structure like:
```
DayShare
├── App
│   └── DayShareApp.swift
├── Models (8 files)
├── ViewModels (4 files)
├── Views
│   ├── Groups (3 files)
│   ├── Shares (2 files)
│   ├── Balance (1 file)
│   ├── HelpRequests (2 files)
│   ├── Notifications (1 file)
│   └── Profile (4 files)
├── Services (3 files)
├── Utilities (3 files)
├── Extensions (2 files)
├── CoreData (1 file)
└── Resources
```

---

## Step 4: Configure CoreData Model (10 minutes)

### 4.1 Open Data Model
1. In Project Navigator, find `DayShareModel.xcdatamodeld`
2. Click to open the visual editor

### 4.2 Delete Default Entity
- Select the default "Item" entity
- Press **Delete** key

### 4.3 Add 7 Entities
Click **"Add Entity"** button (bottom left) **7 times**

Rename them:
1. `Entity` → `User`
2. `Entity` → `Group`
3. `Entity` → `GroupMembership`
4. `Entity` → `Share`
5. `Entity` → `HelpRequest`
6. `Entity` → `Notification`
7. `Entity` → `ActivityLog`

### 4.4 Configure Each Entity

For **EACH** entity, set:
1. Select entity in left panel
2. In **Data Model Inspector** (right panel):
   - **Codegen**: `Manual/None` (IMPORTANT!)
   - **Module**: `Current Product Module`

### 4.5 Add Attributes (Quick Method)

Open `Models/User+CoreDataProperties.swift` in Xcode

For each `@NSManaged` property, add attribute in CoreData:

**Example for User entity**:
```swift
@NSManaged public var id: UUID?           → Add: id, UUID, Optional
@NSManaged public var nickname: String?   → Add: nickname, String, Optional
@NSManaged public var isPremium: Bool     → Add: isPremium, Boolean
```

**Quick Reference Table**:

| Entity | Attributes Count | Key Attributes |
|--------|------------------|----------------|
| User | 11 | id (UUID), nickname (String), isPremium (Bool) |
| Group | 9 | id (UUID), name (String), emoji (String) |
| GroupMembership | 7 | id (UUID), userId (UUID), groupId (UUID) |
| Share | 16 | id (UUID), duration (Double), status (String) |
| HelpRequest | 11 | id (UUID), status (String) |
| Notification | 10 | id (UUID), isRead (Bool) |
| ActivityLog | 7 | id (UUID), action (String) |

**Note**: Don't add relationships yet - attributes only for now!

### 4.6 Save Data Model
- **Cmd+S** to save

---

## Step 5: Add Firebase Dependencies (3 minutes)

### 5.1 Add Package Dependencies
1. **File → Add Package Dependencies**
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk.git`
3. Dependency Rule: **"Up to Next Major Version"** → `10.20.0`
4. Click **"Add Package"**

### 5.2 Select Products
Check these **4 packages**:
- ✅ `FirebaseAuth`
- ✅ `FirebaseFirestore`
- ✅ `FirebaseMessaging`
- ✅ `FirebaseStorage`

Click **"Add Package"**

Wait for packages to download (1-2 minutes)

---

## Step 6: Configure Build Settings (2 minutes)

### 6.1 Select Target
1. Click **DayShare** project (blue icon at top)
2. Select **DayShare** target (under TARGETS)

### 6.2 General Tab
- **Display Name**: `DayShare`
- **Bundle Identifier**: `com.dayshare.DayShare`
- **Version**: `1.0`
- **Build**: `1`
- **Minimum Deployments**: `iOS 17.0`

### 6.3 Signing & Capabilities
1. Select your **Team** (your Apple ID)
2. Check **"Automatically manage signing"**

### 6.4 Add Capabilities
Click **"+ Capability"** button:
- Add **"Push Notifications"**
- Add **"Background Modes"** → Check "Remote notifications"

---

## Step 7: Fix Import Statements (Quick Fix)

Some files may need Firebase imports added. If you see errors:

### 7.1 Open DayShareApp.swift
Add at top if missing:
```swift
import FirebaseCore
```

### 7.2 Open NotificationService.swift
Add if missing:
```swift
import UserNotifications
import FirebaseMessaging
```

---

## Step 8: First Build Attempt! 🚀

### 8.1 Select Simulator
1. Click scheme dropdown (top left, next to "DayShare")
2. Select **iPhone 15 Pro** (or any iOS 17+ simulator)

### 8.2 Build
Press **Cmd+B** to build

### 8.3 Common Errors & Fixes

#### Error: "Cannot find 'User' in scope"
**Fix**: Make sure all Model files are in target
1. Select any Model file
2. Check **File Inspector** (right panel)
3. Ensure **DayShare** is checked under "Target Membership"

#### Error: "No such module 'FirebaseCore'"
**Fix**:
1. **File → Packages → Resolve Package Versions**
2. Wait for download to complete
3. Build again (Cmd+B)

#### Error: CoreData model issues
**Fix**:
1. Open `DayShareModel.xcdatamodeld`
2. For each entity, verify **Codegen** is `Manual/None`
3. Save (Cmd+S)

---

## Step 9: Add Sample Data (Optional but Recommended)

### 9.1 Update PersistenceController.swift

Find the `preview` static var and replace with:

```swift
static var preview: PersistenceController = {
    let controller = PersistenceController(inMemory: true)
    let viewContext = controller.container.viewContext

    // Generate sample data for previews
    SampleDataGenerator.generateSampleData(in: viewContext)

    return controller
}()
```

### 9.2 For Testing in Simulator

In `DayShareApp.swift`, add this temporarily:

```swift
init() {
    // TESTING ONLY - Remove before production
    #if DEBUG
    let context = PersistenceController.shared.container.viewContext
    SampleDataGenerator.generateSampleData(in: context)
    #endif
}
```

---

## Step 10: Run the App! 🎉

### 10.1 Run
Press **Cmd+R** or click **Play** button

### 10.2 What You Should See

**First Launch**:
1. **Onboarding screen** with:
   - DayShare logo (clock icon)
   - "데이셰어" title
   - "시간을 함께 나누는 가장 부드러운 방법" tagline
   - Sign-in buttons

2. Click **"둘러보기"** (Browse) for anonymous sign-in

3. **Main app** with 4 tabs:
   - 그룹 (Groups)
   - 나눔 기록 (Share Log)
   - 도움 요청 (Help Requests)
   - 설정 (Settings)

4. If using sample data:
   - See "우리 가족" group
   - See 4 members (민수, 지은, 서준, 하은)
   - See shares and help requests

---

## Troubleshooting Guide

### Build Succeeds but Crashes on Launch

**Check Console** (Cmd+Shift+Y):
Look for errors like:
```
"The model used to open the store is incompatible with the one used to create the store"
```

**Fix**: Delete app from simulator
1. Long-press app icon in simulator
2. Click X to delete
3. Run again (Cmd+R)

### "Type 'User' has no member 'id'"

**Fix**: Make sure you're using `user.id` not `user.ID` (case sensitive)

### Firebase Errors

**Expected**: You'll see Firebase errors since we haven't configured it yet
```
"The default Firebase app has not yet been configured"
```

**That's OK!** The app will still run in offline mode.

---

## Quick Testing Checklist

Once app launches, test:
- [ ] Sign in anonymously works
- [ ] See groups tab
- [ ] Can create a group
- [ ] Can add a share
- [ ] Can view balance (donut chart)
- [ ] Can create help request
- [ ] Can view notifications
- [ ] Can edit profile
- [ ] Can export data (PIPA compliance)
- [ ] All Korean text displays correctly

---

## Next Steps After Successful Build

### Immediate
1. **Configure Firebase** (see `README.md` section)
2. **Test all features** with sample data
3. **Remove sample data generator** from production build

### This Week
1. Add real Firebase config
2. Test on physical device
3. Add app icon
4. Test push notifications

### Next Week
1. Add more test data
2. Invite beta testers
3. Prepare TestFlight build
4. Track metrics

---

## Common Questions

**Q: Do I need a paid Apple Developer account?**
A: No! Free account works for simulator and personal device testing.

**Q: Why is Xcode showing warnings?**
A: Some warnings are OK (e.g., "CRLF line endings"). Focus on errors first.

**Q: Can I use an older iOS version?**
A: Yes, but change deployment target to iOS 16.0 minimum. iOS 17 is recommended.

**Q: How do I reset all data?**
A: Delete app from simulator and run again, OR call:
```swift
SampleDataGenerator.clearAllData(in: context)
```

---

## Success Criteria

✅ Xcode project opens without errors
✅ Build succeeds (Cmd+B shows "Build Succeeded")
✅ App launches in simulator
✅ Onboarding screen appears
✅ Can sign in
✅ Main tabs visible
✅ Korean text displays correctly
✅ Sample data shows (if enabled)

---

## Getting Help

If stuck:
1. Check error message in Xcode console
2. Review this guide's troubleshooting section
3. Check `XCODE_SETUP_GUIDE.md` for details
4. Look at `README.md` for architecture info

---

## Estimated Time Breakdown

| Step | Time | Cumulative |
|------|------|------------|
| 1. Create Project | 3 min | 3 min |
| 2. Copy Files | 2 min | 5 min |
| 3. Add to Xcode | 3 min | 8 min |
| 4. CoreData Setup | 10 min | 18 min |
| 5. Firebase Packages | 3 min | 21 min |
| 6. Build Settings | 2 min | 23 min |
| 7. Fix Imports | 1 min | 24 min |
| 8. First Build | 2 min | 26 min |
| 9. Sample Data | 2 min | 28 min |
| 10. Run & Test | 2 min | **30 min** |

**Total: ~30 minutes** from start to running app!

---

## You're Almost There!

This guide gets you from **38 Swift files** → **Running iOS app** in 30 minutes.

**Follow each step carefully, and you'll have DayShare running in Xcode!**

Good luck! 화이팅! 🚀💛

---

**Last Updated**: 2025-10-31
**For**: DayShare Phase 1 MVP
**Xcode Version**: 15.0+
**iOS Target**: 17.0+
