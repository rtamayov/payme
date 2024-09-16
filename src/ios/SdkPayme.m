/********* SdkPayme.m Cordova Plugin Implementation *******/

#import "SdkPayme.h"

@implementation SdkPayme

@synthesize setEnviroment;
@synthesize responsePayCallbackId = _responsePayCallbackId;

SdkPayme *sdkPayme;

+ (SdkPayme *) sdkPayme {
    return sdkPayme;
}

- (void)pluginInitialize {
    NSLog(@"SdkPayme - Starting Firebase plugin");
    sdkPayme = self;
}

- (void)coolMethod:(CDVInvokedUrlCommand*)command
{
    
    self.responsePayCallbackId = command.callbackId;
    if (self.responsePayCallbackId != nil) {
        NSMutableString *jsonString = [command.arguments objectAtIndex:0];
        NSError *jsonError;
        NSData *objectData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *jsonData = [NSJSONSerialization JSONObjectWithData:objectData
                                      options:0
                                        error:&jsonError];
        /*  NSDictionary *jsonData = [NSJSONSerialization dataWithJSONObject:[command.arguments objectAtIndex:0]
         options:NSJSONWritingPrettyPrinted
         error:&error]; */
        //  NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        //  NSLog(@"JSON:: %@",jsonString);
        PayViewController *pvc = [PayViewController sharedHelper:jsonData callback:self.responsePayCallbackId];
        pvc.request = [[NSDictionary alloc] initWithDictionary:jsonData copyItems:YES];
            [pvc presentPayMeControllerWithDelegate];
            CDVPluginResult* pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [pluginResult setKeepCallback:[NSNumber numberWithBool:YES]];
            [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    } else {
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
}

- (void)sendResponsePay:(NSString *)responseText callbackId:(NSString *)callbackId
{
    if (callbackId != nil) {
        NSLog(@"In response = %@",self.responsePayCallbackId);
        CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:responseText];
        [pluginResult setKeepCallbackAsBool:NO];
       [self.commandDelegate sendPluginResult:pluginResult callbackId:self.responsePayCallbackId];
    }
}

@end
