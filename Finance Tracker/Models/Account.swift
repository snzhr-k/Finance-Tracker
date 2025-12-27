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
    
//    var totalIncome: Decimal {
//        operations.reduce(0) { result, operation in
//            switch operation.type {
//            case .income(let incomeCategory) :
//                return result + operation.amount
//            }
//        }
//    }
//    var totalExpense: Decimal {
//        operations.reduce(0) { result, operation in
//            switch operation.type {
//            case .expense(let expenseCategory) :
//                return result - operation.amount
//            }
//        }
//    }
    
    //depricated for now
    //var plannedPurchases : [PlannedPurchase] = []
    //var savingGoals : [SavingGoal] = [] //better to make it just an empty array rather then making it optional field variable for easier check
    
//    init(){
//        self.id = UUID()
//        self.name = "Unidentified"
//        self.operations = []()
//        self.currencyCode = "HUF"
//    }
//    
//    init(
//        id: UUID = UUID(),
//        name: String,
//        currencyCode: String,
//        operations: [Operation] = []
//    ){
//        self.id = id
//        self.name = name
//        self.currencyCode = currencyCode
//        self.operations = operations
//    }
    
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
    
}


