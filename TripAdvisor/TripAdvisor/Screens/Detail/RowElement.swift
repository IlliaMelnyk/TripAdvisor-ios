
import SwiftUI

struct RowElement: View {
    var label: String
    var value: String
    
    var body: some View {
        VStack(alignment: .leading){
            Text(label)
                .font(.caption)
            Text(value)
                .font(.callout)
        }
    }
}

#Preview {
    RowElement(label: "Label text", value: "Value text")
}
