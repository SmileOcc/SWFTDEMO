//
//  OSSVCycleMSGView.h
//  OSSVCycleMSGView
//
//  Created by odd on 2020/10/20.
//

#import <UIKit/UIKit.h>

@class OSSVCycleMSGView;

@protocol STLCycleTipViewDelegate <NSObject>

- (void)stl_CycleTipView:(OSSVCycleMSGView *)cycleTipView advEvent:(OSSVAdvsEventsModel *)advModel;

- (void)stl_CycleTipView:(OSSVCycleMSGView *)cycleTipView currentAdv:(OSSVAdvsEventsModel *)advModel;

@end

@interface OSSVCycleMSGView : UIView

@property (nonatomic, strong) UILabel *tempMoveLabel;
@property (strong, nonatomic) dispatch_source_t messageTimer;
@property (nonatomic, strong) NSArray<OSSVAdvsEventsModel *>  *datasArray;
@property (nonatomic, assign) NSInteger         timeCount;
@property (nonatomic, assign) NSInteger         currentIndex;

@property (nonatomic, strong) OSSVAdvsEventsModel  *currentAdvModel;

@property (nonatomic, weak) id<STLCycleTipViewDelegate> delegate;


- (void)startMoveMessageAnimate;

- (void)cancelMessageTimer;

+ (CGSize)contentCalculate:(NSString *)content;

@end

