//
//  ZFExposureManager.m
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "GGExposureManager.h"
#import "UIView+GGViewTracker.h"
#import "UIView+GGViewExposure.h"
#import "UIVIew+GGPageName.h"

#import "GGViewTrackerManager.h"

#pragma mark - GGUTExposureItem

@interface GGUTExposureItem : NSObject
@property (nonatomic, strong) NSString * pageName;    // 页面名称
@property (nonatomic, strong) NSString * uniqueControlName; // Control Name use to mark the unique view.
// some special items need suffix.
@property (nonatomic, strong) NSString * controlName; // Control Name.
@property (nonatomic, strong) NSDictionary * args;    // 自定义参数

@property (nonatomic, assign) NSUInteger times;             // 曝光次数
@property (nonatomic, assign) NSUInteger totalExposureTime; // 总曝光时长，ms

@property (nonatomic, assign) NSUInteger indexInApp;        // 曝光时间，app维度
@property (nonatomic, assign) NSUInteger indexInPage;       // 曝光时间，页面维度
@end

@implementation GGUTExposureItem
@end

#pragma mark - GGUTExposingItem

@interface GGUTExposingItem : NSObject
@property (nonatomic, strong) NSString * exposingControlName; // 当前曝光controlName

@property (nonatomic, assign) BOOL visible;           // current control visibility.
@property (nonatomic ,strong) NSDate *beginTime;     // 当前曝光controlName开始时间
@end

@implementation GGUTExposingItem
@end

#pragma mark - GGExposureManager

//<pageName, <controlName, model>>
typedef NSMutableDictionary<NSString*, NSMutableDictionary<NSString*, GGUTExposureItem*>*> GGUTExposureInfos;

//<controlName, model>
typedef NSMutableDictionary<NSString*, GGUTExposingItem*> GGUTExposingInfos;

@interface GGExposureManager ()
{
    dispatch_queue_t _exposureSerialQueue;
}

// store all data.
@property (nonatomic, strong) GGUTExposureInfos *datas;
// store exposuring data.
@property (nonatomic, strong) GGUTExposingInfos *exposingDatas;
@end

@implementation GGExposureManager


+ (instancetype)shareInstance
{
    static GGExposureManager * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[GGExposureManager alloc] init];
    });
    
    return instance;
}

+ (BOOL)isTargetViewForExposure:(UIView*)view
{
    if ([view respondsToSelector:@selector(controlName)] && view.controlName)
    {
        if ([view respondsToSelector:@selector(commitType)]) {
            return (view.commitType == ECommitTypeBoth || view.commitType == ECommitTypeExposure);
        }
        return YES;
    }
    return NO;
}
#pragma mark - public class method

/**
 * joinMode occasion :
 1. page switch
 2. app switch
 3. sdk switch update.
 4. user invoke.
 */
/**
 * commit joinMode data.
 */
+ (void)commitPolymerInfoForAllPage
{
    dispatch_async([[GGExposureManager shareInstance] getSerialQueue], ^{
        if ([GGExposureManager isPolymerModeOn]) {
            NSArray *items = [[GGExposureManager shareInstance] _itemsForAllPage];
            
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[GGUTExposureItem class]]) {
                    [self _commitItem:obj];
                }
            }];
        }
    });
}


/**
 * commit joinMode data of page.
 
 @param page Page Name
 */
+ (void)commitPolymerInfoForPage:(NSString*)page
{
    dispatch_async([[GGExposureManager shareInstance] getSerialQueue], ^{
        if ([GGExposureManager isPolymerModeOn]) {
            NSArray *items = [[GGExposureManager shareInstance] _itemsForPage:page];
            
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj isKindOfClass:[GGUTExposureItem class]]) {
                    [self _commitItem:obj];
                }
            }];
        }
    });
}

+ (void)adjustStateForView:(UIView *)view forType:(GGViewTrackerAdjustType)type
{
    /**
     * only handle view changed in main thread,
     * if view changed not in main thread, maybe webview.
     */
    if (![NSThread isMainThread]) {
        return;
    }
    
    if (type == GGViewTrackerAdjustTypeForceExposure){
        [self findDestViewInSubviewsAndAdjustState:view recursive:YES];
        return;
    }
    
    if ([[GGViewTrackerManager sharedManager] exposureNeedUpload:view]) {
        [self findDestViewInSubviewsAndAdjustState:view
                                         recursive:type!=GGViewTrackerAdjustTypeUIViewDidMoveToWindow];
    }
}

