//
//  OSSVCycleMSGView.m
//  OSSVCycleMSGView
//
//  Created by odd on 2020/10/20.
//

#import "OSSVCycleMSGView.h"

static NSInteger kCycleTipFirstTag = 20201020;
static NSInteger kCycleTipSecondTag = 20201021;


@interface OSSVCycleMSGView() {
    
    CABasicAnimation *animation;
    CABasicAnimation *animationhead;
}

@end

@implementation OSSVCycleMSGView

- (void)dealloc {
    STLLog(@"------ STLCycleTipView");
}

+ (CGSize)contentCalculate:(NSString *)content {
    if (!content) {
        return CGSizeZero;
    }
    NSDictionary *attr = @{NSFontAttributeName : [UIFont systemFontOfSize:12]};
    CGSize itemSize = [content boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attr context:nil].size;
    return itemSize;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.currentIndex = 0;
        // 创建
        UILabel *firstLabel = [self viewWithTag:kCycleTipFirstTag];
        if (!firstLabel) {
            firstLabel = [self createTopMovieMessageView];
            firstLabel.tag = kCycleTipFirstTag;
            [self addSubview:firstLabel];
            
//            [firstLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.leading.mas_equalTo(self.mas_leading);
//                make.trailing.mas_equalTo(self.mas_trailing);
//                make.top.mas_equalTo(self.mas_top);
//                make.bottom.mas_equalTo(self.mas_bottom);
//            }];
            firstLabel.frame = CGRectMake(0, 0, SCREEN_WIDTH, 32);
            self.tempMoveLabel = firstLabel;
        }

        
        UILabel *secondLabel = [self viewWithTag:kCycleTipSecondTag];
        if (!secondLabel) {
            secondLabel = [self createTopMovieMessageView];
            secondLabel.tag = kCycleTipSecondTag;
            [self addSubview:secondLabel];
            secondLabel.frame = CGRectMake(0, 32, SCREEN_WIDTH, 32);
//            [secondLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//                make.leading.mas_equalTo(self.mas_leading);
//                make.trailing.mas_equalTo(self.mas_trailing);
//                make.top.mas_equalTo(self.mas_top).mas_offset(60);
//                make.bottom.mas_equalTo(self.mas_bottom);
//            }];
        }
        
    }
    return self;
}

- (void)cancelMessageTimer {
    if (self.messageTimer) {
        dispatch_source_cancel(self.messageTimer);
    }
}

