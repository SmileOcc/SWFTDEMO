//
//  YXIAPManager.m
//  uSmartOversea
//
//  Created by 付迪宇 on 2020/3/9.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXIAPManager.h"
#import <StoreKit/StoreKit.h>
#import "uSmartOversea-Swift.h"

static NSString * const receiptKey = @"receipt";
static NSString * const dateKey = @"date";
static NSString * const userIdKey = @"userId";
static NSString * const orderIdKey = @"orderId";
static NSString * const transactionIdKey = @"transactionId";

dispatch_queue_t iap_queue() {
    static dispatch_queue_t as_iap_queue;
    static dispatch_once_t onceToken_iap_queue;
    dispatch_once(&onceToken_iap_queue, ^{
        as_iap_queue = dispatch_queue_create("com.iap.queue", DISPATCH_QUEUE_CONCURRENT);
    });
    
    return as_iap_queue;
}


@implementation Product


@end


@interface YXIAPManager ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, assign) BOOL goodsRequestFinished;

@property (nonatomic, copy) NSString *receipt; //交易成功后拿到的一个64编码字符串

@property (nonatomic, copy) NSString *date; //交易时间

@property (nonatomic, copy) NSString *userId; //交易人

@property (strong, nonatomic) Product *currentProduct;
@property (strong, nonatomic) NSString *currentOrderId;


@end


@implementation YXIAPManager


+ (YXIAPManager *)shared {
    static YXIAPManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[YXIAPManager alloc] init];
    });
    
    return instance;
}

- (void)startManager { //开启监听

    dispatch_async(iap_queue(), ^{
       
        self.goodsRequestFinished = YES;
        
        [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
        
        [self checkIAPFiles];
    });
}

- (void)stopManager{

    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    });
}

#pragma mark 查询

- (void)requestProduct:(Product *)product {
//    id<UIApplicationDelegate> del= [UIApplication sharedApplication].delegate;
    self.currentProduct = product;
    self.userId = product.userId;
    [self requestProductWithId:product.itunes_product_id];

}

- (void)requestProductWithId:(NSString *)productId {
    if (self.goodsRequestFinished) {
        
        if ([SKPaymentQueue canMakePayments]) { //允许app内购
            if (productId.length) {
                NSLog(@"%@商品正在请求中",productId);
                
                self.goodsRequestFinished = NO;
                
                NSArray *product = @[productId];
                NSSet *set = [NSSet setWithArray:product];
                SKProductsRequest *productRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
                productRequest.delegate = self;
                
                [productRequest start];
                
            } else {
                NSLog(@"商品为空");
        
                [self failedWithErrorCode:IAP_FAILEDCOED_PARAMERROR error:nil];
                self.goodsRequestFinished = YES;
//                [_hud hideAnimated:YES];
            }
            
        } else { //没有权限
            
            [self failedWithErrorCode:IAP_FAILEDCOED_NORIGHT error:nil];
            
            self.goodsRequestFinished = YES;
//            [_hud hideAnimated:YES];
        }
        
    } else {
        NSLog(@"上次请求还未完成，请稍等");
  //      [_hud hideAnimated:YES];
    }
}

- (void)failedWithErrorCode:(NSInteger)code error:(NSString *)error {

    if (self.delegate && [self.delegate respondsToSelector:@selector(failedWithErrorCode:andError:)]) {
        switch (code) {
            case IAP_FAILEDCOED_APPLECODE:
                [self.delegate failedWithErrorCode:IAP_FAILEDCOED_APPLECODE andError:error];
                break;

                case IAP_FAILEDCOED_NORIGHT:
                [self.delegate failedWithErrorCode:IAP_FAILEDCOED_NORIGHT andError:@""];
                break;

            case IAP_FAILEDCOED_PARAMERROR:
                [self.delegate failedWithErrorCode:IAP_FAILEDCOED_PARAMERROR andError:@""];
                break;

            case IAP_FAILEDCOED_CANNOTGETINFORMATION:
                 [self.delegate failedWithErrorCode:IAP_FAILEDCOED_CANNOTGETINFORMATION andError:@""];
                break;

            case IAP_FAILEDCOED_BUYFILED:
                 [self.delegate failedWithErrorCode:IAP_FAILEDCOED_BUYFILED andError:@""];
                break;

            case IAP_FAILEDCOED_USERCANCEL:
                 [self.delegate failedWithErrorCode:IAP_FAILEDCOED_USERCANCEL andError:@""];
                break;

            default:
                break;
        }
        self.delegate = nil;
    }
}

#pragma mark SKProductsRequestDelegate 查询成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {

    NSArray *products = response.products;
    
    if (products.count == 0) {
        NSLog(@"无法获取商品信息，请重试");
        [self failedWithErrorCode:IAP_FAILEDCOED_CANNOTGETINFORMATION error:nil];
        
        self.goodsRequestFinished = YES; //失败，请求完成
//        [_hud hideAnimated:YES];
    } else {
        SKProduct *product = products[0];
    
        _currentOrderId = nil;
        SKMutablePayment *payment = [SKMutablePayment paymentWithProduct:product];
        payment.applicationUsername = [NSString stringWithFormat:@"%@", _currentProduct.orderId];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
        _currentProduct = nil;
    }
}


#pragma mark SKProductsRequestDelegate 查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    
    [self failedWithErrorCode:IAP_FAILEDCOED_APPLECODE error:[error localizedDescription]];
    
    self.goodsRequestFinished = YES; //失败，请求完成
