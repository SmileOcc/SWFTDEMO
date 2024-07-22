//
//  ZFAnalyticsQueueManager.m
//  ZZZZZ
//
//  Created by YW on 2019/6/17.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAnalyticsQueueManager.h"
#import "Constants.h"

#ifndef ZF_LOCK
#define ZF_LOCK(lock) dispatch_semaphore_wait(lock, DISPATCH_TIME_FOREVER);
#endif

#ifndef ZF_UNLOCK
#define ZF_UNLOCK(lock) dispatch_semaphore_signal(lock);
#endif

#define MAXParamsCount 10
#define MAXListCount 2

static NSString *ZFAnalyticsQueueFile = @"ZFAnalyticsQueueFile";

@interface ZFAnalyticsQueueManager ()

@property (nonatomic, strong) NSMutableArray <ZFAnalyticsOperation *> *operationList;
@property (nonatomic, strong) NSOperationQueue *operationQueue;
@property (nonatomic, strong) dispatch_semaphore_t analyticsLock;
@property (nonatomic, assign) NSInteger analyticsCount;

+ (instancetype)sharedInstance;

- (ZFAnalyticsQueueUploadType)currentAnalyticsType;

- (void)startOperationQueue;

@end

@implementation ZFAnalyticsQueueManager

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static ZFAnalyticsQueueManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[ZFAnalyticsQueueManager alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _analyticsLock = dispatch_semaphore_create(1);
        self.analyticsCount = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationWillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        
        [self startLocalOperation];
    }
    return self;
}

- (ZFAnalyticsOperation *)creatOperation
{
    ZFAnalyticsOperation *operation = [[ZFAnalyticsOperation alloc] initAnalyticsOperation];
    @weakify(self)
    operation.doneBlock = ^{
        //完成后，再开始下一个
        @strongify(self)
        [self dequeue];
        self.analyticsCount = 0;
        [self startOperationQueue];
    };
    [self seekOperation:operation];
    return operation;
}

- (ZFAnalyticsQueueUploadType)currentAnalyticsType
{
    return ZFAnalyticsQueueUploadType_TEST;
}

- (ZFAnalyticsOperation *)firstOperation
{
    @synchronized (self) {
        ZFAnalyticsOperation *operation = nil;
        if ([self.operationList count]) {
            operation = self.operationList[0];
        } else {
            operation = [self creatOperation];
        }
        return operation;
    }
}

- (ZFAnalyticsOperation *)dequeue
{
    @synchronized (self) {
        ZFAnalyticsOperation *operation = nil;
        if ([self.operationList count]) {
            operation = self.operationList[0];
            [self.operationList removeObjectAtIndex:0];
        }
        return operation;
    }
}

- (void)seekOperation:(ZFAnalyticsOperation *)operation
{
    @synchronized (self) {
        [self.operationList addObject:operation];
    }
}

- (void)startOperationQueue
{
    ZF_LOCK(self.analyticsLock)
    if (self.analyticsCount == 0 && [self.operationList count]) {
        ZF_UNLOCK(self.analyticsLock)
        self.analyticsCount = 1;
        [self.operationQueue addOperation:[self firstOperation]];
    } else {
        ZF_UNLOCK(self.analyticsLock)
    }
}

- (void)saveQueueToLocal
{
    @synchronized (self) {
        @try {
            if (![self.operationList count]) {
                return;
            }
            NSMutableArray *encodeAnalyticsParams = [[NSMutableArray alloc] init];
            for (ZFAnalyticsOperation *operation in self.operationList) {
                if ([operation.analyticsList count]) {
                    NSData *analyticsData = [NSKeyedArchiver archivedDataWithRootObject:operation.analyticsList];
                    [encodeAnalyticsParams addObject:analyticsData];
                }
            }
            NSData *encodeData = [NSKeyedArchiver archivedDataWithRootObject:encodeAnalyticsParams];
            if (!encodeData) {
                return;
            }
            NSError *error = nil;
            [encodeData writeToURL:self.class.localQueueUrl options:NSDataWritingAtomic error:&error];
            if (error) {
                YWLog(@"ZZZZZ operation write file error - %@", error);
            }
        } @catch (NSException *exception) {
            YWLog(@"%@", [self.class exceptionString:exception]);
        }
    }
}

#pragma mark - public method