+ (void)setState:(NSUInteger)state forView:(UIView*)view
{
    if (state == view.showing) return;
    
    // if view has controlName, recode to map.
    if ([GGExposureManager isTargetViewForExposure:view]) {
        // start visible,exposure begin.
        if (view.showing != GGViewVisibleTypeVisible && state == GGViewVisibleTypeVisible) {
            // get pageName after exposure end.
            [self view:view becomeVisible:view.controlName inPage:nil];
        }
        // exposure end.
        else if(view.showing == GGViewVisibleTypeVisible && state == GGViewVisibleTypeInvisible){
            [self view:view becomeInVisible:view.controlName inPage:[view pageName]];
        }
        
        view.showing = state;
    }
}

#pragma mark - class method of tools
+ (void)_commitItem:(GGUTExposureItem *)item
{
    id protocol = [GGViewTrackerManager sharedManager].commitProtocol;
    if (protocol && [protocol respondsToSelector:@selector(module:showedOnPage:duration:args:)]) {
        NSMutableDictionary *args = [NSMutableDictionary dictionary];
        // add view's args.
        if (item.args) {
            [args addEntriesFromDictionary:item.args];
        }
        
        // add exposure args.
        if ([GGExposureManager isPolymerModeOn] && item.times) {
            [args setObject:@(item.times) forKey:@"exposureTimes"];
        }
        
        [args setObject:@(item.indexInApp) forKey:@"exposureIndex"];
        
        if ([[GGViewTrackerManager sharedManager] isPageNameInExposureWhiteList:item.pageName]) {
            [protocol module:item.controlName
                showedOnPage:item.pageName
                    duration:item.totalExposureTime
                        args:[NSDictionary dictionaryWithDictionary:args]];
        }
        
        [[GGExposureManager shareInstance] _clearItem:item];
    }
}

+ (void)findDestViewInSubviewsAndAdjustState:(UIView*)view recursive:(BOOL)recursive
{
    if ([GGExposureManager isTargetViewForExposure:view]){
        
        BOOL visible = [self isViewVisible:view];
        GGViewVisibleType state = visible ? GGViewVisibleTypeVisible : GGViewVisibleTypeInvisible;
        
        [self setState:state forView:view];
    }
    
    if (recursive) {
        for (UIView * subview in view.subviews) {
            [GGExposureManager findDestViewInSubviewsAndAdjustState:subview recursive:recursive];
        }
    }
}

+(BOOL)isViewVisible:(UIView*)view
{
    if (!view.window || view.hidden || view.layer.hidden || !view.alpha) {
        return NO;
    }
    
    UIView * current = view;
    while ([current isKindOfClass:[UIView class]]) {
        if (current.alpha <= 0 || current.hidden == YES) {
            return NO;
        }
        current = current.superview;
    }
    
    CGRect viewRectInWindow = [view convertRect:view.bounds toView:view.window];
    BOOL isIntersects = CGRectIntersectsRect(view.window.bounds, viewRectInWindow);
    
    if (isIntersects) {
        
        if (![GGExposureManager isTargetViewForExposure:view]) {
            return YES;
        }
        
        CGRect intersectRect = CGRectIntersection(view.window.bounds, viewRectInWindow);
        if (intersectRect.size.width != 0.f && intersectRect.size.height != 0.f) {
            // modify size threshold,80%
            CGFloat dimThreshold = [GGViewTrackerManager sharedManager].exposureDimThreshold;
            if (intersectRect.size.width / viewRectInWindow.size.width > dimThreshold &&
                intersectRect.size.height / viewRectInWindow.size.height > dimThreshold) {
                return YES;
            }
        }
    }
    return NO;
}

+ (NSString*)uniqueExposingControlName:(NSString*)controlName suffix:(NSString*)suffix
{
    return [NSString stringWithFormat:@"%@-%@", controlName, suffix];
}

+ (NSString*)uniqueControlName:(NSString*)controlName inPage:(NSString*)pageName withArgs:(NSDictionary*)args
{
    id list = [GGViewTrackerManager sharedManager].config.exposureModifyTagList;
    if ([list isKindOfClass:[NSArray class]]) {
        for (id item in list) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                NSString *destPageName = [item objectForKey:@"pageName"];
                if ([destPageName isKindOfClass:[NSString class]]) {
                    
                    NSString *destId = [item objectForKey:@"argsId"];
                    if ([destId isKindOfClass:[NSString class]])
                    {
                        if ([args isKindOfClass:[NSDictionary class]]) {
                            NSString *suffix = [args objectForKey:destId];
                            
                            if (suffix) {
                                return [NSString stringWithFormat:@"%@_%@", controlName, suffix];
                            }
                        }
                    }
                }
            }
        }
    }
    
    return controlName;
}

