//
//  YXTopicSingleView.m
//  uSmartOversea
//
//  Created by chenmingmao on 2020/9/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXTopicSingleView.h"
#import "YXHotTopicModel.h"
#import "YXTopicVoteBtn.h"
#import "uSmartOversea-Swift.h"
#import <Masonry/Masonry.h>
#import "YXTopicStockListView.h"

@interface YXTopicSingleVoteView: UIView

@property (nonatomic, strong) YXTopicVoteBtn *moreBtn;
@property (nonatomic, strong) YXTopicVoteBtn *lessBtn;

@property (nonatomic, strong) YXHotTopicVoteModel *voteModel;

@property (nonatomic, strong) QMUIButton *selectMoreBtn;
@property (nonatomic, strong) QMUIButton *selectLessBtn;

@property (nonatomic, strong) UILabel *moreLabel;
@property (nonatomic, strong) UILabel *lessLabel;

@end

@implementation YXTopicSingleVoteView


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

    [self addSubview:self.lessBtn];
    [self addSubview:self.moreBtn];
    [self addSubview:self.selectMoreBtn];
    [self addSubview: self.selectLessBtn];
    
    [self addSubview:self.moreLabel];
    [self addSubview:self.lessLabel];
    
    [self.moreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.height.mas_equalTo(25);
        make.top.equalTo(self).offset(2);
        make.width.mas_equalTo(0);
    }];
    
    [self.lessBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.height.mas_equalTo(25);
        make.centerY.equalTo(self.moreBtn);
        make.width.mas_equalTo(0);
    }];
    
    [self.selectMoreBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self.moreBtn.mas_bottom).offset(5);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(24);
    }];
    
    [self.selectLessBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.top.equalTo(self.lessBtn.mas_bottom).offset(5);
        make.width.mas_equalTo(180);
        make.height.mas_equalTo(24);
    }];
    
    [self.moreLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(14);
        make.centerY.equalTo(self.moreBtn);
        make.right.equalTo(self.moreBtn).offset(-10);
    }];
    
    [self.lessLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-14);
        make.centerY.equalTo(self.moreBtn);
        make.left.equalTo(self.lessBtn).offset(10);
    }];
    
    self.selectMoreBtn.hidden = YES;
    self.selectLessBtn.hidden = YES;
}

- (void)setVoteModel:(YXHotTopicVoteModel *)voteModel {
    _voteModel = voteModel;
    YXHotTopicVoteSubModel *first = voteModel.vote_item.firstObject;
    YXHotTopicVoteSubModel *last = voteModel.vote_item.lastObject;
    
    float width = (YXConstant.screenWidth - 40);
    
    if (voteModel.has_vote) {
        self.selectMoreBtn.hidden = NO;
        self.selectLessBtn.hidden = NO;

        self.selectMoreBtn.selected = first.is_pick;
        self.selectLessBtn.selected = last.is_pick;
        [self.selectLessBtn setTitle:[NSString stringWithFormat:@"%@", last.name] forState:UIControlStateNormal];
        
        // 计算比例
        int count = first.count + last.count;
        if (count > 0) {
            float firstRate = first.count / (float)count;
            float secontRate = 1 - firstRate;
            
            
            float firstWidthRato = firstRate;
            float lastWidthRato = secontRate;
            
            self.moreBtn.hidden = firstRate == 0;
            self.lessBtn.hidden = firstRate == 1.0;
            self.selectMoreBtn.hidden = firstRate == 0;
            self.selectLessBtn.hidden = firstRate == 1.0;
            
            if (firstRate == 0 || firstRate == 1.0) {
                firstWidthRato = firstRate;
                lastWidthRato = 1.0 - firstWidthRato;
                self.moreBtn.isFull = YES;
                self.lessBtn.isFull = YES;
            } else {
                if (firstRate < 0.35) {
                    firstWidthRato = 0.35;
                } else if (firstRate > 0.7) {
                    firstWidthRato = 0.7;
                }
                lastWidthRato = 1.1 - firstWidthRato;
            }

            [self.moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(width * firstWidthRato);
                make.height.mas_equalTo(first.is_pick ? 32 : 18);
            }];
            [self.lessBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(width * lastWidthRato);
                make.height.mas_equalTo(last.is_pick ? 32 : 18);
            }];
            float firstPercent = firstRate * 100;
            float secondPercent = 100 - firstPercent;
            self.moreLabel.text = [NSString stringWithFormat:@"%.2f%@", firstPercent, @"%"];
            self.lessLabel.text = [NSString stringWithFormat:@"%.2f%@", secondPercent, @"%"];
            
            if (first.is_pick) {
                [self bringSubviewToFront:self.moreBtn];
                [self bringSubviewToFront:self.moreLabel];
                [self.selectMoreBtn setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"topic_selected"], first.name] forState:UIControlStateNormal];
                self.moreLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
            } else {
                self.moreLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
                [self bringSubviewToFront:self.lessBtn];
                [self bringSubviewToFront:self.lessLabel];
                [self.selectMoreBtn setTitle:[NSString stringWithFormat:@"%@", first.name] forState:UIControlStateNormal];
            }
            
            if (last.is_pick) {
                self.lessLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightMedium];
                [self.selectLessBtn setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"topic_selected"], last.name] forState:UIControlStateNormal];
            } else {
                self.lessLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
                [self.selectLessBtn setTitle:[NSString stringWithFormat:@"%@", last.name] forState:UIControlStateNormal];
            }
        }
    } else {
        self.selectMoreBtn.hidden = YES;
        self.selectLessBtn.hidden = YES;
        self.moreLabel.text = first.name;
        self.lessLabel.text = last.name;
        self.moreLabel.font = [UIFont systemFontOfSize:14];
        self.lessLabel.font = [UIFont systemFontOfSize:14];
        
        [self.moreBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width * 0.5);
            make.height.mas_equalTo(32);
        }];
        [self.lessBtn mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(width * 0.5);
            make.height.mas_equalTo(32);
        }];
    }
    
    [self.moreBtn setNeedsDisplay];
    [self.lessBtn setNeedsDisplay];
}

