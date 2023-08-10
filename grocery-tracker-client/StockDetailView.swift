//
//  StockDetailView.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 09/08/2023.
//

import SwiftUI

struct StockDetailView: View {
    let stock: StockViewModel
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(stock.quantity) available").font(.title)
            if let brand = stock.brand {
                Text(brand).font(.subheadline).foregroundColor(.secondary)
            }
            Spacer()
        }.padding().navigationTitle(stock.name).frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct StockDetailView_Previews: PreviewProvider {
    static var previews: some View {
        StockDetailView(stock:StockViewModel.sampleData[0])
    }
}
