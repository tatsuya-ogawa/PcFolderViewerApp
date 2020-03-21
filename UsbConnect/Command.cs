using iMobileDevice;
using iMobileDevice.iDevice;
using iMobileDevice.Lockdown;
using System.Collections.ObjectModel;
using System.Threading.Tasks;
using System;
using System.Threading;
using System.Linq;
using System.Text.Json;
using System.Collections.Generic;
using System.Text.Json.Serialization;
namespace UsbConnect{
     public class FileInfo{
        public string name{get;set;}
        public int type{get;set;}
    }
    enum CommandType{
        List = 1,
        Get = 2
    }
    class CommandParser{
        public string rootDirectory = Environment.CurrentDirectory;
        byte[] parseCommon(byte[] command){
            byte[] sizeBuffer = new byte[4];
            Array.Copy(command, 1, sizeBuffer, 0, 4);
            int size = BitConverter.ToInt32(sizeBuffer, 0);
            if(size != 0){
                var retBuffer = new byte[size];
                Array.Copy(command, 5, retBuffer, 0, retBuffer.Length);      
                return retBuffer;          
            }else{
                return null;
            }
        }
        byte[] resultCommon(byte[] result){
            if(result == null){
                result = new byte[0];
            }
            var resultBuffer = new byte[1+4+result.Length];
            var sizeBuffer = BitConverter.GetBytes(result.Length);
            Array.Copy(sizeBuffer, 0, resultBuffer, 1, sizeBuffer.Length);
            Array.Copy(result, 0, resultBuffer, 5, result.Length);
            return resultBuffer;
        }
        byte[] parseList(byte[] command){
            var body = parseCommon(command);
            var folder = "";
            if(body != null){
                folder = System.Text.Encoding.UTF8.GetString(body);
            }
            folder = System.IO.Path.Combine(rootDirectory,folder);
            var files = new List<string>();
            files = files.Concat( System.IO.Directory.GetFiles(
                folder, "*", System.IO.SearchOption.TopDirectoryOnly)).ToList();
            files = files.Concat(System.IO.Directory.GetDirectories(
                folder, "*", System.IO.SearchOption.TopDirectoryOnly)).ToList();
            var fileInfos = files.Select((path)=>{
                var attr = System.IO.File.GetAttributes( path );
                return new FileInfo{
                    name = System.IO.Path.GetFileName(path),
                    type = attr.HasFlag( System.IO.FileAttributes.Directory ) ? 0 :1
                };
            });
            var json = JsonSerializer.Serialize(fileInfos);
            byte[] jsonBuffer = System.Text.Encoding.UTF8.GetBytes(json);
            var ret = resultCommon(jsonBuffer);
            ret[0] = (int)CommandType.List;
            // var ret = new byte[1+4+jsonBuffer.Length];
            // sizeBuffer = BitConverter.GetBytes(jsonBuffer.Length);
            // Array.Copy(sizeBuffer, 0, ret, 1, sizeBuffer.Length);
            // Array.Copy(jsonBuffer, 0, ret, 5, jsonBuffer.Length);
            return ret;
        }
        byte[] parseGet(byte[] command){
            var body = parseCommon(command);
            var path = "";
            if(body != null){
                path = System.Text.Encoding.UTF8.GetString(body);
            }
            path = System.IO.Path.Combine(rootDirectory,path);

            System.IO.FileStream fs = new System.IO.FileStream(
            path,
            System.IO.FileMode.Open,
            System.IO.FileAccess.Read);
            byte[] buffer = new byte[fs.Length];
            fs.Read(buffer, 0, buffer.Length);
            fs.Close();
            var ret = resultCommon(buffer);
            ret[0] = (int)CommandType.Get;
            return ret;
        }
        public byte[] parse(byte[] command){
            switch (command[0]) {
                case (int)CommandType.List:
                    return parseList(command);
                    break;
                case (int)CommandType.Get:
                    return parseGet(command);
                    break;
            }
            return null;
        }
    }
}