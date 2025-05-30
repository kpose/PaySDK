### FlutterwaveSDK
A lightweight Swift SDK for integrating Flutterwave Standard Checkout into your iOS apps. Includes native SwiftUI support and async payment handling.

#### 🛠 Requirements
- iOS 13+
- Swift 5.5+
- Xcode 13+

#### 📦 Installation 
To integrate the SDK into your Xcode project:

**Using Swift Package Manager (SPM)** : 

1: In Xcode, go to File → Add Packages...
2: Paste the following GitHub URL:

```
https://github.com/kpose/PaySDK
```
3: Select the latest version and add the package to your target. Make sure to select the appropriate target where you'll use the SDK.



#### ⚙️ Configuration 
Flutterwave’s Standard Checkout supports the following parameters for configuration:
```
let config = FlutterwavePaymentConfig(
    txRef: "TX123456789",
    amount: "5000",
    currency: "NGN", // or "USD", "KES", etc.
    redirectURL: "myapp://flutterwave-redirect", // This should be your app's universal link
    customer: Customer(
        email: "judedoe@email.com",
        name: "Jude Doe",
        phonenumber: "08012345678"
    ),
    customizations: Customizations(
        title: "Buy Coffee",
        logo: "https://yourapp.com/logo.png",
        description: "Coffee Payment"
    ),
    meta: [
        "consumer_id": "7898",
        "device": "iPhone"
    ],
    paymentOptions: "card"
)
```

| Parameter        | Required | Description                                                   |
| ---------------- | -------- | ------------------------------------------------------------- |
| `txRef`          | ✅        | Unique transaction reference                                  |
| `amount`         | ✅        | Amount to charge                                              |
| `currency`       | ✅        | Currency code (NGN, USD, etc.)                                |
| `redirectURL`    | ✅        | URL Flutterwave will redirect to after payment                |
| `customer`       | ✅        | Object containing customer details                            |
| `customizations` | ❌        | UI/UX personalization (title, logo, description)              |
| `meta`           | ❌        | Additional data (dictionary of key-value pairs)               |
| `paymentOptions` | ❌        | Comma-separated string of options (e.g., `card,banktransfer`) |

Pleae visit [Flutterwave's Standard checkout](https://developer.flutterwave.com/docs/flutterwave-standard-1#step-1-create-payment-details) for more details on the configuration options: 



#### 💳  Usage 
**Option 1: Use the Prebuilt Flutterwave Button**
This button opens Flutterwave's hosted payment page and handles loading state and redirection internally.

```
import SwiftUI
import FlutterwaveSDK

struct ContentView: View {
    private let config = FlutterwavePaymentConfig(
        txRef: UUID().uuidString,
        amount: "1000",
        currency: "NGN",
        "myapp://flutterwave-redirect", // This should be your app's universal link
        customer: Customer(email: "email@user.com", name: "John Doe", phonenumber: "08100000000")
    )

    private let secretKey = "FLWSECK_TEST-XXXXXXXX-X" //This is be your Flutterwave Secret Key

    var body: some View {
        VStack(spacing: 40) {
            FlutterwaveButton(
                title: "Pay ₦\(config.amount)",
                config: config,
                secretKey: secretKey,
                onError: { error in
                    print("Payment error: \(error.localizedDescription)")
                }
            )
            .padding()
        }
        .padding()
    }
}
```

**Option 2: Use a Custom Button with FlutterwavePaymentHandler**
Use this if you want full control of your UI:

```
import SwiftUI
import FlutterwaveSDK

struct ContentView: View {
    private let config = FlutterwavePaymentConfig(
        txRef: UUID().uuidString,
        amount: "1000",
        currency: "NGN",
        redirectURL: "https://flutterwave.com",
        customer: Customer(email: "email@user.com", name: "John Doe", phonenumber: "08100000000")
    )

    private let secretKey = "FLWSECK_TEST-XXXXXXXX-X" //This is be your Flutterwave Secret Key

    @StateObject private var paymentHandler: FlutterwavePaymentHandler

    init() {
        let handler = FlutterwavePaymentHandler(config: config, secretKey: secretKey)
        _paymentHandler = StateObject(wrappedValue: handler)
    }

    var body: some View {
        VStack(spacing: 40) {
            Button(action: {
                paymentHandler.startPayment { error in
                    print("Payment error: \(error.localizedDescription)")
                }
            }) {
                if paymentHandler.isLoading {
                    ProgressView()
                } else {
                    Text("Pay ₦\(config.amount)")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }
            }
            .padding()
            .disabled(paymentHandler.isLoading)
        }
        .padding()
    }
}
```

#### 🔄 Handling Redirect and Verifying Payment
Flutterwave will redirect users to the redirectURL after payment. Use **FlutterwavePaymentVerifier** to confirm the transaction:

```
import SwiftUI
import FlutterwaveSDK

@main
struct ExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    Task {
                        do {
                            let data = try await FlutterwavePaymentVerifier.handleRedirectURL(
                                url,
                                secretKey: "FLWSECK_TEST-XXXXXXXX-X"
                            )
                            print("Payment Verified: \(data)")
                            // Handle successful UI update

                        } catch {
                            print("Verification Failed: \(error.localizedDescription)")
                            // Handle error UI update
                        }
                    }
                }
        }
    }
}
```

#### 🔄 Handling Redirect and Verifying Payment
To securely handle payment redirects, you should implement [Universal Links](https://developer.apple.com/documentation/xcode/allowing-apps-and-websites-to-link-to-your-content)  in your iOS app.

1. In your Xcode target → Signing & Capabilities:
    - Add Associated Domains
    - Add: applinks:yourdomain.com

2. Host an apple-app-site-association (AASA) JSON file at:
```
https://yourdomain.com/.well-known/apple-app-site-association
```
3. The file should look like:
```
{
  "applinks": {
    "apps": [],
    "details": [
      {
        "appID": "<TEAMID>.<BUNDLEID>",
        "paths": [ "/flutterwave-redirect" ]
      }
    ]
  }
}
```
4. Your redirectURL in the payment config should match the format:
```
https://yourdomain.com/flutterwave-redirect
```