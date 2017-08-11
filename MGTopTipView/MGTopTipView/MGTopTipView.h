//
//  MGTopTipView.h
//  MGTopTipView
//
//  Created by acmeway on 2017/8/10.
//  Copyright © 2017年 acmeway. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class MGTopTipView;
@protocol MGTopTipViewDelegate <NSObject>

@optional
/**
 落幕消失后代理

 @param topTipView topTipView
 */
- (void)topTipViewDidAppear:(MGTopTipView *)topTipView;

@end

@interface MGTopTipView : UIView

@property (nonatomic, assign) id <MGTopTipViewDelegate> delegate;


/**
 初始化

 @param content 落幕内容
 @param view 显示在指定view上
 @return 对象
 */
+ (instancetype)showTopTipContent:(NSString *)content toView:(UIView *)view;



/**
 初始化

 @param content 落幕内容
 @param color 落幕背景色
 @param view 显示在指定view上
 @return 对象
 */
+ (instancetype)showTopTipContent:(NSString *)content backgroundColor:(UIColor *)color toView:(UIView *)view;

@end
