//
//  ZFCommunityPostPreviewVC.m
//  ZZZZZ
//
//  Created by YW on 2019/10/10.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCommunityPostPreviewVC.h"
#import "ZFInitViewProtocol.h"
#import "UIColor+ExTypeChange.h"
#import "YWCFunctionTool.h"
#import "ZFThemeManager.h"
#import "ZFCommunityPostDetailUserView.h"
#import "ZFCommunityPostDetailPicCCell.h"
#import "ZFPostDetailSimilarGoodsCell.h"
#import "ZFCommunityPostDetailRecommendGoodsCCell.h"
#import "ZFCommunityPreviewDescriptCollectionReusableView.h"
#import "ZFPostDetailTileCollectionReusableView.h"

#import <Masonry/Masonry.h>
#import "ZFFrameDefiner.h"

@interface ZFCommunityPostPreviewVC ()
<ZFInitViewProtocol,
UICollectionViewDelegate,
UICollectionViewDataSource>

@property (nonatomic, strong) UIButton                             *backButton;
@property (nonatomic, strong) UICollectionView                     *detailCollectionView;
@property (nonatomic, strong) ZFCommunityPostDetailUserView        *userInfoView;

@property (nonatomic, strong) NSIndexPath                           *userInfoIndexPath;

@property (nonatomic, strong) NSMutableArray<ZFCommunityTopicDetailBaseSection *> *sectionArray;


@end

@implementation ZFCommunityPostPreviewVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self zfInitView];
    [self zfAutoLayoutView];
    
    [self.detailCollectionView reloadData];
}

- (void)zfInitView {
    [self.view addSubview:self.backButton];
    [self.view addSubview:self.detailCollectionView];
    [self.view bringSubviewToFront:self.backButton];
}

- (void)zfAutoLayoutView {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-16);
        make.top.mas_equalTo(self.view.mas_top).offset(kiphoneXTopOffsetY);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    
    [self.detailCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
    }];
}


#pragma mark - <UICollectionViewDelegate, UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return self.sectionArray.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
    return baseSection.rowCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
    
    if (baseSection.type == ZFTopicSectionTypePic) {
        ZFCommunityPostDetailPicCCell *cell = [ZFCommunityPostDetailPicCCell picCellWithCollectionView:collectionView indexPath:indexPath];
        
        ZFCommunityTopicDetailPicSection *picSection = (ZFCommunityTopicDetailPicSection *)baseSection;
        if (picSection.preivewImages.count > indexPath.row) {
            [cell previewImage:[picSection.preivewImages objectAtIndex:indexPath.row]];
        }
        return cell;
        
    } else if(baseSection.type == ZFTopicSectionTypeSimilar) {

        ZFCommunityTopicDetailSimilarSection *similarSection = (ZFCommunityTopicDetailSimilarSection *)baseSection;

        ZFCommunityPostDetailRecommendGoodsCCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([ZFCommunityPostDetailRecommendGoodsCCell class]) forIndexPath:indexPath];
        cell.similarSection = similarSection;
        cell.contentView.userInteractionEnabled = NO;
        return cell;

    }

    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class]) forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sectionArray.count > indexPath.section) {
        ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
        
        if (baseSection.type == ZFTopicSectionTypeDescrip) {
            
            ZFCommunityPreviewDescriptCollectionReusableView *headerView = [ZFCommunityPreviewDescriptCollectionReusableView descriptWithCollectionView:collectionView indexPath:indexPath];
            [self configContenDatas:headerView indexPath:indexPath];
            return headerView;
            
        } else if(baseSection.type == ZFTopicSectionTypeUserInfo) {
            
            ZFCommunityPostDetailUserView *headerView = [ZFCommunityPostDetailUserView userHeaderViewWithCollectionView:collectionView indexPath:indexPath];
            [self configUserInfo:headerView indexPath:indexPath];
            self.userInfoIndexPath = indexPath;
            return headerView;

        } else if(baseSection.type == ZFTopicSectionTypeSimilar) {
            ZFPostDetailTileCollectionReusableView *headerView = [ZFPostDetailTileCollectionReusableView titleHeaderViewWithCollectionView:collectionView indexPath:indexPath type:ZFTopicDetailTitleTypeSimilar];
            [headerView hideMoreView];
            return headerView;
        }
    }
    UICollectionReusableView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:NSStringFromClass([UICollectionReusableView class]) forIndexPath:indexPath];
    headerView.backgroundColor = ZFC0xF2F2F2();
    return headerView;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

/**
 * 每个section中显示Item的列数
 */
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnCountForSection:(NSInteger)section {
    return 1;
}

