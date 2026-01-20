import SwiftData
import Foundation
import SwiftUI

// MARK: - Sidebar

struct AccountSidebarView: View {
    let accounts: [Account]
    @Binding var selectedAccount: Account?

    let onCreate: () -> Void
    let onDeleteRequest: (Account) -> Void

    var body: some View {
        List(selection: $selectedAccount) {
            ForEach(accounts) { account in
                Label(account.name, systemImage: "creditcard")
                    .contentShape(Rectangle())
                    .tag(account)
                    .contextMenu {
                        Button(role: .destructive) {
                            onDeleteRequest(account)
                        } label: {
                            Label("Delete Account", systemImage: "trash")
                        }
                    }
            }
        }
        .navigationTitle("Accounts")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button(action: onCreate) {
                    Image(systemName: "plus.circle")
                }
            }
        }
        .onChange(of: accounts) {
            if selectedAccount == nil {
                selectedAccount = accounts.first
            }
        }
    }
}

// MARK: - Detail Wrapper

struct AccountDetailView: View {
    let account: Account?

    var body: some View {
        if let account {
            AccountContentView(account: account)
        } else {
            ContentUnavailableView(
                "No Account Selected",
                systemImage: "creditcard",
                description: Text("Select an account from the sidebar")
            )
        }
    }
}



// MARK: - AccountView (Root)

struct AccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]

    @State private var selectedAccount: Account?
    @State private var accountToDelete: Account?
    @State private var showCreateAccount = false

    var body: some View {
        NavigationSplitView {
            AccountSidebarView(
                accounts: accounts,
                selectedAccount: $selectedAccount,
                onCreate: { showCreateAccount = true },
                onDeleteRequest: { accountToDelete = $0 }
            )
        } detail: {
            AccountDetailView(account: selectedAccount)
        }
        .sheet(isPresented: $showCreateAccount) {
            CreateAccountView(presentSheet: $showCreateAccount)
                .frame(minWidth: 500, minHeight: 600)
        }
        .confirmationDialog(
            "Delete Account?",
            isPresented: Binding(
                get: { accountToDelete != nil },
                set: { if !$0 { accountToDelete = nil } }
            ),
            titleVisibility: .visible
        ) {
            Button("Delete Account", role: .destructive) {
                if let account = accountToDelete {
                    if selectedAccount == account {
                        selectedAccount = nil
                    }
                    modelContext.delete(account)
                }
                accountToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                accountToDelete = nil
            }
        }
    }
}




// MARK: - Operations Tab

struct OperationsTab: View {
    let account: Account
    let onAdd: () -> Void
    let onEdit: (Operation) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            header
            Divider()
            List {
                ForEach(account.operations.sorted { $0.date > $1.date }) { operation in
                    OperationRowView(operation: operation, account: account)
                        .contextMenu {
                            Button("Edit") { onEdit(operation) }
                        }
                }
            }
        }
        .padding()
    }

    private var header: some View {
        VStack(alignment: .leading) {
            Text(account.name)
                .font(.largeTitle)
                .bold()
            Text(account.currentAmount, format: .currency(code: account.currencyCode))
                .foregroundStyle(.secondary)
        }
    }
}



struct OperationRowView : View {
    let operation: Operation
    let account: Account

