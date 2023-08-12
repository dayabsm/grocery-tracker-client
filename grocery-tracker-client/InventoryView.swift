//
//  ContentView.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 05/08/2023.
//

import SwiftUI

struct InventoryView: View {
    @State var inventory: [StockViewModel] = []
    @State private var isLoading = true
    @State private var showAddItemView = false
    var body: some View {
        NavigationStack {
            if !self.isLoading {
                VStack {
                    List {
                        ForEach($inventory) { $stock in
                            NavigationLink {
                                StockDetailView(stock: $stock, inventory: $inventory)
                            } label: {
                                StockView(stock: stock)
                            }.swipeActions {
                                Button(role: .destructive) { print("Hello World") } label: { Label("Delete", systemImage: "trash") }
                            }
                        }
                    }.navigationTitle("Your Pantry").listStyle(.inset).refreshable {
                        self.inventory = await loadInventory()
                    }
                }
            } else {
                ProgressView()
            }
        }.task {
            self.inventory = await loadInventory()
            isLoading = false
        }.sheet(isPresented: $showAddItemView) {
            AddStockView(inventory: $inventory)
        }.toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Spacer()
                Button {
                        self.showAddItemView = true
                    } label: {
                        Label("New Item", systemImage: "barcode.viewfinder")
                    }.labelStyle(.automatic)
            }
        }
    }
}

struct InventoryView_Previews: PreviewProvider {
    static var previews: some View {
        InventoryView(inventory: StockViewModel.sampleData)
    }
}
