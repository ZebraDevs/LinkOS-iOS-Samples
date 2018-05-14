//
//  ZebraPrinterStatus.m
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 4/20/18.
//  Copyright © 2018 Zebra. All rights reserved.
//

#import "ZebraPrinterStatus.h"

@interface ZebraPrinterStatus ()

// <c>YES</c> if the printer reports back that it is ready to print.
@property (assign, readwrite, getter=isReadyToPrint) BOOL readyToPrint;

// <c>YES</c> if the head is open.
@property (assign, readwrite, getter=isHeadOpen) BOOL headOpen;

// <c>YES</c> if the head is cold. For CPCL printers this is always <c>NO</c>.
@property (assign, readwrite, getter=isHeadCold) BOOL headCold;

// <c>YES</c> if the head is too hot. For CPCL printers this is always <c>NO</c>.
@property (assign, readwrite, getter=isHeadTooHot) BOOL headTooHot;

// <c>YES</c> if the paper is out.
@property (assign, readwrite, getter=isPaperOut) BOOL paperOut;

// <c>YES</c> if the ribbon is out.
@property (assign, readwrite, getter=isRibbonOut) BOOL ribbonOut;

// <c>YES</c> if the receive buffer is full. For CPCL printers this is always <c>NO</c>.
@property (assign, readwrite, getter=isReceiveBufferFull) BOOL receiveBufferFull;

// <c>YES</c> if the printer is paused. For CPCL printers this is always <c>NO</c>.
@property (assign, readwrite, getter=isPaused) BOOL paused;

// The length of the label in dots. For CPCL printers this is always 0.
@property (assign, readwrite) NSInteger labelLengthInDots;

// The number of formats currently in the receive buffer of the printer. For CPCL printers this is always 0.
@property (assign, readwrite) NSInteger numberOfFormatsInReceiveBuffer;

// The number of labels remaining in the batch. For CPCL printers this is always 0.
@property (assign, readwrite) NSInteger labelsRemainingInBatch;

// <c>YES</c> if there is a partial format in progress. For CPCL printers this is always <c>NO</c>.
@property (assign, readwrite, getter=isPartialFormatInProgress) BOOL partialFormatInProgress;

// The print mode. For CPCL printers this is always \link _ZplPrintMode::ZPL_PRINT_MODE_UNKNOWN ZPL_PRINT_MODE_UNKNOWN\endlink
@property (assign, readwrite) ZebraPrintMode printMode;

// Get the print mode based on the mode char received from ~HS.
+ (ZebraPrintMode) getPrintMode: (NSString*) modeChar;

@end


@implementation ZebraPrinterStatus

// Object initialization
-(id)init {
    self = [super init]; // Initialize the
    return self;
}

// Return the print mode based on the mode char
+ (ZebraPrintMode) getPrintMode: (NSString*) modeChar {
    if ([modeChar isEqualToString:@"0"]) {
        return ZPL_PRINT_MODE_REWIND;
    } else if ([modeChar isEqualToString:@"1"]) {
        return ZPL_PRINT_MODE_PEEL_OFF;
    } else if ([modeChar isEqualToString:@"2"]) {
        return ZPL_PRINT_MODE_TEAR_OFF;
    } else if ([modeChar isEqualToString:@"3"]) {
        return ZPL_PRINT_MODE_CUTTER;
    } else if ([modeChar isEqualToString:@"4"]) {
        return ZPL_PRINT_MODE_APPLICATOR;
    } else if ([modeChar isEqualToString:@"5"]) {
        return ZPL_PRINT_MODE_DELAYED_CUT;
    } else if ([modeChar isEqualToString:@"6"]) {
        return ZPL_PRINT_MODE_LINERLESS_PEEL;
    } else if ([modeChar isEqualToString:@"7"]) {
        return ZPL_PRINT_MODE_LINERLESS_REWIND;
    } else if ([modeChar isEqualToString:@"8"]) {
        return ZPL_PRINT_MODE_PARTIAL_CUTTER;
    } else if ([modeChar isEqualToString:@"9"]) {
        return ZPL_PRINT_MODE_RFID;
    } else if ([modeChar isEqualToString:@"K"]) {
        return ZPL_PRINT_MODE_KIOSK;
    } else {
        return ZPL_PRINT_MODE_UNKNOWN;
    }
}

