//
//  ExampleApp.swift
//  Example
//
//  Created by Jude Ganihu on 27/05/2025.
//

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
                                secretKey: "FLWSECK_TEST-592f56ef8d7384fc710559d3a15dd8d6-X"
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