+ (void)view:(UIView*)view becomeVisible:(NSString*)controlName inPage:(NSString*)pageName
{
    if (!view || !controlName.length){
        return;
    }
    
    __block NSDate* currentDate = [NSDate date];
    __block NSString *suffix = [NSString stringWithFormat:@"%p", view];
    
    dispatch_async([[GGExposureManager shareInstance] getSerialQueue], ^{
        NSString * exposingControlName = [GGExposureManager uniqueExposingControlName:controlName suffix:suffix];
        
        GGUTExposingItem *item = [[GGExposureManager shareInstance] _exposingItemForControlName:exposingControlName];
        if (!item) {
            item = [GGUTExposingItem new];
            item.exposingControlName = exposingControlName;
            [[GGExposureManager shareInstance] _addExposingItem:item];
        }
        item.visible = YES;
        item.beginTime = currentDate;
    });
}

+ (void)view:(UIView*)view becomeInVisible:(NSString*)controlName inPage:(NSString*)pageName
{
    if (!view || !controlName.length ) {//|| !pageName.length
        return;
    }
    
    __block NSDate* currentDate = [NSDate date];
    __block NSDictionary* args = [view.args copy];
    __block NSString *suffix = [NSString stringWithFormat:@"%p", view];
    
    dispatch_async([[GGExposureManager shareInstance] getSerialQueue], ^{
        NSString * exposingControlName = [GGExposureManager uniqueExposingControlName:controlName suffix:suffix];
        
        GGUTExposingItem *exposingItem = [[GGExposureManager shareInstance] _exposingItemForControlName:exposingControlName];
        if (exposingItem && exposingItem.beginTime && exposingItem.visible) {
            
            NSUInteger constMS = ([currentDate timeIntervalSince1970] - [exposingItem.beginTime timeIntervalSince1970]) * 1000;
            
            // remove item when exposuring.
            [[GGExposureManager shareInstance] _removeExposingItemByControlName:exposingControlName];
            
            if (pageName.length) {
                NSString *uniqueControlName = [GGExposureManager uniqueControlName:controlName inPage:pageName withArgs:args];
                
                // search joinMode data.
                GGUTExposureItem* item = [[GGExposureManager shareInstance] _itemForUniqueControlName:uniqueControlName inPage:pageName];
                
                // add item to joinMode data.
                if (!item) {
                    item = [GGUTExposureItem new];
                    item.pageName = pageName;
                    item.uniqueControlName = uniqueControlName;
                    item.controlName = controlName;
                    //                    item.args = args;
                    item.times = 0;
                    item.totalExposureTime = 0;
                    item.indexInApp = 0;
                    item.indexInPage = 0;
                    
                    [[GGExposureManager shareInstance] _addItem:item];
                }
                
                //rewrite args when new exposure occours
                item.args = args;
                
                // judge threshold and sampling rate
                if (constMS >= [GGViewTrackerManager sharedManager].exposureTimeThreshold // threshold
                    && [[GGViewTrackerManager sharedManager] isExposureHitSampling])// sampling rate
                {
                    item.indexInApp++;
                    item.indexInPage++;
                    
                    // commit upload right now.
                    if ([GGExposureManager isPolymerModeOn]) {
                        // modify item.
                        item.totalExposureTime += constMS;
                        item.times++;
                    }else
                    {
                        item.times++;
                        item.totalExposureTime = constMS;
                        
                        if ([GGExposureManager shouldUpload:item]) {// report once in page
                            [GGExposureManager _commitItem:item];
                        }
                    }
                }
            }
        }
    });
}

+ (void)resetPageIndexForPage:(NSString*)pageName
{
    dispatch_async([[GGExposureManager shareInstance] getSerialQueue], ^{
        GGExposureManager *mgr = [GGExposureManager shareInstance];
        NSArray * items = [mgr _itemsForPage:pageName];
        
        if ([items count]) {
            [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GGUTExposureItem* item = (GGUTExposureItem*)obj;
                item.indexInPage = 0;
            }];
        }
    });
}

