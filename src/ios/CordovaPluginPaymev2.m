/********* CordovaPluginPaymev2.m Cordova Plugin Implementation *******/

#import "CordovaPluginPaymev2.h"

@implementation CordovaPluginPaymev2

@synthesize responsePayCallbackId = _responsePayCallbackId;
@synthesize enviroment;

CordovaPluginPaymev2 *cordovaPluginPayme;

+ (CordovaPluginPaymev2 *) cordovaPluginPayme {
    return cordovaPluginPayme;
}

/*- (void)pluginInitialize {
    NSLog(@"CordovaPluginPaymev2 - Starting plugin");
    cordovaPluginPayme = self;
}*/

- (void)initPayme:(CDVInvokedUrlCommand*)command
{
    
    self.responsePayCallbackId = command.callbackId;
    NSLog(@"callback %@",self.responsePayCallbackId);
    if (self.responsePayCallbackId != nil) {
        NSMutableString *jsonString = [command.arguments objectAtIndex:0];
        NSError *jsonError;
        NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:objectData options:0 error:&jsonError];

        if ([[jsonData objectForKey:@"environment"] isEqual:@"2"]){
            enviroment = PaymeEnviromentDevelopment;
        }else if ([[jsonData objectForKey:@"environment"] isEqual:@"1"]){
            enviroment = PaymeEnviromentProduction;
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *uvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];

            PaymeClient * pc = [[PaymeClient alloc] initWithDelegate:self key:[jsonData objectForKey:@"identifier"]];
            [pc setEnvironmentWithEnvironment:[self enviroment]];
            PaymeViewControllerv2 *paymeViewController = [[PaymeViewControllerv2 alloc]init];
            [pc authorizeTransactionWithController:uvc usePresent:true paymeRequest:[paymeViewController setParamsMerchant:jsonData]];
        });
        
//        PaymeViewControllerv2 *pvc = [PaymeViewControllerv2 sharedHelper:jsonData callback:self.responsePayCallbackId];
//        pvc.request = [[NSDictionary alloc] initWithDictionary:jsonData copyItems:YES];
//        [pvc presentPayMeControllerWithDelegate:jsonData];
        
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}


- (void)sendResponsePay:(NSString *)responseText callbackId:(NSString *)callbackId
{
    if (callbackId != nil) {
        NSLog(@"In response = %@",callbackId);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:responseText];
        [pluginResult setKeepCallbackAsBool:NO];
        NSLog(@"In response = %@",pluginResult);
        [self.commandDelegate sendPluginResult:pluginResult callbackId:callbackId];
        NSLog(@"In response fin");

    }
}

- (void)onNotificateWithAction:(enum PaymeInternalAction)action {
    NSLog(@"Noti");
}

- (void)onRespondsPaymeWithResponse:(PaymeResponse * _Nonnull)response {
    NSMutableDictionary *main = [NSMutableDictionary dictionary];
    
    [main setValue:response.resultCode forKey:@"resultCode"];
    [main setValue:response.resultMessage forKey:@"resultMessage"];
    [main setValue:response.resultDetail forKey:@"resultDetail"];
    [main setValue:response.success?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"success"];
    
    NSMutableDictionary *payment = [NSMutableDictionary dictionary];
    [payment setValue:response.payment.accepted?[NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"accepted"];
    [payment setValue:response.payment.authorizationCode forKey:@"authorizationCode"];
    [payment setValue:response.payment.brand forKey:@"brand"];
    [payment setValue:response.payment.maskedPan forKey:@"maskedPan"];
    [payment setValue:response.payment.operationDate forKey:@"operationDate"];
    [payment setValue:response.payment.operationNumber forKey:@"operationNumber"];
    
    [main setValue:payment forKey:@"payment"];


    NSData *jsonResponseData = [NSJSONSerialization dataWithJSONObject:main options:NSJSONWritingPrettyPrinted error:nil];
    NSString *jsonResponseText = [[NSString alloc] initWithData:jsonResponseData encoding:NSUTF8StringEncoding];
    NSLog(@"RESPONSE %@",main);
    
    NSLog(@"In response = %@",self.responsePayCallbackId);
    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResponseText];
    [pluginResult setKeepCallbackAsBool:NO];
    NSLog(@"In response = %@",pluginResult);
    [self.commandDelegate sendPluginResult:pluginResult callbackId:self.responsePayCallbackId];
    NSLog(@"In response fin");
}

@end
