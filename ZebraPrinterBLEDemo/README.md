# Intro
Zebra printers of ZQ500 series and ZD400 series have both Bluetooth Classic and Low Energy (LE) capabilities. This ZebraPrinterBLEDemo demonstrates how to scan, connect and send ZPL to a BLE enabled Zebra printer from an iOS device.

To query if Bluetooth LE is enabled or not, use Zebra SGD command below to configure the printer:
* `! U1 getvar "bluetooth.le.controller_mode"`

To enable Bluetooth LE, use one of the following Zebra SGD commands to configure the printer:
* `! U1 setvar "bluetooth.le.controller_mode" "le"`
* `! U1 setvar "bluetooth.le.controller_mode" "both"`



# References
This ZebraPrinterBLEDemo uses or refers to the following materials:
* [Link-OS Enviornment Bluetooth Low Energy AppNote](https://www.zebra.com/content/dam/zebra/software/en/application-notes/AppNote-BlueToothLE-v4.pdf), by Zebra
* [Bluetooth Low Energy Printing - iOS](https://km.zebra.com/resources/sites/ZEBRA/content/live/WHITE_PAPERS/0/WH146/en_US/BluetoothLowEnergyPrinting_iOS.pdf), by Zebra
* [BTLE Central Peripheral Transfer](https://developer.apple.com/library/content/samplecode/BTLE_Transfer/Introduction/Intro.html#//apple_ref/doc/uid/DTS40012927-Intro-DontLinkElementID_2), by Apple Bluetooth for Developers.
