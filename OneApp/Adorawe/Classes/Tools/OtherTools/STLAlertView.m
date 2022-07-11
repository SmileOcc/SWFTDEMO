//
//  STLAlertView.m
//  Staradora
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 Staradora. All rights reserved.
//

#import "STLAlertView.h"

@interface STLAlertView ()

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSString *confirm;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIButton *confirmBtn;
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UIView *backgroundview;
@property (nonatomic, assign) BOOL isTextAlignmentCenter;

@end

@implementation STLAlertView

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content OkButton:(NSString *)okButton andAlertTag:(NSString *)alertTag isTextAlignmentCenter:(BOOL)isTextAlignmentCenter {
    if (self = [super initWithFrame:[[UIApplication sharedApplication] keyWindow].frame]) {
        self.title = title;
        self.content = content;
        self.confirm = okButton;
        self.isTextAlignmentCenter = isTextAlignmentCenter;
        [self setUp];
    }
    return self;
}

-(void)setUp{
    
    self.backgroundview = [[UIView alloc] initWithFrame:[[UIApplication sharedApplication] keyWindow].frame];
    self.backgroundview.backgroundColor = [UIColor blackColor];
    self.backgroundview.alpha = 0.5;
    [self addSubview:self.backgroundview];

    self.alertView = [[UIView alloc] initWithFrame:CGRectMake(20, 200, SCREEN_WIDTH - 40, 300 *DSCREEN_WIDTH_SCALE)];
    self.alertView.backgroundColor = [UIColor whiteColor];
    self.alertView.layer.cornerRadius = 10;
    self.alertView.clipsToBounds = YES;
    [self addSubview:self.alertView];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.alertView.bounds.size.width, self.alertView.bounds.size.height - 50)];
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self.alertView addSubview:self.scrollView];
    
    self.contentLabel = [UILabel new];
    if (self.isTextAlignmentCenter) {
        self.contentLabel.textAlignment = NSTextAlignmentCenter;
    }
    self.contentLabel.text = [NSString stringWithFormat:@"%@",self.content];
    self.contentLabel.numberOfLines = 0;
//    self.contentLabel.lineBreakMode = NSLineBreakByCharWrapping;
    self.contentLabel.font = [UIFont systemFontOfSize:14];
    self.contentLabel.textColor = STLCOLOR_102_102_102;
    [self.scrollView addSubview:self.contentLabel];
    

    CGRect labelRect = [self.contentLabel.text boundingRectWithSize:CGSizeMake(self.scrollView.bounds.size.width - 20,10000) options:(NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.f]} context:nil];
    if(labelRect.size.height < 300){
        self.alertView.frame = CGRectMake(20, 200, SCREEN_WIDTH - 40, labelRect.size.height + 70);
        self.scrollView.frame = CGRectMake(0, 0, self.alertView.bounds.size.width, self.alertView.bounds.size.height - 50);
    }
    self.contentLabel.frame = CGRectMake(10, 10, self.scrollView.bounds.size.width - 20, labelRect.size.height + 10);
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH - 40, labelRect.size.height + 20);
   
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.confirmBtn.frame = CGRectMake(0, self.alertView.bounds.size.height - 50, self.alertView.bounds.size.width, 50);
    self.confirmBtn.backgroundColor = [UIColor clearColor];
    [self.confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.confirmBtn setTitle:self.confirm forState:UIControlStateNormal];
    [self.confirmBtn addTarget:self action:@selector(confirmBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.alertView addSubview:self.confirmBtn];
    
    self.lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.scrollView.bounds.size.width, 0.5)];
    self.lineView.backgroundColor = [UIColor grayColor];
    self.lineView.alpha = 0.2;
    [self.confirmBtn addSubview:self.lineView];
}

#pragma mark - 显示AlertView
- (void)show {
    UIView * keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:self];
    self.alpha = 1.0;
    self.alertView.center = self.center;
}

#pragma mark - 点击确认收起Alertview
- (void)confirmBtnClick{
    self.alpha = 0.0;
    [self removeFromSuperview];
}

@end
