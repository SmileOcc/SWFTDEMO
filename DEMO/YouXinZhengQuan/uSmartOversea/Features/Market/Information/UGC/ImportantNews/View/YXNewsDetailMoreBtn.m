//
//  YXNewsDetailMoreBtn.m
//  YouXinZhengQuan
//
//  Created by 陈明茂 on 2021/6/2.
//  Copyright © 2021 RenRenDai. All rights reserved.
//

#import "YXNewsDetailMoreBtn.h"
#import "ASPopover.h"
#import "uSmartOversea-Swift.h"
#import "NSDictionary+Category.h"

@interface YXNewsDetailMoreBtn ()

@property(nonatomic, strong) YXStockPopover *popover;
@property(nonatomic, strong) UIView *popoverContentView;

@property (nonatomic, strong) NSString *newsId;
@property (nonatomic, strong) NSArray *typeArr;

@property (nonatomic, assign) BOOL isCollection;

@property (nonatomic, assign) YXNewsDetailType type;

@end

@implementation YXNewsDetailMoreBtn


- (instancetype)initWithFrame:(CGRect)frame andTypeArr: (NSArray *)typeArr andNewsId: (NSString *)newsId andType: (YXNewsDetailType)type {
    if (self = [super initWithFrame:frame]) {
        self.newsId = newsId;
        self.typeArr = typeArr;
        self.type = type;
        [self setUI];
    }
    
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame {
//    if (self = [super initWithFrame:frame]) {
//        [self setUI];
//    }
//    return self;
//}

- (void)setShareDic:(NSDictionary *)shareDic {
    _shareDic = shareDic;
}

#pragma mark - 设置UI
- (void)setUI {
    [self setImage:[UIImage imageNamed:@"icon_ugc_more"] forState:UIControlStateNormal];
    
    [self addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    
    for (NSNumber *number in self.typeArr) {
        if (number.longValue == YXNewsDetailMoreTypeCollection) {
            if (self.newsId.length > 0) {
                if ([YXUserManager isLogin]) {
                    [self collectionStatusRequest];
                }
            }
            break;
        }
    }
    
    @weakify(self);
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:YX_Noti_Login object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
//        @strongify(self);
//        [self collectionStatusRequest];
//    }];
    
//    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:YX_Noti_Login object:nil] takeUntil:self.rac_willDeallocSignal] subscribeNext:^(NSNotification * _Nullable x) {
//        @strongify(self);
//        self.isCollection = NO;
//        [self reloadCollectionStatus];
//    }];
}


#pragma mark- lazy load

- (YXStockPopover *)popover {

    if (!_popover) {
        _popover = [[YXStockPopover alloc] init];
    }

    return _popover;
}

- (UIView *)popoverContentView {

    if (!_popoverContentView) {
        _popoverContentView = [[UIView alloc] init];
        CGFloat btnH = 38;
        _popoverContentView.frame = CGRectMake(0, 0, 95, self.typeArr.count * btnH);

        
        for (int i = 0; i < self.typeArr.count; ++i) {
            NSNumber *typeNumber = self.typeArr[i];
            QMUIButton *btn = [[QMUIButton alloc] init];
            btn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightRegular];
            [btn setTitleColor:QMUITheme.textColorLevel1 forState:UIControlStateNormal];
            btn.tag = typeNumber.longValue;
            btn.imagePosition = QMUIButtonImagePositionLeft;
            btn.spacingBetweenImageAndTitle = 8;
            btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
            btn.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
            switch (typeNumber.longValue) {
                case YXNewsDetailMoreTypeCollection:
                {
                    [btn setTitle:[YXLanguageUtility kLangWithKey:@"news_favorite"] forState:UIControlStateNormal];
                    [btn setTitle:[YXLanguageUtility kLangWithKey:@"news_unfavorite"] forState:UIControlStateSelected];
                    [btn setImage:[UIImage imageNamed:@"news_unstar"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"news_star"] forState:UIControlStateSelected];
                }
                    break;
                case YXNewsDetailMoreTypeShare:
                {
                    [btn setTitle:[YXLanguageUtility kLangWithKey:@"share"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"news_share"] forState:UIControlStateNormal];
                }
                    break;
                case YXNewsDetailMoreTypeFont:
                {
                    [btn setTitle:[YXLanguageUtility kLangWithKey:@"news_font"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"news_font"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"news_font_big"] forState:UIControlStateSelected];
                }
                    break;
                case YXNewsDetailMoreTypeTranslate:
                {
                    [btn setTitle:[YXLanguageUtility kLangWithKey:@"news_share_translate"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"translate_cn"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"translate_en"] forState:UIControlStateSelected];
                }
                    break;
                case YXNewsDetailMoreTypeCopyURL:
                {
                    [btn setTitle:[YXLanguageUtility kLangWithKey:@"share_copy_url"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"translate_cn"] forState:UIControlStateNormal];
                    [btn setImage:[UIImage imageNamed:@"translate_en"] forState:UIControlStateSelected];
                }
                    break;
                    
                default:
                    break;
            }
            
            [btn addTarget:self action:@selector(typeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            btn.frame = CGRectMake(0, btnH * i, 95, btnH);
            [_popoverContentView addSubview:btn];
            
            
            // 分割线
            if (i < self.typeArr.count - 1) {
                UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(4, btnH - 1, 95 - 8, 0.5)];
                lineView.backgroundColor = QMUITheme.separatorLineColor;
                [btn addSubview:lineView];
            }
        }
    }

    return _popoverContentView;
}


- (void)reloadCollectionStatus {
    
    for (UIView *view in self.popoverContentView.subviews) {
        if ([view isKindOfClass:[QMUIButton class]]) {
            QMUIButton *btn = (QMUIButton *)view;
            if (btn.tag == YXNewsDetailMoreTypeCollection) {
                btn.selected = self.isCollection;
                break;
            }
        }
    }
}

- (void)typeBtnClick: (QMUIButton *)sender {
    
    [self.popover dismiss];
    
    if (self.subItemCallBack) {
        self.subItemCallBack(sender.tag);
    }
    
    switch (sender.tag) {
        case YXNewsDetailMoreTypeCollection:
        {
            if (![YXUserManager isLogin]) {
                //海外版没有收藏功能
//                [YXToolUtility presentToLoginVC:^{
//
//                }];
            } else {
                [self collectionRequest];
            }
        }
            break;
        case YXNewsDetailMoreTypeShare:
        {
            @weakify(self)
//            [YXToolUtility presentToLoginVC:^{
//                @strongify(self)
//                YXShareConfig *config = [YXShareManager shareLinkConfigWith:self.shareDic];
//                UIViewController* vc = [UIViewController currentYXViewController];
//                config.miniProgramImage = [UIImage qmui_imageWithView:vc.view];
//                [YXShareManager.shared showLink:config];
//            }];
            
        }
            break;
        case YXNewsDetailMoreTypeFont:
        {
            
        }
            break;
            break;
        case YXNewsDetailMoreTypeTranslate:
        {
            sender.selected = !sender.selected;
        }
            break;
        default:
            break;
    }
    
}

- (void)btnClick:(UIButton *)sender {
    [self.popover show:self.popoverContentView fromView:self];
}

#pragma mark - 收藏相关
- (void)collectionStatusRequest {
    if (self.type == YXNewsDetailTypeNews) {
        YXIsCollectRequestModel *model = [[YXIsCollectRequestModel alloc] init];
        model.newsid = self.newsId;
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:model];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                self.isCollection = [responseModel.data yx_boolValueForKey:@"collected"];
                [self reloadCollectionStatus];
            }else {
                [YXProgressHUD showError:responseModel.msg in:[UIViewController currentViewController].view];
            }
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
        }];
    } else if (self.type == YXNewsDetailTypeArticle) {
        YXArticleIsCollectRequestModel *model = [[YXArticleIsCollectRequestModel alloc] init];
        model.cid = @[self.newsId];
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:model];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                NSArray *list = [responseModel.data yx_arrayValueForKey:@"cid"];
                for (NSNumber *cid in list) {
                    if ([cid.stringValue isEqualToString:self.newsId]) {
                        self.isCollection = YES;
                        [self reloadCollectionStatus];
                        break;;
                    }
                }
            }else {
                [YXProgressHUD showError:responseModel.msg in:[UIViewController currentViewController].view];
            }
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
        }];
    } else if (self.type == YXNewsDetailTypeVideo) {
        YXVideoIsCollectRequestModel *model = [[YXVideoIsCollectRequestModel alloc] init];
        model.id = self.newsId;
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:model];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
            if (responseModel.code == YXResponseStatusCodeSuccess) {
                self.isCollection = [responseModel.data yx_boolValueForKey:@"has_collected"];
                [self reloadCollectionStatus];
            }else {
                [YXProgressHUD showError:responseModel.msg in:[UIViewController currentViewController].view];
            }
            
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            
        }];
    }
}


