//
//  Networking.swift
//  PrimerSDK_Example
//
//  Created by Evangelos on 30/11/21.
//  Copyright © 2021 CocoaPods. All rights reserved.
//

import Foundation
import PrimerSDK

var environment: Environment = .sandbox

enum Environment: String, Codable {
    case local, dev, sandbox, staging, production
    
    init(intValue: Int) {
        switch intValue {
        case 0:
            self = .local
        case 1:
            self = .dev
        case 2:
            self = .sandbox
        case 3:
            self = .staging
        case 4:
            self = .production
        default:
            fatalError()
        }
    }
    
    var intValue: Int {
        switch self {
        case .local:
            return 0
        case .dev:
            return 1
        case .sandbox:
            return 2
        case .staging:
            return 3
        case .production:
            return 4
        }
    }
    
    var baseUrl: URL {
        switch self {
        case .local:
            return URL(string: "https://primer-mock-back-end.herokuapp.com")!
        default:
            return URL(string: "https://us-central1-primerdemo-8741b.cloudfunctions.net")!
        }
    }
    
}

enum APIVersion: String {
    case v2 = "2021-09-27"
    case v3 = "2021-10-19"
    case v4 = "2021-12-01"
    case v5 = "2021-12-10"
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}

struct Payment {
    
    struct Request: Encodable {
        let paymentMethodToken: String
    }

    struct Response: Codable {
        let id: String
        let amount: Int?
        let currencyCode: String?
        let customer: ClientSessionRequestBody.Customer?
        let customerId: String?
        let dateStr: String?
        var date: Date? {
            return dateStr?.toDate()
        }
        let order: ClientSessionRequestBody.Order?
        let orderId: String?
        let requiredAction: Payment.Response.RequiredAction?
        let status: Status
        
        enum CodingKeys: String, CodingKey {
            case id, amount, currencyCode, customer, customerId, order, orderId, requiredAction, status
            case dateStr = "date"
        }
        
        struct RequiredAction: Codable {
            let clientToken: String
            let name: String
            let description: String?
        }
        
        enum Status: String, Codable {
            case authorized = "AUTHORIZED"
            case settled = "SETTLED"
            case declined = "DECLINED"
            case failed = "FAILED"
            case pending = "PENDING"
        }
    }
}

struct TransactionResponse {
    var id: String
    var date: String
    var status: String
    var requiredAction: Payment.Response.RequiredAction?
}

enum NetworkError: Error {
    case missingParams
    case unauthorised
    case timeout
    case serverError
    case invalidResponse
    case serializationError
}

class Networking {
    
    static func buildClientSessionRequestBody(amount: Int, currency: Currency, countryCode: CountryCode) -> ClientSessionRequestBody {
        let clientSessionRequestBody = ClientSessionRequestBody(
            customerId: "customer_id",
            orderId: "ios_order_id_\(String.randomString(length: 8))",
            currencyCode: currency,
            amount: nil,
            metadata: nil,
            customer: ClientSessionRequestBody.Customer(
                firstName: "John",
                lastName: "Smith",
                emailAddress: "john@primer.io",
                mobileNumber: "+4478888888888",
                billingAddress: Address(
                    firstName: "John",
                    lastName: "Smith",
                    addressLine1: "65 York Road",
                    addressLine2: nil,
                    city: "London",
                    state: nil,
                    countryCode: "GB",
                    postalCode: "NW06 4OM"),
                shippingAddress: Address(
                    firstName: "John",
                    lastName: "Smith",
                    addressLine1: "9446 Richmond Road",
                    addressLine2: nil,
                    city: "London",
                    state: nil,
                    countryCode: "GB",
                    postalCode: "EC53 8BT")
            ),
            order: ClientSessionRequestBody.Order(
                countryCode: countryCode,
                lineItems: [
                    ClientSessionRequestBody.Order.LineItem(
                        itemId: "_item_id_0",
                        description: "Item",
                        amount: amount,
                        quantity: 1)
                ]),
            paymentMethod: nil)
        
        return clientSessionRequestBody
    }
    
    func request(
        apiVersion: APIVersion?,
        url: URL,
        method: HTTPMethod,
        headers: [String: String]?,
        queryParameters: [String: String]?,
        body: Data?,
        completion: @escaping (_ result: Result<Data, Error>) -> Void)
    {
        var msg = "REQUEST\n"
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)!
        
