//
//  grocery_tracker_clientApp.swift
//  grocery-tracker-client
//
//  Created by Dayanand Balasubramanian on 05/08/2023.
//

import SwiftUI

/*
 - Create a settings page where we can add the API key and the endpoint!
 - Add ability to scan barcode
 */

@main
struct grocery_tracker_clientApp: App {
    var body: some Scene {
        WindowGroup {
            InventoryView()
        }
    }
}
