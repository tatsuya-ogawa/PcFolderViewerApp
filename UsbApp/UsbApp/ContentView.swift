//
//  ContentView.swift
//  UsbApp
//
//  Created by Tatsuya Ogawa on 2020/03/18.
//  Copyright © 2020 Tatsuya Ogawa. All rights reserved.
//

import SwiftUI


struct ContentView: View {
    @ObservedObject var viewModel:FileViewModel = FileViewModel()
    let fileManager:FileManager
    init() {
        fileManager = FileManager()
        fileManager.viewModel = self.viewModel
        UINavigationBar.appearance().backgroundColor = .lightGray
        fileManager.reload()
        fileManager.startTimer()
    }
    func reload(){
        fileManager.reload()
    }
    func uoToParent(){
        self.viewModel.currentDirectory = (self.viewModel.currentDirectory as NSString ).deletingLastPathComponent as String
        fileManager.reload()
    }
    func downToFile(file:FileInfo){
        var currentDirectory = viewModel.currentDirectory
        if currentDirectory.count == 0{
            currentDirectory = file.name
        }else{
            currentDirectory = "\(viewModel.currentDirectory)/\(file.name)"
        }
        viewModel.currentDirectory = currentDirectory
        fileManager.reload()
    }
    @ObservedObject var documentViewModel:DocumentViewModel = DocumentViewModel()
    @State var selectedFileInfo:FileInfo? = nil
    var body: some View {
        NavigationView{
            GeometryReader { geometry in
                List{
                //VStack(alignment: .leading, spacing: 10) {
                    ForEach(self.viewModel.fileList, id: \.self) { file in
                        HStack(spacing: 10) {
                            if file.type == 0{
                                Image(systemName: "folder")
                            }else{
                                Image(systemName: "doc.text")
                            }
                            if file.type == 0{
                                Text("\(file.name)")
                                    .onTapGesture {
                                        self.downToFile(file: file)
                                }
                            }else{
                                Text("\(file.name)")
                                    .onTapGesture {
                                        self.selectedFileInfo = file
                                        self.documentViewModel.isPresented.toggle()
                                }
                            }
                            Spacer()
                        }.padding(10)
                    }
                    Spacer()
                //    }
                
            }.sheet(isPresented: self.$documentViewModel.isPresented) {
                    DocumentView(path: self.selectedFileInfo!.name ,viewModel:self.viewModel, documentViewModel: self.documentViewModel)
                }
                    //.frame(width: geometry.size.width, height: geometry.size.height)
                    .navigationBarItems(
                        leading:
                        Button(action: {
                            self.uoToParent()
                        }, label: {
                            if !self.viewModel.isTop {
                                Text("Up")
                            }
                        }),
                        trailing:
                        HStack {
                            Button(action: {
                                self.reload()
                            }) {
                                Image(systemName: "folder")
                            }.foregroundColor(.blue)
                    })
                    .navigationBarTitle(Text(self.viewModel.currentDirectoryText))
            }
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
