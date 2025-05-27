//
//  FlutterwavePaymentConfig.swift
//  FlutterwaveSDK
//
//  Created by kpose on 27/05/2025.
//

import Foundation


public struct Customer: Codable {
    public let email: String
    public let name: String?
    public let phonenumber: String?

    public init(email: String, name: String? = nil, phonenumber: String? = nil) {
        self.email = email
        self.name = name
        self.phonenumber = phonenumber
    }
}


public struct Customizations: Codable {
    public let title: String?
    public let logo: String?
    public let description: String?

    public init(title: String? = nil, logo: String? = nil, description: String? = nil) {
        self.title = title
        self.logo = logo
        self.description = description
    }
}


public struct FlutterwavePaymentConfig {
    public let txRef: String
    public let amount: String
    public let currency: String
    public let redirectURL: String
    public let customer: Customer
    public let customizations: Customizations?
    public let meta: [String: Any]?
    public let paymentOptions: String?
    public let sessionDuration: Int?
    public let maxRetryAttempt: Int?

    

    public init(
        txRef: String,
        amount: String,
        currency: String = "NGN",
        redirectURL: String,
        customer: Customer,
        customizations: Customizations? = nil,
        meta: [String: Any]? = nil,
        paymentOptions: String? = nil,
        sessionDuration: Int? = nil,
        maxRetryAttempt: Int? = nil
    ) {
        self.txRef = txRef
        self.amount = amount
        self.currency = currency
        self.redirectURL = redirectURL
        self.customer = customer
        self.customizations = customizations
        self.meta = meta
        self.paymentOptions = paymentOptions
        self.sessionDuration = sessionDuration
        self.maxRetryAttempt = maxRetryAttempt
    }
}
