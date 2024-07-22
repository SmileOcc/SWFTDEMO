//
//  ZFCMSCouponCCell.m
//  ZZZZZ
//
//  Created by YW on 2019/10/30.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCMSCouponCCell.h"
#import "ZFThemeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

static NSInteger kCMSCouponTag = 178900;

@implementation ZFCMSCouponCCell

+ (ZFCMSCouponCCell *)reusableCouponModuleCell:(UICollectionView *)collectionView forIndexPath:(NSIndexPath *)indexPath
{
    return [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([self class]) forIndexPath:indexPath];
}

- (void)createSubItems:(NSInteger)count {
    if (count <= 0) {
        return;
    }
    if (count >= 4) {
        count = 4;
    }
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    
    ZFCMSCouponItemView *tempView;
    for (int i=0; i<count; i++) {
        
        ZFCMSCouponItemView *itemView;
        if (count == 1) {
            itemView = [[ZFCMSCouponBigItemBaseView alloc] initWithFrame:CGRectZero];
            itemView.maxTitleWidth = 150;
            
        } else if (count == 2) {
            itemView = [[ZFCMSCouponMediumItemBaseView alloc] initWithFrame:CGRectZero];
            itemView.maxTitleWidth = 150;

        } else if (count == 3) {
            itemView = [[ZFCMSCouponTrisectionItemBaseView alloc] initWithFrame:CGRectZero];
            itemView.maxTitleWidth = 85;

        } else if (count == 4) {
            itemView = [[ZFCMSCouponQuarterItemBaseView alloc] initWithFrame:CGRectZero];
            itemView.maxTitleWidth = 65;

        }
        itemView.tag = kCMSCouponTag + i;
        @weakify(self)
        @weakify(itemView)
        itemView.tapBlock = ^{
            @strongify(self)
            @strongify(itemView)
            [self actionTap:itemView];
        };

        [self.contentView addSubview:itemView];
        [itemsArray addObject:itemView];
        
        
        if (i == 0) {
            if (i == (count-1)) {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self);
                }];
            } else {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(self.mas_leading);
                    make.top.bottom.mas_equalTo(self);
                }];
            }
        } else {
            
            if (i == (count - 1)) {
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(tempView.mas_trailing).offset([ZFCMSItemModel cmsCouponSpace]);
                    make.top.bottom.trailing.mas_equalTo(self);
                    make.width.mas_equalTo(tempView.mas_width);
                }];

            } else {
                
                [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.leading.mas_equalTo(tempView.mas_trailing).offset([ZFCMSItemModel cmsCouponSpace]);
                    make.top.bottom.mas_equalTo(self);
                    make.width.mas_equalTo(tempView.mas_width);
                }];
            }
        }
        tempView = itemView;
    }
    
//    if (itemsArray.count > 1) {
//
//        [itemsArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:[ZFCMSItemModel cmsCouponSpace] leadSpacing:0 tailSpacing:0];
//        [itemsArray mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.bottom.mas_equalTo(self);
//        }];
//    } else {
//
//        ZFCMSCouponItemView *couponItemView = itemsArray.firstObject;
//        [couponItemView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.mas_equalTo(self);
//        }];
//    }
}

- (void)updateItem:(NSArray <ZFCMSItemModel *> *)itemModels sctionModel:(ZFCMSSectionModel *)sectionModel {
    
    if (ZFJudgeNSArray(itemModels) && itemModels.count > 0) {
        self.itemModelArrays = itemModels;
        
        NSInteger counts = self.itemModelArrays.count;
        if (counts >= 4) {
            counts = 4;
        }
        CGSize contentSize = CGSizeMake(sectionModel.sectionItemSize.width / counts, sectionModel.sectionItemSize.height);
        for (int i=0; i<self.itemModelArrays.count; i++) {
            ZFCMSCouponMediumItemBaseView *itemView  = (ZFCMSCouponMediumItemBaseView *)[self viewWithTag:kCMSCouponTag + i];
            
            if (itemView) {
                ZFCMSItemModel *itemModel = itemModels[i];
                [itemView updateItem:itemModel sectionModel:sectionModel contentSize:contentSize];
            }
        }
    }
}

- (void)actionTap:(ZFCMSCouponItemView *)itemView {
    
    NSInteger index = itemView.tag - kCMSCouponTag;
    if (self.selectBlock) {
        if (index >= 0 && ZFJudgeNSArray(self.itemModelArrays) && self.itemModelArrays.count > index) {
            ZFCMSItemModel *itemModel = self.itemModelArrays[index];
            self.selectBlock(itemModel);
        }
    }
}
@end


@implementation ZFCMSCouponOneCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubItems:1];
    }
    return self;
}
@end

@implementation ZFCMSCouponTwoCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubItems:2];
    }
    return self;
}
@end


@implementation ZFCMSCouponThreeCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubItems:3];
    }
    return self;
}

@end

@implementation ZFCMSCouponFourCCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubItems:4];
    }
    return self;
}
@end
