import Foundation
import SwiftData

@Model
class PlannedPurchase : Identifiable{
    var category: ExpenseCategory
    var price: Decimal
    var name: String = ""
    
    init(category: ExpenseCategory = ExpenseCategory.undefined, price: Decimal, name: String){
        self.category = category
        self.price = price
        self.name = name
    }
}
