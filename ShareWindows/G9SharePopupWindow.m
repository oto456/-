//
//  G9SharePopupWindow.m
//  ShareWindows
//
//  Created by kakapo on 15/7/29.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import "G9SharePopupWindow.h"
#import "G9shareBaseActivity.h"
#import "UIImage+REFrosted.h"
#import "UIView+REFrosted.h"

static const CGFloat LogoImgWidth = 60.0;
static const CGFloat LogoImgHeight = LogoImgWidth;
static const CGFloat LogoTopSpace = 15;
static const CGFloat LogoTitleSpace = 7;
static const CGFloat LogoVerticalSpace = 10;
static const CGFloat TitleLabelHeight = 11;
static const CGFloat IndicateHeight = 5;
static const CGFloat IndicateButtomSpace = 5;
static const CGFloat BottomViewSpace = 45;
static const CGFloat CancelButtonWidth = 30;
static const CGFloat CancelButtonHeight = CancelButtonWidth;

static const CGFloat MaskViewHeight = 251;

static const NSTimeInterval ItemAnimationInterval = 0.04;
static const NSTimeInterval ItemDuration = 0.4;

#define ScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define ScreenHeight ([UIScreen mainScreen].bounds.size.height)
#define LogoHorizonSpace ((ScreenWidth - 3 * LogoImgWidth)/4)

#define RGB(c,a) [UIColor colorWithRed:((c>>16)&0xFF)/256.0  green:((c>>8)&0xFF)/256.0   blue:((c)&0xFF)/256.0   alpha:a]

CGSize ItemSize(){
    return (CGSize){LogoImgWidth, LogoImgHeight + LogoTitleSpace + TitleLabelHeight};
};

@interface G9SharePopupWindow () <UIScrollViewDelegate>

@property (nonatomic, strong) NSMutableArray *itemList;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIButton *btn_cancel;
@property (nonatomic, strong) NSMutableArray *scrollviewsArray;
@property (nonatomic, strong) UIImageView *blurBackGround;
@property (nonatomic, strong) UIView *interateView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIView *buttonContainer;
@property (nonatomic, assign) NSInteger currentIndex;

@end

@implementation G9SharePopupWindow


#pragma mark - public method

- (instancetype)initWithASharedActivity:(NSArray *)shareActivity actionActivities:(NSArray *)actionActivities
{
    if (self = [self initWithFrame:[UIScreen mainScreen].bounds]){
        _itemList = [[NSMutableArray alloc] init];
        for (G9shareBaseActivity *item in shareActivity) {
            [_itemList addObject:item];
        }
        for (G9shareBaseActivity *item in actionActivities) {
            [_itemList addObject:item];
        }
        [self configAllUI];
    }
    return self;
}

- (void)show
{

    
    NSInteger ItemInPageCount = MIN(6, self.itemList.count);
    NSTimeInterval totalTime = (ItemInPageCount - 1) * ItemAnimationInterval + ItemDuration;
    self.pageControl.currentPage = 0;
    
    void (^showBlock)() = ^{
        for (int i=0; i < ItemInPageCount; i++) {
            ((G9shareBaseActivity *)_itemList[i]).center = (CGPoint){((G9shareBaseActivity *)_itemList[i]).center.x, ((G9shareBaseActivity *)_itemList[i]).center.y + MaskViewHeight};
            [UIView animateWithDuration:ItemDuration delay:(i * ItemAnimationInterval) usingSpringWithDamping:0.7 initialSpringVelocity:1.0 options:UIViewAnimationOptionCurveLinear animations:^{
                ((G9shareBaseActivity *)_itemList[i]).center = (CGPoint){((G9shareBaseActivity *)_itemList[i]).center.x, ((G9shareBaseActivity *)_itemList[i]).center.y - MaskViewHeight};
            } completion:nil];
        }
        self.interateView.alpha = 0.0;
        [UIView animateWithDuration:totalTime animations:^{
            self.interateView.alpha = 1;
        }];
        [_btn_cancel.layer removeAllAnimations];
        CABasicAnimation *rotationAnimation;
        rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        rotationAnimation.toValue = [NSNumber numberWithFloat:M_PI];
        rotationAnimation.duration = 0.4;
        rotationAnimation.cumulative = YES;
        rotationAnimation.fillMode=kCAFillModeForwards;
        rotationAnimation.removedOnCompletion = NO;
        [_btn_cancel.layer addAnimation:rotationAnimation forKey:@"totation"];
    };
    
    __block UIImage *image;
    image = [[UIApplication sharedApplication].keyWindow re_screenshot];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        image = [image re_applyBlurWithRadius:7.0
                                    tintColor:[UIColor colorWithWhite:1 alpha:0.85f]
                        saturationDeltaFactor:1.8
                                    maskImage:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.blurBackGround setImage:image];
            [self makeKeyAndVisible];
            showBlock();
        });
    });
}

#pragma mark - lifeCircle