#pragma mark - lazy load
- (YXTopicVoteBtn *)moreBtn {
    if (_moreBtn == nil) {
        _moreBtn = [[YXTopicVoteBtn alloc] init];
        _moreBtn.isLeft = YES;
        _moreBtn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        [_moreBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    return _moreBtn;
}

- (YXTopicVoteBtn *)lessBtn {
    if (_lessBtn == nil) {
        _lessBtn = [[YXTopicVoteBtn alloc] init];
        _lessBtn.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightMedium];
        [_lessBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    }
    return _lessBtn;
}

- (QMUIButton *)selectMoreBtn {
    if (_selectMoreBtn == nil) {
        _selectMoreBtn = [[QMUIButton alloc] init];
        _selectMoreBtn.userInteractionEnabled = NO;
        _selectMoreBtn.imagePosition = QMUIButtonImagePositionLeft;
        _selectMoreBtn.spacingBetweenImageAndTitle = 2;
        [_selectMoreBtn setImage:[UIImage imageNamed:@"topic_select_more"] forState:UIControlStateSelected];
        [_selectMoreBtn setTitleColor:[UIColor qmui_colorWithHexString:@"#555FEE"] forState:UIControlStateNormal];
        _selectMoreBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _selectMoreBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _selectMoreBtn;
}

- (QMUIButton *)selectLessBtn {
    if (_selectLessBtn == nil) {
        _selectLessBtn = [[QMUIButton alloc] init];
        _selectLessBtn.userInteractionEnabled = NO;
        _selectLessBtn.imagePosition = QMUIButtonImagePositionLeft;
        _selectLessBtn.spacingBetweenImageAndTitle = 2;
        [_selectLessBtn setImage:[UIImage imageNamed:@"topic_select_less"] forState:UIControlStateSelected];
        [_selectLessBtn setTitleColor:[UIColor qmui_colorWithHexString:@"#1CBE9C"] forState:UIControlStateNormal];
        _selectLessBtn.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
        _selectLessBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _selectLessBtn;
}

- (UILabel *)moreLabel {
    if (_moreLabel == nil) {
        _moreLabel = [UILabel labelWithText:@"" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:14]];
    }
    return _moreLabel;
}

- (UILabel *)lessLabel {
    if (_lessLabel == nil) {
        _lessLabel = [UILabel labelWithText:@"" textColor:UIColor.whiteColor textFont:[UIFont systemFontOfSize:14]];
        _lessLabel.textAlignment = NSTextAlignmentRight;
    }
    return _lessLabel;
}

@end



@interface YXTopicSingleCommentView: UIView

@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) QMUILabel *contentLabel;

@property (nonatomic, strong) YXHotTopicCommentModel *commentModel;

@end

@implementation YXTopicSingleCommentView


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
    [self addSubview:self.contentLabel];
    [self addSubview:self.iconView];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(32);
        make.left.equalTo(self);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(26);
        make.left.equalTo(self).offset(11);
        make.centerY.equalTo(self);
        make.right.lessThanOrEqualTo(self);
    }];
}

