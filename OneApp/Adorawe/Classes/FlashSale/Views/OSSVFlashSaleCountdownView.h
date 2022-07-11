//
//  OSSVFlashSaleCountdownView.h
// XStarlinkProject
//
//  Created by odd on 2020/11/12.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MZTimerLabel.h"

NS_ASSUME_NONNULL_BEGIN

@interface OSSVFlashSaleCountdownView : UIView

@property (nonatomic, strong) UILabel   *timeLabel;

@property (nonatomic, strong) UIView  *timeBgView; 
@property (nonatomic, strong) UILabel *endLabel;   //endTime
@property (nonatomic, strong) UILabel *hourLabel;  //时
@property (nonatomic, strong) UILabel *minuteLabel; //分
@property (nonatomic, strong) UILabel *secondLabel; //秒
@property (nonatomic, strong) UILabel *pointLabel1; //：
@property (nonatomic, strong) UILabel *pointLabel2; //:
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *pointLabel3; //:
//@property (nonatomic, strong) MZTimerLabel *countdownL;
- (void)updateTimeWithDay:(NSInteger)day hour:(NSInteger)hour minute:(NSInteger)minute second:(NSInteger)second endString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
