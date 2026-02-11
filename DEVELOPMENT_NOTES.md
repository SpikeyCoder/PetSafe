# PetSafe iOS App - Development Notes & Execution Plan

## Current State Audit

### ✅ Completed Features
1. **Onboarding Flow** (OnboardingFlow.swift)
   - 7-step wizard collecting dog information
   - Validation for each step
   - Data model: `PetOnboardingData`
   - Persistence via `OnboardingCache` (UserDefaults)

2. **Authentication** (LoginView.swift)
   - Email/password login
   - Sign in with Apple integration
   - Mock authentication (1.2s delay)

3. **Navigation Structure** (RootView.swift)
   - Loading screen
   - Login gate
   - First-time onboarding gate
   - Main dashboard transition

4. **UI Design System**
   - Tailwind-inspired color palette (orange, blue, green, yellow, red)
   - Custom color extensions
   - Consistent styling patterns

### ⚠️ Incomplete Features & TODOs

#### 1. Premium Subscription System
**Location:** PersonalizedInsights.swift
**Issues:**
- `@State private var isPremium: Bool = false` - hardcoded, no real injection
- TODO: "Inject real premium status"
- TODO: "Present paywall" (2 occurrences)
- No StoreKit integration
- No persistence of premium status
- Premium gates exist but don't actually block features properly

#### 2. Barcode Scanner
**Location:** PersonalizedInsights.swift (scanSection)
**Issues:**
- TODO: "Hook into real scanner flow"
- Button exists but triggers nothing
- No AVFoundation camera integration
- No barcode detection
- Mock data only

#### 3. Food Logging & Viewing
**Location:** PersonalizedInsights.swift (logSection)
**Issues:**
- Hardcoded mock data: `[("Chicken & Rice (homemade)", "0.42 mg Cu", "Today")]`
- No SwiftData models
- No persistence layer
- No real data services
- Food entries shown but can't be added/edited/deleted

#### 4. API Integration
**Location:** PersonalizedInsights.swift (bottom of file)
**Issues:**
- `OpenFoodFactsMock` - returns hardcoded data
- `USDAMock` - returns stub estimates
- No actual network calls
- No async/await implementation for real APIs
- No error handling

#### 5. Architecture Issues
- **Two main views**: ContentView.swift (599 lines) vs PersonalizedInsights.swift (866 lines)
  - Unclear which is primary
  - Possible duplication
- **No MVVM**: Business logic mixed in views
- **No ViewModels**: All state in @State variables
- **No proper dependency injection**: Services hardcoded as properties

### 📁 File Structure
```
PetSafe/
├── PetSafeApp.swift (0 lines - deadlock error)
├── RootView.swift (82 lines) ✅
├── LoginView.swift (110 lines) ✅
├── OnboardingFlow.swift (246 lines) ✅
├── OnboardingData.swift (23 lines) ✅
├── OnboardingCache.swift (30 lines) ✅
├── PersonalizedInsights.swift (866 lines) ⚠️ Main dashboard, needs work
├── ContentView.swift (599 lines) ⚠️ Duplicate? Or old version?
├── CustomizedAlertsPanel.swift (200 lines)
├── LoadingScreen.swift (0 lines - deadlock error)
├── LoginScreen.swift (0 lines - deadlock error)
├── AlertsPanel.swift (0 lines - deadlock error)
├── MembershipPlans.swift (0 lines - deadlock error)
```

**Note:** Several files show "Resource deadlock" errors - may need Xcode to be closed.

---

## 🎯 V1.0 Release Requirements

### Feature A: Premium Subscription System
**Goal:** Implement full premium upgrade flow with StoreKit 2

**Requirements:**
1. StoreKit 2 integration
2. Product definitions (monthly/yearly subscriptions)
3. Purchase flow with restoration
4. Premium status management (observable object)
5. Paywall UI improvements
6. Persistent premium status (KeyChain or UserDefaults)
7. Feature gates that actually work

### Feature B: Barcode Scanner
**Goal:** Real barcode scanning with food database lookup

**Requirements:**
1. AVFoundation camera integration
2. Barcode detection (VNDetectBarcodesRequest)
3. Real OpenFoodFacts API integration
4. Product display and safety analysis
5. Permission handling (camera access)
6. Error states and retry logic

### Feature C: Food Logging & Viewing
**Goal:** Full CRUD operations on food entries with persistence

