import XCTest
@testable import EzyMMP

final class EzyMMPTests: XCTestCase {

    func testSanitizeForJSON() {
        let sdk = EzyMMP.shared
        
        let date = Date(timeIntervalSince1970: 1700000000)
        let url = URL(string: "https://example.com")!
        let uuid = UUID(uuidString: "12345678-1234-1234-1234-123456789ABC")!
        
        struct CustomObject {
            let name = "test"
        }
        
        let extraData: [String: Any] = [
            "string": "hello",
            "int": 42,
            "double": 3.14,
            "bool": true,
            "date": date,
            "url": url,
            "uuid": uuid,
            "customObj": CustomObject(),
            "nestedDict": [
                "innerDate": date
            ],
            "array": [date, "string"]
        ]
        
        let sanitized = sdk.sanitizeForJSON(extraData) as? [String: Any]
        XCTAssertNotNil(sanitized)
        XCTAssertEqual(sanitized?["string"] as? String, "hello")
        XCTAssertEqual(sanitized?["int"] as? Int, 42)
        XCTAssertEqual(sanitized?["double"] as? Double, 3.14)
        XCTAssertEqual(sanitized?["bool"] as? Bool, true)
        XCTAssertEqual(sanitized?["url"] as? String, "https://example.com")
        XCTAssertEqual(sanitized?["uuid"] as? String, "12345678-1234-1234-1234-123456789ABC")
        XCTAssertNotNil(sanitized?["date"])
        XCTAssertNotNil(sanitized?["customObj"])
        
        // Verify JSONSerialization.isValidJSONObject succeeds
        XCTAssertTrue(JSONSerialization.isValidJSONObject(sanitized!))
    }
}