#pragma mark - instance method
- (instancetype)init
{
    if (self =[super init]) {
        _exposureSerialQueue = dispatch_queue_create("exposure_handler_queue", DISPATCH_QUEUE_SERIAL);
        
        _datas = [NSMutableDictionary dictionary];
        _exposingDatas = [NSMutableDictionary dictionary];
        
        // register backgroud notification,to commit joinMode data.
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TMVEM_handlerNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(TMVEM_handlerNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
    }
    return self;
}

- (void)TMVEM_handlerNotification:(NSNotification*)notify
{
    if ([notify.name isEqualToString:UIApplicationDidEnterBackgroundNotification]) {
        if ([GGExposureManager isPolymerModeOn]) {
            [GGExposureManager commitPolymerInfoForAllPage];
        }
    }else if ([notify.name isEqualToString:UIApplicationWillEnterForegroundNotification])
    {
        //reset Page Index
        [GGExposureManager resetPageIndexForPage:[GGViewTrackerManager currentPageName]];
    }
}

+ (BOOL)isPolymerModeOn
{
    if ([GGViewTrackerManager sharedManager].isDebugModeOn) {
        return NO;
    }
    return [GGViewTrackerManager sharedManager].config.exposureUploadMode == GGExposureDataUploadModePolymer;
}

+ (BOOL) shouldUpload:(GGUTExposureItem*)item
{
    if ([GGViewTrackerManager sharedManager].config.exposureUploadMode == GGExposureDataUploadModeNormal) {
        return YES;
    }
    
    if ([GGViewTrackerManager sharedManager].config.exposureUploadMode == GGExposureDataUploadModeSingleInPage && item.indexInPage == 1) {
        return YES;
    }
    
    return NO;
}

- (dispatch_queue_t)getSerialQueue
{
    return _exposureSerialQueue;
}

#pragma mark - 以下函数，操作本地内存缓存，被commitPolymerInfoXXX和view:becomeXXX系列函数调用，异步串行队列。
#pragma mark - get & set item in exposingDatas
- (GGUTExposingItem*)_exposingItemForControlName:(NSString*)exposingControlName
{
    if (exposingControlName.length) {
        return [self.exposingDatas objectForKey:exposingControlName];
    }
    
    return nil;
}

- (void)_addExposingItem:(GGUTExposingItem*)item
{
    if (item && item.exposingControlName.length) {
        [self.exposingDatas setObject:item forKey:item.exposingControlName];
    }
}

- (void)_removeExposingItemByControlName:(NSString*)exposingControlName
{
    if (exposingControlName.length){
        [self.exposingDatas removeObjectForKey:exposingControlName];
    }
}

- (void)_clearExposingItem:(GGUTExposingItem*)item
{
    if (item && item.exposingControlName.length) {
        item.visible = NO;
        item.beginTime = nil;
    }
}
#pragma mark - get & set item in datas
- (NSArray<GGUTExposureItem*>*)_itemsForAllPage
{
    NSMutableArray *array = [NSMutableArray array];
    
    for (NSDictionary * pageItem in self.datas.allValues) {
        NSArray *allValues = pageItem.allValues;
        [array addObjectsFromArray:allValues];
    }
    
    return array;
}

- (NSArray<GGUTExposureItem*>*)_itemsForPage:(NSString*)pageName
{
    if (pageName.length) {
        NSDictionary * pageItem = [self.datas objectForKey:pageName];
        if (pageItem) {
            return [pageItem allValues];
        }
    }
    
    return nil;
}

- (GGUTExposureItem*)_itemForUniqueControlName:(NSString*)uniqueControlName inPage:(NSString*)pageName
{
    if (uniqueControlName.length && pageName.length) {
        NSDictionary * pageItem = [self.datas objectForKey:pageName];
        if (pageItem) {
            return [pageItem objectForKey:uniqueControlName];
        }
    }
    
    return nil;
}

- (void)_addItem:(GGUTExposureItem*)item
{
    if (item && item.pageName.length && item.uniqueControlName.length) {
        NSMutableDictionary * pageItem = [self.datas objectForKey:item.pageName];
        if (!pageItem) {
            pageItem = [NSMutableDictionary dictionary];
            [self.datas setObject:pageItem forKey:item.pageName];
        }
        
        [pageItem setObject:item forKey:item.uniqueControlName];
    }
}

//generally, dont need to remove any item, cause we need to record times in app.
- (void)_removeItem:(GGUTExposureItem*)item
{
    if (item && item.uniqueControlName.length && item.pageName.length) {
        NSMutableDictionary * pageItem = [self.datas objectForKey:item.pageName];
        if (pageItem) {
            [pageItem removeObjectForKey:item.uniqueControlName];
        }
    }
}

// clear item's status,after joinMode commit.
- (void)_clearItem:(GGUTExposureItem*)item
{
    if (item) {
        item.times = 0;
        item.totalExposureTime = 0;
    }
}
@end
