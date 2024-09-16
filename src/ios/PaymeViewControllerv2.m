#import "PaymeViewControllerv2.h"

@implementation PaymeViewControllerv2

@synthesize setEnviroment;
@synthesize request = _request;
@synthesize resultResponse = _resultResponse;
@synthesize callbackId = _callbackId;
NSString  *operationNumberG = nil;

+ (instancetype)sharedHelper:(NSDictionary *)inputRequest callback:(NSString *)callbackid;
{
    
    static PaymeViewControllerv2 *sharedClass = nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        sharedClass = [[self alloc] init];
        sharedClass.request = inputRequest;
        sharedClass.callbackId = callbackid;
    });
    
    return sharedClass;
}

-(id)initWithArgs:(NSDictionary *)request
{
    self.request = request;
    return self;
}


- (void)presentPayMeControllerWithDelegate:(NSDictionary *)request{
    if ([[request objectForKey:@"environment"] isEqual:@"2"]){
        setEnviroment = PaymeEnviromentDevelopment;
    }else if ([[request objectForKey:@"environment"] isEqual:@"1"]){
        setEnviroment = PaymeEnviromentProduction;
    }
    self.resultResponse = @"0";
    //Conseguir ruta del View Controller Actual
    
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *uvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];

        PaymeClient * pc = [[PaymeClient alloc] initWithDelegate:self key:[self.request objectForKey:@"identifier"]];
        [pc setEnvironmentWithEnvironment:[self setEnviroment]];
        [pc authorizeTransactionWithController:uvc usePresent:true paymeRequest:[self setParamsMerchant:request]];
    });
}

//Validar datos string nullos
- (NSString *)validateEmptyOrNull:(NSString *)value{
    NSString *rs;
    if([value  isEqual: NULL]){
        rs = @" ";
    }else{
        rs = value;
    }
    return rs;
}

- (void)dismissed {
    NSLog(@"Close payme ...");
    if (![self.resultResponse isEqual:@"1"]) {
        NSMutableDictionary *main = [NSMutableDictionary dictionary];
        
        [main setValue:[NSNumber numberWithBool:YES] forKey:@"success"];
        [main setValue:@"999" forKey:@"messageCode"];
        [main setValue:@"Cancel Transaction" forKey:@"message"];
        [main setValue:[self.request objectForKey:@"amount"] forKey:@"amount"];
        
        NSMutableDictionary *payment = [NSMutableDictionary dictionary];
        
        [payment setValue:[NSNumber numberWithBool:NO] forKey:@"accepted"];
        [payment setValue:@" " forKey:@"resultCode"];
        [payment setValue:@" " forKey:@"resultMessage"];
        [payment setValue:@" " forKey:@"authorizationResult"];
        [payment setValue:@" " forKey:@"brand"];
        [payment setValue:@" " forKey:@"bin"];
        [payment setValue:@" " forKey:@"lastPan"];
        [payment setValue:@" " forKey:@"transactionIdentifier"];
        [payment setValue:@" " forKey:@"errorCode"];
        [payment setValue:@" " forKey:@"errorMessage"];
        [payment setValue:@" " forKey:@"date"];
        [payment setValue:@" " forKey:@"hour"];
        [payment setValue:@" " forKey:@"authorizationCode"];
        [payment setValue:operationNumberG forKey:@"operationNumber"];
        
        
        [main setValue:payment forKey:@"payment"];
        
        NSMutableDictionary *features = [NSMutableDictionary dictionary];
        
        NSMutableArray *contentarray;
        
        NSMutableDictionary *content = [NSMutableDictionary dictionary];
        [content setValue:@" " forKey:@"name"];
        [content setValue:@" " forKey:@"value"];
        [contentarray addObject:content];
        
        [features setValue:contentarray forKey:@"reserved"];
        
        NSMutableDictionary *planQuota = [NSMutableDictionary dictionary];
        
        [planQuota setValue:@" " forKey:@"plan" ];
        [planQuota setValue:@" " forKey:@"quota" ];
        [planQuota setValue:@" " forKey:@"quotaProcessed" ];
        [planQuota setValue:@" " forKey:@"amount" ];
        [planQuota setValue:@" " forKey:@"dueDate" ];
        [planQuota setValue:@" " forKey:@"currency" ];
        [planQuota setValue:@" " forKey:@"interest" ];
        
        [features setValue:planQuota forKey:@"planQuotaData"];
        
        [main setValue: features forKey:@"features"];
        
        //Convert NSDictionary to JSON String
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:main options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *jsonStr = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        
        NSLog(@"Callback PVC %@",self.callbackId);
        [CordovaPluginPaymev2.cordovaPluginPayme sendResponsePay:jsonStr callbackId:self.callbackId];
    }    
}

- (void)onRespondsPaymeWithResponse:(PaymeResponse *)response{
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
    
    CordovaPluginPaymev2 *pluginPayme = [[CordovaPluginPaymev2 alloc] init];
    [pluginPayme sendResponsePay:jsonResponseText callbackId:self.callbackId];
    
//    CDVPluginResult *pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:jsonResponseText];
//    [pluginResult setKeepCallbackAsBool:NO];
//   [self.commandDelegate sendPluginResult:pluginResult callbackId:self.callbackId];
    
}

