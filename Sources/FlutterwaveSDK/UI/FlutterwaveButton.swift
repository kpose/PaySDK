//
//  SwiftUIView.swift
//  FlutterwaveSDK
//
//  Created by kpose on 27/05/2025.
//

import SwiftUI



import SwiftUI
import UIKit

public struct FlutterwaveButton: View {
    let config: FlutterwavePaymentConfig
    let secretKey: String
    let title: String
    let onError: ((Error) -> Void)?
    
    public init(
        title: String = "Pay with Flutterwave",
        config: FlutterwavePaymentConfig,
        secretKey: String,
        onError: ((Error) -> Void)? = nil
    ) {
        self.title = title
        self.config = config
        self.secretKey = secretKey
        self.onError = onError
    }

    public var body: some View {
        Button(action: {
            let api = ApiClient(secretKey: secretKey)
            api.createPayment(with: config) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let url):
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        } else {
                            onError?(NSError(domain: "FlutterwaveButton", code: 0, userInfo: [NSLocalizedDescriptionKey: "Cannot open URL"]))
                        }
                    case .failure(let error):
                        onError?(error)
                    }
                }
            }
        }) {
            Text(title)
                .padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(8)
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
            secretKey: "test_secret_key"
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

