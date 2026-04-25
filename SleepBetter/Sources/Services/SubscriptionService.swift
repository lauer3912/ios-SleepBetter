import Foundation
import StoreKit

final class SubscriptionService {
    static let shared = SubscriptionService()

    private let productIds = ["sleepbetter_premium_monthly", "sleepbetter_premium_yearly"]

    var products: [Product] = []
    var purchasedProducts: [Product] = []

    var isPremium: Bool {
        purchasedProducts.contains { $0.id == productIds[0] } ||
        purchasedProducts.contains { $0.id == productIds[1] }
    }

    private init() {
        Task {
            await loadProducts()
        }
    }

    @MainActor
    func loadProducts() async {
        do {
            products = try await Product.products(for: productIds)
        } catch {
            print("Failed to load products: \(error)")
        }
    }

    @MainActor
    func purchase(_ product: Product) async throws -> Bool {
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            await transaction.finish()
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

    @MainActor
    func restorePurchases() async {
        await updatePurchasedProducts()
    }

    @MainActor
    private func updatePurchasedProducts() async {
        var purchased: [Product] = []

        for await result in Transaction.currentEntitlements {
            if case .success(let transaction) = result {
                if let product = products.first(where: { $0.id == transaction.productID }) {
                    purchased.append(product)
                }
            }
        }

        purchasedProducts = purchased
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw SubscriptionError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }

    enum SubscriptionError: Error {
        case verificationFailed
    }
}