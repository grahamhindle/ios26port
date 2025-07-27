import Foundation

public extension AuthenticationRecord {
    static let mockAuthenticationRecords: [AuthenticationRecord] = [
        AuthenticationRecord(
            id: 1,
            authId: "auth0|123456789",
            isAuthenticated: true,
            providerID: "auth0"
            ),

        AuthenticationRecord(
            id: 2,
            authId: "google|987654321",
            isAuthenticated: true,
            providerID: "google"
        ),


        AuthenticationRecord(
            id: 3,
            authId: "apple|555666777",
            isAuthenticated: false,
            providerID: "apple"


        ),
        
    ]
    
    static let mockAuthenticationRecord = mockAuthenticationRecords[0]
}
