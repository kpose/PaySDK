//
//  File.swift
//  FlutterwaveSDK
//
//  Created by kpose on 27/05/2025.
//

import Foundation

class ApiClient {
    private let secretKey: String

    init(secretKey: String) {
        self.secretKey = secretKey
    }
    
    func createPayment(with config: FlutterwavePaymentConfig, completion: @escaping @Sendable (Result<URL, Error>) -> Void) {
        guard let url = URL(string: "https://api.flutterwave.com/v3/payments") else {
            return completion(.failure(NSError(domain: "Invalid URL", code: 400, userInfo: nil)))
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        var body: [String: Any] = [
            "tx_ref": config.txRef,
            "amount": config.amount,
            "currency": config.currency,
            "redirect_url": config.redirectURL,
            "customer": [
                "email": config.customer.email,
                "name": config.customer.name ?? "",
                "phonenumber": config.customer.phonenumber ?? ""
            ]
        ]

        if let customization = config.customizations {
            body["customizations"] = [
                "title": customization.title ?? "",
                "logo": customization.logo ?? "",
                "description": customization.description ?? ""
            ]
        }

        if let session = config.sessionDuration {
            body["session_duration"] = session
        }

        if let retry = config.maxRetryAttempt {
            body["max_retry_attempt"] = retry
        }

        if let meta = config.meta {
            body["meta"] = meta
        }

        if let options = config.paymentOptions {
            body["payment_options"] = options
        }

        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: body, options: [])
        } catch {
            return completion(.failure(error))
        }

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                return completion(.failure(error))
            }

            guard let data = data else {
                return completion(.failure(NSError(domain: "Empty response", code: 500, userInfo: nil)))
            }

            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let data = json["data"] as? [String: Any],
                   let link = data["link"] as? String,
                   let url = URL(string: link) {
                    completion(.success(url))
                } else {
                    throw NSError(domain: "Invalid JSON", code: 500, userInfo: nil)
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }


}