//    [_hud hideAnimated:YES];
}

#pragma mark SKPaymentTransactionObserver 购买操作后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(nonnull NSArray<SKPaymentTransaction *> *)transactions {

    for (SKPaymentTransaction *transaction in transactions) {
       
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing://正在交易
                break;
            case SKPaymentTransactionStatePurchased://交易完成
                
                [self getReceipt]; //获取购买凭证
                [self saveReceiptTransaction:transaction]; //存储凭证
                [self checkIAPFiles];//验证凭证
                [self completeTransaction:transaction];
                
                break;

            case SKPaymentTransactionStateFailed://交易失败
        
                [self failedTransaction:transaction];
//                [_hud hideAnimated:YES];
                break;

            case SKPaymentTransactionStateRestored://已经购买过该商品
                
                [self restoreTransaction:transaction];
//                [_hud hideAnimated:YES];
                break;
           
            default:
               
                break;
        }
    }
}

#pragma mark 存储用户购买凭证
-(void)saveReceiptTransaction:(SKPaymentTransaction *)transaction {

    NSDateFormatter *dateFormatter = [NSDateFormatter en_US_POSIXFormatter];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    self.date = [dateFormatter stringFromDate:[NSDate date]];
    
    NSString *fileName = [[NSUUID UUID] UUIDString];
    NSString *savedPath = [NSString stringWithFormat:@"%@/%@.plist", [self iapReceiptPath], fileName];
    
    NSDictionary *dic = @{receiptKey: self.receipt,
            dateKey: self.date,
            userIdKey: self.userId,
            orderIdKey: transaction.payment.applicationUsername,
            transactionIdKey: transaction.transactionIdentifier};
    _currentOrderId = transaction.payment.applicationUsername;
    [dic writeToFile:savedPath atomically:YES];
}

#pragma mark 将存储到本地的IAP文件发送给服务端 验证receipt失败,App启动后再次验证
- (void)checkIAPFiles{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
   
    NSArray *cacheFileNameArray = [fileManager contentsOfDirectoryAtPath:[self iapReceiptPath] error:&error];
    
    if (error == nil) {
        for (NSString *name in cacheFileNameArray) {
            if ([name hasSuffix:@".plist"]){
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self iapReceiptPath], name];
                [self sendAppStoreRequestBuyPlist:filePath];
            }
        }
    
    } else {
        NSLog(@"AppStoreInfoLocalFilePath error:%@", [error domain]);
       // [_hud hideAnimated:YES];
    }
}

-(void)sendAppStoreRequestBuyPlist:(NSString *)plistPath {
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:plistPath];

    if (self.delegate && [self.delegate respondsToSelector:@selector(successWithResult:)] && [_currentOrderId isEqualToString:dic[orderIdKey]]) {
        _currentOrderId = nil;
        [self.delegate successWithResult:dic];
    } else {
        _currentOrderId = nil;
        if (dic[receiptKey]) {
            YXIAPRequestModel *requestModel = [[YXIAPRequestModel alloc] init];
            requestModel.receiptData = dic[receiptKey];
            requestModel.paymentNo = [dic[orderIdKey] longLongValue];
            YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
            [request startWithBlockWithSuccess:^(__kindof YXIAPResponseModel *responseModel) {
                if (responseModel.flag) {
                    NSFileManager *fileManager = [NSFileManager defaultManager];
                    [fileManager removeItemAtPath:plistPath error:nil];
                }
            } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
                
            }];
        }
    }

//    [self removeReceipt:plistPath];
//    [_hud hideAnimated:YES];

}

#pragma mark 获取交易成功后的购买凭证
- (void)getReceipt {
    NSURL *receiptUrl = [[NSBundle mainBundle] appStoreReceiptURL];
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptUrl];
        
    self.receipt = [receiptData base64EncodedStringWithOptions:0];
}


-(void)removeReceiptWithOrderId:(NSString *)orderId{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSArray *cacheFileNameArray = [fileManager contentsOfDirectoryAtPath:[self iapReceiptPath] error:&error];
    
    if (error == nil) {
        for (NSString *name in cacheFileNameArray) {
            if ([name hasSuffix:@".plist"]){
                NSString *filePath = [NSString stringWithFormat:@"%@/%@", [self iapReceiptPath], name];
                NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:filePath];
                if ([dict[orderIdKey] isEqualToString:orderId]) {
                    [fileManager removeItemAtPath:filePath error:nil];
                    return;
                }
            }
        }
    } else {
        
        NSLog(@"AppStoreInfoLocalFilePath error:%@", [error domain]);
        //[_hud hideAnimated:YES];
    }
}


- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    self.goodsRequestFinished = YES;
    self.delegate = nil;
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {

    NSLog(@"transaction.error.code = %ld", (long)transaction.error.code);

    if(transaction.error.code != SKErrorPaymentCancelled) {
        [self failedWithErrorCode:IAP_FAILEDCOED_BUYFILED error:nil];
    } else {
        [self failedWithErrorCode:IAP_FAILEDCOED_USERCANCEL error:nil];
    }

    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
   
    self.goodsRequestFinished = YES; //失败，请求完成

}


- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    self.goodsRequestFinished = YES;
    self.delegate = nil;
}

- (NSString *)iapReceiptPath {
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths[0] stringByAppendingFormat:@"/Preferences"] stringByAppendingFormat:@"/EACEF35FE363A75A"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:NULL];
    }
    return path;
}

@end