- (void)collectionRequest {
    
    if (self.type == YXNewsDetailTypeNews) {
        YXCollectRequestModel *model = [[YXCollectRequestModel alloc] init];
        model.newsids = self.newsId;
        model.collectflag = !self.isCollection;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:model];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
             if (responseModel.code == YXResponseStatusCodeSuccess) {
                 self.isCollection = !self.isCollection;
                 if (self.isCollection) {
//                     [YXProgressHUD showSuccess:kLang(@"news/collection_success") inView:[UIViewController currentViewController].view];
                 } else {
//                     [YXProgressHUD showSuccess:kLang(@"news/collection_cancel") inView:[UIViewController currentViewController].view];
                 }
                 [self reloadCollectionStatus];
             } else {
                 [YXProgressHUD showError:responseModel.msg];
             }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [YXProgressHUD showError:@"网络开小差了"];
        }];
    } else if (self.type == YXNewsDetailTypeArticle) {
        YXAritckcCollectRequestModel *model = [[YXAritckcCollectRequestModel alloc] init];
        model.cid = @[self.newsId];
        model.collect_type = self.isCollection ? 2 : 1;
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:model];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
             if (responseModel.code == YXResponseStatusCodeSuccess) {
                 self.isCollection = !self.isCollection;
                 if (self.isCollection) {
//                     [YXProgressHUD showSuccess:kLang(@"news/collection_success") inView:[UIViewController currentViewController].view];
                 } else {
//                     [YXProgressHUD showSuccess:kLang(@"news/collection_cancel") inView:[UIViewController currentViewController].view];
                 }
                 [self reloadCollectionStatus];
             } else {
                 [YXProgressHUD showError:responseModel.msg];
             }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [YXProgressHUD showError:@"网络开小差了"];
        }];
    } else if (self.type == YXNewsDetailTypeVideo) {
        YXHZBaseRequestModel *requestModel;
        if (self.isCollection) {
            YXVideoCancelCollectRequestModel *cancel = [[YXVideoCancelCollectRequestModel alloc] init];
            cancel.id = self.newsId;
            requestModel = cancel;
            
        } else {
            YXVideoAddCollectRequestModel *add = [[YXVideoAddCollectRequestModel alloc] init];
            add.id = self.newsId;
            requestModel = add;
        }
        
        YXRequest *request = [[YXRequest alloc] initWithRequestModel:requestModel];
        [request startWithBlockWithSuccess:^(__kindof YXResponseModel *responseModel) {
             if (responseModel.code == YXResponseStatusCodeSuccess) {
                 self.isCollection = !self.isCollection;
                 if (self.isCollection) {
//                     [YXProgressHUD showSuccess:kLang(@"news/collection_success") inView:[UIViewController currentViewController].view];
                 } else {
//                     [YXProgressHUD showSuccess:kLang(@"news/collection_cancel") inView:[UIViewController currentViewController].view];
                 }
                 [self reloadCollectionStatus];
             } else {
                 [YXProgressHUD showError:responseModel.msg];
             }
        } failure:^(__kindof YTKBaseRequest * _Nonnull request) {
            [YXProgressHUD showError:@"网络开小差了"];
        }];
         
    }

}


@end
