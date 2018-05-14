## Introduction
In iOS 11, Apple introduced the [Core NFC Framework](https://developer.apple.com/documentation/corenfc?language=objc), which enables apps to detect Near Field Communication (NFC) tags. This is great news for developers writing iOS apps to work with Zebra mobile printers, because all Zebra mobile printers are NFC enabled. This makes it easy for apps to obtain the printer's Serial Number to pair with Bluetooth. This ZebraPrinterNFCDemo demonstrates how to read the NFC tags on Zebra mobile printers and how to pair with Bluetooth Classic or connect Bluetooth Low Energy.

## NFC Tag on Zebra Mobile Printers
Every Zebra mobile printer is equipped with a passive NFC tag. The tag is located on the right side of the printer and marked by an icon.  The NFC tag is encoded with the following information in a URL format, as an example shown below.

Full URL: http://www.zebra.com/apps/r/nfc?mE=000000000000&mW=&mB=cc78ab3ebae0&c=ZQ320-A0E02T0-001&s=XXZFJ170700336&v=0

|Keys |Values           |     Explanation     |
|----:|:----------------|:--------------------|
|host |www.zebra.com    |                     |
|path |/apps/r/nfc      |                     |
|mE   |000000000000     |Ethernet MAC Address |
|mW   |                 |WiFi MAC Address     |
|mB   |cc78ab3ebae0     |Bluetooth MAC Address|
|c    |ZQ320-A0E02T0-001|                     |
|s    |XXZFJ170700336   |Printer Serial Number|
|v    |0                |Hardware Version     |

On iOS, the Serial Number is used when making a connection to the Bluetooth.

## Code Overview













## References
This ZebraPrinterNFCDemo uses or refers to the following materials:
* [Active Near Field Communication AppNote](https://www.zebra.com/content/dam/zebra/software/en/application-notes/AppNote-Active_NFC-v5.pdf), by Zebra.