- (void)setCommentModel:(YXHotTopicCommentModel *)commentModel {
    _commentModel = commentModel;
    self.contentLabel.text = commentModel.content;
    if ([commentModel.head_image hasPrefix:@"http"]) {
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:commentModel.head_image] placeholderImage:[UIImage imageNamed:@"user_default_photo"]];
    }
}

#pragma mark - lazy load
- (UIImageView *)iconView {
    if (_iconView == nil) {
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 16;
        _iconView.clipsToBounds = YES;
        _iconView.image = [UIImage imageNamed:@"user_default_photo"];
        _iconView.backgroundColor = UIColor.whiteColor;
    }
    return _iconView;
}

- (QMUILabel *)contentLabel {
    if (_contentLabel == nil) {
        _contentLabel = (QMUILabel *)[QMUILabel labelWithText:@"" textColor:QMUITheme.textColorLevel2 textFont:[UIFont systemFontOfSize:14]];
        _contentLabel.numberOfLines = 1;
        _contentLabel.contentEdgeInsets = UIEdgeInsetsMake(0, 31, 0, 10);
        _contentLabel.layer.cornerRadius = 13;
        _contentLabel.clipsToBounds = YES;
        _contentLabel.backgroundColor = [UIColor qmui_colorWithHexString:@"#EDEDED"];
    }
    return _contentLabel;
}

@end

@interface YXTopicSingleView ()

@property (nonatomic, strong) YYLabel *titleLabel;

@property (nonatomic, strong) YXTopicSingleVoteView *voteView;
@property (nonatomic, strong) UIStackView *commentView;

@property (nonatomic, strong) QMUIButton *commentCountBtn;

@property (nonatomic, strong) YXTopicStockListView *stockListView;

@property (nonatomic, strong) UIImageView *tagImageView;

@end

@implementation YXTopicSingleView


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
    
    self.backgroundColor = UIColor.whiteColor;
    
    [self addSubview:self.tagImageView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.commentView];
    [self addSubview:self.voteView];
    [self addSubview:self.commentCountBtn];
    [self addSubview:self.stockListView];
    
    
    [self.tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(7);
        make.top.equalTo(self).offset(4);
        make.width.height.mas_equalTo(40);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tagImageView.mas_right).offset(5);
        make.top.equalTo(self).offset(0);
        make.right.equalTo(self).offset(-14);
        make.height.mas_equalTo(48);
    }];
    
    [self.commentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(18);
        make.right.equalTo(self).offset(-18);
        make.bottom.equalTo(self).offset(-65);
    }];
    
    [self.voteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(20);
        make.right.equalTo(self).offset(-20);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.height.mas_equalTo(65);
    }];
    
    [self.commentCountBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-13);
        make.bottom.equalTo(self).offset(-50);
        make.height.mas_equalTo(20);
    }];
    
    [self.stockListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.height.mas_equalTo(17);
        make.bottom.equalTo(self).offset(-29);
    }];
    
    @weakify(self);
    [[self.voteView.moreBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.model.vote.has_vote) {
            return;
        }
        if (self.voteCallBack) {
            self.voteCallBack(YES);
        }
        
    }];
    [[self.voteView.lessBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        if (self.model.vote.has_vote) {
            return;
        }
        if (self.voteCallBack) {
            self.voteCallBack(NO);
        }
    }];
    
    [self.stockListView setStockClickCallBack:^(YXHotTopicStockModel * _Nonnull model) {
        @strongify(self);
        if (self.stockClickCallBack) {
            self.stockClickCallBack(model);
        }
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick:)];
    [self addGestureRecognizer:tap];
}

