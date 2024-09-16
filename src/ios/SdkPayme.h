#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <Payme/Payme.h>
#import "PayViewController.h"
@interface SdkPayme : CDVPlugin<PaymeMobileDelegate>

+ (SdkPayme *)sdkPayme;

- (void)coolMethod:(CDVInvokedUrlCommand*)command;
- (void)sendResponsePay:(NSString *)responseText callbackId:(NSString *)callbackId;

@property (copy, nonatomic) NSString *responsePayCallbackId;

@end
