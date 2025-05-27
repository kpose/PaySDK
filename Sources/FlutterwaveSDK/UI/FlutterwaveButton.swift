//
//  SwiftUIView.swift
//  FlutterwaveSDK
//
//  Created by Jude Ganihu on 27/05/2025.
//

import SwiftUI
import UIKit


public struct FlutterwaveButton: View {
    @ObservedObject private var handler: FlutterwavePaymentHandler
    let title: String
    let onError: ((Error) -> Void)?

    public init(
        title: String = "Pay with Flutterwave",
        config: FlutterwavePaymentConfig,
        secretKey: String,
        onError: ((Error) -> Void)? = nil
    ) {
        self.handler = FlutterwavePaymentHandler(config: config, secretKey: secretKey)
        self.title = title
        self.onError = onError
    }

    public var body: some View {
        Button(action: {
            handler.startPayment(onError: onError)
        }) {
            if handler.isLoading {
                if #available(iOS 14.0, *) {
                    ProgressView()
                } else {
                    Text("Loading...")
                        .padding()
                }
            } else {
                Text(title)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
    }
}


struct FlutterwaveButton_Previews: PreviewProvider {
    static var previews: some View {
        FlutterwaveButton(
            config: FlutterwavePaymentConfig(
                txRef: "kkkk",
                amount: "100",
                currency: "NGN",
                redirectURL: "https://google.com",
                customer: Customer(email: "test@example.com", name: "John Doe", phonenumber: "08012345678"),
                customizations: Customizations(title: "Pay Now", logo: nil, description: "Test payment")
            ),
            secretKey: "111111"
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

