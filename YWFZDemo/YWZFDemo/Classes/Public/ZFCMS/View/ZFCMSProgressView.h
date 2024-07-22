//
//  ZFCMSProgressView.h
//  ZZZZZ
//
//  Created by YW on 2019/6/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ZFCMSProgressView : UIView

@property (nonatomic, strong) UIView *progressTrackView;
@property (nonatomic, strong) UIView *progressView;

@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, strong) UIColor *backColor;
@property (nonatomic, assign) CGFloat max;
@property (nonatomic, assign) CGFloat min;

- (void)updateProgressMax:(CGFloat)max min:(CGFloat)min;
@end



@interface ZFCMSLineProgressView : UIView

@property (nonatomic, strong) UIView *progressTrackView;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UILabel *percentageLabel;



@property (nonatomic, strong) UIColor *trackColor;
@property (nonatomic, strong) UIColor *backColor;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) UIFont  *textFont;


@property (nonatomic, assign) CGFloat max;
@property (nonatomic, assign) CGFloat min;
@property (nonatomic, strong) UIColor *pathLineColor;


@property (nonatomic, strong) CAShapeLayer *lineChartLayer;



- (void)updateProgressMax:(CGFloat)max min:(CGFloat)min;
@end
