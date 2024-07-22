//
//  ZFAccountCMSBannerCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFAccountCMSBannerCell.h"
#import <YYWebImage/YYWebImage.h>
#import <Masonry/Masonry.h>
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "ZFAccountHeaderCellTypeModel.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFBannerModel.h"
#import "ZFThemeManager.h"

@interface ZFAccountCMSBannerCell ()
@property (nonatomic, strong) ZFNewBannerModel *firstNewBannerModel;
@end

@implementation ZFAccountCMSBannerCell

@synthesize cellTypeModel = _cellTypeModel;


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = ZFCClearColor();
        self.backgroundColor = ZFCClearColor();
    }
    return self;
}

#pragma mark - Setter Method

- (void)setCellTypeModel:(ZFAccountHeaderCellTypeModel *)cellTypeModel {
    
    if (self.firstNewBannerModel && [self.firstNewBannerModel isEqual:cellTypeModel.cmsBannersModelArray.firstObject]) {
        YWLog(@"刷新CMSBanner时防止反复创建子视图,判断如果第一个banner数据模型对象一样就不重新绘制子视图");
        return;
    }
    _cellTypeModel = cellTypeModel;
    self.firstNewBannerModel = cellTypeModel.cmsBannersModelArray.firstObject;
    
    [self.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    __block CGFloat lastRowMaxY = 0;
    [cellTypeModel.cmsBannersModelArray enumerateObjectsUsingBlock:^(ZFNewBannerModel *newBannerModel, NSUInteger idx1, BOOL * _Nonnull stop1) {
        
        __block CGFloat tmpBannerHeight = 0.0;
        NSInteger branch = newBannerModel.banners.count;
        [newBannerModel.banners enumerateObjectsUsingBlock:^(ZFBannerModel *bannerModel, NSUInteger idx2, BOOL * _Nonnull stop2) {
            
            CGFloat bannerWidth   = KScreenWidth / branch;
            tmpBannerHeight  = bannerWidth * [bannerModel.banner_height floatValue] / [bannerModel.banner_width floatValue];
            CGFloat offsetX = bannerWidth * idx2;
            
            YYAnimatedImageView *bannerView = [[YYAnimatedImageView alloc] initWithFrame:CGRectMake(offsetX, lastRowMaxY, bannerWidth, tmpBannerHeight)];
            bannerView.userInteractionEnabled = YES;
            bannerView.contentMode = UIViewContentModeScaleAspectFill;
            bannerView.clipsToBounds = YES;
            
            [bannerView yy_setImageWithURL:[NSURL URLWithString:bannerModel.image]
                                            placeholder:[UIImage imageNamed:@"index_banner_loading"]
                                                 options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                                                progress:nil
                                               transform:nil
                                              completion:nil];
            @weakify(self);
            [bannerView addTapGestureWithComplete:^(UIView * _Nonnull view) {
                @strongify(self);
                if (self.cellTypeModel.accountCellActionBlock) {
                    self.cellTypeModel.accountCellActionBlock(ZFAccountBannerCell_ShowBanner, bannerModel);
                }
            }];
            [self.contentView addSubview:bannerView];
        }];
        ///多行起始位置Y
        lastRowMaxY += tmpBannerHeight;
    }];
}

@end
