//
//  Stock.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 06/08/2023.
//

import Foundation



struct Product: Decodable {
    let id: Int
    let name: String
    let brand: String?
}

struct Barcode: Decodable {
    let id: Int
    let code: String
    let product_id: Int
    let product: Product
}

struct Stock: Decodable {
    let id: Int
    let barcode_id: Int
    let quantity: Int
    let barcode: Barcode
}

class StockViewModel: ObservableObject {
    init(id: Int, name: String, quantity: Int, brand: String?) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.brand = brand
    }
    
    let id: Int
    let name: String
    let brand: String?
    @Published var quantity: Int = 1
}

extension StockViewModel {
    static func fromStock(stock: Stock) -> StockViewModel {
        return StockViewModel(id: stock.id, name: stock.barcode.product.name, quantity: stock.quantity, brand: stock.barcode.product.brand)
    }
    
    static let sampleData: [StockViewModel] = [
        StockViewModel(id: 1, name: "Xbox", quantity: 1, brand: "Microsoft"),
        StockViewModel(id: 2, name: "PS5", quantity: 2, brand: "Sony"),
    ]
}

struct StockRequest: Encodable {
    let barcode: String
    let quantity: Int
}
