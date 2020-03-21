////
////  DocumentViewController.swift
////  UsbApp
////
////  Created by Tatsuya Ogawa on 2020/03/21.
////  Copyright © 2020 Tatsuya Ogawa. All rights reserved.
////
//
//import Foundation
//import UIKit
//import SwiftUI
//
//class DocumentViewController: UIViewController {
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//}
//class DocumentViewModel:NSObject,ObservableObject,UIDocumentInteractionControllerDelegate{
//    @Published var isPresented: Bool = false
//    var currentViewController:UIDocumentInteractionController?
//    func documentInteractionControllerDidEndPreview(_ controller: UIDocumentInteractionController){
//        currentViewController = nil
//        //        self.isPresented.toggle()
//        self.isPresented = false
//    }
//
//    func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController){
//        currentViewController = nil
//        //        self.isPresented.toggle()
//        self.isPresented = false
//
//    }
//
//    func documentInteractionControllerDidDismissOpenInMenu(_ controller: UIDocumentInteractionController){
//        currentViewController = nil
//        //        self.isPresented.toggle()
//        self.isPresented = false
//
//    }
//}
//struct DocumentView: View {
//    var path : String
//    var viewModel:FileViewModel
//    @ObservedObject var documentViewModel:DocumentViewModel
//
//    func absolutePath(_ fileName:String)->String{
//        var path = viewModel.currentDirectory
//        if path.count == 0{
//            path = fileName
//        }else{
//            path = "\(viewModel.currentDirectory)/\(fileName)"
//        }
//        return path
//    }
//    var body: some View {
//        DocumentViewRepresentable(path: self.absolutePath(path), documentViewModel: documentViewModel)
//    }
//}
//struct DocumentViewRepresentable : UIViewControllerRepresentable{
//    typealias UIViewControllerType = DocumentViewController
//    var path:String
//    @ObservedObject var documentViewModel:DocumentViewModel
//
//    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) -> DocumentViewRepresentable.UIViewControllerType {
//        return DocumentViewController()
//    }
//
//    func updateUIViewController(_ uiViewController: DocumentViewRepresentable.UIViewControllerType, context: UIViewControllerRepresentableContext<DocumentViewRepresentable>) {
//        DispatchQueue.global().async {
//            let fileManager = FileManager()
//            guard let url = fileManager.getFile(self.path) else{return}
//            DispatchQueue.main.async {
//                if !self.documentViewModel.isPresented{
//                    return
//                }
//                if self.documentViewModel.currentViewController != nil{
//                    return
//                }
//                self.documentViewModel.currentViewController = UIDocumentInteractionController.init(url: url)
//                self.documentViewModel.currentViewController?.delegate = self.documentViewModel
//                if !( self.documentViewModel.currentViewController!.presentOpenInMenu(from: uiViewController.view.frame, in: uiViewController.view, animated: true)) {
//                    print("failed to open url \(url)")
//                }
//            }
//        }
//    }
//}
