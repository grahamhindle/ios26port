import Testing
@testable import UserFeature
import SharedModels

struct UserFeatureTests {
    @Test func userModelInitialization() async throws {
        let model = UserModel()
        #expect(model.users.isEmpty)
        #expect(model.searchText == "")
        #expect(model.userForm == nil)
    }
}