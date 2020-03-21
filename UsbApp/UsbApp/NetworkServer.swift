//
//  SocketServer.swift
//  UsbApp
//
//  Created by Tatsuya Ogawa on 2020/03/18.
//  Copyright © 2020 Tatsuya Ogawa. All rights reserved.
//

import Foundation
import Network


class NetworkServer{
    public static let shared = NetworkServer()
    
    public var running = true
    let myQueue = DispatchQueue(label: "UsbNetwork")
    var connection:NWConnection! = nil
    func startListener() {
        
        do {
            let nWListener = try NWListener(using: .tcp, on: 5050)
            nWListener.newConnectionHandler = { (newConnection) in
                print("New Connection!!")
                self.connection = newConnection
                self.connection.stateUpdateHandler = {(newState) in
                    switch newState {
                    case .ready:
                        NSLog("Ready to send")
                    case .waiting(let error):
                        NSLog("\(#function), \(error)")
                    case .failed(let error):
                        NSLog("\(#function), \(error)")
                    case .setup: break
                    case .cancelled:break
                    case .preparing: break
                    @unknown default:
                        fatalError()
                    }
                }
                self.connection.start(queue: self.myQueue)
                
            }
            nWListener.start(queue: myQueue)
            print("start")
        }
        catch {
            print(error)
        }
    }
    
    func send(data:Data,nwConnection:NWConnection){
        let semaphore = DispatchSemaphore(value: 0)
        let completion = NWConnection.SendCompletion.contentProcessed { (error: NWError?) in
            semaphore.signal()
        }
        nwConnection.send(content: data, completion: completion)
        semaphore.wait()
    }
    func receive(nWConnection:NWConnection)->Data? {
        var ret : Data? = nil
        let semaphore = DispatchSemaphore(value: 0)
        nWConnection.receive(minimumIncompleteLength: 1, maximumLength: 1024*1024*1024, completion: { (data, context, flag, error) in
            // print("receiveMessage")
           
            guard let data = data else {
                print("receiveMessage data nil")
                return
            }
            ret = data
//            if(!flag) {
//                if let result = self.receive(nWConnection: nWConnection){
//                    ret?.append(result)
//                }
//            }
            semaphore.signal()
        })
        semaphore.wait()
        return ret
    }
}