        if let queryParameters = queryParameters {
            components.queryItems = queryParameters.map { (key, value) in
                URLQueryItem(name: key, value: value)
            }
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        
        msg += "URL: \(components.url!.absoluteString )\n"
        
        var request = URLRequest(url: components.url!)
        request.httpMethod = method.rawValue
        
        request.addValue(environment.rawValue, forHTTPHeaderField: "environment")
        if method != .get {
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        if let headers = headers {
            for header in headers {
                request.addValue(header.value, forHTTPHeaderField: header.key)
            }
        }
        
        if let apiVersion = apiVersion {
            request.addValue(apiVersion.rawValue, forHTTPHeaderField: "x-api-version")
        }
        
        msg += "Headers:\n\(request.allHTTPHeaderFields ?? [:])\n"
        
        if let body = body {
            request.httpBody = body
            
            let bodyJson = try? JSONSerialization.jsonObject(with: body, options: .allowFragments)
            msg += "Body:\n\(bodyJson ?? [:])\n"
        }
        
        print(msg)
        msg = ""
        
        URLSession.shared.dataTask(with: request, completionHandler: { (data, response, err) in
            msg += "RESPONSE\n"
            msg += "URL: \(request.url?.absoluteString ?? "Invalid")\n"
            
            if err != nil {
                msg += "Error: \(err!)\n"
                print(msg)
                completion(.failure(err!))
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                msg += "Error: Invalid response\n"
                print(msg)
                completion(.failure(NetworkError.invalidResponse))
                return
            }

            if (httpResponse.statusCode < 200 || httpResponse.statusCode > 399) {
                msg += "Status code: \(httpResponse.statusCode)\n"
                if let data = data, let resJson = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] {
                    msg += "Body:\n\(resJson)\n"
                }
                print(msg)
                completion(.failure(NetworkError.invalidResponse))
                
                guard let data = data else {
                    print("No data")
                    completion(.failure(NetworkError.invalidResponse))
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    print("Response body: \(json)")
                } catch {
                    print("Error: \(error)")
                }
                return
            }
            
            print("Status code: \(httpResponse.statusCode)")

            guard let data = data else {
                msg += "Status code: \(httpResponse.statusCode)\n"
                msg += "Body:\nNo data\n"
                print(msg)
                completion(.failure(NetworkError.invalidResponse))
                return
            }
            
            msg += "Status code: \(httpResponse.statusCode)\n"
            if let resJson = (try? JSONSerialization.jsonObject(with: data, options: .allowFragments)) as? [String: Any] {
                msg += "Body:\n\(resJson)\n"
            } else {
                msg += "Body (String): \(String(describing: String(data: data, encoding: .utf8)))"
            }
            
            print(msg)

            completion(.success(data))
        }).resume()
    }
    
    func createPayment(with paymentMethod: PaymentMethodToken, completion: @escaping (Payment.Response?, Error?) -> Void) {
        guard let paymentMethodToken = paymentMethod.token else {
            completion(nil, NetworkError.missingParams)
            return
        }
        
        let url = environment.baseUrl.appendingPathComponent("/api/payments/")

        let body = Payment.Request(paymentMethodToken: paymentMethodToken)

        var bodyData: Data!

        do {
            bodyData = try JSONEncoder().encode(body)
        } catch {
            completion(nil, NetworkError.missingParams)
            return
        }

        let networking = Networking()
        networking.request(
            apiVersion: .v2,
            url: url,
            method: .post,
            headers: nil,
            queryParameters: nil,
            body: bodyData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        do {
                            let paymentResponse = try JSONDecoder().decode(Payment.Response.self, from: data)
                            completion(paymentResponse, nil)
                        } catch {
                            completion(nil, error)
                        }

                    case .failure(let err):
                        completion(nil, err)
                    }
                }
            }
    }
    
    func resumePayment(_ paymentId: String, withResumeToken resumeToken: String, completion: @escaping (Payment.Response?, Error?) -> Void) {
        let url = environment.baseUrl.appendingPathComponent("/api/payments/\(paymentId)/resume")
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let bodyDic: [String: Any] = [
            "resumeToken": resumeToken
        ]
        
        var bodyData: Data!
        
        do {
            bodyData = try JSONSerialization.data(withJSONObject: bodyDic, options: .fragmentsAllowed)
        } catch {
            let merchantErr = NSError(domain: "merchant-domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Oh no, something went wrong creating the request..."])
            completion(nil, merchantErr)
            return
        }
        
        let networking = Networking()
        networking.request(
            apiVersion: .v2,
            url: url,
            method: .post,
            headers: nil,
            queryParameters: nil,
            body: bodyData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        do {
                            let paymentResponse = try JSONDecoder().decode(Payment.Response.self, from: data)
                            completion(paymentResponse, nil)
                            
                        } catch {
                            completion(nil, error)
                        }
                        
                    case .failure(let err):
                        print(err)
                        let merchantErr = NSError(domain: "merchant-domain", code: 1, userInfo: [NSLocalizedDescriptionKey: "Oh no, something went wrong resuming the payment..."])
                        completion(nil, merchantErr)
                    }
                }
            }
    }
    
    func requestClientSession(requestBody: ClientSessionRequestBody, completion: @escaping (String?, Error?) -> Void) {
        let url = environment.baseUrl.appendingPathComponent("/api/client-session")

        let bodyData: Data!
        
        do {
            if let requestBodyJson = requestBody.dictionaryValue {
                bodyData = try JSONSerialization.data(withJSONObject: requestBodyJson, options: .fragmentsAllowed)
            } else {
                completion(nil, NetworkError.serializationError)
                return
            }
        } catch {
            completion(nil, NetworkError.missingParams)
            return
        }
        
        let networking = Networking()
        networking.request(
            apiVersion: .v3,
            url: url,
            method: .post,
            headers: nil,
            queryParameters: nil,
            body: bodyData) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let data):
                        do {
                            if let token = (try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any])?["clientToken"] as? String {
                                completion(token, nil)
                            } else {
                                let err = NSError(domain: "example", code: 10, userInfo: [NSLocalizedDescriptionKey: "Failed to find client token"])
                                completion(nil, err)
                            }
                            
                        } catch {
                            completion(nil, error)
                        }
                    case .failure(let err):
                        completion(nil, err)
                    }
                }
            }
    }
    
}

internal extension String {
    func toDate(withFormat f: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ", timeZone: TimeZone? = nil) -> Date? {
        let df = DateFormatter()
        df.dateFormat = f
        df.locale = Locale(identifier: "en_US_POSIX")
        df.timeZone = timeZone == nil ? TimeZone(abbreviation: "UTC") : timeZone
        return df.date(from: self)
    }
}
