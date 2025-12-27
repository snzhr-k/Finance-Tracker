import SwiftData
import Foundation
import SwiftUI

struct AccountView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var accounts: [Account]
    
    
    
    var body: some View {
        VStack{
            if accounts.isEmpty {
                EmptyAccountView()
            }
            else {
                List{
                    ForEach(accounts) { acc in
                        Button{
                            print(acc.name)
                        } label: {
                            Text(acc.name)
                        }
                    }.onDelete(perform: deleteAccount)
                }
            }
        }
    }
    
    func deleteAccount(_ indexSet: IndexSet){
        for i in indexSet{
            let account = accounts[i]
            modelContext.delete(account)
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
    
    var body: some View {
        Form{
            Section {
                TextField("Account Name", text: $accountName)
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
                Text("Invalid amount").foregroundStyle(.red)
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
                        if(validateAccountCreation(accountName, transfer: currentAmount)){
                            var newAccount: Account = Account(name: accountName, currencyCode: currencyCode, initialDeposit: currentAmount)
                            modelContext.insert(newAccount)
                            presentSheet = false
                        }
                    } label: {
                        Image(systemName: "plus.circle")
                        Text("Create")
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.green)
                    .disabled(!validateAccountCreation(accountName, transfer: currentAmount))
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