    var body: some View {
        HStack {
            Image(systemName: operation.icon)
                .foregroundStyle(operation.color)
                .frame(width: 24)

            VStack(alignment: .leading) {
                Text(operation.categoryDisplayName)
                    .font(.headline)

                Text(operation.date, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(operation.amount, format: .currency(code: account.currencyCode))
                .foregroundStyle(operation.color)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Account Content

struct AccountContentView: View {
    @Bindable var account: Account

    @State private var selectedTab: Tab = .operations
    @State private var selectedOperation: Operation?
    @State private var showOperationSheet = false
    @State private var showGoalSheet = false

    enum Tab {
        case operations
        case goals
    }

    var body: some View {
        NavigationStack {
            TabView(selection: $selectedTab) {
                OperationsTab(
                    account: account,
                    onAdd: {
                        selectedOperation = nil
                        showOperationSheet = true
                    },
                    onEdit: {
                        selectedOperation = $0
                        showOperationSheet = true
                    }
                )
                .tabItem { Label("Operations", systemImage: "list.bullet") }
                .tag(Tab.operations)

                GoalsTab(account: account)
                    .tabItem { Label("Saving Goals", systemImage: "target") }
                    .tag(Tab.goals)
            }
            .navigationTitle(account.name)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        switch selectedTab {
                        case .operations:
                            selectedOperation = nil
                            showOperationSheet = true
                        case .goals:
                            showGoalSheet = true
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showOperationSheet) {
            CreateOperationView(
                account: account,
                operationToEdit: selectedOperation
            )
        }
        .sheet(isPresented: $showGoalSheet) {
            CreateSavingGoalView(account: account)
        }
    }
}

struct CreateAccountView : View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    
    @Binding var presentSheet: Bool
    
    private let currencyCodes = ["HUF", "EUR", "KZT", "RUB"]
    
    @State private var accountName: String = ""
    @State private var currencyCode: String = "HUF"
    @State private var currentAmount: Decimal = 0.0
    
    func validateAccountCreation(_ name: String, transfer amount: Decimal) -> Bool
    { /**Validates the account data, returns true if all data is valid, false otherwise**/
        return (!name.isEmpty && amount >= 0)
    }
    
    var errorMessage: String? {
        if (accountName.isEmpty) {return "Invalid account name"}
        else if (currentAmount < 0) {return "Invalid amount of initial deposit"}
        else {return nil}
    }
    var isFormValid: Bool {
        !accountName.isEmpty && currentAmount >= 0
    }
    
    @State var didEditName: Bool = false
    @State var didEditAmount: Bool = false
    
    var body: some View {
        Form{
            Section {
                TextField("Account Name", text: $accountName).onSubmit {
                    didEditName = true

                    
                }
                Picker("Currency Code", selection: $currencyCode) {
                    ForEach(currencyCodes, id: \.self) {
                        Text($0)
                    }
                }.pickerStyle(DefaultPickerStyle())
            }
            
            Section {
                TextField("Income",
                          value: $currentAmount,
                          format: .currency(code: currencyCode))
            } header: {
                Text("Initial Deposit")
            } footer: { //TODO: fix it to show only when the input data is invalid
                if currentAmount < 0 {
                    Text("Invalid amount").foregroundStyle(.red)
                }
            }
           
            Section{
                HStack{
                    Button {
                        presentSheet = false
                    } label: {
                        Image(systemName: "xmark.circle")
                        Text("Cancel")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Spacer()
                    
                    Button {
                        if (isFormValid){
                            let newAccount: Account = Account(name: accountName, currencyCode: currencyCode, initialDeposit: currentAmount)
                            modelContext.insert(newAccount)
                            presentSheet = false
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                        Text("Create")
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.green)
                    .disabled(!isFormValid)
                }.padding()
            }
        }.formStyle(.grouped)
        .padding()
    }
}

struct CreateOperationView : View {
    @Environment(\.dismiss) private var dismiss
    
    let account: Account
    let operationToEdit: Operation?
    
    enum OperationKind : String, CaseIterable, Identifiable {
        case income
        case expense
        
        var id: String {rawValue}
    }
    
    @State private var amount: Decimal = 0.0
    @State private var kind : OperationKind = .income
    @State private var incomeCategory : IncomeCategory = .undefined
    @State private var expenseCategory : ExpenseCategory = .undefined
    @State private var date: Date = Date()
    
    var isFormValid: Bool {
        amount >= 0
    }
    
    init (account: Account, operationToEdit: Operation? = nil) {
        self.account = account
        self.operationToEdit = operationToEdit

        if let operation = operationToEdit {
            _amount = State(initialValue: operation.amount)
            _date = State(initialValue: operation.date)

            switch operation.type {
            case .income(let category):
                _kind = State(initialValue: .income)
                _incomeCategory = State(initialValue: category)

            case .expense(let category):
                _kind = State(initialValue: .expense)
                _expenseCategory = State(initialValue: category)
            }
        }
    }
    
    
    
    var body : some View {
        Text(operationToEdit == nil ? "New Operation" : "Edit Operation")
            .font(.largeTitle)
            .bold()
        
        Form {
            /**Picker for the operation kind (expense/income)**/
            Picker ("Type", selection : $kind) {
                ForEach(OperationKind.allCases) { kind in
                    Text(kind.rawValue.capitalized)
                        .tag(kind)
                }
            }
            .disabled(operationToEdit != nil)
            .pickerStyle(.segmented)
            .padding()
            
            /**picker of the income/expense category depending on the category**/
            if kind == .income {
                Picker("Category", selection: $incomeCategory){
                    ForEach(IncomeCategory.allCases, id: \.self){
                        Text($0.rawValue.capitalized)
                    }
                }
                .padding()
            } else {
                Picker("Category", selection: $expenseCategory){
                    ForEach(ExpenseCategory.allCases, id: \.self){
                        Text($0.rawValue.capitalized)
                    }
                }
                .padding()
            }
            
            //date field
            DatePicker(
                "Date",
                selection: $date,
                displayedComponents: [.date]
            )
            .datePickerStyle(.graphical)
            .padding()
            
            //amount field
            TextField(
                "Amount",
                value: $amount,
                format: .currency(code: account.currencyCode)
            )
            
            /**cancel & submit buttons**/
            Section{
                HStack{
                    //Cancel button
                    Button {
                        dismiss()
                    } label : {
                        Image(systemName: "xmark.circle")
                        Text("Cancel")
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                    
                    Spacer()
            
                    //submit button
                    Button {
                        guard isFormValid else { return }

                        let category: OperationCategory =
                            kind == .income
                            ? .income(incomeCategory)
                            : .expense(expenseCategory)

                        
                        
                        withAnimation{
                            if let operation = operationToEdit {
                                operation.amount = amount
                                operation.date = date
                                operation.type = category
                            } else {
                                account.addOperation(
                                    date: date,
                                    amount: amount,
                                    type: category
                                )
                            }
                        }
                        dismiss()
                        
                        
                
                    } label: {
                        Image(systemName: operationToEdit == nil ? "plus.circle" : "checkmark.circle")
                        Text(operationToEdit == nil ? "Create" : "Save")
                    }
                    .keyboardShortcut(.return, modifiers: [])
                    .buttonStyle(.bordered)
                    .foregroundColor(.green)
                    .disabled(!isFormValid)
            
                }
                .padding()
            }
            
            
            
            
        }
    }
    
}