/**
 * 每个Item的大小
 */
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.sectionArray.count > indexPath.section) {
        ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
        CGSize size = baseSection.itemSize;
        if (baseSection.type == ZFTopicSectionTypePic) {
            
            ZFCommunityTopicDetailPicSection *picSection = (ZFCommunityTopicDetailPicSection *)baseSection;
            
            CGFloat realH = KScreenWidth;
            if (picSection.preivewImages.count > indexPath.row) {
                UIImage *image = [picSection.preivewImages objectAtIndex:indexPath.row];
                CGFloat imageW = image.size.width;
                CGFloat imageH = image.size.height;
                if (imageW > 0 && imageH > 0) {
                    realH = KScreenWidth * imageH / imageW;
                }
            }
            size = CGSizeMake(KScreenWidth, realH);
        }
        return size;
    }
    return CGSizeZero;
}

/**
 * 每个section中item的横向间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

/**
 * 每个section中item的纵向间距
 */
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumColumnSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

/**
 * 每个section之间的缩进间距
 */
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (self.sectionArray.count > section) {
        ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
        return baseSection.edgeInsets;
    }
    return UIEdgeInsetsZero;
}

//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForHeaderInSection:(NSInteger)section {
//    if (self.sectionArray.count > section) {
//        ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
//        return baseSection.headerSize.height;
//    }
//    return 0;
//}
//
//- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout heightForFooterInSection:(NSInteger)section {
//    return 0;
//}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.sectionArray.count > section) {
        ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:section];
        if (baseSection.type == ZFTopicSectionTypeDescrip) {
            ZFCommunityTopicDetailDescripSection *descripSection = (ZFCommunityTopicDetailDescripSection *)baseSection;

            return descripSection.previewHeaderSize;
        }
        return baseSection.headerSize;
    }
    return CGSizeZero;
}

/**
 配置帖子描述数据
 */
- (void)configContenDatas:(ZFCommunityPreviewDescriptCollectionReusableView *)descripView indexPath:(NSIndexPath *)indexPath {
    
    if (self.sectionArray.count <= indexPath.section) {
        return;
    }
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
    
    if ([baseSection isKindOfClass:[ZFCommunityTopicDetailDescripSection class]]) {
        ZFCommunityTopicDetailDescripSection *descripSection = (ZFCommunityTopicDetailDescripSection *)baseSection;

        [descripView setContentString:descripSection.topicContentString];
        [descripView setDeepLinkTitle:descripSection.deeplinkTitle url:descripSection.deeplinkUrl];
        [descripView setTagArray:descripSection.tagArray];
        [descripView setReadNumber:descripSection.readNumberString];
        [descripView setPublishTime:descripSection.publishTimeString];
    }
}

/**
 配置用户数据
 */
- (void)configUserInfo:(ZFCommunityPostDetailUserView *)userView indexPath:(NSIndexPath *)indexPath {
    
    if (self.sectionArray.count <= indexPath.section) {
        return;
    }
    ZFCommunityTopicDetailBaseSection *baseSection = [self.sectionArray objectAtIndex:indexPath.section];
    if (baseSection.type != ZFTopicSectionTypeUserInfo) {
        return;
    }
    ZFCommunityTopicDetailUserInfoSection *userInfoSection = (ZFCommunityTopicDetailUserInfoSection *)baseSection;
    
    NSString *userAvarteURL = ZFToString(userInfoSection.userAvatarURL);
    NSString *userNickName  = ZFToString(userInfoSection.userNickName);
    NSString *userPostNum   = ZFToString(userInfoSection.postNumber);
    NSString *userTotalLike = ZFToString(userInfoSection.likedNumber);
    
    [userView hideFollowView];
    [userView setUserWithAvarteURL:userAvarteURL];
    [userView setPreviewNickName:userNickName];
    [userView setUserWithRank:[userInfoSection.identify_type integerValue]  imgUrl:userInfoSection.identify_icon content:userInfoSection.identify_content];

    [self.userInfoView hideFollowView];
    [self.userInfoView setUserWithAvarteURL:userAvarteURL];
    [self.userInfoView setPreviewNickName:userNickName];    
    [self.userInfoView setUserWithRank:[userInfoSection.identify_type integerValue]  imgUrl:userInfoSection.identify_icon content:userInfoSection.identify_content];
}



- (void)actionBack:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Public Method

