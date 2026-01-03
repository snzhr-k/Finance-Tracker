import Foundation
import SwiftData

@Model
class Account 
{
    var id: UUID
    var name: String
    @Relationship var operations: [Operation]
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
        operations.append(Operation(date: Date.now, amount: initialDeposit, type: OperationCategory.income(IncomeCategory.undefined)))
    }
    
    func addOperation(date: Date, amount: Decimal, type: OperationCategory) -> Void {
        let operation: Operation = Operation(date: date, amount: amount, type: type)
        operations.append(operation)
    }
    
    func removeOperation(operation: Operation) -> Void {
        operations.removeAll { $0 == operation }
    }
    
}


