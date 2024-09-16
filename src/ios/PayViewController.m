#import "PayViewController.h"

@implementation PayViewController

@synthesize setEnviroment;
@synthesize request = _request;
@synthesize resultResponse = _resultResponse;
@synthesize callbackId = _callbackId;

+ (instancetype)sharedHelper:(NSDictionary *)inputRequest callback:(NSString *)callbackid;
{
    
    static PayViewController *sharedClass = nil;
    
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


- (void)presentPayMeControllerWithDelegate{
    if ([[self.request objectForKey:@"environment"] isEqual:@"2"]){
        setEnviroment = EnviromentDevelopment;
    }else if ([[self.request objectForKey:@"environment"] isEqual:@"1"]){
        setEnviroment = EnviromentProduction;
    }
    self.resultResponse = @"0";
    //Conseguir ruta del View Controller Actual
    dispatch_async(dispatch_get_main_queue(), ^{
        UIViewController *uvc = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"MainPaymeApi" bundle: [NSBundle bundleForClass:[PayController class]]];
        PayController *vc = [sb instantiateViewControllerWithIdentifier:@"PayController"];
        vc.paymeProtocol = self;
        
        [uvc presentViewController:vc animated:YES completion:nil];
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

- (NSString *)getPrivateKey{
    NSString* key = @"-----BEGIN PRIVATE KEY----- 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 5yrFp+iZY/hKT2x0q/R86oOz6Vf19Q== -----END PRIVATE KEY-----";
    
    return key;
}

- (NSString* )decryptString:(NSString *)string{
    NSString *stringVal = [RSA decryptString:string privateKey:[self getPrivateKey]];
    NSArray<NSString *> *string_array= [stringVal componentsSeparatedByString:@"cryptoentel"];
    stringVal = [string_array objectAtIndex:1];
    return stringVal;
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
        [payment setValue:@" " forKey:@"operationNumber"];
        
        
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
        [SdkPayme.sdkPayme sendResponsePay:jsonStr callbackId:self.callbackId];
    }    
}

- (void)getResponsePayWithResponse:(ModelPayment * _Nullable)response {
    
    
    if (response != NULL) {
        NSMutableDictionary *main = [NSMutableDictionary dictionary];
        
        [main setValue:response.success ? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"success"];
        [main setValue:response.messageCode forKey:@"messageCode"];
        [main setValue:response.success ? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"message"];
        [main setValue:[self.request objectForKey:@"amount"] forKey:@"amount"];
        
        
        NSMutableDictionary *payment = [NSMutableDictionary dictionary];
        if([response.payment isEqual:NULL]){
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
            [payment setValue:@" " forKey:@"operationNumber"];
        }else{
            [payment setValue:response.payment.accepted ? [NSNumber numberWithBool:YES]:[NSNumber numberWithBool:NO] forKey:@"accepted"];
            [payment setValue:[self validateEmptyOrNull:response.payment.resultCode] forKey:@"resultCode"];
            [payment setValue:[self validateEmptyOrNull:response.payment.resultMessage] forKey:@"resultMessage"];
            [payment setValue:[self validateEmptyOrNull:response.payment.authorizationResult] forKey:@"authorizationResult"];
            [payment setValue:[self validateEmptyOrNull:response.payment.brand] forKey:@"brand"];
            [payment setValue:[self validateEmptyOrNull:response.payment.bin] forKey:@"bin"];
            [payment setValue:[self validateEmptyOrNull:response.payment.lastPan] forKey:@"lastPan"];
            [payment setValue:[self validateEmptyOrNull:response.payment.transactionIdentifier] forKey:@"transactionIdentifier"];
            [payment setValue:[self validateEmptyOrNull:response.payment.errorCode] forKey:@"errorCode"];
            [payment setValue:[self validateEmptyOrNull:response.payment.errorMessage] forKey:@"errorMessage"];
            [payment setValue:[self validateEmptyOrNull:response.payment.date] forKey:@"date"];
            [payment setValue:[self validateEmptyOrNull:response.payment.hour] forKey:@"hour"];
            [payment setValue:[self validateEmptyOrNull:response.payment.errorMessage] forKey:@"authorizationCode"];
            [payment setValue:[self validateEmptyOrNull:response.payment.errorMessage] forKey:@"operationNumber"];
        }
        
        [main setValue:payment forKey:@"payment"];
        
        
        NSMutableDictionary *features = [NSMutableDictionary dictionary];
        
        NSMutableArray *contentarray;
        
        
        if([response.features.reserved isEqual:NULL]){
            NSMutableDictionary *content = [NSMutableDictionary dictionary];
            [content setValue:@" " forKey:@"name"];
            [content setValue:@" " forKey:@"value"];
            [contentarray addObject:content];
        }else{
            for (int i = 0; i < [response.features.reserved count]; i++) {
                NSMutableDictionary *content = [NSMutableDictionary dictionary];
                [content setValue:[self validateEmptyOrNull:response.features.reserved[i].name] forKey:@"name"];
                [content setValue:[self validateEmptyOrNull:response.features.reserved[i].value] forKey:@"value"];
                [contentarray addObject:content];
            }
        }
        
        [features setValue:contentarray forKey:@"reserved"];
        
        NSMutableDictionary *planQuota = [NSMutableDictionary dictionary];
        
        if([response.features.planQuota isEqual:NULL]){
            [planQuota setValue:@" " forKey:@"plan" ];
            [planQuota setValue:@" " forKey:@"quota" ];
            [planQuota setValue:@" " forKey:@"quotaProcessed" ];
            [planQuota setValue:@" " forKey:@"amount" ];
            [planQuota setValue:@" " forKey:@"dueDate" ];
            [planQuota setValue:@" " forKey:@"currency" ];
            [planQuota setValue:@" " forKey:@"interest" ];
            
            [features setValue:planQuota forKey:@"planQuotaData"];
        }else{
            [planQuota setValue:[self validateEmptyOrNull:response.features.planQuota.plan] forKey:@"plan" ];
            [planQuota setValue:[self validateEmptyOrNull:response.features.planQuota.quota] forKey:@"quota" ];
            [planQuota setValue:[self validateEmptyOrNull:response.features.planQuota.quotaProcessed] forKey:@"quotaProcessed" ];
            [planQuota setValue:[self validateEmptyOrNull:response.features.planQuota.amount] forKey:@"amount" ];
            [planQuota setValue:[self validateEmptyOrNull:response.features.planQuota.dueDate] forKey:@"dueDate" ];
            [planQuota setValue:[self validateEmptyOrNull:response.features.planQuota.currency] forKey:@"currency" ];
            [planQuota setValue:[self validateEmptyOrNull:response.features.planQuota.interest] forKey:@"interest" ];
            
            [features setValue:planQuota forKey:@"planQuotaData"];
        }
        
        [main setValue: features forKey:@"features"];
        
        //Convert NSDictionary to JSON String
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:main options:NSJSONWritingPrettyPrinted error:nil];
        
        NSString *jsonStr = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
        
        NSLog(@"Callback PVC %@",self.callbackId);
        [SdkPayme.sdkPayme sendResponsePay:jsonStr callbackId:self.callbackId];
        
        self.resultResponse = @"1";
    }else {
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
        [payment setValue:@" " forKey:@"operationNumber"];
        
        
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
        [SdkPayme.sdkPayme sendResponsePay:jsonStr callbackId:self.callbackId];
        
        self.resultResponse = @"1";
    }
}

- (ModelMerchant * _Nonnull)setParamsMerchant {
    
    NSString *settingIdentifier = [self decryptString:[self.request objectForKey:@"identifier" ]];
    NSString *settingLocale = [self.request objectForKey:@"locale"];
    NSString *settingBrands = [self.request objectForKey:@"brands" ];
    NSArray<NSString *> *array_brands = [settingBrands componentsSeparatedByString:@","];
    NSString *operationNumber = [self decryptString:[self.request objectForKey:@"operationNumber"]];
    NSString *operationCurrencyCode = [self.request objectForKey:@"code"];
    NSString *operationCurrencySymbol = [self.request objectForKey:@"symbol"];
    NSString *operationProduct = [self.request objectForKey:@"productDescription"];
    NSString *featuresWalletUserCode = [self.request objectForKey:@"userCommerce"];
    NSString *featuresPlanQuota = [self.request objectForKey:@"planQuota"];
    NSString *signatureKey = [self decryptString:[self.request objectForKey:@"signatureKey"]];
    
    NSString *firstName = [self.request objectForKey:@"firstName"];
    NSString *lastName = [self.request objectForKey:@"lastName"];
    NSString *email = [self.request objectForKey:@"email"];
    NSString *address = [self.request objectForKey:@"address"];
    NSString *zip = [self.request objectForKey:@"zip"];
    NSString *city = [self.request objectForKey:@"city"];
    NSString *state = [self.request objectForKey:@"state"];
    NSString *country = [self.request objectForKey:@"country"];
    NSString *phone = [self.request objectForKey:@"phone"];
    
    NSString *amount = [self.request objectForKey:@"amount"];
    
    NSString *name = [self.request objectForKey:@"name"];
    NSString *value = [self.request objectForKey:@"value"];
    
    BOOL planQuota = true;
    if([featuresPlanQuota  isEqual: @"1"]){
        planQuota = true;
    }else{
        planQuota = false;
    }
    
    ModelMerchantDataPerson *modelMerchantDataPerson = [[ModelMerchantDataPerson alloc] initWithFirstName:firstName lastName:lastName email:email address:address zip:zip city:city state:state country:country phone:phone];
    
    ModelMerchantDataOperationCurrency *currency = [[ModelMerchantDataOperationCurrency alloc] initWithCode: operationCurrencyCode symbol: operationCurrencySymbol];
    
    ModelMerchantDataOperation *modelMerchantDataOperation = [[ModelMerchantDataOperation alloc] initWithOperationNumber:operationNumber amount:amount currency:currency productDescription:operationProduct];
    
    ModelMerchantData *modelMerchantData = [[ModelMerchantData alloc] initWithOperation: modelMerchantDataOperation shipping: modelMerchantDataPerson billing: modelMerchantDataPerson customer: modelMerchantDataPerson];
    
    ModelMerchantSettings *modelMerchantSettings = [[ModelMerchantSettings alloc] initWithLocale:settingLocale identifier:settingIdentifier brands:array_brands signatureKey:signatureKey];
    
    ModelMerchantFeaturesWallet *modelMerchantFeaturesWallet = [[ModelMerchantFeaturesWallet alloc] initWithUserCommerce:featuresWalletUserCode];
    
    ModelMerchantFeaturesReserved *reserved1 = [[ModelMerchantFeaturesReserved alloc] initWithName:name value:value];
    ModelMerchantFeaturesReserved *reserved2 = [[ModelMerchantFeaturesReserved alloc] initWithName:@"reserved2" value:@"2"];
    ModelMerchantFeaturesReserved *reserved3 = [[ModelMerchantFeaturesReserved alloc] initWithName:@"reserved3" value:@"3"];
    
    NSArray *reservedArray = @[reserved1, reserved2, reserved3];
    
    ModelMerchantFeatures *modelMerchantFeatures = [[ModelMerchantFeatures alloc] initWithWallet:modelMerchantFeaturesWallet reserved:reservedArray planQuota:planQuota];
    
    
    ModelMerchant *merchant = [[ModelMerchant alloc] initWithData: modelMerchantData settings: modelMerchantSettings features: modelMerchantFeatures];
    
    return merchant;
}



@end
