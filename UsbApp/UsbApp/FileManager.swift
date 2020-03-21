//
//  FileManager.swift
//  UsbApp
//
//  Created by Tatsuya Ogawa on 2020/03/21.
//  Copyright © 2020 Tatsuya Ogawa. All rights reserved.
//

import Foundation
class FileManager{
    let queue = DispatchQueue.init(label: "list")
    var viewModel : FileViewModel?
    var timer:Timer?
    func startTimer(){
        self.timer = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.reload), userInfo: nil, repeats: true)
    }
    @objc func reload(){
        queue.async{
            print("getting initial folder")
            guard let viewModel = self.viewModel else{return}
            if let list = CommandManager.list( viewModel.currentDirectory){
                DispatchQueue.main.async {
                    viewModel.fileList = list
                }
            }
        }
    }
    func getFile(_ path:String)->URL?{
        let semaphore = DispatchSemaphore(value: 0)
        var url : URL? = nil
        queue.async{
            if let data = CommandManager.get(path){
                let nsData = data as NSData
                let saveUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(path)
                if nsData.write(to: saveUrl, atomically: true) {
                    url = saveUrl
                }
            }
            semaphore.signal()
        }
        semaphore.wait()
        return url
    }
}
class FileViewModel:ObservableObject{
    @Published var isTop = true
    @Published var currentDirectory:String = "" {
        didSet {
            self.isTop = currentDirectory == ""
            self.currentDirectoryText = currentDirectory == "" ? "ルートディレクトリ" : currentDirectory
        }
    }
    @Published var currentDirectoryText:String = "ルートディレクトリ"
    @Published var fileList:[FileInfo] = []
}
