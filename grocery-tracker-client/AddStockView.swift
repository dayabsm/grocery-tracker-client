//
//  AddStockView.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 09/08/2023.
//

import SwiftUI
import CodeScanner

struct AddStockView: View {
    @State private var inErrorState = false
    @Binding var inventory: [StockViewModel]
    @State private var stockViewModel: StockViewModel = StockViewModel.empty(barcode: "")
    @State private var scanComplete = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing:0) {
                if !scanComplete {
                    // TODO: Check which kinds of barcodes we actually need
                    CodeScannerView(codeTypes: [.upce, .ean13, .gs1DataBarExpanded], scanMode: .continuous) { result in
                        switch result {
                        case .success(let result):
                            let scannedBarcode = result.string
                            Task {
                                let productResponse = try! await queryBarcode(barcode: result.string)
                                if let productResponse = productResponse {
                                    self.stockViewModel = StockViewModel.basic(barcode: scannedBarcode, name: productResponse.product_name, brand: productResponse.brands)
                                    scanComplete = true
                                }
                            }
                        case .failure(let error):
                            // TODO: Handle errors here!
                            self.inErrorState = true
                        }
                    }.frame(height:geometry.size.height)
                } else {
                    EditStockView(stockViewModel: $stockViewModel, newItem: true) { stockViewModel in
                        inventory.append(stockViewModel)
                    }
                }
            }.navigationTitle("New item").alert("Unable to resolve barcode!", isPresented: $inErrorState) {}
        }
    }
}

struct AddStockView_Previews: PreviewProvider {
    static var previews: some View {
        AddStockView(inventory: .constant([]))
    }
}
