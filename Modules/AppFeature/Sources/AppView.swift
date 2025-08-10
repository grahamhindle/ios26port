public struct AppView: View {
    @Bindable var store: StoreOf<AppFeature>

    public init(store: StoreOf<AppFeature>) {
        self.store = store
    }

    public var body: some View {
        Group {
            if let store = store.scope(state: \.welcomeState, action: \.welcome) {
                WelcomeView(store: store)
            } else if let store = store.scope(state: \.tabBarState, action: \.tabBar) {
                TabBarView(store: store)
            } else {
                // Loading state while checking authentication
                ProgressView("Loading...")
            }
        }
        .onAppear {
            store.send(.onAppear)
        }
    }
}

#Preview {
    AppView(store: Store(initialState: AppFeature.State()) {
        AppFeature()
    })
}
