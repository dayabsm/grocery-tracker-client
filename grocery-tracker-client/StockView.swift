//
//  StockView.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 06/08/2023.
//

import SwiftUI

struct StockView: View {
    @ObservedObject var stock: StockViewModel
    var body: some View {
        HStack {
            Text(stock.name)
            Spacer()
            Text("\(stock.quantity)")
        }.padding(.horizontal, 10)
    }
}

struct StockView_Previews: PreviewProvider {
    static var stock = StockViewModel.sampleData[0]
    static var previews: some View {
        StockView(stock: stock).previewLayout(.fixed(width: 200, height: 60))
    }
}
