//
//  File.swift
//  FlutterwaveSDK
//
//  Created by Jude Ganihu on 27/05/2025.
//


import Foundation

public class FlutterwavePaymentVerifier {
    public static func handleRedirectURL(
        _ url: URL,
        secretKey: String
    ) async throws -> [String: Any] {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            throw NSError(domain: "Invalid redirect URL", code: 400, userInfo: nil)
        }

        let status = queryItems.first(where: { $0.name == "status" })?.value
        let txId = queryItems.first(where: { $0.name == "transaction_id" })?.value

        guard status == "successful", let transactionId = txId else {
            throw NSError(domain: "Payment not successful", code: 401, userInfo: nil)
        }

        let api = ApiClient(secretKey: secretKey)
        return try await api.verifyPayment(transactionId: transactionId)
    }
}
