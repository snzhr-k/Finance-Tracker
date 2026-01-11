import Foundation
import SwiftData
import SwiftUI

//shortly speaking it is a mini account
@Model
class SavingGoal : Identifiable {
    var id: UUID  // Mutable now, set in init
    
    var name: String
    var targetAmount: Decimal
    @Relationship var savingOperations: [Operation] = []  // Default here too
    @Relationship(deleteRule: .nullify, inverse: \Account.savingGoals)
    var account: Account?  // Add this property if missing
    
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
    
    init(id: UUID = UUID(), name: String, targetAmount: Decimal, account: Account) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.account = account
        // No initialDeposit—handle allocations post-creation for safety
    }
}

struct SavingGoalDetailView: View {
    let goal: SavingGoal
    let account: Account
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(goal.name)
                .font(.largeTitle)
                .bold()
            
            Text("\(goal.currentAmount, format: .currency(code: account.currencyCode)) / \(goal.targetAmount, format: .currency(code: account.currencyCode))")
                .font(.title3)
                .foregroundStyle(.secondary)
            
            ProgressView(value: goal.progressPercentage)
                .progressViewStyle(.linear)
            
            Divider()
            
            List {
                ForEach(goal.savingOperations.sorted(by: { $0.date > $1.date })) { operation in
                    OperationRowView(operation: operation, account: account)
                }
            }
        }
        .padding()
    }
}

struct SavingGoalRowView: View {
    let goal: SavingGoal
    let currencyCode: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(goal.name)
                    .font(.headline)
                
                Text("\(goal.currentAmount, format: .currency(code: currencyCode)) / \(goal.targetAmount, format: .currency(code: currencyCode))")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            ProgressView(value: goal.progressPercentage)
                .progressViewStyle(.linear)
                .frame(width: 100)
        }
        .padding(.vertical, 4)
    }
}

struct CreateSavingGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var targetAmount: Decimal = 0.0
    
    let account: Account  // Passed from parent
    
    var isFormValid: Bool {
        !name.isEmpty && targetAmount > 0
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Name", text: $name)
                    TextField("Target Amount", value: $targetAmount, format: .currency(code: account.currencyCode))
                } header: {
                    Text("New Saving Goal")
                }
                
                if targetAmount <= 0 {
                    Text("Target must be greater than zero").foregroundStyle(.red)
                }
            }
            .toolbar {
                ToolbarContent()  // Explicit builder to fix inference error
            }
            .frame(minWidth: 400, minHeight: 200)
        }
    }
    
    @ToolbarContentBuilder
    private func ToolbarContent() -> some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                dismiss()
            }
        }
        
        ToolbarItem(placement: .confirmationAction) {
            Button("Create") {
                let goal = SavingGoal(name: name, targetAmount: targetAmount, account: account)
                modelContext.insert(goal)
                dismiss()  // Close sheet after creation
            }
            .disabled(!isFormValid)
        }
    }
}


