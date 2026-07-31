import Foundation
#if canImport(UIKit)
import UIKit
#endif

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
        
        #if canImport(UIKit)
        let deviceModel = UIDevice.current.model
        let osName = "iOS"
        #else
        let deviceModel = "Mac"
        let osName = "macOS"
        #endif
        
        let payload: [String: Any] = [
            "deviceId": id,
            "os": osName,
            "deviceModel": deviceModel
        ]
        
        let sanitizedPayload = sanitizeForJSON(payload) as? [String: Any] ?? payload
        guard JSONSerialization.isValidJSONObject(sanitizedPayload) else { return }
        request.httpBody = try? JSONSerialization.data(withJSONObject: sanitizedPayload)
        
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
            payload["eventData"] = sanitizeForJSON(data)
        }
        
        let sanitizedPayload = sanitizeForJSON(payload) as? [String: Any] ?? payload
        guard JSONSerialization.isValidJSONObject(sanitizedPayload) else {
            print("EzyMMP: Failed to serialize event payload for event '\(eventName)' - invalid JSON object")
            return
        }
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: sanitizedPayload)
        
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

    /// Recursively sanitizes data to ensure all values and dictionary keys are valid JSON types for JSONSerialization.
    internal func sanitizeForJSON(_ value: Any) -> Any {
        switch value {
        case is NSNull:
            return value
        case let string as String:
            return string
        case let bool as Bool:
            return bool
        case let int as Int:
            return int
        case let double as Double:
            if double.isNaN || double.isInfinite {
                return String(describing: double)
            }
            return double
        case let float as Float:
            if float.isNaN || float.isInfinite {
                return String(describing: float)
            }
            return float
        case let number as NSNumber:
            if CFGetTypeID(number) == CFBooleanGetTypeID() {
                return number.boolValue
            }
            if number.doubleValue.isNaN || number.doubleValue.isInfinite {
                return String(describing: number)
            }
            return number
        case let decimal as Decimal:
            return NSDecimalNumber(decimal: decimal)
        case let date as Date:
            if #available(iOS 10.0, *) {
                return ISO8601DateFormatter().string(from: date)
            } else {
                let formatter = DateFormatter()
                formatter.locale = Locale(identifier: "en_US_POSIX")
                formatter.timeZone = TimeZone(secondsFromGMT: 0)
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
                return formatter.string(from: date)
            }
        case let url as URL:
            return url.absoluteString
        case let uuid as UUID:
            return uuid.uuidString
        case let dict as [String: Any]:
            var sanitizedDict: [String: Any] = [:]
            for (k, v) in dict {
                sanitizedDict[k] = sanitizeForJSON(v)
            }
            return sanitizedDict
        case let dict as [AnyHashable: Any]:
            var sanitizedDict: [String: Any] = [:]
            for (k, v) in dict {
                sanitizedDict[String(describing: k)] = sanitizeForJSON(v)
            }
            return sanitizedDict
        case let array as [Any]:
            return array.map { sanitizeForJSON($0) }
        default:
            return String(describing: value)
        }
    }
}
