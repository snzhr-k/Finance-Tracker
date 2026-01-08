import Foundation
import SwiftData

@Model
class Account 
{
    var id: UUID
    var name: String
    
    @Relationship var operations: [Operation]
    @Relationship var savingGoals: [SavingGoal]
    @Relationship var plannedPurchases: [PlannedPurchase]
    
    var currencyCode: String
    var currentAmount: Decimal {
        operations.reduce(0) { result, operation in
            switch operation.type {
            case .income(let incomeCategory) : 
                return result + operation.amount
            case .expense (let expenseCategory) : 
                return result - operation.amount
            }
        }
    }
    
    init(
        id: UUID = UUID(),
        name: String,
        currencyCode: String,
        initialDeposit: Decimal
    ){
        self.id = id
        self.name = name
        self.currencyCode = currencyCode
        self.operations = []
        self.savingGoals = []
        self.plannedPurchases = []
        operations.append(Operation(date: Date.now, amount: initialDeposit, type: OperationCategory.income(IncomeCategory.undefined)))
    }
    
    func addOperation(date: Date, amount: Decimal, type: OperationCategory) -> Void {
        let operation: Operation = Operation(date: date, amount: amount, type: type)
        operations.append(operation)
    }
    
    func removeOperation(operation: Operation) -> Void {
        operations.removeAll { $0 == operation }
    }
    
    func allocate(to goal: SavingGoal, amount: Decimal) throws {
        guard currentAmount >= amount else {throw AllocationError.insufficientFunds}
        guard savingGoals.contains(goal) else {throw AllocationError.invalidGoal}
        
        let accountOp = Operation(date: Date.now, amount: amount, type: OperationCategory.expense(.saving))
        operations.append(accountOp)
        let goalOp = Operation(date: Date.now, amount: amount, type: OperationCategory.income(.undefined))
        goal.savingOperations.append(goalOp)
    }
    
}

enum AllocationError : Error {
    case insufficientFunds
    case invalidGoal
}


