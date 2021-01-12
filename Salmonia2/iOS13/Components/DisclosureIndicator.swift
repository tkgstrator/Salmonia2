//
//  DisclosureIndicator.swift
//  Salmonia2
//
//  Created by devonly on 2020-12-25.
//

import SwiftUI

struct DisclosureIndicator: View {
    
//    @ScaledMetric private var size: CGFloat = 13.5
    
    var body: some View {
        Image(systemName: "chevron.right")
            .foregroundColor(Color(.tertiaryLabel))
            .font(.system(size: 13.5, weight: .semibold))
    }
}

struct DisclosureIndicator_Previews: PreviewProvider {
    static var previews: some View {
        DisclosureIndicator()
    }
}
