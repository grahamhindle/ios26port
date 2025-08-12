import Foundation
import JWTDecode

// MARK: - Auth Error

public enum AuthError: Error, LocalizedError {
    case missingUserId

    public var errorDescription: String? {
        switch self {
        case .missingUserId:
            "Authentication succeeded but user ID is missing"
        }
    }
}

// MARK: - JWT Token Parsing Utilities

public func extractUserIdFromToken(_ idToken: String?) -> String? {
    guard let token = idToken else {
        print("❌ No token provided")
        return nil
    }

    do {
        let jwt = try decode(jwt: token)

        print("🔍 Token payload keys: \(Array(jwt.body.keys).sorted())")

        // Try multiple possible user ID fields
        if let sub = jwt.subject {
            print("✅ Found subject: \(sub)")
            return sub
        } else if let userId = jwt.body["user_id"] as? String {
            print("✅ Found user_id: \(userId)")
            return userId
        } else if let id = jwt.body["id"] as? String {
            print("✅ Found id: \(id)")
            return id
        } else {
            print("❌ No user ID field found. Available keys: \(Array(jwt.body.keys))")
            return nil
        }
    } catch {
        print("❌ Failed to decode JWT: \(error)")
        return nil
    }
}

public func extractProviderFromToken(_ idToken: String?) -> String? {
    guard let token = idToken else {
        print("❌ No token provided for provider extraction")
        return nil
    }

    do {
        let jwt = try decode(jwt: token)

        // Try extracting provider from different JWT fields
        if let provider = extractProviderFromSubject(jwt.subject) {
            return provider
        }

        if let provider = extractProviderFromIssuer(jwt.issuer) {
            return provider
        }

        if let provider = extractProviderFromIdp(jwt.body["idp"] as? String) {
            return provider
        }

        print("🔍 No specific provider found, defaulting to auth0")
        return "auth0"
    } catch {
        print("❌ Failed to decode JWT for provider extraction: \(error)")
        return nil
    }
}

private func extractProviderFromSubject(_ subject: String?) -> String? {
    guard let sub = subject else { return nil }

    print("🔍 Checking subject for provider: \(sub)")

    let providerMap = [
        "google-oauth2": "google",
        "facebook": "facebook",
        "apple": "apple",
        "twitter": "twitter",
        "github": "github",
        "linkedin": "linkedin",
        "auth0": "email"
    ]

    for (prefix, provider) in providerMap where sub.hasPrefix(prefix) {
        return provider
    }

    return nil
}

private func extractProviderFromIssuer(_ issuer: String?) -> String? {
    guard let iss = issuer else { return nil }

    print("🔍 Checking issuer for provider: \(iss)")

    let providers = ["google", "facebook", "apple"]
    for provider in providers where iss.contains(provider) {
        return provider
    }

    return nil
}

private func extractProviderFromIdp(_ idp: String?) -> String? {
    guard let idp else { return nil }

    print("🔍 Found idp field: \(idp)")
    return idp.lowercased()
}

public func extractEmailFromToken(_ idToken: String?) -> String? {
    guard let token = idToken else {
        print("❌ No token provided for email extraction")
        return nil
    }

    do {
        let jwt = try decode(jwt: token)

        // Try multiple possible email fields
        if let email = jwt.body["email"] as? String, !email.isEmpty {
            print("✅ Found email: \(email)")
            return email
        }

        // Check for email in user_metadata or app_metadata
        if let userMetadata = jwt.body["user_metadata"] as? [String: Any],
           let email = userMetadata["email"] as? String, !email.isEmpty {
            print("✅ Found email in user_metadata: \(email)")
            return email
        }

        if let appMetadata = jwt.body["app_metadata"] as? [String: Any],
           let email = appMetadata["email"] as? String, !email.isEmpty {
            print("✅ Found email in app_metadata: \(email)")
            return email
        }

        // Some providers use 'name' field for email
        if let name = jwt.body["name"] as? String, name.contains("@") {
            print("✅ Found email in name field: \(name)")
            return name
        }

        // Check for email in custom fields
        if let customEmail = jwt.body["https://yourapp.com/email"] as? String, !customEmail.isEmpty {
            print("✅ Found email in custom field: \(customEmail)")
            return customEmail
        }

        // If no email found, this is normal for some providers (like Apple)
        // when users choose not to share email or Auth0 isn't configured to request it
        print("🔍 No email found in JWT token - this is normal for some providers")
        return nil
    } catch {
        print("❌ Failed to decode JWT for email extraction: \(error)")
        return nil
    }
}