- (void)setDetailModel:(ZFCommunityPostDetailModel *)detailModel {
    _detailModel = detailModel;
    
    [self.sectionArray removeAllObjects];
      if (self.detailModel.previewImages.count > 0) {
          ZFCommunityTopicDetailPicSection *picSection = [[ZFCommunityTopicDetailPicSection alloc] init];
          picSection.type = ZFTopicSectionTypePic;
          picSection.preivewImages = self.detailModel.previewImages;
          picSection.rowCount = self.detailModel.previewImages.count;
          [self.sectionArray addObject:picSection];
      }
      
      if (self.detailModel) {
          ZFCommunityTopicDetailDescripSection *descripSection = [[ZFCommunityTopicDetailDescripSection alloc] init];
          descripSection.type = ZFTopicSectionTypeDescrip;
          descripSection.rowCount = 0;
          [descripSection updateTitle:self.detailModel.title contentDesc:self.detailModel.content deeplinkUrl:ZFToString(self.detailModel.deeplinkUrl) deeplinkTitle:ZFToString(self.detailModel.deeplinkTitle) tags:self.detailModel.labelInfo readNumber:self.detailModel.viewNum publishTime:self.detailModel.addTime];
          [self.sectionArray addObject:descripSection];
      }
      
      if (self.detailModel) {
          ZFCommunityTopicDetailUserInfoSection *userInfoSection = [[ZFCommunityTopicDetailUserInfoSection alloc] init];
          userInfoSection.type = ZFTopicSectionTypeUserInfo;
          userInfoSection.userAvatarURL = self.detailModel.avatar;
          userInfoSection.userNickName  = self.detailModel.nickname;
          userInfoSection.postNumber    = self.detailModel.reviewTotal;
          userInfoSection.likedNumber   = self.detailModel.beLikedTotal;
          userInfoSection.isFollow      = self.detailModel.isFollow;
          userInfoSection.identify_icon = self.detailModel.identify_icon;
          userInfoSection.identify_type = self.detailModel.identify_type;
          userInfoSection.identify_content = self.detailModel.identify_content;
          userInfoSection.rowCount = 0;
          [self.sectionArray addObject:userInfoSection];
      }
    
    if (self.detailModel) {
        ZFCommunityTopicDetailBaseSection *baseSpaceSection = [[ZFCommunityTopicDetailBaseSection alloc] init];
        baseSpaceSection.headerSize = CGSizeMake(KScreenWidth, 12);
        [self.sectionArray addObject:baseSpaceSection];
    }
      
      if (self.detailModel.goodsInfos.count > 0) {
          ZFCommunityTopicDetailSimilarSection *similarSection = [[ZFCommunityTopicDetailSimilarSection alloc] init];
          similarSection.type = ZFTopicSectionTypeSimilar;
          similarSection.goodsArray = self.detailModel.goodsInfos;
          [self.sectionArray addObject:similarSection];
      }
    
    [self.detailCollectionView reloadData];
}

- (NSMutableArray<ZFCommunityTopicDetailBaseSection *> *)sectionArray {
    if (!_sectionArray) {
        _sectionArray = [[NSMutableArray alloc] init];
    }
    return _sectionArray;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[UIImage imageNamed:@"z-me_outfits_post_close"] forState:UIControlStateNormal];
        [_backButton addTarget:self action:@selector(actionBack:) forControlEvents:UIControlEventTouchUpInside];
        _backButton.layer.cornerRadius = 18;
        _backButton.layer.masksToBounds = YES;
        _backButton.backgroundColor = ZFC0xFFFFFF();
    }
    return _backButton;
}
- (UICollectionView *)detailCollectionView {
    if (!_detailCollectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.minimumLineSpacing = 2;
        layout.minimumInteritemSpacing = 0;
        _detailCollectionView                    = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _detailCollectionView.dataSource         = self;
        _detailCollectionView.delegate           = self;
        _detailCollectionView.scrollsToTop       = NO;
        _detailCollectionView.backgroundColor    = [UIColor whiteColor];
        _detailCollectionView.showsHorizontalScrollIndicator = NO;
        _detailCollectionView.showsVerticalScrollIndicator   = NO;
        _detailCollectionView.alwaysBounceVertical           = YES;
        
        if (@available(iOS 11.0, *)) {
            _detailCollectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        
        [_detailCollectionView registerClass:[UICollectionViewCell class]
                  forCellWithReuseIdentifier:NSStringFromClass([UICollectionViewCell class])];
        [_detailCollectionView registerClass:[UICollectionReusableView class]
                  forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
                         withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
        [_detailCollectionView registerClass:[UICollectionReusableView class]
                  forSupplementaryViewOfKind:UICollectionElementKindSectionFooter
                         withReuseIdentifier:NSStringFromClass([UICollectionReusableView class])];
    
        [_detailCollectionView registerClass:[ZFCommunityPostDetailPicCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityPostDetailPicCCell class])];
        [_detailCollectionView registerClass:[ZFPostDetailSimilarGoodsCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFPostDetailSimilarGoodsCell class])];
        [_detailCollectionView registerClass:[ZFCommunityPostDetailRecommendGoodsCCell class] forCellWithReuseIdentifier:NSStringFromClass([ZFCommunityPostDetailRecommendGoodsCCell class])];

    }
    return _detailCollectionView;
}
@end