// Return the localized description of the print mode
+ (NSString *) getPrintModeLocalizedDescriptino: (ZebraPrintMode) printMode {
    if (printMode == ZPL_PRINT_MODE_REWIND) {
        return @"ZPL_PRINT_MODE_REWIND";
    } else if (printMode == ZPL_PRINT_MODE_PEEL_OFF) {
        return @"ZPL_PRINT_MODE_PEEL_OFF";
    } else if (printMode == ZPL_PRINT_MODE_TEAR_OFF) {
        return @"ZPL_PRINT_MODE_TEAR_OFF";
    } else if (printMode == ZPL_PRINT_MODE_CUTTER) {
        return @"ZPL_PRINT_MODE_CUTTER";
    } else if (printMode == ZPL_PRINT_MODE_APPLICATOR) {
        return @"ZPL_PRINT_MODE_APPLICATOR";
    } else if (printMode == ZPL_PRINT_MODE_DELAYED_CUT) {
        return @"ZPL_PRINT_MODE_DELAYED_CUT";
    } else if (printMode == ZPL_PRINT_MODE_LINERLESS_PEEL) {
        return @"ZPL_PRINT_MODE_LINERLESS_PEEL";
    } else if (printMode == ZPL_PRINT_MODE_LINERLESS_REWIND) {
        return @"ZPL_PRINT_MODE_LINERLESS_REWIND";
    } else if (printMode == ZPL_PRINT_MODE_PARTIAL_CUTTER) {
        return @"ZPL_PRINT_MODE_PARTIAL_CUTTER";
    } else if (printMode == ZPL_PRINT_MODE_RFID) {
        return @"ZPL_PRINT_MODE_RFID";
    } else if (printMode == ZPL_PRINT_MODE_KIOSK) {
        return @"ZPL_PRINT_MODE_KIOSK";
    } else {
        return @"ZPL_PRINT_MODE_UNKNOWN";
    }
}

// Get the current status of the printer based on the return from ~HS
+ (ZebraPrinterStatus*) getCurrentStatus: (NSData*)data error:(NSError**) error {
    // Using NSString to decode the return of ~HS
    NSString *pStatusStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSMutableCharacterSet *charSet = [NSMutableCharacterSet characterSetWithCharactersInString:@"\n"];
    pStatusStr = [pStatusStr stringByTrimmingCharactersInSet:charSet];
    pStatusStr = [pStatusStr stringByReplacingOccurrencesOfString:@"\002" withString:@""];
    pStatusStr = [pStatusStr stringByReplacingOccurrencesOfString:@"\003" withString:@""];
    pStatusStr = [pStatusStr stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    pStatusStr = [pStatusStr stringByReplacingOccurrencesOfString:@"\n" withString:@","];
    
    NSArray *pStatusArray = [pStatusStr componentsSeparatedByString:@","];
    NSLog(@"pStatusArray = %@", pStatusArray);
    
    
    char *statusStr = (char *)data.bytes;
    int aaa; // Communication (interface) settings. Unused in status.
    int b, c, dddd, eee, f;
    int g, h, iii, j; // Unused in status
    int k, l;
    int mmm, n;       // Unused in status
    int o, p;
    int q;            // Unused in status
    char r;           // For print mode character
    int s, t;         // Unused in status
    int uuuuuuuu;
    int v, www;       // Unused in status
    char xxxx[4];     // For password string. Unused in status.
    bzero(xxxx, sizeof(xxxx));
    int y;
    int nn = sscanf(statusStr, "\002%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d,%d\003\r\n\002%d,%d,%d,%d,%d,%c,%d,%d,%d,%d,%d\003\r\n\002%[^,],%d\003\r\n",
                    &aaa, &b, &c, &dddd, &eee, &f, &g, &h, &iii, &j, &k, &l, &mmm, &n, &o, &p, &q, &r, &s, &t, &uuuuuuuu, &v, &www, xxxx, &y);
    
    if (nn != 25) {
        // Missing info from ~HS response. Set malformed error
        NSDictionary *errInfo = nil;
        errInfo = @{NSLocalizedDescriptionKey: @"Malformed printer status response"};
        *error = [NSError errorWithDomain:@"ZebraErrorCode" code:7 userInfo:errInfo];
        
        // Return nil
        return nil;
    }
    
    ZebraPrinterStatus *status = [[ZebraPrinterStatus alloc] init];
    [status setPaperOut:((1 == b)? YES : NO)];          // 1 = paper out
    [status setPaused:((1 == c)? YES : NO)];            // 1 = pause active
    [status setLabelLengthInDots:dddd];                 // Label length in dots
    [status setNumberOfFormatsInReceiveBuffer:eee];     // number of formats in receive buffer
    [status setReceiveBufferFull: ((1 == f)? YES : NO)];// 1 = receive buffer full
    
    [status setHeadCold:((1 == k)? YES : NO)];          // 1 = under temperature
    [status setHeadTooHot:((1 == l)? YES : NO)];        // 1 = over temperature
    
    [status setHeadOpen:((1 == o)? YES : NO)];          // 1 = head in up position
    [status setRibbonOut:((1 == p)? YES : NO)];         // 1 = ribbon out
    
    [status setPrintMode:[self getPrintMode:[NSString stringWithFormat:@"%c", r]]]; // r is the print model
    
    [status setLabelsRemainingInBatch:uuuuuuuu];
    
    [status setReadyToPrint:(!status.paperOut && !status.paused && !status.headTooHot &&
    !status.headCold && !status.ribbonOut && !status.headOpen)];
    
    return status;
}

@end
