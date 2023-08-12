//
//  AddStockView.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 09/08/2023.
//

import SwiftUI
import CodeScanner

struct EditStockView: View {
    @State private var submitting: Bool
    @State private var inErrorState: Bool
    @State private var isPerishable: Bool
    @Binding var stockViewModel: StockViewModel
    @State private var expiryDate: Date
    let newItem: Bool
    //@Binding var editing: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var onItemAdded: ((StockViewModel) -> Void)?
    
    init(submitting: Bool = false, inErrorState: Bool = false, stockViewModel: Binding<StockViewModel>, newItem: Bool, onItemAdded: ( (StockViewModel) -> Void)? = nil) {
        self._stockViewModel = stockViewModel
        self.newItem = newItem
        self.onItemAdded = onItemAdded
        self._submitting = State(initialValue: submitting)
        self._inErrorState = State(initialValue: inErrorState)
        self._isPerishable = State(initialValue: (stockViewModel.wrappedValue.expiry != nil))
        self._expiryDate = State(initialValue: stockViewModel.wrappedValue.expiry ?? Date())

    }
    
    var body: some View {
        Form {
            LabeledContent("Barcode", value: stockViewModel.barcode)
            TextField("Name", text: $stockViewModel.name)
            TextField("Brand (Optional)", text: $stockViewModel.brand)
            Stepper("^[\(stockViewModel.quantity) unit](inflect: true)", value: $stockViewModel.quantity, in: 1...100)
            DatePicker("Purchase Date", selection: $stockViewModel.bought, displayedComponents: [.date])
            Toggle("Perishable", isOn: $isPerishable)
            if self.isPerishable {
                DatePicker("Expiry Date", selection: $expiryDate, displayedComponents: [.date])
            }
            if !self.submitting {
                Button(newItem ? "Add Item" : "Update Item") {
                    // TODO: Do validation checks!
                    closeKeyboard()
                    self.submitting = true
                    Task {
                        do {
                            self.stockViewModel.expiry = self.isPerishable ? expiryDate : nil
                            let stock = try await addStock(viewModel: self.stockViewModel)
                            self.stockViewModel.id = stock.id
                            onItemAdded?(self.stockViewModel)
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
            if !newItem {
                Section {
                    Button("Delete item", role: .destructive) {
                        print("blah")
                    }
                }
            }
        }.disabled(submitting).alert("Unable to resolve barcode!", isPresented: $inErrorState) {}
    }
}

func closeKeyboard() {
  UIApplication.shared.sendAction(
    #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
  )
}

struct EditStockView_Previews: PreviewProvider {
    static var previews: some View {
        EditStockView(stockViewModel: .constant(StockViewModel.empty(barcode: "123")), newItem: true)
    }
}
