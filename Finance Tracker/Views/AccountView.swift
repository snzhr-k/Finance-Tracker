import SwiftData
import Foundation
import SwiftUI

struct AccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    @State var presentSheet: Bool = false
    @State private var selectedAccount: Account?
    @State private var accountToDelete: Account?
    
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedAccount){ /**sidebar with the list of all accounts**/
                ForEach(accounts) { account in
                    Text(account.name)
                        .tag(account)
                        .contextMenu {
                            Button(role: .destructive){
                                confirmDelete(account)
                            } label: {
                                Label("Delete Account", systemImage: "trash")
                                
                            }
                        }
                }.onDelete(perform: deleteAccount)
                .onChange(of: accounts){
                    if selectedAccount == nil {
                        selectedAccount = accounts.first
                    }
                }
            }
            .navigationSplitViewColumnWidth(min: 180, ideal: 200)
            .toolbar{
                ToolbarItem(placement: .primaryAction){
                    Button{
                        presentSheet = true
                    } label: {
                        Image(systemName: "plus.circle")
                        //Text("Create") //NOTE: text of the buttons cannot be displayed in toolbar

                    }.buttonStyle(.borderedProminent)
                        .sheet(isPresented: $presentSheet, content: {
                            CreateAccountView(presentSheet: $presentSheet).frame(
                                minWidth: 500,
                                maxWidth: .infinity,
                                minHeight: 600,
                                maxHeight: .infinity)})
                }
                
                
            }
        } detail: {
            if let account = selectedAccount {
                AccountDetailView(account: account)
            } else {
                ContentUnavailableView(
                    "No Account Selected",
                    systemImage: "creditcard",
                    description: Text("Select an account from the sidebar")
                )
            }
        }.confirmationDialog(
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
                    accountToDelete = nil
                }
            }

            Button("Cancel", role: .cancel) {
                accountToDelete = nil
            }
        } message: {
            Text("This will permanently delete the account and all its operations.")
        }
    }
    
    func deleteAccount(_ indexSet: IndexSet){
        for i in indexSet{
            let account = accounts[i]
            modelContext.delete(account)
        }
    }
    
    func confirmDelete(_ account: Account){
        accountToDelete = account
    }
    
}

struct AccountDetailView : View {
    
    @Bindable var account: Account

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {

            Text(account.name)
                .font(.largeTitle)
                .bold()

            Text(
                account.currentAmount,
                format: .currency(code: account.currencyCode)
            )
            .font(.title2)

            Divider()

            List {
                ForEach(account.operations) { operation in
                    HStack {
                        Text(operation.date, style: .date)
                        Spacer()
                        Text(
                            operation.amount,
                            format: .currency(code: account.currencyCode)
                        )
                        .foregroundStyle(operationAmountColor(operation))
                    }
                }
            }
        }
        .padding()
    }

    private func operationAmountColor(_ operation: Operation) -> Color {
        switch operation.type {
        case .income:
            return .green
        case .expense:
            return .red
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
                        //if(validateAccountCreation(accountName, transfer: currentAmount)){ //TODO: use computed property instead of calling function every time
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
                    //.disabled(!validateAccountCreation(accountName, transfer: currentAmount)) //TODO: use computed property instead of calling function every time
                }.padding()
            }
        }.formStyle(.grouped)
        .padding()
    }
}

struct EmptyAccountView : View {
    @State var presentSheet: Bool = false
    
    var body: some View {
        VStack{
            Text("You don't have accounts yet") //TODO: add text styles
            
            Button{
                presentSheet = true
            } label: {
                Image(systemName: "plus.circle")
                Text("Create")

            }.buttonStyle(.borderedProminent)
                .sheet(isPresented: $presentSheet, content: {
                    CreateAccountView(presentSheet: $presentSheet).frame(
                        minWidth: 500,
                        maxWidth: .infinity,
                        minHeight: 600,
                        maxHeight: .infinity
                    )
                })
        }
    }
}

#Preview{
    AccountView().modelContainer(for: Account.self, inMemory: true)
    //EmptyAccountView().frame(minWidth: 800, minHeight: 600)
}
