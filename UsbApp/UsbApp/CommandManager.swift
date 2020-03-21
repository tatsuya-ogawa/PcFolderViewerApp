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
        return Command.common(data, type: .List)
    }
    static func get(_ path:String)->Data{
        let data = path.data(using: .utf8)!
        return Command.common(data, type: .Get)
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
    static func common(_ data:Data)->Data?{
        let buffer = [UInt8](data)
        let size:Int = Int(Array(buffer[1...4]).ToInt32())
        if size == 0 {
            return nil
        }
        return Data(Array(buffer[5..<(size+5)]))
    }
    static func list(_ data:Data)->[FileInfo]?{
        guard let ret = Result.common(data) else { return nil }
        return try? JSONDecoder().decode([FileInfo].self, from: ret)
    }
    static func get(_ data:Data)->Data?{
        guard let ret = Result.common(data) else { return nil }
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
    
    static func list(_ directory:String = "")->[FileInfo]?{
        let data = NetworkServer.shared.sendReceive(data: Command.list(directory) )
        guard let ret = data else {
            return nil
        }
        return Result.list(ret)
    }
    static func get(_ path:String = "")->Data?{
        let data = NetworkServer.shared.sendReceive(data: Command.get(path) )
        guard let ret = data else {
            return nil
        }
        return Result.get(ret)
    }
}