- (void)startMoveMessageAnimate {
    
    if (!self.superview) {
        [self cancelMessageTimer];
        return;
    }
    
    self.currentIndex = 0;
    self.currentAdvModel = nil;
    [self cancelMessageTimer];
    NSArray *msgs = self.datasArray;
    if (msgs.count == 1) {
        UILabel *firstLabel = [self viewWithTag:kCycleTipFirstTag];
        OSSVAdvsEventsModel *advModel = self.datasArray.firstObject;
        firstLabel.text = [NSString stringWithFormat:@"  %@",STLToString(advModel.marqueeText)];
        firstLabel.textColor =  [UIColor colorWithHexString:STLToString(advModel.marqueeColor)];
        firstLabel.backgroundColor =  [UIColor colorWithHexString:STLToString(advModel.marqueeBgColor)];
        self.backgroundColor = [UIColor colorWithHexString:advModel.marqueeBgColor];

        CGRect firstFram = firstLabel.frame;

        if (advModel.paoMaDengWidt > SCREEN_WIDTH) {
            firstFram.size.width = advModel.paoMaDengWidt;

        } else {
            firstFram.size.width = SCREEN_WIDTH;
        }
        firstLabel.frame = firstFram;
        [self sssss:firstLabel advModel:advModel];
    }
    
    if (msgs.count > 1) {
        UILabel *firstLabel = [self viewWithTag:kCycleTipFirstTag];
        OSSVAdvsEventsModel *advModel = self.datasArray.firstObject;
        firstLabel.text = [NSString stringWithFormat:@"  %@",STLToString(advModel.marqueeText)];
        firstLabel.textColor =  [UIColor colorWithHexString:STLToString(advModel.marqueeColor)];
        firstLabel.backgroundColor =  [UIColor colorWithHexString:STLToString(advModel.marqueeBgColor)];
        self.backgroundColor = [UIColor colorWithHexString:advModel.marqueeBgColor];

        CGRect firstFram = firstLabel.frame;

        if (advModel.paoMaDengWidt > SCREEN_WIDTH) {
            firstFram.size.width = advModel.paoMaDengWidt;

        } else {
            firstFram.size.width = SCREEN_WIDTH;
        }
        firstLabel.frame = firstFram;
        [self sssss:firstLabel advModel:advModel];


        UILabel *secondLabel = [self viewWithTag:kCycleTipSecondTag];
        OSSVAdvsEventsModel *secAdvModel = self.datasArray[1];
        secondLabel.text = [NSString stringWithFormat:@"  %@",STLToString(secAdvModel.marqueeText)];
        secondLabel.textColor =  [UIColor colorWithHexString:STLToString(secAdvModel.marqueeColor)];
        secondLabel.backgroundColor =  [UIColor colorWithHexString:STLToString(secAdvModel.marqueeBgColor)];
        
        CGRect secondFram = secondLabel.frame;

        if (secAdvModel.paoMaDengWidt > SCREEN_WIDTH) {
            secondFram.size.width = secAdvModel.paoMaDengWidt;

        } else {
            secondFram.size.width = SCREEN_WIDTH;
        }
        secondLabel.frame = secondFram;
        
        self.currentIndex++;
        [self startMessageTimer];
    }
}

- (void)moveAnimateView:(UIButton *)msgButton content:(NSString *)messageInfo{
    if (self.datasArray.count <= 0) {
        return;
    }
    UILabel *firstLabel = [self viewWithTag:kCycleTipFirstTag];
    UILabel *secondLabel = [self viewWithTag:kCycleTipSecondTag];
    

    if (firstLabel && secondLabel) {
        
        [UIView animateWithDuration:0.4 animations:^{
            
            CGRect temFram = self.tempMoveLabel.frame;
            temFram.origin.y -= 32;
            self.tempMoveLabel.frame = temFram;
            
            if (self.tempMoveLabel == firstLabel) {
                
                CGRect lastTemFram = secondLabel.frame;
                lastTemFram.origin.y -= 32;
                secondLabel.frame = lastTemFram;
                
            } else if(self.tempMoveLabel == secondLabel) {
                CGRect lastTemFram = firstLabel.frame;
                lastTemFram.origin.y -= 32;
                firstLabel.frame = lastTemFram;
            }
            
            [self layoutIfNeeded];
        } completion:^(BOOL finished) {
            
            OSSVAdvsEventsModel *showNowAdvModeltt = self.datasArray[self.currentIndex];
            self.currentIndex++;
            self.currentIndex = self.currentIndex % self.datasArray.count;
            
            OSSVAdvsEventsModel *advModeltt = self.datasArray[self.currentIndex];

            CGRect temFram = self.tempMoveLabel.frame;
            temFram.origin.y = 32;
            
            if (advModeltt.paoMaDengWidt > SCREEN_WIDTH) {
                temFram.size.width = advModeltt.paoMaDengWidt;
            } else {
                temFram.size.width = SCREEN_WIDTH;
            }
            self.tempMoveLabel.frame = temFram;

            
            if (self.datasArray.count > self.currentIndex) {
//                OSSVAdvsEventsModel *advModel = self.datasArray[self.currentIndex+1];
                self.tempMoveLabel.text = STLToString(advModeltt.marqueeText);
                self.tempMoveLabel.textColor = [UIColor colorWithHexString:STLToString(advModeltt.marqueeColor)];
                self.tempMoveLabel.backgroundColor = [UIColor colorWithHexString:advModeltt.marqueeBgColor];

            }
            if (self.tempMoveLabel == firstLabel) {
                self.tempMoveLabel = secondLabel;
                [firstLabel sendSubviewToBack:self.tempMoveLabel];
            } else if(self.tempMoveLabel == secondLabel) {
                self.tempMoveLabel = firstLabel;
                [secondLabel sendSubviewToBack:self.tempMoveLabel];

            }
            
            [self sssss:self.tempMoveLabel advModel:showNowAdvModeltt];

            self.backgroundColor = [UIColor colorWithHexString:showNowAdvModeltt.marqueeBgColor];
            [self startMessageTimer];
            [self layoutIfNeeded];

        }];
    }
}