- (void)setModel:(YXHotTopicModel *)model {
    _model = model;
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:model.topic_title];
    att.yy_font = [UIFont systemFontOfSize:16];
    att.yy_color = [UIColor qmui_colorWithHexString:@"#000000"];
    att.yy_lineSpacing = 6;
    
    if ([model.tag.tag_addr hasPrefix:@"http"]) {
        [self.tagImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(40);
        }];
        [self.tagImageView sd_setImageWithURL:[NSURL URLWithString:model.tag.tag_addr]];
    } else {
        [self.tagImageView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(0);
        }];
    }

    self.titleLabel.attributedText = att;
    
    self.stockListView.list = model.stock_list;
    
    if (model.vote.vote_item.count == 2) {
        // 显示投票
        self.voteView.hidden = NO;
        self.voteView.voteModel = model.vote;
    } else {
        // 隐藏投票
        self.voteView.hidden = YES;
    }
        
    for (UIView *view in self.commentView.arrangedSubviews) {
        [view removeFromSuperview];
    }
    
    NSInteger commontCount = model.comment.count;
    if (!self.voteView.hidden && commontCount > 1) {
        commontCount = 1;
    }
    
    if (commontCount > 2) {
        commontCount = 2;
    }
    
    for (int i = 0; i < commontCount; ++i) {
        YXTopicSingleCommentView *view = [[YXTopicSingleCommentView alloc] init];
        YXHotTopicCommentModel *commentModel = model.comment[i];
        view.commentModel = commentModel;
        [view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(40);
        }];
        [self.commentView addArrangedSubview:view];
    }
    
    if (model.comment_count > 0) {
        [self.commentCountBtn setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"topic_veiew_all_messages"], @(model.comment_count)] forState:UIControlStateNormal];
    } else {

        [self.commentCountBtn setTitle:[NSString stringWithFormat:[YXLanguageUtility kLangWithKey:@"topic_veiew_all_messages"], @""] forState:UIControlStateNormal];
    }
}


- (void)commentCountBtnClick: (UIButton *)sender {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}

- (void)tapClick: (UITapGestureRecognizer *)sender {
    if (self.clickCallBack) {
        self.clickCallBack();
    }
}

#pragma mark - lazy load
- (YYLabel *)titleLabel {
    if (_titleLabel == nil) {
        _titleLabel = [[YYLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textColor = [UIColor qmui_colorWithHexString:@"#000000"];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textVerticalAlignment = YYTextVerticalAlignmentCenter;
    }
    return _titleLabel;
}

- (YXTopicSingleVoteView *)voteView {
    if (_voteView == nil) {
        _voteView = [[YXTopicSingleVoteView alloc] init];
        _voteView.hidden = NO;
    }
    return _voteView;
}

- (UIStackView *)commentView {
    if (_commentView == nil) {
        _commentView = [[UIStackView alloc] init];
        _commentView.axis = UILayoutConstraintAxisVertical;
        _commentView.distribution = UIStackViewDistributionFill;
    }
    return _commentView;
}

- (UIImageView *)tagImageView {
    if (_tagImageView == nil) {
        _tagImageView = [[UIImageView alloc] init];
        _tagImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _tagImageView;
}

- (QMUIButton *)commentCountBtn {
    if (_commentCountBtn == nil) {
        _commentCountBtn = [QMUIButton buttonWithType:UIButtonTypeCustom title:@"" font:[UIFont systemFontOfSize:11] titleColor:QMUITheme.textColorLevel3 target:self action:@selector(commentCountBtnClick:)];
        [_commentCountBtn setImage:[UIImage imageNamed:@"icons_news_more"] forState:UIControlStateNormal];
        _commentCountBtn.imagePosition = QMUIButtonImagePositionRight;
        _commentCountBtn.spacingBetweenImageAndTitle = 8;
    }
    return _commentCountBtn;
}

- (YXTopicStockListView *)stockListView {
    if (_stockListView == nil) {
        _stockListView = [[YXTopicStockListView alloc] init];
    }
    return _stockListView;
}

@end
