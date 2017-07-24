//
//  MyFirstZebraAppViewController.h
//  MyFirstZebraApp
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

@interface ViewController : UIViewController {
    UILabel *statusLabel;
    UITextField *ipDnsTextField;
    UITextField *portTextField;
    UIButton *testButton;
    UITextView *printerStatusText;
}

@property (nonatomic,retain) IBOutlet UILabel *statusLabel;
@property (nonatomic,retain) IBOutlet UITextField *ipDnsTextField;
@property (nonatomic,retain) IBOutlet UITextField *portTextField;
@property (nonatomic,retain) IBOutlet UIButton *testButton;
@property (nonatomic,retain) IBOutlet UITextView *printerStatusText;

-(IBAction)buttonPressed:(id)sender;
-(IBAction)textFieldDoneEditing : (id)sender;
-(IBAction)backgroundTap : (id)sender;

@end
