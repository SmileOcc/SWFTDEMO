//
//  OSSVFeedBaksViewModel.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/2.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVFeedBaksViewModel.h"
#import "OSSVFeedBacksAip.h"
#import "OSSVFeedsBacksReason.h"

NSString *const FeedBackKeyOfType = @"type";
NSString *const FeedBackKeyOfEmail = @"email";
NSString *const FeedBackKeyOfContent = @"content";
NSString *const FeedBackKeyOfimages = @"images";

@interface OSSVFeedBaksViewModel ()

@property (nonatomic, strong) NSMutableArray *pickerArray;
@end

@implementation OSSVFeedBaksViewModel

#pragma mark - Requset
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj))completion failure:(void (^)(id obj))failure {

    @weakify(self);
    [[STLNetworkStateManager sharedManager] networkState:^{
        @strongify(self)
        @weakify(self)
        NSDictionary *dict = (NSDictionary *)parmaters;
        OSSVFeedBacksAip *feedBacksAip = [[OSSVFeedBacksAip alloc] initWithFeedBackType:dict[FeedBackKeyOfType] email:dict[FeedBackKeyOfEmail] content:dict[FeedBackKeyOfContent] images:dict[FeedBackKeyOfimages]];
        
        [feedBacksAip.accessoryArray addObject:[[STLRequestAccessory alloc] initWithApperOnView:self.controller.view]];
        [feedBacksAip  startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            
            @strongify(self);
            
            id requestJSON = [OSSVNSStringTool desEncrypt:request];
            
            if ([self dataAnalysisFromJson: requestJSON request:feedBacksAip]) {
                if (completion) {
                    completion(@YES);
                }
            }
            else {
                if (completion) {
                    completion(nil);
                }
            }
        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
            if (failure) {
                failure(nil);
            }
        }];
    } exception:^{
        if (failure) {
            failure(nil);
        }
    }];
}

#pragma mark ---   请求反馈原因
- (void)requestFeedBackReason {
    @weakify(self)
    [[STLNetworkStateManager sharedManager] networkState:^{
        OSSVFeedsBacksReason *api = [[OSSVFeedsBacksReason alloc] init];
        [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
            @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
            
            if ([requestJSON isKindOfClass:[NSDictionary class]]) {
                if ([requestJSON[kStatusCode] integerValue] == kStatusCode_200) {
                    
                    NSArray *resultArray = requestJSON[kResult];
                    if ([resultArray isKindOfClass:[NSArray class]] && resultArray.count > 0) {
                        [self.pickerArray removeAllObjects];
                        [self.pickerArray addObjectsFromArray:resultArray];
                    }
                }
            }

        } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        
        }];
        
    } exception:^{
        
    }];
}
- (id)dataAnalysisFromJson:(id)json request:(OSSVBasesRequests *)request {
    
//    STLLog(@"json == %@",json);
    if ([request isKindOfClass:[OSSVFeedBacksAip class]]) {
        if ([json[kStatusCode] integerValue] == kStatusCode_200) {
            [self alertMessage:json[@"message"]];
            return @YES;
        }
        else {
            [self alertMessage:json[@"message"]];
        }
    }
    return nil;
}

#pragma mark 选中PickView
//此处是为了第一响应的情况下
- (void)pickerViewDidSelected:(UIPickerView *)pickerView {
    NSInteger index  = [pickerView selectedRowInComponent:0];
    if (self.pickerArray.count) {
        NSString *selectString = self.pickerArray[index][@"typeName"];
        NSInteger selectType = [self.pickerArray[index][@"type"] intValue];
        if (self.showPickerBlock) {
            self.showPickerBlock(selectString,selectType);
        }
    }
}

#pragma mark - UIPickerViewDataSource
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

-(NSInteger) pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return [self.pickerArray count];
}

-(NSString*) pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component{
    if (self.pickerArray.count) {
        return [self.pickerArray objectAtIndex:row][@"typeName"];
    } else {
        return @"";
    }
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    [self pickerViewDidSelected:pickerView];
}

#pragma mark - LazyLoad
- (NSMutableArray *)pickerArray {
    if (!_pickerArray) {
        //取消了本地文案，改为返回的文案
//        _pickerArray = @[STLLocalizedString_(@"bugOrTechnicalIssue", nil),
//                         STLLocalizedString_(@"suggestion", nil),
//                         STLLocalizedString_(@"positiveFeedback", nil),
//                         STLLocalizedString_(@"otherIssue", nil)].mutableCopy;
        
        _pickerArray = [NSMutableArray array];
    }
    return _pickerArray;
}



@end
