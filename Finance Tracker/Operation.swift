import Foundation
import SwiftData
import SwiftUI

enum ExpenseCategory : String, Codable, CaseIterable
{
    case food
    case rent
    case gift
    case saving
    case trip
    case undefined
    
    var displayName: String {
        rawValue.capitalized
    }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .rent: return "house"
        case .gift: return "gift"
        case .saving: return "archivebox"
        case .trip: return "backpack"
        case .undefined: return "questionmark.circle"
        }
    }
}

enum IncomeCategory : String, Codable, CaseIterable
{
    case salary
    case gift
    case interest
    case undefined

    var displayName: String {
        rawValue.capitalized
    }

    var icon: String {
        switch self {
        case .salary: return "banknote"
        case .gift: return "gift"
        case .interest: return "chart.line.uptrend.xyaxis"
        case .undefined: return "questionmark.circle"
        }
    }
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
    
    var categoryDisplayName: String {
        switch type {
        case .income(let category):
            return category.displayName
        case .expense(let category):
            return category.displayName
        }
    }

    var icon: String {
        switch type {
        case .income(let category):
            return category.icon
        case .expense(let category):
            return category.icon
        }
    }

    var color: Color {
        switch type {
        case .income:
            return .green
        case .expense:
            return .red
        }
    }
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




