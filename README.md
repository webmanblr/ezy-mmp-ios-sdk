# EzyMMP iOS SDK Library

`EzyMMP` is a lightweight Swift library for iOS apps to attribute app installs and track events (such as purchases, signups, etc.) back to EzyURL short links.

## Installation

### Option A: Swift Package Manager (Recommended)

1. In Xcode, open your project and navigate to **File > Add Packages...** (or select your project in the Project Navigator > **Package Dependencies**).
2. Enter the repository URL:
   `https://github.com/webmanblr/ezy-mmp-ios-sdk.git`
3. Set Dependency Rule to **Up to Next Major Version** (`1.0.2`) and click **Add Package**.

Or in `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/webmanblr/ezy-mmp-ios-sdk.git", from: "1.0.2")
]
```

---

### Option B: CocoaPods

Add the following to your `Podfile`:

```ruby
pod 'EzyMMP', '~> 1.0.2'
```

Then run `pod install`.

---

## Quick Usage

### 1. Configure in `AppDelegate` or `SceneDelegate`

```swift
import EzyMMP

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Initialize EzyMMP SDK with your API key
        EzyMMP.shared.configure(apiKey: "ezkey_YOUR_API_KEY")
        
        return true
    }
}
```

### 2. Track Purchases & Revenue

```swift
EzyMMP.shared.trackPurchase(
    revenue: 799.00,
    currency: "INR",
    transactionId: "TXN_123456789",
    extraData: ["plan": "premium_monthly"]
)
```

### 3. Track Custom Events

```swift
EzyMMP.shared.trackEvent(eventName: "signup", eventData: ["method": "google"])
```
