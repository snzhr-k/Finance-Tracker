import Foundation
import SwiftData

enum ExpenseCategory : String, Codable, CaseIterable
{
    case food
    case rent
    case gift
    case saving
    case trip
    case undefined
}

enum IncomeCategory : String, Codable, CaseIterable
{
    case salary
    case gift
    case undefined
}

enum OperationCategory : Codable
{
    case expense(ExpenseCategory)
    case income(IncomeCategory)
}

//I do want to persist this data since it is refered in the Account model
@Model
class Operation {
    var id: UUID
    var date: Date
    var amount: Decimal
    var type: OperationCategory
    
    //depricated for now
    //var savingGoal: SavingGoal?
    
    init(date: Date, 
         amount: Decimal,
         type: OperationCategory)
    {
        self.id = UUID()
        self.date = date
        self.amount = amount
        self.type = type
    }
    
    
}

extension Date {
    var startOfDay : Date {
        Calendar.current.startOfDay(for: self)
    }
}