**Requirements:**
1. SwiftData models for food entries
2. Add/Edit/Delete functionality
3. Daily history view
4. Copper calculation aggregation
5. Search and filter capabilities
6. Export data functionality (optional)

### Feature D: Figma Design Implementation
**Goal:** Match the design specifications from Figma

**Note:** Chrome extension not connected - manual analysis needed
**URL:** https://revel-mold-57595758.figma.site

**Action items:**
1. Connect Chrome with Figma MCP
2. Extract design specifications
3. Compare with current implementation
4. Implement missing UI components
5. Ensure responsive design across iPhone sizes

---

## 🏗️ Proposed Architecture Refactor

### MVVM Structure
```
PetSafe/
├── App/
│   └── PetSafeApp.swift
├── Core/
│   ├── Models/
│   │   ├── FoodEntry.swift (SwiftData)
│   │   ├── OnboardingData.swift
│   │   └── DogProfile.swift (SwiftData)
│   ├── Services/
│   │   ├── OpenFoodFactsService.swift
│   │   ├── USDAService.swift
│   │   ├── SubscriptionService.swift
│   │   └── NetworkManager.swift
│   └── Utilities/
│       ├── Theme.swift
│       └── Extensions.swift
├── Features/
│   ├── Authentication/
│   │   ├── Views/
│   │   │   └── LoginView.swift
│   │   └── ViewModels/
│   │       └── AuthViewModel.swift
│   ├── Onboarding/
│   │   ├── Views/
│   │   │   └── OnboardingFlow.swift
│   │   └── ViewModels/
│   │       └── OnboardingViewModel.swift
│   ├── Dashboard/
│   │   ├── Views/
│   │   │   ├── DashboardView.swift
│   │   │   └── Components/
│   │   └── ViewModels/
│   │       └── DashboardViewModel.swift
│   ├── Scanner/
│   │   ├── Views/
│   │   │   └── BarcodeScannerView.swift
│   │   └── ViewModels/
│   │       └── ScannerViewModel.swift
│   ├── FoodLog/
│   │   ├── Views/
│   │   │   └── FoodLogView.swift
│   │   └── ViewModels/
│   │       └── FoodLogViewModel.swift
│   └── Subscription/
│       ├── Views/
│       │   └── PaywallView.swift
│       └── ViewModels/
│           └── SubscriptionViewModel.swift
└── Resources/
    └── Assets.xcassets
```

---

## 📋 Step-by-Step Execution Plan

### Phase 1: Foundation & Architecture (2-3 hours)
1. **Close Xcode and resolve file deadlock issues**
2. **Create proper folder structure**
   - Set up MVVM folders
   - Move existing files to appropriate locations
3. **Create SwiftData models**
   - `FoodEntry` model with @Model macro
   - `DogProfile` model
   - Model container configuration
4. **Create Theme.swift**
   - Centralize color definitions
   - Typography system
   - Component styles
5. **Set up dependency injection**
   - Protocol-based services
   - Environment objects for ViewModels

### Phase 2: Premium Subscription System (3-4 hours)
1. **StoreKit 2 Integration**
   - Create `SubscriptionService.swift`
   - Define products in App Store Connect
   - Implement purchase flow
   - Handle transaction verification
2. **SubscriptionViewModel**
   - Observable premium status
   - Purchase methods
   - Restore purchases
   - Error handling
3. **Improve PaywallView**
   - Better benefits presentation
   - Pricing display
   - Loading states
4. **Feature Gates**
   - Create reusable `PremiumGate` component
   - Update all premium features to use proper gates
5. **Persistence**
   - Store premium status in UserDefaults/Keychain
   - Sync on app launch

### Phase 3: Barcode Scanner (4-5 hours)
1. **Camera Integration**
   - Create `BarcodeScannerView.swift`
   - AVCaptureSession setup
   - Request camera permissions
   - Handle permission denials
2. **Barcode Detection**
   - Vision framework integration
   - Barcode type detection (EAN-13, UPC-A, etc.)
   - Visual feedback (overlay rectangle)
3. **OpenFoodFacts API**
   - Create real `OpenFoodFactsService.swift`
   - async/await API calls
   - JSON decoding models
   - Error handling
4. **Product Analysis**
   - Parse ingredients
   - Estimate copper content
   - Safety level calculation
   - Display results UI
5. **ScannerViewModel**
   - Manage scan state
   - Handle API responses
   - Copper calculation logic

### Phase 4: Food Logging (3-4 hours)
1. **SwiftData Setup**
   - Configure ModelContainer in App
   - Create @Query bindings
