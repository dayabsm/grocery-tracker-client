//
//  Inventory.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 05/08/2023.
//

import Foundation

enum InventoryError: Error {
    case unresolvedBarcode
}

func urlSession() -> URLSession {
    let configuration = URLSessionConfiguration.default
    configuration.httpAdditionalHeaders = ["x-api-key": "Izx7nph7Xb3DcZDUGYhcr4BMFC3ubjs88j87Qk3C"]
    return URLSession(configuration: configuration)
}

func urlRequest(resource: String) -> URLRequest {
    let endpointURL = URL(string: "https://azmaelkkze.execute-api.eu-west-2.amazonaws.com/test/\(resource)")!
    return URLRequest(url: endpointURL)
}

func loadInventory() async -> [StockViewModel] {
    let session = urlSession()
    var request = urlRequest(resource: "inventory")
    request.httpMethod = "GET"
    let (data, _) = try! await session.data(for: request)
    let inventory = try! JSONDecoder().decode([Stock].self, from:data)
    return inventory.map { StockViewModel.fromStock(stock: $0) }
}

func addStock(barcode: String, quantity: Int) async throws -> Stock {
    let session = urlSession()
    var request = urlRequest(resource: "stock")
    request.httpMethod = "POST"
    let stockRequest = StockRequest(barcode: barcode, quantity: quantity)
    request.httpBody = try! JSONEncoder().encode(stockRequest)
    let (data, response) = try! await session.data(for: request)
    if (response as! HTTPURLResponse).statusCode != 200 {
        throw InventoryError.unresolvedBarcode
    }
    let stock = try! JSONDecoder().decode(Stock.self, from:data)
    return stock
}