#pragma mark - private method
- (void)dismissWithAnimation
{
    [_btn_cancel.layer removeAllAnimations];
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: -M_PI];
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.fillMode=kCAFillModeForwards;
    rotationAnimation.removedOnCompletion = NO;
    [_btn_cancel.layer addAnimation:rotationAnimation forKey:@"totation"];
    
    NSInteger ItemInPageCount = MIN(6, self.itemList.count);
    NSTimeInterval totalTime = (ItemInPageCount - 1) * ItemAnimationInterval + ItemDuration;
    for (int i=0; i < MIN(6, _itemList.count - _currentIndex * ItemInPageCount); i++) {
        [UIView animateWithDuration:ItemDuration delay:((ItemInPageCount - 1 -i) * ItemAnimationInterval) usingSpringWithDamping:0.8 initialSpringVelocity:0.8 options:UIViewAnimationOptionCurveLinear animations:^{
            ((G9shareBaseActivity *)_itemList[i+_currentIndex * ItemInPageCount]).center = (CGPoint){((G9shareBaseActivity *)_itemList[i+_currentIndex * ItemInPageCount]).center.x, ((G9shareBaseActivity *)_itemList[i + _currentIndex * ItemInPageCount]).center.y + MaskViewHeight};
        } completion:nil];
    }
    
    [UIView animateWithDuration:totalTime animations:^{
        self.interateView.alpha = 0;
        self.blurBackGround.alpha = 0;
        self.buttonContainer.alpha = 0;
        self.pageControl.alpha = 0;
    } completion:^(BOOL finished) {
        for (int i; i < ItemInPageCount; i++) {
            ((G9shareBaseActivity *)_itemList[i]).center = (CGPoint){((G9shareBaseActivity *)_itemList[i]).center.x, ((G9shareBaseActivity *)_itemList[i]).center.y - MaskViewHeight};
        }
        [self resignKeyWindow];
        [self setHidden:YES];
        [[UIApplication sharedApplication].keyWindow makeKeyAndVisible];
    }];
}

- (void)configAllUI
{
    [self configInteratieView];
    [self configMaskView];
    [self configScrollView];
    [self.maskView bringSubviewToFront:_buttonContainer];
    [self.maskView bringSubviewToFront:_pageControl];
}

- (void)configInteratieView
{
    self.interateView = [[UIView alloc] initWithFrame:self.bounds];
    [self.interateView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonClick:)]];
    self.interateView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.5];
    [self addSubview:self.interateView];
}

- (void)cancelButtonClick:(id)sender
{
    [self dismissWithAnimation];
}

- (void)configScrollView
{
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.frame = (CGRect){0, 0, ScreenWidth, MaskViewHeight};
    _scrollView.contentSize = (CGSize){(1 + _itemList.count/6) * ScreenWidth, MaskViewHeight};
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.clipsToBounds = YES;
    [self.maskView addSubview:_scrollView];
    for (int i=0; i < _itemList.count; i++) {
        CGFloat x = LogoHorizonSpace + (i % 3) * (LogoHorizonSpace + LogoImgWidth) + (ScreenWidth) * (i / 6);
        NSInteger row = (i / 3) % 2;
        CGFloat y = LogoTopSpace + (((G9shareBaseActivity *)_itemList[i]).bounds.size.height + LogoVerticalSpace) * row;
        ((G9shareBaseActivity *)_itemList[i]).frame = (CGRect){x, y, ((G9shareBaseActivity *)_itemList[i]).bounds.size};
        ((G9shareBaseActivity *)_itemList[i]).block = ^(){
            [self dismissWithAnimation];
        };
        [_scrollView addSubview:((G9shareBaseActivity *)_itemList[i])];
    }

    
    _pageControl = [[UIPageControl alloc] initWithFrame:(CGRect){0, MaskViewHeight - BottomViewSpace - IndicateButtomSpace -IndicateHeight, ScreenWidth, 20}];
    self.pageControl.currentPageIndicatorTintColor = RGB(0x99999, 1.0);
    self.pageControl.pageIndicatorTintColor = RGB(0xdbdbdb, 0.3);
    self.pageControl.numberOfPages = _itemList.count/6 + 1;
    self.pageControl.userInteractionEnabled = NO;
    [self.maskView addSubview:_pageControl];
}

- (void)configMaskView
{
    _maskView = [[UIView alloc] initWithFrame:(CGRect){0, ScreenHeight - MaskViewHeight, ScreenWidth, MaskViewHeight}];
    _maskView.backgroundColor = [UIColor clearColor];
    _maskView.clipsToBounds = YES;
    [self addSubview:_maskView];
    
    _blurBackGround = [[UIImageView alloc] initWithFrame:(CGRect){0, - (ScreenHeight - MaskViewHeight), ScreenWidth, ScreenHeight}];
    [self.maskView addSubview:_blurBackGround];
    
    _buttonContainer = [[UIView alloc] initWithFrame:(CGRect){-2, MaskViewHeight - BottomViewSpace, ScreenWidth+4, BottomViewSpace+2}];
    _buttonContainer.backgroundColor = [UIColor clearColor];
    _buttonContainer.layer.borderColor = [RGB(0xdddddd, 1.0) CGColor];
    _buttonContainer.layer.borderWidth = 2;
    [self.maskView addSubview:_buttonContainer];
    
    _btn_cancel = [[UIButton alloc] initWithFrame:(CGRect){0, 0, CancelButtonWidth, CancelButtonHeight}];
    [_btn_cancel addTarget:self action:@selector(cancelButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btn_cancel setImage:[UIImage imageNamed:@"close"] forState:UIControlStateNormal];
    _btn_cancel.center = (CGPoint){_buttonContainer.bounds.size.width/2, _buttonContainer.bounds.size.height/2};
    [_buttonContainer addSubview:self.btn_cancel];
    [self.maskView addSubview:_buttonContainer];
}



#pragma mark - ScrollViewDelegate

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    int now = (int)round((scrollView.contentOffset.x / self.scrollView.frame.size.width));
    _currentIndex = now;
    _pageControl.currentPage = now;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    int now = (int)round((scrollView.contentOffset.x / self.scrollView.frame.size.width));
    _currentIndex = now;
    _pageControl.currentPage = now;
}


@end
