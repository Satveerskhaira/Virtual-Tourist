//
//  GCDBlankBox.swift
//  Virtual Tourist
//
//  Created by Satveer Singh on 1/27/18.
//  Copyright © 2018 Satveer Singh. All rights reserved.
//

import Foundation

func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}
