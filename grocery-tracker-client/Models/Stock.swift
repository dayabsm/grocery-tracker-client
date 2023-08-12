//
//  Stock.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 06/08/2023.
//

import Foundation

struct StockPartition: Decodable {
    let id: Int
    let quantity: Int
    let bought: Double
    let expiry: Double?
}


struct Stock: Decodable {
    let id: Int
    let name: String
    let barcode: String
    let brand: String?
    let partitions: [StockPartition]
}

class StockViewModel: ObservableObject, Identifiable {
    init(id: Int, barcode: String, name: String, quantity: Int, bought: TimeInterval, brand: String?, expiry: TimeInterval?) {
        self.barcode = barcode
        self.id = id
        self.name = name
        self.quantity = quantity
        self.brand = brand ?? ""
        self.bought = Date(timeIntervalSince1970: bought)
        self.expiry = expiry != nil ? Date(timeIntervalSince1970: expiry!) : nil
    }
    
    static func empty(barcode: String) -> StockViewModel {
        return StockViewModel(id: 0, barcode: barcode, name: "", quantity: 1, bought: Date().timeIntervalSince1970, brand: "", expiry: nil)
    }

    static func basic(barcode: String, name: String, brand: String?) -> StockViewModel {
        return StockViewModel(id: 0, barcode: barcode, name: name, quantity: 1, bought: Date().timeIntervalSince1970, brand: brand ?? "", expiry: nil)
    }
    
    var id: Int
    let barcode: String
    @Published var name: String
    @Published var brand: String = ""
    @Published var bought: Date
    @Published var expiry: Date?
    @Published var quantity: Int = 1
}

extension StockViewModel {
    static func fromStock(stock: Stock) -> StockViewModel {
        let partition = stock.partitions[0]
        return StockViewModel(id: stock.id, barcode: stock.barcode, name: stock.name, quantity: partition.quantity, bought: partition.bought, brand: stock.brand, expiry: partition.expiry)
    }
    
    static let sampleData: [StockViewModel] = [
        StockViewModel(id: 1, barcode: "123", name: "Xbox", quantity: 1, bought: Date().timeIntervalSince1970, brand: "Microsoft", expiry: Date().timeIntervalSince1970),
        StockViewModel(id: 2, barcode: "456", name: "PS5", quantity: 2, bought: Date().timeIntervalSince1970, brand: "Sony", expiry: Date().timeIntervalSince1970),
    ]
}

struct ProductHint: Encodable {
    let product_name: String
    let brand: String?
}

struct StockParitionRequest: Encodable {
    let quantity: Int
    let bought: TimeInterval
    let expiry: TimeInterval?
}

struct StockRequest: Encodable {
    let barcode: String
    let product: ProductHint
    let partitions: [StockParitionRequest]

}
