import Foundation

/// Auth0 Configuration
public struct Auth0Config: Sendable {
    public let domain: String
    public let clientId: String
    public let audience: String

    public init(domain: String, clientId: String, audience: String) {
        self.domain = domain
        self.clientId = clientId
        self.audience = audience
    }

    /// Default Auth0 configuration
    public static let `default` = Auth0Config(
        domain: "dev-mt7cwqgw3eokr8pz.us.auth0.com",
        clientId: "FYrB5CVx1aGhEZaMIQJ6ZaOtxPtwfFeS",
        audience: "https://dev-mt7cwqgw3eokr8pz.us.auth0.com/api/v2/"
    )
}
