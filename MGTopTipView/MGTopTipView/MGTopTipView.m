//
//  MGTopTipView.m
//  MGTopTipView
//
//  Created by acmeway on 2017/8/10.
//  Copyright © 2017年 acmeway. All rights reserved.
//

#import "MGTopTipView.h"

#define MGSCREENWIDTH  [UIScreen mainScreen].bounds.size.width

@interface MGTopTipView ()
{
    CGFloat     _viewHeight;
}
@property (nonatomic, copy) NSString        *content;

@property (nonatomic, strong) UILabel       *contentLbl;

@property (nonatomic, strong) MGTopTipView  *topTipHUD;

@end

NSString *_contents;

@implementation MGTopTipView

static NSMutableDictionary *_tempDict;

+ (void)initialize
{
    _tempDict = [NSMutableDictionary dictionary];
}

+ (instancetype)showTopTipContent:(NSString *)content toView:(UIView *)view
{
   return  [self showTopTipContent:content backgroundColor:[UIColor brownColor] toView:view];
}

+ (instancetype)showTopTipContent:(NSString *)content backgroundColor:(UIColor *)color toView:(UIView *)view
{
    if (view == nil) view = [UIApplication sharedApplication].keyWindow;
    
    _contents = content;
    
    MGTopTipView *topTipHUD = _tempDict[@"TipView"];
    
    if (topTipHUD == nil)
    {
        MGTopTipView *topTipHUD = [MGTopTipView showHUDAddedTo:view animated:YES];
        
        _tempDict[@"TipView"] = topTipHUD;
        
        topTipHUD.backgroundColor = [UIColor brownColor];
        
        topTipHUD.content = content;
        
        return topTipHUD;
    }

    return topTipHUD;
}

+ (instancetype)showHUDAddedTo:(UIView *)view animated:(BOOL)animated
{
    MGTopTipView *topTipHUD = [[self alloc] init];
    
    [view addSubview:topTipHUD];
    
    [topTipHUD showAnimated:animated];
    
    return topTipHUD;
}

- (void)showAnimated:(BOOL)animated
{
    if (animated)
    {
        [UIView animateWithDuration:2.0f animations:^{
            
            self.frame = CGRectMake(0, 0, MGSCREENWIDTH, _viewHeight);
            
        } completion:^(BOOL finished) {
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                [UIView animateWithDuration:0.5 animations:^{
                    
                    self.frame = CGRectMake(0, -_viewHeight, MGSCREENWIDTH, _viewHeight);
                    
                } completion:^(BOOL finished) {
                    
                    [self removeFromSuperview];
                    
                    [_tempDict removeAllObjects];
                    
                    if ([self.delegate respondsToSelector:@selector(topTipViewDidAppear:)]) {
                        
                        [self.delegate topTipViewDidAppear:self];
                    }

                }];
            });
            
        }];
 
    }
    
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"]) {
        
        NSLog(@"self.frame.y = %f", self.frame.origin.y);
    }

}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        [self setupSubviews];
        
        [self addObserver:self
               forKeyPath:@"frame"
                  options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                  context:nil];
        
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.contentLbl];
    
    CGFloat txtHeight = [self heightWithFont:[UIFont systemFontOfSize:14]
                          constrainedToWidth:MGSCREENWIDTH - 30];
    
    _viewHeight = txtHeight + 30;
    
    self.frame = CGRectMake(0, -_viewHeight, MGSCREENWIDTH, _viewHeight);
    
    _contentLbl.frame = CGRectMake(17, 10, MGSCREENWIDTH - 17 * 2, _viewHeight - 10);
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    

}

- (void)setContent:(NSString *)content
{
    _content = content;
    
    NSMutableAttributedString *att = [[NSMutableAttributedString alloc] initWithString:content];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    
    style.lineSpacing = 5;
    
    [att addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, content.length)];
    
    self.contentLbl.attributedText = att;
    
    self.contentLbl.textAlignment = NSTextAlignmentCenter;
}

- (CGFloat)heightWithFont:(UIFont *)font constrainedToWidth:(CGFloat)width
{
    UIFont *textFont = font ? font : [UIFont systemFontOfSize:[UIFont systemFontSize]];
    
    CGSize textSize;
    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 70000
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)])
    {
        NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
        
        paragraph.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                     NSParagraphStyleAttributeName: paragraph};
        
        textSize = [self boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
    }
    else
    {
        textSize = [self sizeWithFont:textFont
                    constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)
                        lineBreakMode:NSLineBreakByWordWrapping];
    }
#else
    
    NSMutableParagraphStyle *paragraph = [[NSMutableParagraphStyle alloc] init];
    
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    
    paragraph.lineSpacing = 5;
    
    NSDictionary *attributes = @{NSFontAttributeName: textFont,
                                 NSParagraphStyleAttributeName: paragraph};
    
    textSize = [_contents boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                      options:(NSStringDrawingUsesLineFragmentOrigin |
                                               NSStringDrawingTruncatesLastVisibleLine)
                                   attributes:attributes
                                      context:nil].size;
#endif
    
    return ceil(textSize.height);
}

- (UILabel *)contentLbl
{
    if (!_contentLbl) {
        
        _contentLbl = [[UILabel alloc] init];
        
        _contentLbl.font = [UIFont systemFontOfSize:14];
        
        _contentLbl.textAlignment = NSTextAlignmentLeft;
        
        _contentLbl.numberOfLines = 0;
        
        _contentLbl.textColor = [UIColor redColor];
    }
    
    return _contentLbl;
}

- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"frame"];
}


@end
