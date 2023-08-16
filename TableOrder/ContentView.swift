//
//  ContentView.swift
//  TableOrder
//
//  Created by AtheerAlshehri on 20/02/2023.
//


import SwiftUI
enum Status: Int, Hashable, CaseIterable, Identifiable, Comparable{
    
    
    static func < (lhs: Status, rhs: Status) -> Bool{
        return lhs.rawValue < rhs.rawValue
    }
    var id: Int{rawValue}
    case Ready
    case NotReady
    
    var localizedName: LocalizedStringKey{
        
        switch(self){
        case .Ready:
            return "Ready"
        case .NotReady:
            return "Not Ready"
        }
    }
}

struct Expenses: Identifiable{
    let id = UUID()
    var orderN: Int
    var phoneN: Int
    var Status: Status
}

class ExpenseData : ObservableObject {
    @Published var exampleData = [
        Expenses(orderN: 112, phoneN: 522083136, Status: .Ready),
        Expenses(orderN: 113, phoneN: 545464789, Status: .NotReady)
    ]
}


struct ContentView: View {
    
    @StateObject private var expenses = ExpenseData()
    @State private var selectExpense = Set<Expenses.ID>()
    @State private var sortOrder = [KeyPathComparator(\Expenses.orderN)]
    @State private var isSheet = false
    @State private var showSettings = false
    @State private var showAddNew = false
    
    
    
    var body: some View {
       
        NavigationStack {
            Group{
                VStack{
                
                    Table (expenses.exampleData, selection: $selectExpense, sortOrder:$sortOrder){
                        TableColumn ("Order Number", value:\.orderN) {value in
                            Text ("# \(value.orderN)")
                                
                        }
                        TableColumn("Phone Number", value:\.phoneN){value in
                            let num = value.phoneN.description.replacingOccurrences(of: ",", with: "")
                            Text ("0966 \(num)")
                           
                        }
                        TableColumn("Status", value:\.Status) {value in
                            if value.Status == .Ready {
                                Text(value.Status.localizedName)
                                    .foregroundColor(.green)
                                    
                            }
                            else{
                                Text(value.Status.localizedName)
                                    .foregroundColor (.red)
                            }
                            
                            
                        }
                    }
                    
                    .onChange (of: sortOrder) {
                        expenses.exampleData.sort(using: $0)
                    }
                    
                }
            }
            
            HStack{
                Text ("\(expenses.exampleData.count) entries")
                Spacer ()
                Text ("\(selectExpense.count) items are selected")
                    .padding (.leading)
                    .padding (.trailing)
            }
            .navigationTitle("Orders")
            //Remove the comments here if you would like the nav title to only be inline instead of dynamic.
            //.navigationBarTitleDisplayMode(.inline)
            
        // MARK: SETTINGS BUTTON AND ADD BUTTON
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                         self.showSettings = true
                    }) {
                        Label("", systemImage: "gear")
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        
                        //We can easily move this to the bottom of the page.
                        Button (action: {
                            for item in selectExpense {
                                if let index = expenses.exampleData.firstIndex(where: {$0.id == item}){
                                    expenses.exampleData.remove(at: index)
                                }
                            }
                            selectExpense = Set<Expenses.ID> ()
                        }, label: {
                            Label("Delete Item",systemImage: "trash")
                        })
                        
                        Button(action: {
                            self.showAddNew = true
                        }) {
                            Label("", systemImage: "plus.circle")
                        }
                        
                        
                    }
                }
                    
            }
            
            .sheet(isPresented: $showSettings) {
                setting()
                    
            }
            
            .sheet(isPresented:$showAddNew) {
                AddExpence().environmentObject(expenses)
            }
            
        }//NAVSTACK
        
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
