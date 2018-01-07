//
//  SlideshowView.m
//  Slideshow
//
//  Created by 朱晓峰 on 2018/1/7.
//  Copyright © 2018年 朱晓峰. All rights reserved.
//

#import "SlideshowView.h"
#import <objc/runtime.h>
#define  kWidth  self.bounds.size.width
#define  kHeight self.bounds.size.height

@interface SlideshowView () <UIScrollViewDelegate>

@property(strong, nonatomic) UIScrollView *scrollView;
@property(strong, nonatomic) UIPageControl *pageControl;

// 前一个视图,当前视图,下一个视图
@property(strong, nonatomic) UIImageView *lastImgView;
@property(strong, nonatomic) UIImageView *currentImgView;
@property(strong, nonatomic) UIImageView *nextImgView;

@property(strong, nonatomic) NSTimer *timer;
@property(nonatomic,strong)NSArray * images;

@end

@implementation SlideshowView

#pragma mark - 初始化方法
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _time = 2;
    _autoScroll = YES;
    _pageColor = [UIColor grayColor];
    _currentPageColor = [UIColor whiteColor];
}

#pragma mark - Public Method
// 如果是本地图片调用此方法
+(SlideshowView *)slideshowViewWithFrame:(CGRect)frame LocalImages:(NSArray<NSString *> *)imageNames{
    SlideshowView *slideshowView =[[SlideshowView alloc] initWithFrame:frame];
    // 调用set方法
    slideshowView.localImages = imageNames;
    return slideshowView;
}

// 如果是网络图片调用此方法
+(SlideshowView *)slideshowViewWithFrame:(CGRect)frame urlImages:(NSArray<NSString *> *)imageNames{
    SlideshowView *slideshowView =[[SlideshowView alloc] initWithFrame:frame];
    // 调用set方法
    slideshowView.urlImages = imageNames;
    return slideshowView;
}

// 开启定时器
- (void)openTimer {
    // 开启之前一定要先将上一次开启的定时器关闭,否则会跟新的定时器重叠
    [self closeTimer];
    if (_autoScroll) {
        //这种方式创建定时器需要手动添加runloop
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.time target:self selector:@selector(timerAction) userInfo:self repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSRunLoopCommonModes];
    }
}
// 关闭定时器
- (void)closeTimer {
    [_timer invalidate];
    _timer = nil;
}
// timer事件
-(void)timerAction{
    // 定时器每次触发都让当前图片为轮播图的第三张ImageView的image
    [_scrollView setContentOffset:CGPointMake(kWidth*2, 0) animated:YES];
}

-(void)configure{
    [self addSubview:self.scrollView];
    // 添加最初的三张imageView
    [self.scrollView addSubview:self.lastImgView];
    [self.scrollView addSubview:self.currentImgView];
    [self.scrollView addSubview:self.nextImgView];
    [self addSubview:self.pageControl];
    
    // 将上一张图片设置为数组中最后一张图片
    [self setImageView:_lastImgView withSubscript:(_kImageCount-1)];
    // 将当前图片设置为数组中第一张图片
    [self setImageView:_currentImgView withSubscript:0];
    // 将下一张图片设置为数组中第二张图片,如果数组只有一张图片，则上、中、下图片全部是数组中的第一张图片
    [self setImageView:_nextImgView withSubscript:_kImageCount == 1 ? 0 : 1];
    
    _scrollView.contentSize = CGSizeMake(kWidth * 3, kHeight);
    //显示中间的图片
    _scrollView.contentOffset = CGPointMake(kWidth, 0);
    
    if (!_pageControl.hidden) {
        _pageControl.numberOfPages = self.kImageCount;
    }
    _pageControl.currentPage = 0;
    
    self.nextPhotoIndex = 1;
    self.lastPhotoIndex = _kImageCount - 1;
    
    [self layoutIfNeeded];
}
#pragma mark - scrollView代理方法
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    // 到第一张图片时   (一上来，当前图片的x值是kWidth)
    if (ceil(scrollView.contentOffset.x) <= 0) {  // 右滑
        _nextImgView.image = _currentImgView.image;
        _currentImgView.image = _lastImgView.image;
        // 将轮播图的偏移量设回中间位置
        scrollView.contentOffset = CGPointMake(kWidth, 0);
        _lastImgView.image = nil;
        // 一定要是小于等于，否则数组中只有一张图片时会出错
        if (_lastPhotoIndex <= 0) {
            _lastPhotoIndex = _kImageCount - 1;
            _nextPhotoIndex = _lastPhotoIndex - (_kImageCount - 2);
        } else {
            _lastPhotoIndex--;
            if (_nextPhotoIndex == 0) {
                _nextPhotoIndex = _kImageCount - 1;
            } else {
                _nextPhotoIndex--;
            }
        }
        [self setImageView:_lastImgView withSubscript:_lastPhotoIndex];
    }
    // 到最后一张图片时（最后一张就是轮播图的第三张）
    if (ceil(scrollView.contentOffset.x)  >= kWidth*2) {  // 左滑
        _lastImgView.image = _currentImgView.image;
        _currentImgView.image = _nextImgView.image;
        // 将轮播图的偏移量设回中间位置
        scrollView.contentOffset = CGPointMake(kWidth, 0);
        _nextImgView.image = nil;
        // 一定要是大于等于，否则数组中只有一张图片时会出错
        if (_nextPhotoIndex >= _kImageCount - 1 ) {
            _nextPhotoIndex = 0;
            _lastPhotoIndex = _nextPhotoIndex + (_kImageCount - 2);
        } else{
            _nextPhotoIndex++;
            if (_lastPhotoIndex == _kImageCount - 1) {
                _lastPhotoIndex = 0;
            } else {
                _lastPhotoIndex++;
            }
        }
        [self setImageView:_nextImgView withSubscript:_nextPhotoIndex];
    }
    
    if (_nextPhotoIndex - 1 < 0) {
        self.pageControl.currentPage = _kImageCount - 1;
    } else {
        self.pageControl.currentPage = _nextPhotoIndex - 1;
    }
}

