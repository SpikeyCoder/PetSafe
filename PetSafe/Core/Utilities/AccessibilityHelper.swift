import SwiftUI

// MARK: - Accessibility Helper
/// Provides reusable accessibility modifiers for Apple HIG compliance

extension View {
    // MARK: - Standard Accessibility
    func accessibleButton(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }

    func accessibleValue(_ value: String) -> some View {
        self
            .accessibilityValue(value)
    }

    func accessibleHeader(_ label: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isHeader)
    }

    // MARK: - Progress Indicators
    func accessibleProgress(label: String, value: Double, total: Double) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue("\(Int(value)) of \(Int(total))")
            .accessibilityAddTraits(.updatesFrequently)
    }

    func accessiblePercentage(label: String, percentage: Double) -> some View {
        self
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label)
            .accessibilityValue("\(Int(percentage))%")
    }

    // MARK: - Interactive Elements
    func accessibleTab(label: String, isSelected: Bool) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isButton)
            .accessibilityAddTraits(isSelected ? .isSelected : [])
            .accessibilityHint(isSelected ? "Currently selected" : "Double tap to select")
    }

    func accessibleCard(title: String, content: String) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel("\(title). \(content)")
    }

    // MARK: - Safety Status
    func accessibleSafetyStatus(level: String, value: Double, limit: Double) -> some View {
        let description: String
        if value < limit * 0.7 {
            description = "Safe. \(value) milligrams out of \(limit) milligram limit"
        } else if value < limit * 0.9 {
            description = "Caution. Approaching limit. \(value) milligrams out of \(limit) milligram limit"
        } else {
            description = "Danger. Near or over limit. \(value) milligrams out of \(limit) milligram limit"
        }

        return self
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Copper status: \(level)")
            .accessibilityValue(description)
    }

    // MARK: - Dynamic Type Support
    func supportsDynamicType() -> some View {
        self
            .dynamicTypeSize(...DynamicTypeSize.xxxLarge)
    }

    // MARK: - Reduce Motion
    @ViewBuilder
    func withReduceMotion<T: View>(
        _ animation: Animation,
        @ViewBuilder alternative: () -> T
    ) -> some View {
        if UIAccessibility.isReduceMotionEnabled {
            alternative()
        } else {
            self.animation(animation, value: true)
        }
    }
}

// MARK: - Custom Accessibility Actions
extension View {
    func customAccessibilityActions(_ actions: [AccessibilityAction]) -> some View {
        var view = self
        for action in actions {
            view = view.accessibilityAction(named: action.name, action.handler) as! Self
        }
        return view
    }
}

struct AccessibilityAction {
    let name: String
    let handler: () -> Void
}

// MARK: - Accessibility Announcements
struct AccessibilityAnnouncement {
    static func post(_ message: String, delay: TimeInterval = 0.1) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            UIAccessibility.post(notification: .announcement, argument: message)
        }
    }

    static func postScreenChanged(to view: Any?) {
        UIAccessibility.post(notification: .screenChanged, argument: view)
    }

    static func postLayoutChanged(to view: Any?) {
        UIAccessibility.post(notification: .layoutChanged, argument: view)
    }
}

// MARK: - Example Usage in Views
/*

 // Progress Bar Example
 GeometryReader { geometry in
     Capsule()
         .fill(Theme.Colors.orange600)
         .frame(width: geometry.size.width * copperPercentage)
 }
 .accessibleProgress(
     label: "Today's copper intake",
     value: todayCopper,
     total: dailyLimit
 )

 // Button Example
 Button("Scan Food") {
     startScanning()
 }
 .accessibleButton(
     label: "Scan Food",
     hint: "Opens camera to scan product barcode"
 )

 // Tab Example
 Button {
     selectedTab = .home
 } label: {
     Image(systemName: "house.fill")
     Text("Home")
 }
 .accessibleTab(
     label: "Home",
     isSelected: selectedTab == .home
 )

 // Safety Status Example
 HStack {
     Image(systemName: safetyIcon)
     Text(safetyText)
 }
 .accessibleSafetyStatus(
     level: safetyLevel.displayText,
     value: copperToday,
     limit: copperLimit
 )

 // Dynamic Announcement Example
 .onAppear {
     AccessibilityAnnouncement.post("Loaded 5 food entries for today")
 }

 */
