//
//  StockDetailView.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 09/08/2023.
//

import SwiftUI

struct StockDetailView: View {
    @Binding var stock: StockViewModel
    @State var editing: Bool = false
    @Binding var inventory: [StockViewModel]
    var body: some View {
        EditStockView(stockViewModel: $stock, newItem: false).navigationTitle($stock.name)
        /*if !self.editing {
            VStack(alignment: .leading, spacing: 10) {
                Text("\(Image(systemName: "house")) \(stock.quantity) available")
                /*if let brand = stock.brand {
                    Text("\(Image(systemName: "tag")) \(brand)")
                }*/
                Group {
                    Text("\(Image(systemName: "cart")) Purchased: ") +
                    Text(stock.bought, style: .date)
                }
                if let expiry = stock.expiry {
                    Group {
                        Text("\(Image(systemName: "trash")) Expires: ") +
                        Text(expiry, style: .date)
                    }
                }
                Spacer()
            }.padding().navigationTitle(stock.name).frame(maxWidth: .infinity, alignment: .leading).toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Spacer()
                    Button {
                        self.editing = true
                    } label: {
                        Label("Edit", systemImage: "square.and.pencil")
                    }.labelStyle(.automatic)
                }
            }
        } else {
            EditStockView(stockViewModel: $stock).navigationTitle("Edit item")
        }*/
    }
}

struct StockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailView(stock:.constant(StockViewModel.sampleData[0]), inventory: .constant([]))
    }
}
