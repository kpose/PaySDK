//
//  ContentView.swift
//  Test
//
//  Created by Jude Ganihu on 27/05/2025.
//

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

    private let secretKey = "FLWSECK_TEST-592f56ef8d7384fc710559d3a15dd8d6-X"

    @StateObject private var paymentHandler: FlutterwavePaymentHandler

    init() {
        let handler = FlutterwavePaymentHandler(config: config, secretKey: secretKey)
        _paymentHandler = StateObject(wrappedValue: handler)
    }

    var body: some View {
        VStack(spacing: 40) {
            Text("Flutterwave Pay SDK")
                .font(.title2)
                .fontWeight(.semibold)

            FlutterwaveButton(
                title: "Pay ₦\(config.amount) with Flutterwave Button",
                config: config,
                secretKey: secretKey,
                onError: { error in
                    print("Default button error: \(error.localizedDescription)")
                }
            )
            .padding()

            Button(action: {
                paymentHandler.startPayment { error in
                    print("Custom button error: \(error.localizedDescription)")
                }
            }) {
                if paymentHandler.isLoading {
                    ProgressView()
                } else {
                    Text("Pay ₦\(config.amount) With Custom Button")
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

#Preview {
    ContentView()
}
