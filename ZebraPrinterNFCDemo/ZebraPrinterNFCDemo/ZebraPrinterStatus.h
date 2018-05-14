//
//  ZebraPrinterStatus.h
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 4/20/18.
//  Copyright © 2018 Zebra. All rights reserved.
//

#import <Foundation/Foundation.h>

// Enumeration of the various print modes supported by Zebra printers.
typedef NS_ENUM(NSInteger, ZebraPrintMode) {
    
    // Rewind print mode
    ZPL_PRINT_MODE_REWIND,
    
    // Peel-off print mode
    ZPL_PRINT_MODE_PEEL_OFF,
    
    // Tear-off print mode (this also implies Linerless Tear print mode)
    ZPL_PRINT_MODE_TEAR_OFF,
    
    // Cutter print mode
    ZPL_PRINT_MODE_CUTTER,
    
    // Applicator print mode
    ZPL_PRINT_MODE_APPLICATOR,
    
    // Delayed cut print mode
    ZPL_PRINT_MODE_DELAYED_CUT,
    
    // Linerless peel print mode
    ZPL_PRINT_MODE_LINERLESS_PEEL,
    
    // Linerless rewind print mode
    ZPL_PRINT_MODE_LINERLESS_REWIND,
    
    // Partial cutter print mode
    ZPL_PRINT_MODE_PARTIAL_CUTTER,
    
    // RFID print mode
    ZPL_PRINT_MODE_RFID,
    
    // Kiosk print mode
    ZPL_PRINT_MODE_KIOSK,
    
    // Unknown print mode
    ZPL_PRINT_MODE_UNKNOWN
};


@interface ZebraPrinterStatus : NSObject

// <c>YES</c> if the printer reports back that it is ready to print.
@property (assign, readonly, getter=isReadyToPrint) BOOL readyToPrint;

// <c>YES</c> if the head is open.
@property (assign, readonly, getter=isHeadOpen) BOOL headOpen;

// <c>YES</c> if the head is cold. For CPCL printers this is always <c>NO</c>.
@property (assign, readonly, getter=isHeadCold) BOOL headCold;

// <c>YES</c> if the head is too hot. For CPCL printers this is always <c>NO</c>.
@property (assign, readonly, getter=isHeadTooHot) BOOL headTooHot;

// <c>YES</c> if the paper is out.
@property (assign, readonly, getter=isPaperOut) BOOL paperOut;

// <c>YES</c> if the ribbon is out.
@property (assign, readonly, getter=isRibbonOut) BOOL ribbonOut;

// <c>YES</c> if the receive buffer is full. For CPCL printers this is always <c>NO</c>.
@property (assign, readonly, getter=isReceiveBufferFull) BOOL receiveBufferFull;

// <c>YES</c> if the printer is paused. For CPCL printers this is always <c>NO</c>.
@property (assign, readonly, getter=isPaused) BOOL paused;

// The length of the label in dots. For CPCL printers this is always 0.
@property (assign, readonly) NSInteger labelLengthInDots;

// The number of formats currently in the receive buffer of the printer. For CPCL printers this is always 0.
@property (assign, readonly) NSInteger numberOfFormatsInReceiveBuffer;

// The number of labels remaining in the batch. For CPCL printers this is always 0.
@property (assign, readonly) NSInteger labelsRemainingInBatch;

// <c>YES</c> if there is a partial format in progress. For CPCL printers this is always <c>NO</c>.
@property (assign, readonly, getter=isPartialFormatInProgress) BOOL partialFormatInProgress;

// The print mode. For CPCL printers this is always \link _ZplPrintMode::ZPL_PRINT_MODE_UNKNOWN ZPL_PRINT_MODE_UNKNOWN\endlink
@property (assign, readonly) ZebraPrintMode printMode;


// Get the current status of the printer.
+ (ZebraPrinterStatus*) getCurrentStatus: (NSData*)data error:(NSError**) error;

// Return the localized description of the print mode
+ (NSString *) getPrintModeLocalizedDescriptino: (ZebraPrintMode) printMode;

@end
