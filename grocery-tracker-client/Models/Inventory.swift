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
    configuration.httpAdditionalHeaders = ["x-api-key": "RY6GLvY4S4660MaophhR8a8ui062or7l5mlxeLsW"]
    return URLSession(configuration: configuration)
}

func urlRequest(resource: String) -> URLRequest {
    let endpointURL = URL(string: "https://cd7u7aaxvi.execute-api.eu-west-2.amazonaws.com/test/\(resource)")!
    return URLRequest(url: endpointURL)
}

func loadInventory() async -> [StockViewModel] {
    let session = urlSession()
    var request = urlRequest(resource: "inventory")
    request.httpMethod = "GET"
    let (data, _) = try! await session.data(for: request)
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let inventory = try! decoder.decode([Stock].self, from:data)
    return inventory.map { StockViewModel.fromStock(stock: $0) }
}

struct RawProductResponse: Decodable {
    let product_name: String?
    let brands: String?
}

struct RawBarcodeResponse: Decodable {
    let code: String
    let product: RawProductResponse
    let status: Int?
    let status_verbose: String?
}

struct ProductResponse: Decodable {
    let product_name: String
    let brands: String?
}

func queryBarcode(barcode: String) async throws -> ProductResponse? {
    let endpointURL = URL(string: "https://world.openfoodfacts.org/api/v0/product/\(barcode).json")!
    let urlRequest = URLRequest(url: endpointURL)
    let (data, _) = try! await URLSession.shared.data(for: urlRequest)
    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
    do {
        let barcodeResponse = try JSONDecoder().decode(RawBarcodeResponse.self, from:data)
        let productName = barcodeResponse.product.product_name ?? resolveProductName(productJson: json["product"] as! [String : Any])
        guard let productName = productName else {
            return nil
        }
        return ProductResponse(product_name: productName, brands: barcodeResponse.product.brands)
    } catch {
        return nil
    }
}

func resolveProductName(productJson: [String: Any]) -> String? {
    for (key, value) in productJson {
        if key.hasPrefix("product_name") {
            return value as? String
        }
    }
    
    return nil
}

func addStock(viewModel: StockViewModel) async throws -> Stock {
    return try! await addStock(barcode: viewModel.barcode, quantity: viewModel.quantity, productHint: ProductHint(product_name: viewModel.name, brand: viewModel.brand), bought: viewModel.bought, expiry: viewModel.expiry)
}


func addStock(barcode: String, quantity: Int, productHint: ProductHint, bought: Date, expiry: Date?) async throws -> Stock {
    let session = urlSession()
    var request = urlRequest(resource: "stock")
    request.httpMethod = "POST"
    let stockPartition = StockParitionRequest(quantity: quantity, bought: bought.timeIntervalSince1970, expiry: expiry?.timeIntervalSince1970)
    let stockRequest = StockRequest(barcode: barcode, product: productHint, partitions: [stockPartition])
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    request.httpBody = try! encoder.encode(stockRequest)
    let (data, response) = try! await session.data(for: request)
    if (response as! HTTPURLResponse).statusCode != 200 {
        throw InventoryError.unresolvedBarcode
    }
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let stock = try! decoder.decode(Stock.self, from:data)
    return stock
}
