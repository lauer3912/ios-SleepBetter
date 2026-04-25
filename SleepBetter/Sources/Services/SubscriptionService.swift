import Foundation
import StoreKit

@MainActor
final class SubscriptionService: ObservableObject {
    static let shared = SubscriptionService()

    private let productIds = ["sleepbetter_premium_monthly", "sleepbetter_premium_yearly"]

    @Published var products: [Product] = []
    @Published var purchasedProducts: [Product] = []

    var isPremium: Bool {
        !purchasedProducts.isEmpty
    }

    private init() {
        Task {
            await loadProducts()
            await updatePurchasedProducts()
        }
    }

    func loadProducts() async {
        do {
            products = try await Product.products(for: productIds)
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success:
            await updatePurchasedProducts()
            return true
        case .userCancelled:
            return false
        case .pending:
            return false
        @unknown default:
            return false
        }
    }

    func restorePurchases() async {
        await updatePurchasedProducts()
    }

    func updatePurchasedProducts() async {
        var purchased: [Product] = []

        for await result in Transaction.currentEntitlements {
            switch result {
            case .verified(let transaction):
                if let product = products.first(where: { $0.id == transaction.productID }) {
                    purchased.append(product)
                }
            case .unverified:
                break
            }
        }

        purchasedProducts = purchased
    }
}