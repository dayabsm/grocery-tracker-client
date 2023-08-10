//
//  AddStockView.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 09/08/2023.
//

import SwiftUI
import CodeScanner

struct AddStockView: View {
    @State private var barcode: String = ""
    @State private var quantity: Int = 1
    @State private var submitting = false
    @State private var inErrorState = false
    @Binding var inventory: [StockViewModel]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing:0) {
                // TODO: Check which kinds of barcodes we actually need
                CodeScannerView(codeTypes: [.upce, .ean13, .gs1DataBarExpanded], scanMode: .continuous) { result in
                    switch result {
                    case .success(let result):
                        self.barcode = result.string
                    case .failure(let error):
                        // TODO: Handle errors here!
                        self.inErrorState = true
                    }
                }.frame(height:geometry.size.height*0.66)
                Form {
                    TextField("Barcode", text: $barcode).keyboardType(.numberPad)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...100)
                    HStack {
                        Spacer()
                        if !self.submitting {
                            Button("Add Item") {
                                closeKeyboard()
                                self.submitting = true
                                Task {
                                    do {
                                        let added_stock = try await addStock(barcode:self.barcode, quantity: self.quantity)
                                        let matching_stock = inventory.first { stock in
                                            return stock.id == added_stock.id
                                        }
                                        if let resolved_stock = matching_stock {
                                            resolved_stock.quantity = added_stock.quantity
                                        } else {
                                            inventory.append(StockViewModel.fromStock(stock: added_stock))
                                        }
                                        self.presentationMode.wrappedValue.dismiss()
                                    } catch {
                                        // TODO: Clean this up!
                                        self.inErrorState = true
                                        self.submitting = false
                                    }
                                }
                            }
                        }
                        else {
                            ProgressView()
                        }
                        Spacer()
                    }
                }.disabled(submitting)
            }.navigationTitle("New item").alert("Unable to resolve barcode!", isPresented: $inErrorState) {}
        }
    }
}

func closeKeyboard() {
  UIApplication.shared.sendAction(
    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
  )
}

struct AddStockView_Previews: PreviewProvider {
    static var previews: some View {
        AddStockView(inventory: .constant([]))
    }
}
