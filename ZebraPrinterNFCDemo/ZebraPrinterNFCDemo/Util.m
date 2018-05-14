//
//  Util.m
//  ZebraPrinterNFCDemo
//
//  Created by Zebra ISV Team on 3/28/18.
//  Copyright © 2018 Zebra. All rights reserved.
//

#import "Util.h"

@implementation Util

+ (void) showAlert:(NSString *) alertMsg withTitle:(NSString *) title withStyle:(UIAlertControllerStyle) style
   withActionTitle:(NSString *) actionTitle inViewController:(UIViewController *) viewController {
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:alertMsg
                                                            preferredStyle:style];
    
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:actionTitle
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * action) {}];
    
    [alert addAction:defaultAction];
    [viewController presentViewController:alert animated:YES completion:nil];
}

@end