2. **FoodLogViewModel**
   - CRUD operations
   - Daily aggregation
   - Copper tracking
3. **Food Log UI**
   - List view with SwiftUI List
   - Add food form
   - Edit functionality
   - Delete with swipe actions
4. **Dashboard Integration**
   - Real-time copper updates
   - Today's summary
   - History view

### Phase 5: Figma Design Implementation (2-3 hours)
**Prerequisites:** Chrome + Figma MCP connected
1. **Analyze Figma design**
   - Extract component specifications
   - Note spacing, colors, typography
   - Identify interaction patterns
2. **Compare with current code**
   - List missing components
   - Note style discrepancies
3. **Implement missing features**
   - Create new components as needed
   - Update existing views
4. **Responsive design**
   - Test on multiple iPhone sizes
   - Adjust layouts for different screens

### Phase 6: Testing & Polish (2-3 hours)
1. **Unit Tests**
   - DashboardViewModel tests
   - ScannerViewModel tests
   - FoodLogViewModel tests
   - Service mock tests
2. **Integration Testing**
   - Complete user flows
   - Premium upgrade flow
   - Scan and log workflow
3. **Bug Fixes**
   - Address any errors
   - Performance optimization
   - Memory leak checks
4. **Final Polish**
   - Loading states
   - Error messages
   - Haptic feedback
   - Accessibility labels

---

## 🎨 Design System Standards

### Colors (from existing code)
- **Orange**: Primary brand color, CTAs, premium badges
  - orange50, orange100, orange200, orange600, orange700, orange800, orange900
- **Blue**: Info, profile cards
  - blue50, blue200, blue600
- **Green**: Safe status, success
  - green50, green200, green500, green600
- **Yellow**: Caution/warning
  - yellow50, yellow200, yellow500, yellow600
- **Red**: Danger, avoid
  - red50, red200, red500, red600

### Typography
- Title: `.title2.weight(.semibold)`
- Headline: `.headline`
- Subheadline: `.subheadline.weight(.semibold)`
- Body: `.subheadline`
- Caption: `.caption`

### Component Patterns
- Card: 12pt corner radius, padding, stroke overlay
- Buttons: `.borderedProminent` for primary, `.bordered` for secondary
- Badges: 8pt corner radius, 8pt horizontal padding, 4pt vertical padding

---

## 🚀 Quality Standards

### Swift Concurrency
✅ Use `async/await` for all network calls
✅ Use `@MainActor` for UI updates
✅ Handle Task cancellation properly

### Testing
✅ Unit tests for all ViewModels
✅ Mock services for testing
✅ 80%+ code coverage on business logic

### Responsive Design
✅ Support iPhone SE (smallest) to iPhone Pro Max (largest)
✅ Dynamic Type support
✅ Light/Dark mode support
✅ Accessibility labels for VoiceOver

### Error Handling
✅ User-friendly error messages
✅ Retry mechanisms for network failures
✅ Graceful degradation when features unavailable

---

## ⚠️ Known Issues & Blockers

1. **File Deadlock Errors**
   - Several Swift files show "Resource deadlock avoided"
   - Likely cause: Xcode has files open
   - **Solution:** Close Xcode before running scripts

2. **Figma MCP Not Connected**
   - Chrome extension not available
   - Cannot analyze Figma design programmatically
   - **Solution:** User needs to connect Chrome extension

3. **Duplicate Views**
   - `ContentView.swift` vs `PersonalizedInsights.swift`
   - Need to clarify which is the correct main view
   - **Solution:** Review with user, consolidate if needed

4. **No Theme.swift File**
   - Colors defined inline in views
   - No centralized design system
   - **Solution:** Create Theme.swift in Phase 1

5. **Missing PetSafeApp.swift Content**
   - Shows 0 lines due to deadlock
   - Cannot verify app entry point configuration
   - **Solution:** Read after closing Xcode

---

## 🎯 Next Steps

**Awaiting user approval for:**
1. Confirm execution plan approach
2. Clarify priority: All features vs. specific ones first
3. Figma design analysis access (need Chrome extension)
4. Confirm whether to refactor architecture or work with existing structure

**Immediate actions once approved:**
1. Close Xcode to resolve file deadlock
2. Read all missing files
3. Begin Phase 1: Architecture setup
4. Create first ViewModels and services

---

**Created:** 2026-02-10
**Status:** Awaiting approval
**Target:** v1.0 Production Release
