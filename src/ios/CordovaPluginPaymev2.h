#import <UIKit/UIKit.h>
#import <Cordova/CDVPlugin.h>
#import <Payme/Payme.h>
#import "PaymeViewControllerv2.h"
@interface CordovaPluginPaymev2 : CDVPlugin<PaymeClientDelegate>

+ (CordovaPluginPaymev2 *)cordovaPluginPayme;

- (void)initPayme:(CDVInvokedUrlCommand*)command;
- (void)sendResponsePay:(NSString *)responseText callbackId:(NSString *)callbackId;

@property (copy, nonatomic) NSString *responsePayCallbackId;
@property NSInteger enviroment;

@end
