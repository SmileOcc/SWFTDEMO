//
//  YXHotTopicViewCell.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXHotTopicViewCell1.h"

//#import "YXSubjectCardView.h"
#import <YYCategories/UIView+YYAdd.h>
#import "YXTopicSingleView.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "UIImage+YYAdd.h"

@interface YXTopicPageControl1 : UIPageControl

@end

@implementation YXTopicPageControl1


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setUI];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)setUI {
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 140000
    if (@available(iOS 14.0, *)) {
        self.preferredIndicatorImage = [[UIImage imageWithColor:UIColor.blackColor size:CGSizeMake(9, 3)] imageByRoundCornerRadius:1.5];
    }
#endif
}

- (void)setCurrentPage:(NSInteger)page {
    [super setCurrentPage:page];

    if (@available(iOS 14.0, *)) {
        
    } else {
        for (NSUInteger subviewIndex = 0; subviewIndex < [self.subviews count]; subviewIndex++) {
            UIView* subview = [self.subviews objectAtIndex:subviewIndex];
            CGSize size;
            size.height = 3;
            size.width = 9;
            subview.layer.cornerRadius = 1.5;
            [subview setFrame:CGRectMake(subview.frame.origin.x, subview.frame.origin.y,size.width,size.height)];
        }
    }
}

@end

@interface YXHotTopicViewCell1 ()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel *titleLab; //标题
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;

@end

@implementation YXHotTopicViewCell1

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initialUI];
    }
    return self;
}

#pragma mark - 设置UI
- (void)initialUI {
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = [UIColor whiteColor];
    
    
    UIView *leftView = [[UIView alloc] init];
    leftView.backgroundColor = QMUITheme.themeTextColor;
    [self.contentView addSubview:leftView];
    [leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView);
        make.width.mas_equalTo(4);
        make.height.mas_equalTo(17);
        make.top.equalTo(self.contentView).offset(16);
    }];
    
    UILabel *titleLab = [[UILabel alloc] init];
    titleLab.text = [YXLanguageUtility kLangWithKey:@"topic_community"];
    titleLab.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    titleLab.textColor = [UIColor qmui_colorWithHexString:@"#353547"];
    [self.contentView addSubview:titleLab];
    [titleLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(12);
        make.top.equalTo(self.contentView).offset(12);
        make.height.mas_equalTo(25);
    }];
    
    UIImageView *iconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons_news_hot"]];
    [self.contentView addSubview:iconView];
    [iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(titleLab.mas_right).offset(8);
        make.centerY.equalTo(titleLab);
    }];
    
    UIImageView *arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icons_news_more"]];    
    [self.contentView addSubview:arrowImageView];
    [arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(titleLab);
        make.right.equalTo(self.contentView.mas_right).offset(-18);
    }];
    
    
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.delegate = self;
    self.scrollView.clipsToBounds = NO;
    self.scrollView.pagingEnabled = YES;
    [self.contentView addSubview:self.scrollView];
    [_scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(YXConstant.screenWidth);
        make.right.equalTo(self.contentView);
        make.top.equalTo(self).offset(47);
        make.height.mas_equalTo(217);
        make.left.equalTo(self.contentView).offset(0);
    }];
    
    self.pageControl = [[YXTopicPageControl1 alloc] init];
    self.pageControl.hidesForSinglePage = YES;
    self.pageControl.pageIndicatorTintColor = [[UIColor qmui_colorWithHexString:@"#606060"] colorWithAlphaComponent:0.15];
    self.pageControl.currentPageIndicatorTintColor = [[UIColor qmui_colorWithHexString:@"#606060"] colorWithAlphaComponent:0.45];
    self.pageControl.numberOfPages = 4;
    self.pageControl.transform = CGAffineTransformScale(CGAffineTransformIdentity, 2, 2);
    
    [self.contentView addSubview:self.pageControl];
    [self.pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.bottom.equalTo(self).offset(-7);
        make.left.right.equalTo(self);
        make.height.mas_equalTo(5);
    }];
    
    UIControl *clickControl = [[UIControl alloc] init];
    [clickControl addTarget:self action:@selector(moreBtnAction)  forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:clickControl];
    [clickControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self.contentView);
        make.height.mas_equalTo(47);
    }];
}

- (void)moreBtnAction {
    if (self.moreClickCallBack) {
        self.moreClickCallBack();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

}

- (void)setTopicArr:(NSArray *)topicArr {
    _topicArr = topicArr;
    [self setScrollViewDataWithDataArr:_topicArr];
}

- (void)setScrollViewDataWithDataArr:(NSArray *) arr {
    
    [self.scrollView setContentOffset:CGPointMake(0, 0)];
    for (UIView *view in self.scrollView.subviews) {
        if ([view isKindOfClass:[YXTopicSingleView class]]) {
            [view removeFromSuperview];
        }
    }
    
    float width = YXConstant.screenWidth;
    NSInteger newsCount = arr.count > 4 ? 4 : arr.count;
    
    self.pageControl.numberOfPages = newsCount;
    self.pageControl.currentPage = 0;
    
    self.scrollView.contentSize = CGSizeMake(width * newsCount, 217);

    for (int i=0; i<newsCount; i++) {
        YXTopicSingleView *cardView = [[YXTopicSingleView alloc] init];
        [self.scrollView addSubview:cardView];

        cardView.frame = CGRectMake(i*width, 0, width, 217);
        YXHotTopicModel *model = arr[i];
        cardView.model = model;
        @weakify(self, cardView);
        [cardView setVoteCallBack:^(BOOL isFirst) {
            @strongify(self, cardView);
            if (self.voteCallBack) {
                NSString *voteId = @"";
                if (isFirst) {
                    voteId = model.vote.vote_item.firstObject.id;
                } else {
                    voteId = model.vote.vote_item.lastObject.id;
                }
                self.voteCallBack(model.topic_id?:@"", voteId, ^(BOOL isSuccess) {
                    if (isSuccess) {
                        model.vote.has_vote = YES;
                        if (isFirst) {
                            model.vote.vote_item.firstObject.count += 1;
                            model.vote.vote_item.firstObject.is_pick = YES;
                        } else {
                            model.vote.vote_item.lastObject.count += 1;
                            model.vote.vote_item.lastObject.is_pick = YES;
                        }
                        cardView.model = model;
                    }
                });
            }
        }];
        
        [cardView setClickCallBack:^{
            @strongify(self);
            if (self.topicClickCallBack) {
                self.topicClickCallBack(model.topic_id);
            }
        }];
                
        [cardView setStockClickCallBack:^(YXHotTopicStockModel * _Nonnull model) {
            @strongify(self);
            if (self.stockClickCallBack) {
                self.stockClickCallBack(model);
            }
        }];

    }
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = (NSInteger)(scrollView.contentOffset.x / scrollView.mj_w);
    self.pageControl.currentPage = index;
}



@end