- (void)onNotificateWithAction:(enum PaymeInternalAction)action{
    switch (action) {
        case PaymeInternalActionPRESS_PAY_BUTTON:
            [FIRAnalytics logEventWithName:@"InPasarela" parameters:[self logEvent:@"PRESS_PAY_BUTTON" eventAction:@"click" eventLabel:@"El usuario presionó el boton pagar exitosamente." ]];
            break;
        case PaymeInternalActionSTART_SCORING:
            [FIRAnalytics logEventWithName:@"InPasarela" parameters:[self logEvent:@"START_SCORING" eventAction:@"scoring" eventLabel:@"Inicia el proceso de evaluación de riesgo." ]];
            break;;
        case PaymeInternalActionEND_SCORING:
            [FIRAnalytics logEventWithName:@"InPasarela" parameters:[self logEvent:@"END_SCORING" eventAction:@"scoring" eventLabel:@"Termina el proceso de evaluación de riesgo." ]];
            break;
        case PaymeInternalActionSTART_TDS:
            [FIRAnalytics logEventWithName:@"InPasarela" parameters:[self logEvent:@"START_TDS" eventAction:@"tds" eventLabel:@"Inicia el proceso de autenticación." ]];
            break;
        case PaymeInternalActionEND_TDS:
            [FIRAnalytics logEventWithName:@"InPasarela" parameters:[self logEvent:@"END_TDS" eventAction:@"tds" eventLabel:@"Termina el proceso de autenticación." ]];
            break;
        case PaymeInternalActionSTART_AUTHORIZATION:
            [FIRAnalytics logEventWithName:@"InPasarela" parameters:[self logEvent:@"START_AUTHORIZATION" eventAction:@"authorization" eventLabel:@"Se inicia la autorización." ]];
            break;
        default:
            break;
    }
}

-(NSDictionary *) logEvent:(NSString *)eventCategory eventAction:(NSString *)eventAction eventLabel:(NSString *)eventLabel {
    NSDictionary *parameters;
    [parameters setValue:eventCategory forKey:@"eventCategory"];
    [parameters setValue:eventAction forKey:@"eventAction"];
    [parameters setValue:eventLabel forKey:@"eventLabel"];
    return parameters;
}

- (PaymeRequest * _Nonnull)setParamsMerchant:(NSDictionary *)request {
    
    NSString *firstName = [request objectForKey:@"firstName"];
    NSString *lastName = [request objectForKey:@"lastName"];
    NSString *email = [request objectForKey:@"email"];
    NSString *address1 = [request objectForKey:@"address1"];
    NSString *address2 = [request objectForKey:@"address2"];
    NSString *countryCode = [request objectForKey:@"countryCode"];
    NSString *countryNumber = [request objectForKey:@"countryNumber"];
    NSString *zip = [request objectForKey:@"zip"];
    NSString *city = [request objectForKey:@"city"];
    NSString *state = [request objectForKey:@"state"];
    NSString *homePhone = [request objectForKey:@"homePhone"];
    NSString *workPhone = [request objectForKey:@"workPhone"];
    NSString *mobilePhone = [request objectForKey:@"mobilePhone"];
    
    NSString *currencyCode = [request objectForKey:@"currencyCode"];
    NSString *currencySymbol = [request objectForKey:@"currencySymbol"];
    
    NSString *operationNumber = [request objectForKey:@"operationNumber"];
    NSString *operationDescription = [request objectForKey:@"productDescription"];
    NSString *amount = [request objectForKey:@"amount"];
    
    NSString *name = [request objectForKey:@"name"];
    NSString *value = [request objectForKey:@"value"];
    NSMutableDictionary<NSString *, NSString *> *reserved = [NSMutableDictionary dictionary];
    [reserved setObject:(value?value:@"1") forKey:(name?name:@"reserved1")];
    
    NSString *userCode = [request objectForKey:@"userCommerce"];
    NSString *planQuota = [request objectForKey:@"planQuota"];
    BOOL installments = true;
    if([planQuota  isEqual: @"1"]){
        installments = true;
    }else{
        installments = false;
    }
    NSString *authentication = [request objectForKey:@"authentication"];
    
    NSString *locale = [request objectForKey:@"locale"];
    NSString *settingBrands = [request objectForKey:@"brands" ];
    NSArray<NSString *> *brands = [settingBrands componentsSeparatedByString:@","];
    
    PaymePersonData *modelMerchantDataPerson = [[PaymePersonData alloc] initWithFirstName:firstName lastName:lastName email:email addrLine1:address1 addrLine2:address2 countryCode:countryCode countryNumber:countryNumber zip:zip city:city state:state mobilePhone:mobilePhone homePhone:homePhone workPhone:workPhone];
    
    PaymeCurrencyData *currency = [[PaymeCurrencyData alloc] initWithCode: currencyCode symbol: currencySymbol];
    
    PaymeOperationData *paymeOperationData = [[PaymeOperationData alloc] initWithOperationNumber:operationNumber operationDescription:operationDescription amount:amount currency:currency ];
    
    PaymeMerchantData *modelMerchantData = [[PaymeMerchantData alloc] initWithOperation: paymeOperationData addrMatch:true billing:modelMerchantDataPerson shipping:modelMerchantDataPerson];
    
    PaymeSettingData *modelMerchantSettings = [[PaymeSettingData alloc] initWithLocale:locale brands:brands];
    
    PaymeWalletData *paymeWalletData = [[PaymeWalletData alloc] initWithEnable:true userID:userCode];
    
    PaymeFeatureData *modelMerchantFeaturesWallet = [[PaymeFeatureData alloc] initWithReserved:reserved wallet:paymeWalletData installments: [[PaymeInstallmentsData alloc] initWithEnable:installments] authentication:[[PaymeAuthenticationData alloc] initWithTdsChallengeInd:authentication]];
    
    PaymeRequest *paymeRequest = [[PaymeRequest alloc] initWithMerchant:modelMerchantData feature:modelMerchantFeaturesWallet  setting:modelMerchantSettings];
    
    return paymeRequest;
}
@end
