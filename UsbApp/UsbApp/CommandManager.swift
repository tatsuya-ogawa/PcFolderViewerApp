//
//  FileManager.swift
//  UsbApp
//
//  Created by Tatsuya Ogawa on 2020/03/21.
//  Copyright © 2020 Tatsuya Ogawa. All rights reserved.
//

import Foundation
import SwiftUI
enum CommandType:UInt8{
    case List = 1
    case Get = 2
}
class Command{
    static func common(_ data:Data,type:CommandType)->Data{
        var command = Data([type.rawValue])
        var size:Int32 = Int32(data.count)
        command.append(Data(buffer:UnsafeBufferPointer(start: &size, count: 1)))
        command.append(data)
        return command
    }
    static func list(_ directory:String)->Data{
        let data = directory.data(using: .utf8)!
        return common(data, type: .List)
    }
    static func get(_ path:String)->Data{
        let data = path.data(using: .utf8)!
        return common(data, type: .Get)
    }
}
extension Array where Element == UInt8 {
    func ToInt32()->UInt32{
        let array:[UInt8] = self;
        let data = Data(array)
        return data.withUnsafeBytes { $0.load( as: UInt32.self ) }.littleEndian
        //        let value = UInt32(littleEndian: data.withUnsafeBytes { $0.pointee })
        //        return value;
    }
}
class Result{
    static func getSize(_ data:Data)->Int{
        let buffer = [UInt8](data)
        let size:Int = Int(Array(buffer[1...4]).ToInt32())
        return size
    }
    static func getPayload(_ data:Data)->Data?{
        let buffer = [UInt8](data)
        let size:Int = min( getSize(data) ,buffer.count - 5)
        if size == 0 {
            return nil
        }
        return Data(Array(buffer[5..<(size+5)]))
    }
    static func common(_ data:Data)->Data?{
        let buffer = [UInt8](data)
        let size:Int = getSize(data)
        if size == 0 {
            return nil
        }
        return Data(Array(buffer[5..<(size+5)]))
    }
    static func list(_ data:Data)->[FileInfo]?{
        //guard let ret = common(data) else { return nil }
        let ret = data
        return try? JSONDecoder().decode([FileInfo].self, from: ret)
    }
    static func get(_ data:Data)->Data?{
        //guard let ret = common(data) else { return nil }
        let ret = data
        return ret
    }
}
enum FileType:Int{
    case Directory = 0
    case File = 1
}
struct FileInfo:Codable,Hashable{
    
    //var id = UUID()
    var name:String
    var type:Int
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(type)
    }
}

class CommandManager{
    static func sendReceive(_ command:Data)->Data?{
        guard let connection = NetworkServer.shared.connection else{
            return nil
        }
        NetworkServer.shared.send(data: command, nwConnection: connection)
        guard let ret = NetworkServer.shared.receive(nWConnection: connection) else {
            return nil
        }
        let size = Result.getSize(ret)
        var data = Result.getPayload(ret)
        if data == nil {
            return nil
        }
        while data!.count < size{
            guard let rest = NetworkServer.shared.receive(nWConnection: connection) else {
                break
            }
            let restSize = min(size - data!.count,rest.count)
            let buffer = [UInt8](rest)
            data?.append(Data(Array(buffer[0..<(restSize)])))
        }
        return data
    }
    static func list(_ directory:String = "")->[FileInfo]?{
        let data = self.sendReceive(Command.list(directory) )
        guard let ret = data else {
            return nil
        }
        return Result.list(ret)
    }
    static func get(_ path:String = "")->Data?{
        let data = self.sendReceive(Command.get(path) )
        guard let ret = data else {
            return nil
        }
        return Result.get(ret)
    }
}
