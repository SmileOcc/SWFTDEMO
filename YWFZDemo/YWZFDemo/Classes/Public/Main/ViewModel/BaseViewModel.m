//
//  BaseViewModel.m
//  Yoshop
//
//  Created by YW on 16/5/25.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "BaseViewModel.h"
#import "SYBaseRequest.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "ZFLocalizationString.h"
#import "Masonry.h"

typedef void (^NoDataBlock)(void);
typedef void (^NoNetworkBlock)(void);

@interface BaseViewModel ()

@property (nonatomic, copy) NoDataBlock noDataBlock;

@property (nonatomic, copy) NoNetworkBlock noNetworkBlock;

@end

@implementation BaseViewModel
{
    UIView *emptyView;
    UIView *noDataView;
}


- (instancetype)init {
    self = [super init];
    if (self) {
        self.emptyViewShowType = EmptyViewHideType;
        self.loadingViewShowType = LoadingViewIsShow;
    }
    return self;
}
/**
 *  该方法为页面请求数据，继承BaseViewModel的类要根据自己的需要重写该方法
 *
 *  @param parmaters             网络请求参数
 *  @param completionExcuteBlock 请求完成后所要执行的操作，如：重新页面等
 */
- (void)requestNetwork:(id)parmaters completion:(void (^)(id obj)) completion failure:(void (^)(id obj))failure{
    if (completion) {
        completion(nil);
    }
}
/**
 *  数据解析方法，后期要提取通用，如果特殊再重写该方法
 *
 *  @param json    网络请求返回的数据-以JSON格式为主
 *  @param request 发送请求的API
 *
 *  @return 返回所需要的类型可以是字典，model，数组。。。。
 */
- (id)dataAnalysisFromJson:(id)json  request:(SYBaseRequest *)request{
    return nil;
}

#define CODE_201    @"201"
#define CODE_202    @"202"
#define CODE_2001   @"2001"
#define CODE_2002   @"2002"


/**
 *  网络请求刷新
 *
 *  @param sender
 */
- (void)emptyOperationTouch {
    if(self.emptyOperationBlock){
        self.emptyOperationBlock();
    }
}

- (void)emptyJumpOperationTouch  {
    if (self.emptyJumpOperationBlock) {
        self.emptyJumpOperationBlock();
    }
}


- (void)showNoDataInView:(UIView *)view imageView:(NSString *)imgName titleLabel:(NSString *)title button:(NSString *)name buttonBlock:(void (^)(void))btnBlock{
    
    /**
     *  防止用户退出登录时,view未加载而导致奔溃.
     */
    if (view == nil) return;
    
    noDataView = [[UIView alloc] initWithFrame:CGRectZero];
    noDataView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [view addSubview:noDataView];
    [noDataView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).with.insets(UIEdgeInsetsZero);
    }];
    
    YYAnimatedImageView *imageView = [YYAnimatedImageView new];
    imageView.image = [UIImage imageNamed:imgName];
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [noDataView addSubview:imageView];
    
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(86, 86));
        make.centerX.mas_equalTo(view.mas_centerX);
        if (name == nil) {
            make.centerY.mas_equalTo(view.mas_centerY).offset(-60);
        }else{
            make.centerY.mas_equalTo(view.mas_centerY).offset(-80);
        }
    }];

    
    UILabel *titleLabel = [UILabel new];
    titleLabel.textColor = ZFCOLOR(178, 178, 178, 1.0);
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.text = title;
    [noDataView addSubview:titleLabel];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.top.mas_equalTo(imageView.mas_bottom).offset(15);
    }];
    
    if (name == nil)return;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = ZFCOLOR(0, 0, 0, 1.0);
    button.titleLabel.font = [UIFont boldSystemFontOfSize:18.0];
    [button setTitleColor:ZFCOLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
    [button setTitle:name forState:UIControlStateNormal];
    button.layer.cornerRadius = 3;
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    [noDataView addSubview:button];
    
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(view.mas_centerX);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(45);
        make.leading.mas_equalTo(view.mas_leading).offset(38);
        make.trailing.mas_equalTo(view.mas_trailing).offset(-38);
        make.height.equalTo(@50);
    }];
    
    self.noDataBlock = btnBlock;
}

- (void)buttonClick {
    if (self.noDataBlock) {
        
        [noDataView removeFromSuperview];
        noDataView = nil;
        self.noDataBlock();
    }
}

-(void)noNetworkClick {
    if (self.noNetworkBlock) {
        [emptyView removeFromSuperview];
        emptyView = nil;
        self.noNetworkBlock();
    }
}

- (void)showNoNetworkViewInView:(UIView *)view buttonBlock:(void (^)(void))btnBlock {
    if (view == nil) return;
    
    emptyView = [[UIView alloc]initWithFrame:CGRectZero];
    emptyView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    [view addSubview:emptyView];
    
    UIButton *requestBut = [UIButton buttonWithType:UIButtonTypeCustom];
    requestBut.backgroundColor = [UIColor clearColor];
    [requestBut addTarget:self action:@selector(noNetworkClick) forControlEvents:UIControlEventTouchUpInside];
    [emptyView addSubview:requestBut];
    [requestBut mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    YYAnimatedImageView *emptyImage = [[YYAnimatedImageView alloc]initWithFrame:CGRectZero];
    emptyImage.image = [UIImage imageNamed:@"blankPage_networkError"];
    [emptyView addSubview:emptyImage];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    titleLabel.textColor = ZFCOLOR(178, 178, 178, 1.0);
    titleLabel.font = [UIFont systemFontOfSize:18];
    titleLabel.text = ZFLocalizedString(@"Global_EMPTY_TITLE",nil);
    [emptyView addSubview:titleLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc]initWithFrame:CGRectZero];
    descriptionLabel.textColor = ZFCOLOR(178, 178, 178, 1.0);
    descriptionLabel.font = [UIFont systemFontOfSize:14];
    descriptionLabel.text = ZFLocalizedString(@"Global_NO_NET_404",nil);
    [emptyView addSubview:descriptionLabel];
    
    [emptyView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.bottom.mas_equalTo(@(0));
    }];
    
    [emptyImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self->emptyView.mas_centerX);
        make.centerY.mas_equalTo(self->emptyView.mas_centerY).offset(-80);//距离Y轴中心向上偏移80.
    }];
    
    [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self->emptyView.mas_centerX);
        make.top.mas_equalTo(emptyImage.mas_bottom).offset(20);
    }];
    [descriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self->emptyView.mas_centerX);
        make.top.mas_equalTo(titleLabel.mas_bottom).offset(10);
    }];
    self.noNetworkBlock = btnBlock;
}


@end
