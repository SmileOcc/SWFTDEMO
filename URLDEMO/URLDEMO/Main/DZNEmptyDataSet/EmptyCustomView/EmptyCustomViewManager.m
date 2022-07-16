//
//  EmptyCustomViewManage.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "EmptyCustomViewManager.h"
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"

@interface EmptyCustomViewManager ()<EmptyCustomNoNetViewDelegate>

// 固定的没有网的 emptyView
@property (nonatomic, strong) EmptyCustomNoNetView *customNoNetView;

@end



@implementation EmptyCustomViewManager

#pragma mark - 单例

//+ (instancetype)sharedInstance {
//    static EmptyCustomViewManager *_sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _sharedInstance = [[self alloc] init];
//    });
//    return _sharedInstance;
//}


#pragma mark -  init 
- (instancetype)init {
    if (self = [super init]) {
      
    }
    return self;
}

- (void)dealloc {
//    STLLog(@"EmptyCustomViewManager Dealloc");
}

- (UIView *)accordingToTypeReBackView:(EmptyViewShowType)emptyViewShowType {
    
    switch (emptyViewShowType) {
        case EmptyViewShowTypeHide:
        {
            UIView *emptyView = [[UIView alloc] init];
            emptyView.hidden = YES;
            return emptyView;
        }
            break;
        case EmptyViewShowTypeNoData:
        {
            if (self.customNoDataView) {
                return self.customNoDataView;
            }
        }
            break;
        case EmptyViewShowTypeNoNet:
        {
            return self.customNoNetView;
        }
            break;
    }
    return [UIView new];
}

#pragma mark empty button 点击事件
- (void)emptyRefreshAction {
    
    /**
     *  这个事件不通过代理响应，为什么？？？
        注意 manager 不能提前被释放
            方法：   1、sharedInstance（但是不匹配同时多个页面显示的情况）
                    2、外部强引用 （不符合高内聚底耦合的思想） === 暂用
                    3、delegate 强引用 （循环引用，内存不能释放）
     */
    if (self.emptyRefreshOperationBlock) {
        self.emptyRefreshOperationBlock();
    }
}


- (EmptyCustomNoNetView *)customNoNetView {
    
    if (!_customNoNetView) {
        _customNoNetView = [[EmptyCustomNoNetView alloc] initWithFrame:CGRectZero];
        _customNoNetView.delegate = self;
    }
    return _customNoNetView;
}

@end

#pragma mark - EmptyCustomNoNetView
@interface EmptyCustomNoNetView()

@end

@implementation EmptyCustomNoNetView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        YYAnimatedImageView *imageView = [YYAnimatedImageView new];
        imageView.image = [UIImage imageNamed:@"loading_failed"];
        [self addSubview:imageView];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.mas_top).offset(52);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.textColor = [UIColor blackColor];
        titleLabel.font = [UIFont systemFontOfSize:12];
        titleLabel.text = NSLocalizedString(@"load_failed", nil);
        [self addSubview:titleLabel];
        
        [titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(imageView.mas_bottom).offset(36);
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
        refreshButton.backgroundColor = [UIColor grayColor];
        refreshButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [refreshButton setTitle:@"refresh" forState:UIControlStateNormal];
        [refreshButton addTarget:self action:@selector(emptyRefreshButtonAction) forControlEvents:UIControlEventTouchUpInside];
        refreshButton.layer.cornerRadius = 3;
        [self addSubview:refreshButton];
        
        [refreshButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(titleLabel.mas_bottom).offset(33);
            make.centerX.mas_equalTo(self.mas_centerX);
            make.width.mas_equalTo(@180);
            make.height.mas_equalTo(@40);
        }];
    }
    return self;
}

- (void)emptyRefreshButtonAction {
 
    if (self.delegate && [self.delegate respondsToSelector:@selector(emptyRefreshAction)]) {
        [self.delegate emptyRefreshAction];
    }

}

@end



