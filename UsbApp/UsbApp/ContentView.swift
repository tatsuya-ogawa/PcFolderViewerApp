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
    let fileManager:RemoteFileManager
    init() {
        fileManager = RemoteFileManager()
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
    func absolutePath(_ fileName:String)->String{
        var path = viewModel.currentDirectory
        if path.count == 0{
            path = fileName
        }else{
            path = "\(viewModel.currentDirectory)/\(fileName)"
        }
        return path
    }
    func downloadFile(file:FileInfo){
        let path = self.absolutePath(file.name)
        DispatchQueue.global().async {
            guard let url = self.fileManager.getFile(path) else{return}
            DispatchQueue.main.async {
                let documentViewController = UIDocumentInteractionController.init(url: url)
                let viewController = UIApplication.shared.keyWindow!.rootViewController!
                if !(
                    documentViewController.presentOpenInMenu(from:
                        viewController.view.frame, in: viewController.view, animated: true)) {
                    print("failed to open url \(url)")
                }
            }
        }
    }
    var body: some View {
        NavigationView{
            List{
                //VStack(alignment: .leading, spacing: 10) {
                ForEach(self.viewModel.fileList, id: \.self) { file in
                    GeometryReader { geometry in
                        
                        HStack(spacing: 10) {
                            if file.type == 0{
                                Image(systemName: "folder")
                            }else{
                                Image(systemName: "doc.text")
                            }
                            
                            Text("\(file.name)")
                                                            
                            Spacer()
                        }.padding(10).onTapGesture {
                            if file.type == 0{
                                self.downToFile(file: file)
                            }else{
                                self.downloadFile(file: file)
                            }
                        }
                        //.rotation3DEffect(.degrees( 60.0 * sin(Double(geometry.frame(in: .global).minY / 50.0 ))), axis: (x: 1, y: 0, z: 0))
                        //.frame(width: geometry.size.width)
                    }
                }
                
                Spacer()
                
            }
                
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
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