// 用户将要拖拽时将定时器关闭
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    // 关闭定时器
    [self closeTimer];
}

// 用户结束拖拽时将定时器开启(在打开自动轮播的前提下)
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (self.autoScroll) {
        [self openTimer];
    }
}

#pragma mark - 手势点击事件
-(void)handleTapActionInImageView:(UITapGestureRecognizer *)tap {
    if (self.clickedImageBlock) {
        // 如果_nextPhotoIndex == 0,那么中间那张图片一定是数组中最后一张，我们要传的就是中间那张图片在数组中的下标
        if (_nextPhotoIndex == 0) {
            self.clickedImageBlock(_kImageCount-1);
        }else{
            self.clickedImageBlock(_nextPhotoIndex-1);
        }
    } else if (_delegate && [_delegate respondsToSelector:@selector(slideshowView:didSelectedIndex:)]) {
        // 如果_nextPhotoIndex == 0,那么中间那张图片一定是数组中最后一张，我们要传的就是中间那张图片在数组中的下标
        if (_nextPhotoIndex == 0) {
            [_delegate carouselView:self clickedImageAtIndex:_kImageCount-1];
        }else{
            [_delegate carouselView:self clickedImageAtIndex:_nextPhotoIndex-1];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = self.bounds;
    // 重新设置contentOffset和contentSize对于轮播图下拉放大以及里面的图片跟随放大起着关键作用，因为scrollView放大了，如果不手动设置contentOffset和contentSize，则会导致scrollView的容量不够大，从而导致图片越出scrollview边界的问题
    self.scrollView.contentSize = CGSizeMake(kWidth * 3, kHeight);
    // 这里如果采用动画效果设置偏移量将不起任何作用
    self.scrollView.contentOffset = CGPointMake(kWidth, 0);
    
    self.lastImgView.frame = CGRectMake(0, 0, kWidth, kHeight);
    self.currentImgView.frame = CGRectMake(kWidth, 0, kWidth, kHeight);
    self.nextImgView.frame = CGRectMake(kWidth * 2, 0, kWidth, kHeight);
    
    // 等号左边是掉setter方法，右边调用getter方法
    self.pageControlPosition = self.pageControlPosition;
    
}

#pragma mark - 懒加载
-(UIScrollView *)scrollView{
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.clipsToBounds = YES;
        _scrollView.layer.masksToBounds = YES;
    }
    return _scrollView;
}

-(UIPageControl *)pageControl{
    if (_pageControl == nil) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.hidesForSinglePage = YES;
        _pageControl.pageIndicatorTintColor = self.pageColor;
        _pageControl.currentPageIndicatorTintColor = self.currentPageColor;
        _pageControl.currentPage = 0;
        //获取初始化时系统内部调用的属性
        unsigned int count=0;
        Ivar *ivars= class_copyIvarList([_pageControl class], &count);
        for (int i=0; i<count; i++) {
            Ivar iva=*(ivars+i);
            ivar_getName(iva);
            NSLog(@"%s",ivar_getName(iva));
        }
    }
    return _pageControl;
}

-(UIImageView *)lastImgView{
    if (_lastImgView == nil) {
        _lastImgView = [self loadImageView];
    }
    return _lastImgView;
}

-(UIImageView *)currentImgView{
    if (_currentImgView == nil) {
        _currentImgView = [self loadImageView];
        // 给当前图片添加手势
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapActionInImageView:)];
        [_currentImgView addGestureRecognizer:tap];
        _currentImgView.userInteractionEnabled = YES;
    }
    return _currentImgView;
}

-(UIImageView *)nextImgView{
    if (_nextImgView == nil) {
        _nextImgView = [self loadImageView];
    }
    return _nextImgView;
}

-(UIImageView *)loadImageView{
    UIImageView * imageView = [[UIImageView alloc] init];
    imageView.layer.masksToBounds = YES;
    imageView.backgroundColor = [UIColor grayColor];
    return imageView;
}

#pragma mark - 系统方法
-(void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [self closeTimer];
    }
}

-(void)dealloc {
    NSLog(@"dealloc");
    _scrollView.delegate = nil;
}

@end
