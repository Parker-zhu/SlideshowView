//
//  SlideshowView.h
//  Slideshow
//
//  Created by 朱晓峰 on 2018/1/7.
//  Copyright © 2018年 朱晓峰. All rights reserved.
//  轮播图

#import <UIKit/UIKit.h>

@class SlideshowView;
@protocol SlideshowViewDelegate <NSObject>

-(void)slideshowView:(SlideshowView *)slideshowView didSelectedIndex:(NSInteger)index;

@end

@interface SlideshowView : UIView

//轮播图滚动时间
@property(nonatomic,assign)NSTimeInterval time;
//加载本地图片
@property(nonatomic,strong)NSArray * localImages;
//加载网络图片
@property(nonatomic,strong)NSArray * urlImages;
//当前展示的图片index
@property(nonatomic,assign,readonly)NSInteger currentIndex;

//代理
@property(nonatomic,weak)id<SlideshowViewDelegate> delegate;

//是否自动滚动，默认为YES
@property(nonatomic,assign)BOOL autoScroll;
// 当前小圆点的颜色
@property (strong, nonatomic) UIColor *currentPageColor;
// 其余小圆点的颜色
@property (strong, nonatomic) UIColor *pageColor;
// 是否显示pageControl
@property (nonatomic, assign, getter=isShowPageControl) BOOL showPageControl;

/// 设置小圆点的图片
- (void)setPageImage:(UIImage *)image currentPageImage:(UIImage *)currentImage;

//加载本地图片
+(SlideshowView *)slideshowViewWithFrame:(CGRect)frame LocalImages:(NSArray<NSString *> *)imageNames;
//加载网络图片
+(SlideshowView *)slideshowViewWithFrame:(CGRect)frame urlImages:(NSArray<NSString *> *)imageNames;

@end
