import Foundation
import SwiftData

@Model
class SavingGoal : Identifiable {
    let id: UUID
    var name: String
    var targetAmount: Decimal
    @Relationship var operations: [Operation]
    var currentAmount: Decimal {
        return operations.reduce(0){ result, operation in
            switch operation.type {
            case .income (let incomeCategory):
                return result + operation.amount
            case .expense (let expenseCategory) :
                return result - operation.amount
            }
        }
    }
    var progressAmount: Decimal {
        return targetAmount - currentAmount
    }
    var progressPercentage: Double {
        guard targetAmount > 0 else {return 0}
        return (NSDecimalNumber(decimal: currentAmount)
            .dividing(by: NSDecimalNumber(decimal:targetAmount))
            .doubleValue)
    }
    
    init(id: UUID, name: String, targetAmount: Decimal) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.operations = []
        
    }
}
