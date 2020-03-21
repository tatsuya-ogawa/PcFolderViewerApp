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
namespace UsbConnect
{
    class Client
    {
        // CommandParser commandParser = new CommandParser{
        // };
        CommandParser commandParser = new CommandParser{
            rootDirectory =  System.Environment.GetFolderPath(Environment.SpecialFolder.Desktop)
        };
        string deviceUdid = null;
        ushort port = 5050;
        private readonly LibiMobileDevice api = new LibiMobileDevice();
        public void BeginListening()
        {
            this.api.iDevice.idevice_event_subscribe(EventCallback(), new IntPtr());
        }

        private iDeviceEventCallBack EventCallback()
        {
            return (ref iDeviceEvent devEvent, IntPtr data) =>
            {
                switch (devEvent.@event)
                {
                    case iDeviceEventType.DeviceAdd:
                        this.deviceUdid = devEvent.udidString;
                        Connect();
                        break;
                    case iDeviceEventType.DeviceRemove:
                        this.deviceUdid = null;
                        break;
                    default:
                        return;
                }
            };
        }

        private void Connect()
        {            
            while(this.deviceUdid != null){
                this.api.iDevice.idevice_new(out iDeviceHandle deviceHandle, deviceUdid).ThrowOnError();
                var error = this.api.iDevice.idevice_connect(deviceHandle, port, out iDeviceConnectionHandle connection);
                if (error != iDeviceError.Success) 
                {
                    Thread.Sleep(100);
                    continue;
                }
                ReceiveDataFromDevice(connection);
                connection.Close();
                // Thread.Sleep(100);
            }
        }

        private void ReceiveDataFromDevice(iDeviceConnectionHandle connection)
        {
            byte[] buffer = new byte[1024 * 1024];
            while (true)
            {
                uint receivedBytes = 0;
                
                this.api.iDevice.idevice_connection_receive(connection, buffer, (uint)buffer.Length,
                    ref receivedBytes);
                if (receivedBytes <= 0){
                    break;
                }
                // Do something with your received bytes
                var command = commandParser.parse(buffer);
                uint sendBytes = 0;
                this.api.iDevice.idevice_connection_send(connection,command,(uint)command.Length,ref sendBytes);                
            }
        }
    }
    class Program
    {
        static void Main(string[] args)
        {
            var client = new Client();
            // var test = new CommandParser();
            // var command = new byte[8];
            // command[0] = 1;
            // test.parse(command);
            NativeLibraries.Load();
            //client.Connect();
            client.BeginListening();

            while (true)
            {
                Thread.Sleep(1000);
            }
        }
    }
}
