import Foundation
import UIKit

/// EzyMMP - A lightweight SDK for attributing app installs and tracking events back to short links.
public class EzyMMP {
    
    public static let shared = EzyMMP()
    public static let defaultBaseUrl = "https://ezyurl.io/api/v1/sdk"
    
    private var apiKey: String = ""
    private var baseUrl: String = EzyMMP.defaultBaseUrl
    
    private let userDefaults = UserDefaults.standard
    private let deviceIdKey = "ezy_mmp_device_id"
    
    private var deviceId: String {
        if let id = userDefaults.string(forKey: deviceIdKey) {
            return id
        } else {
            let newId = UUID().uuidString
            userDefaults.set(newId, forKey: deviceIdKey)
            // This is a fresh install, notify the backend
            trackInstall(with: newId)
            return newId
        }
    }
    
    private init() {}
    
    /// Initialize the SDK in your AppDelegate or SceneDelegate
    public func configure(apiKey: String, baseUrl: String? = nil) {
        self.apiKey = apiKey
        if let url = baseUrl {
            self.baseUrl = url
        } else {
            self.baseUrl = EzyMMP.defaultBaseUrl
        }
        
        // Accessing deviceId triggers install tracking if it's the first time
        _ = self.deviceId
    }
    
    private func trackInstall(with id: String) {
        guard let url = URL(string: "\(baseUrl)/install") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        let payload: [String: Any] = [
            "deviceId": id,
            "os": "iOS",
            "deviceModel": UIDevice.current.model
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("EzyMMP: Failed to track install: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("EzyMMP: Install track response: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    /// Track a post-install event
    /// - Parameters:
    ///   - eventName: Name of the event (e.g., "signup", "purchase")
    ///   - eventData: Dictionary of extra properties
    public func trackEvent(eventName: String, eventData: [String: Any]? = nil) {
        guard let url = URL(string: "\(baseUrl)/event") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apiKey, forHTTPHeaderField: "x-api-key")
        
        var payload: [String: Any] = [
            "deviceId": deviceId,
            "eventName": eventName
        ]
        
        if let data = eventData {
            payload["eventData"] = data
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: payload)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("EzyMMP: Failed to track event: \(error)")
                return
            }
            if let httpResponse = response as? HTTPURLResponse {
                print("EzyMMP: Event track response: \(httpResponse.statusCode)")
            }
        }.resume()
    }
    
    /// Standardized method to track a purchase event
    /// - Parameters:
    ///   - revenue: The amount of the purchase
    ///   - currency: The 3-letter currency code (e.g., "USD")
    ///   - transactionId: A unique identifier for the transaction
    ///   - extraData: Optional extra properties
    public func trackPurchase(revenue: Double, currency: String, transactionId: String, extraData: [String: Any]? = nil) {
        var data: [String: Any] = [
            "revenue": revenue,
            "currency": currency,
            "transactionId": transactionId
        ]
        if let extra = extraData {
            for (key, value) in extra {
                data[key] = value
            }
        }
        trackEvent(eventName: "purchase", eventData: data)
    }
}
