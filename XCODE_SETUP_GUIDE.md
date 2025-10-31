# Xcode Project Setup Guide
## Creating the DayShare Xcode Project

Since the project files were created programmatically, you need to create an Xcode project to use them. Follow these steps:

---

## Option 1: Create New Xcode Project (Recommended)

### Step 1: Create Project in Xcode

1. Open **Xcode**
2. **File → New → Project**
3. Select **iOS** → **App**
4. Configure:
   - **Product Name**: `DayShare`
   - **Team**: Your Apple Developer Team
   - **Organization Identifier**: `com.dayshare` (or your own)
   - **Bundle Identifier**: `com.dayshare.DayShare`
   - **Interface**: **SwiftUI**
   - **Language**: **Swift**
   - **Storage**: **Core Data** ✓ (check this!)
   - **Include Tests**: ✓ (optional but recommended)
5. Save to: `C:\Projects\DayShare\DayShare-iOS-Xcode` (new folder)

### Step 2: Replace Generated Files

After Xcode creates the project:

1. **Close Xcode**
2. Copy all files from `DayShare-iOS/DayShare/` to your new project's `DayShare/` folder
3. **Replace** the auto-generated files:
   - `DayShareApp.swift`
   - `ContentView.swift`
   - Keep the `.xcdatamodeld` file (you'll configure it in Step 3)

### Step 3: Add Files to Project

1. **Reopen Xcode**
2. In Project Navigator, **right-click on DayShare folder** → **Add Files to "DayShare"**
3. Select all folders:
   - `Models/`
   - `Views/`
   - `ViewModels/`
   - `Services/`
   - `CoreData/`
   - `Resources/`
4. Check **"Copy items if needed"**
5. Check **"Create groups"**
6. Click **Add**

### Step 4: Configure CoreData Model

1. Open `DayShareModel.xcdatamodeld` in Xcode
2. Click **"Add Entity"** 7 times to create:
   - User
   - Group
   - GroupMembership
   - Share
   - HelpRequest
   - Notification
   - ActivityLog

For **each entity**, add attributes matching the `Models/*+CoreDataProperties.swift` files:

#### User Entity
| Attribute | Type | Optional |
|-----------|------|----------|
| id | UUID | No |
| nickname | String | Yes |
| avatarEmoji | String | Yes |
| authProvider | String | Yes |
| authProviderID | String | Yes |
| language | String | Yes |
| notificationsEnabled | Boolean | No |
| isPremium | Boolean | No |
| premiumPurchaseDate | Date | Yes |
| createdAt | Date | Yes |
| lastActiveAt | Date | Yes |

**Relationships**:
- `memberships` → GroupMembership (To Many, Delete Rule: Cascade)
- `sharesGiven` → Share (To Many, Delete Rule: Cascade)
- `sharesReceived` → Share (To Many, Delete Rule: Cascade)
- `requestsCreated` → HelpRequest (To Many, Delete Rule: Cascade)
- `notifications` → Notification (To Many, Delete Rule: Cascade)
- `activityLogs` → ActivityLog (To Many, Delete Rule: Cascade)

#### Group Entity
| Attribute | Type | Optional |
|-----------|------|----------|
| id | UUID | No |
| name | String | Yes |
| emoji | String | Yes |
| maxMembers | Integer 16 | No |
| isArchived | Boolean | No |
| createdBy | UUID | Yes |
| createdAt | Date | Yes |
| lastActivityAt | Date | Yes |
| inviteCode | String | Yes |
| inviteExpiresAt | Date | Yes |

**Relationships**:
- `memberships` → GroupMembership (To Many, Delete Rule: Cascade)
- `shares` → Share (To Many, Delete Rule: Cascade)
- `helpRequests` → HelpRequest (To Many, Delete Rule: Cascade)

#### GroupMembership Entity
| Attribute | Type | Optional |
|-----------|------|----------|
| id | UUID | No |
| userId | UUID | Yes |
| groupId | UUID | Yes |
| role | String | Yes |
| displayName | String | Yes |
| isActive | Boolean | No |
| joinedAt | Date | Yes |
| leftAt | Date | Yes |

**Relationships**:
- `user` → User (To One, Delete Rule: Nullify)
- `group` → Group (To One, Delete Rule: Nullify)

#### Share Entity
| Attribute | Type | Optional |
|-----------|------|----------|
| id | UUID | No |
| groupId | UUID | Yes |
| giverUserId | UUID | Yes |
| receiverUserId | UUID | Yes |
| shareDescription | String | Yes |
| category | String | Yes |
| occurredAt | Date | Yes |
| duration | Double | No |
| status | String | Yes |
| confirmedAt | Date | Yes |
| confirmedBy | UUID | Yes |
| thankYouNote | String | Yes |
| createdAt | Date | Yes |
| createdBy | UUID | Yes |
| updatedAt | Date | Yes |
| isDeleted | Boolean | No |
| deletedAt | Date | Yes |

**Relationships**:
- `group` → Group (To One, Delete Rule: Nullify)
- `giver` → User (To One, Delete Rule: Nullify)
- `receiver` → User (To One, Delete Rule: Nullify)

#### HelpRequest Entity
| Attribute | Type | Optional |
|-----------|------|----------|
| id | UUID | No |
| groupId | UUID | Yes |
| requesterId | UUID | Yes |
| requestDescription | String | Yes |
| estimatedDuration | Double | No |
| neededBy | Date | Yes |
| status | String | Yes |
| claimedBy | UUID | Yes |
| claimedAt | Date | Yes |
| completedAt | Date | Yes |
| createdAt | Date | Yes |
| updatedAt | Date | Yes |
| resultingShareId | UUID | Yes |

**Relationships**:
- `group` → Group (To One, Delete Rule: Nullify)
- `requester` → User (To One, Delete Rule: Nullify)
- `resultingShare` → Share (To One, Delete Rule: Nullify)

#### Notification Entity
| Attribute | Type | Optional |
|-----------|------|----------|
| id | UUID | No |
| userId | UUID | Yes |
| type | String | Yes |
| title | String | Yes |
| body | String | Yes |
| relatedEntityType | String | Yes |
| relatedEntityId | UUID | Yes |
| isRead | Boolean | No |
| readAt | Date | Yes |
| createdAt | Date | Yes |
| expiresAt | Date | Yes |

**Relationships**:
- `user` → User (To One, Delete Rule: Nullify)

#### ActivityLog Entity
| Attribute | Type | Optional |
|-----------|------|----------|
| id | UUID | No |
| userId | UUID | Yes |
| action | String | Yes |
| entityType | String | Yes |
| entityId | UUID | Yes |
| timestamp | Date | Yes |
| ipAddress | String | Yes |
| deviceInfo | String | Yes |

**Relationships**:
- `user` → User (To One, Delete Rule: Nullify)

### Step 5: Configure Code Generation

For each entity:
1. Select the entity
2. In **Data Model Inspector** (right panel):
3. Set **Codegen**: **Manual/None**
4. Set **Module**: **Current Product Module**

This is important because we've already created the classes manually!

### Step 6: Add Firebase via Swift Package Manager

1. **File → Add Package Dependencies**
2. Enter URL: `https://github.com/firebase/firebase-ios-sdk.git`
3. Version: **10.20.0** or later
4. Add packages:
   - FirebaseAuth
   - FirebaseFirestore
   - FirebaseMessaging
   - FirebaseStorage

### Step 7: Add Signing & Capabilities

1. Select **DayShare** target
2. **Signing & Capabilities** tab
3. Select your **Team**
4. Click **+ Capability** and add:
   - **Push Notifications**
   - **Background Modes** → Check "Remote notifications"
   - **Sign in with Apple**

### Step 8: Build Settings

1. Set **iOS Deployment Target**: **17.0**
2. Set **Swift Language Version**: **Swift 5**
3. Under **Build Settings** → **Packaging**:
   - **Info.plist File**: `DayShare/Info.plist`

---

## Option 2: Manual Project File Creation (Advanced)

If you're comfortable with `.pbxproj` files, you can create a minimal Xcode project file. However, **Option 1 is strongly recommended** as Xcode's project files are complex and error-prone to create manually.

---

## After Setup

### 1. Add Firebase Configuration

- Download `GoogleService-Info.plist` from Firebase Console
- Drag it into Xcode under `DayShare/Resources/`
- Replace the template file

### 2. Build and Run

1. Select target: **iPhone 15 Pro** (or your device)
2. Press **Cmd+R**
3. If build errors occur, check:
   - All files are added to target
   - Firebase packages are resolved
   - CoreData model is properly configured

### 3. Test Basic Flow

- App should launch to onboarding screen
- Anonymous sign-in should work
- You should see the main tab view after sign-in

---

## Troubleshooting

### "No such module 'FirebaseCore'"
- Go to **File → Packages → Resolve Package Versions**
- Wait for packages to download

### "Cannot find 'User' in scope"
- Ensure all `Models/*.swift` files are added to target
- Check target membership in File Inspector

### CoreData crash on launch
- Verify entity names match exactly (case-sensitive)
- Check attribute types are correct
- Ensure relationships are bidirectional

### "PersistenceController not found"
- Make sure `CoreData/PersistenceController.swift` is added to target

---

## Next Steps

Once the project builds successfully:

1. Review `README.md` for development roadmap
2. Configure Firebase (follow README instructions)
3. Start implementing group creation UI
4. Refer to `DayShare-UX-Tone-Kit.md` for all UI copy

---

**Need Help?**
- Check Phase 0 documentation in parent directory
- Review Firebase setup guide in README.md
- Ensure all 7 entities are properly configured in CoreData

---

**Last Updated**: 2025-10-31
