# ==== AuthFeature Lanes ====
#TAG group 1
desc "Build AuthFeature module"
  lane :build_auth do
    build_module(module: "AuthFeature")
  end
#TAG group 1
  desc "Test AuthFeature module"
  lane :test_auth do
    test_module(module: "AuthFeature")
  end
#TAG group 1
  desc "CI for AuthFeature module"
  lane :ci_auth do
    ci_module(module: "AuthFeature")
  end
