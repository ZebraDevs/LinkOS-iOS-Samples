## Intro
Zebra printers of ZQ500 series and ZD400 series have both Bluetooth Classic and Low Energy (LE or BLE) capabilities. This ZebraPrinterBLEDemo demonstrates how to scan, connect, send ZPL to and read data from a BLE enabled Zebra printer on an iOS device. The Bluetooth LE on Zebra printer acts as a peripheral. A BLE central device needs to connect to the printer first before it starts to discover the services and characteristics.

To query if Bluetooth LE is enabled or not on a printer, use Zebra SGD command below with [Zebra Setup Utilities](https://www.zebra.com/us/en/products/software/barcode-printers/zebralink/zebra-setup-utility.html):
* `! U1 getvar "bluetooth.le.controller_mode"`

To enable Bluetooth LE on a printer, use one of the following Zebra SGD commands to enable the BLE on the printer with [Zebra Setup Utilities](https://www.zebra.com/us/en/products/software/barcode-printers/zebralink/zebra-setup-utility.html):
* `! U1 setvar "bluetooth.le.controller_mode" "le"`
* `! U1 setvar "bluetooth.le.controller_mode" "both"`

## Code overview
`ZPrinterLEService.h` defines the UUID of services and characteristics as specified in [Link-OS Enviornment Bluetooth Low Energy AppNote](https://www.zebra.com/content/dam/zebra/software/en/application-notes/AppNote-BlueToothLE-v4.pdf). The `ScanBLEZPrinterTableViewController.m` handles scanning, discovering and connecting. The Apple iOS Bluetooth LE framework uses asynchronous callbacks to notify the application when a peripheral is found, a service or a characteristic is discovered. `ScanBLEZPrinterTableViewController.m` calls iOS Bluetooth LE framework to initiate scan, discover and connect, and it implements the corresponding callbacks too.

`ConnectBLEZPrinterViewController.m` handles the UI in `Connected` view. `ScanBLEZPrinterTableViewController.m` communicates to `ConnectBLEZPrinterViewController.m` via Notification Center when the value of a characterstic has been updated. There are three types of notifications, `WriteNotification, ReadNotification & DISNotification`, which are all defined in `ZPrinterLEService.h`. The `viewDidLoad` in `ConnedtBLEPrinterViewController.m` registers for these notifications.

## Services on Zebra printer
The Zebra Bluetooth LE enabled printers offer two services, i.e. Device Information Service (DIS, UUID is `0x180A`) and Parser Service (UUID is `38eb4a80-c570-11e3-9507-0002a5d5c51b`). These services cannot be discovered unless the central device has connected to the printer.

The DIS is a standard service that includes the characteristics of Device Name, Serial Number, Firmware Rrevision, etc. that can be read back. The Parser Service offers two characteristics for getting data from printer (named as `"From Printer Data"`) and for sending data to printer (named as `"To Printer Data"`). 

## Discover BLE enabled Zebra printers
The Bluetooth LE on Zebra printer acts as a peripheral. As a peripheral, the printer advertises its device name through the advertisements. The printer does not advertise any other services. The central device needs to connect to the printer in order to discover services, and then to discover characteristics. 

The central device (an iOS device in our case) initiates a scan to find the peripheral by calling the following in `(void)centralManagerDidUpdateState:(nonnull CBCentralManager *)central`.
```Objective-C
[self.centralManager scanForPeripheralsWithServices:nil options:@{ CBCentralManagerScanOptionAllowDuplicatesKey : @YES }];
```
Once a peripheral is discovered, the iOS Bluetooth LE framework invokes
```Objective-C
(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
```
callback, in which we build a list of the discovered peripherals based on the RSSI values that fall inot the specified range. From here, we let the user to select a specific printer on the list to connect to.

## Connect to a BLE enabled Zebra printer
In `viewDidLoad` method in `ConnectBLEZPrinterViewController.m`, we call the following to stop scanning and to connect the selected printer.
```Objective-C
// Stop scanning
[[self.scanBLEZPrinterTVC centralManager] stopScan];

// Connect to the selected printer.
[[self.scanBLEZPrinterTVC centralManager] connectPeripheral:_selectedPrinter options:nil];
```

## Discover services and characteristics
Once connected, the iOS BLE framework invokes `(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral`, where we call the following to discover the `ZPRINTER_SERVICE_UUID` and `ZPRINTER_DIS_SERVICE` services:
```Objective-C
// Search only for services that match the UUID of Zebra Printer Service and the UUID of Device Information Service
[peripheral discoverServices:@[[CBUUID UUIDWithString:ZPRINTER_SERVICE_UUID], [CBUUID UUIDWithString:ZPRINTER_DIS_SERVICE]]];
```


## Screenshot of the demo
![Screenshot of the demo](https://github.com/Zebra/LinkOS-iOS-Samples/blob/ZebraPrinterBLEDemo/ZebraPrinterBLEDemo/ZebraPrinterBLEDemo.png)


## References
This ZebraPrinterBLEDemo uses or refers to the following materials:
* [Link-OS Enviornment Bluetooth Low Energy AppNote](https://www.zebra.com/content/dam/zebra/software/en/application-notes/AppNote-BlueToothLE-v4.pdf), by Zebra
* [Bluetooth Low Energy Printing - iOS](https://km.zebra.com/resources/sites/ZEBRA/content/live/WHITE_PAPERS/0/WH146/en_US/BluetoothLowEnergyPrinting_iOS.pdf), by Zebra
* [BTLE Central Peripheral Transfer](https://developer.apple.com/library/content/samplecode/BTLE_Transfer/Introduction/Intro.html#//apple_ref/doc/uid/DTS40012927-Intro-DontLinkElementID_2), by Apple Bluetooth for Developers.