+ (void)asyncAnalyticsEvent:(NSString *)eventName withValues:(NSDictionary *)values;
{
    ZFAnalyticsOperation *operation = [[ZFAnalyticsQueueManager sharedInstance] creatOperation];
    [operation.analyticsList addObject:@{eventName : values}];
    [[ZFAnalyticsQueueManager sharedInstance] startOperationQueue];
}

- (void)startLocalOperation
{
    @synchronized (self) {
        NSArray *analyticsArray = nil;
        @try {
            NSError *error = nil;
            NSData *data = [NSData dataWithContentsOfURL:self.class.localQueueUrl options:0 error:&error];
            if ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSFileReadNoSuchFileError) {
                analyticsArray = [NSArray array];
            } else if (!error && data) {
                analyticsArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            if (![analyticsArray isKindOfClass:[NSArray class]]) {
                @throw [NSException exceptionWithName:NSInvalidArgumentException
                                               reason:@"Saved server queue is invalid." userInfo:nil];
            } 
        } @catch (NSException *exception) {
            YWLog(@"An exception occurred while attempting to load the queue file, "
                  "proceeding without requests. Exception information:\n\n%@.",
                  [self.class exceptionString:exception]
                  );
        }
        
        for (NSData *analyticsData in analyticsArray) {
            NSMutableArray *analyticsList = nil;
            @try {
                analyticsList = [NSKeyedUnarchiver unarchiveObjectWithData:analyticsData];
            } @catch (NSException *exception) {
                continue;
            }
            
            if ([analyticsList isKindOfClass:[NSArray class]]) {
                ZFAnalyticsOperation *operation = [self creatOperation];
                operation.analyticsList = analyticsList;
            }
        }
        [self startOperationQueue];
    }
}

#pragma mark - Property Method

-(NSMutableArray *)operationList
{
    if (!_operationList) {
        _operationList = [[NSMutableArray alloc] init];
    }
    return _operationList;
}

-(NSOperationQueue *)operationQueue
{
    if (!_operationQueue) {
        _operationQueue = [[NSOperationQueue alloc] init];
        _operationQueue.maxConcurrentOperationCount = 1;
    }
    return _operationQueue;
}

#pragma mark - application delegate

- (void)applicationWillResignActive:(UIApplication *)application
{
    if ([self.operationQueue operations]) {
        [self.operationQueue setSuspended:YES];
        [self.operationList addObjectsFromArray:self.operationQueue.operations];
        [self.operationQueue cancelAllOperations];
    }
    [self saveQueueToLocal];
}

#pragma mark - class method

+ (NSURL *)localQueueUrl
{
    NSURL *URL = [self localURL];
    URL = [URL URLByAppendingPathComponent:ZFAnalyticsQueueFile isDirectory:NO];
    return URL;
}

+ (NSURL *)localURL
{
    static dispatch_once_t onceToken;
    static NSURL *url = nil;
    dispatch_once(&onceToken, ^{
        url = [self gainDocumentZFIOUrl];
    });
    return url;
}

+ (NSURL *)gainDocumentZFIOUrl
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray <NSURL *> *URLs = [fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask | NSLocalDomainMask];
    
    for (NSURL *URL in URLs) {
        NSError *error = nil;
        NSURL *branchURL = [[NSURL alloc] initWithString:@"io.ZZZZZ" relativeToURL:URL];
        BOOL success =
        [fileManager
         createDirectoryAtURL:branchURL
         withIntermediateDirectories:YES
         attributes:nil
         error:&error];
        if (success) {
            return branchURL;
        } else  {
            YWLog(@"[io.ZZZZZ] Info: CreateBranchURL failed: %@ URL: %@.", error, branchURL);
        }
    }
    
    //  Worst case backup plan:
    NSString *path = [@"~/Library/io.ZZZZZ" stringByExpandingTildeInPath];
    NSURL *branchURL = [NSURL fileURLWithPath:path isDirectory:YES];
    NSError *error = nil;
    BOOL success =
    [fileManager
     createDirectoryAtURL:branchURL
     withIntermediateDirectories:YES
     attributes:nil
     error:&error];
    if (!success) {
        YWLog(@"[io.ZZZZZ] Error: Worst case CreateBranchURL error was: %@ URL: %@.", error, branchURL);
    }
    return branchURL;
}

+ (NSString *)exceptionString:(NSException *)exception {
    return [NSString stringWithFormat:@"Name: %@\nReason: %@\nStack:\n\t%@\n\n",
            exception.name, exception.reason,
            [exception.callStackSymbols componentsJoinedByString:@"\n\t"]];
}

@end