-(void)sssss:(UILabel *)moveLabl advModel:(OSSVAdvsEventsModel *)model{
 
    if (self.delegate && [self.delegate respondsToSelector:@selector(stl_CycleTipView:currentAdv:)]) {
        [self.delegate stl_CycleTipView:self currentAdv:model];
    }
    self.currentAdvModel = model;
    if (model.paoMaDengWidt > SCREEN_WIDTH) {
        
        CGFloat moveX = model.paoMaDengWidt - SCREEN_WIDTH;
        
        animation = [CABasicAnimation animationWithKeyPath:@"position"];
        // 动画选项的设定
        animation.duration = 2.9; // 持续时间
        animation.repeatCount = 1; // 重复次数
        animation.removedOnCompletion = NO;
        animation.autoreverses = NO;
        // 起始帧和终了帧的设定
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(moveLabl.layer.position.x -moveX, moveLabl.layer.position.y)]; // 起始帧

        } else {
            animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(moveLabl.layer.position.x, moveLabl.layer.position.y)]; // 起始帧

        }
        
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(moveLabl.layer.position.x, moveLabl.layer.position.y)]; // 终了帧

        } else {
            animation.toValue = [NSValue valueWithCGPoint:CGPointMake(moveLabl.layer.position.x - moveX, moveLabl.layer.position.y)]; // 终了帧

        }
        // 添加动画
        [moveLabl.layer addAnimation:animation forKey:@"AnimationMoveY"];
        //  [headImage.layer addAnimation:animation forKey:@"AnimationMoveY"];
    }
 
}

#pragma mark - 消息横向滚动

- (void)startMessageTimer {
    [self cancelMessageTimer];
    
    // 队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    // 创建 dispatch_source
    dispatch_source_t timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    // 声明成员变量
    self.messageTimer = timer;
    // 设置两秒后触发
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 3.0 * NSEC_PER_SEC);
    // 设置下次触发事件为 DISPATCH_TIME_FOREVER
    dispatch_time_t nextTime = DISPATCH_TIME_FOREVER;
    // 设置精确度
    dispatch_time_t leeway = 0.1 * NSEC_PER_SEC;
    // 配置时间
    dispatch_source_set_timer(timer, startTime, nextTime, leeway);
    // 回调
    dispatch_source_set_event_handler(timer, ^{
        
        [self moveAnimateView:nil content:@""];

    });
    // 激活
    dispatch_resume(self.messageTimer);
    
}

- (void)actionText:(UIButton *)sender {
    if (self.datasArray.count > self.currentIndex && self.currentAdvModel) {
        OSSVAdvsEventsModel *advModel = self.currentAdvModel;
        if (self.delegate && [self.delegate respondsToSelector:@selector(stl_CycleTipView:advEvent:)]) {
            [self.delegate stl_CycleTipView:self advEvent:advModel];
        }
    }
}

- (UILabel *)createTopMovieMessageView {
    UIButton *messageButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
    [messageButton addTarget:self action:@selector(actionText:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *msgLable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 32)];
    msgLable.textAlignment = NSTextAlignmentCenter;
    msgLable.font = [UIFont systemFontOfSize:12];
    [msgLable addSubview:messageButton];
    msgLable.userInteractionEnabled = YES;
    msgLable.backgroundColor = [OSSVThemesColors stlWhiteColor];
    
    
    return msgLable;
}

@end
