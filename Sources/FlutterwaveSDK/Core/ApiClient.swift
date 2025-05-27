import Foundation

final class ApiClient {
    private let secretKey: String
    private let baseURL = "https://api.flutterwave.com/v3"

    init(secretKey: String) {
        self.secretKey = secretKey
    }

    func verifyPayment(transactionId: String) async throws -> [String: Any] {
        guard let url = URL(string: "\(baseURL)/transactions/\(transactionId)/verify") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(secretKey)", forHTTPHeaderField: "Authorization")

        let (data, _) = try await URLSession.shared.data(for: request)
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "Invalid JSON", code: 500, userInfo: nil)
        }

        return json
    }

    func createPayment(with config: FlutterwavePaymentConfig) async throws -> URL {
        guard let url = URL(string: "\(baseURL)/payments") else {
            throw URLError(.badURL)
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

        if let meta = config.meta {
            body["meta"] = meta
        }

        if let options = config.paymentOptions {
            body["payment_options"] = options
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let dataDict = json["data"] as? [String: Any],
            let link = dataDict["link"] as? String,
            let paymentURL = URL(string: link)
        else {
            throw NSError(domain: "Invalid payment response", code: 500, userInfo: nil)
        }

        return paymentURL
    }
}
