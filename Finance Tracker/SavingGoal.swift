import Foundation
import SwiftData


//shortly speaking it is a mini account
@Model
class SavingGoal : Identifiable {
    let id: UUID //might be not necessary
    
    var name: String
    var targetAmount: Decimal
    @Relationship var savingOperations: [Operation]
    var currentAmount: Decimal {
        return savingOperations.reduce(0){ result, operation in
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
    
    init(id: UUID, name: String, targetAmount: Decimal, initialDeposit: Decimal = 0.0) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.savingOperations = []        
    }
}
