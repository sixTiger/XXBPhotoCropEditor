//
//  PWSocialAmazingCropperVC.m
//  XXBPhotoCropEditorDemo
//
//  Created by xiaobing on 2017/10/6.
//  Copyright © 2017年 xiaobing. All rights reserved.
//

#import "XXBPhotoCropEditorController.h"

#define BOUNDCE_DURATION 0.3f
#define XXBPhotoCropEditorControllerMargin 20

@interface XXBPhotoCropEditorController ()
@property (nonatomic, assign) CGRect            cropFrame;
/**
 *  原始图片
 */
@property (nonatomic, retain) UIImage           *originalImage;
/**
 *  编辑之后的图片
 */
@property (nonatomic, retain) UIImage           *editedImage;

@property (nonatomic, retain) UIImageView       *showImgView;
@property (nonatomic, retain) UIView            *overlayView;
@property (nonatomic, retain) UIView            *ratioView;

@property (nonatomic, assign) CGRect            oldFrame;
@property (nonatomic, assign) CGRect            largeFrame;
@property (nonatomic, assign) CGFloat           limitRatio;

@property (nonatomic, assign) CGRect            latestFrame;

@property(nonatomic ,weak) UIView               *coverView ;
@end

@implementation XXBPhotoCropEditorController
- (void)dealloc {
    self.originalImage = nil;
    self.showImgView = nil;
    self.editedImage = nil;
    self.overlayView = nil;
    self.ratioView = nil;
}

- (instancetype)initWithImage:(UIImage *)originalImage {
    return [self initWithImage:originalImage limitScaleRatio:[UIScreen mainScreen].scale];
}

- (instancetype)initWithImage:(UIImage *)originalImage limitScaleRatio:(NSInteger)limitRatio {
    CGFloat x = 0;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = width;
    CGFloat y = ([UIScreen mainScreen].bounds.size.height - height) * 0.5;
    CGRect cropFrame = CGRectMake(x, y, width, height);
    return [self initWithImage:originalImage cropFrame:cropFrame limitScaleRatio:limitRatio];
}

- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio {
    if (self = [super init]) {
        self.cropFrame = cropFrame;
        self.limitRatio = limitRatio;
        self.originalImage = [self fixOrientation:originalImage];;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    [self initButton];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return NO;
}

/**
 *  初始化view
 */
- (void)initView {
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    /**
     *  存放原始图片的额view
     */
    self.showImgView = [[UIImageView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.showImgView.backgroundColor = [UIColor redColor];
    [self.showImgView setMultipleTouchEnabled:YES];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setImage:self.originalImage];
    [self.showImgView setUserInteractionEnabled:YES];
    [self.showImgView setMultipleTouchEnabled:YES];
    
    // 等比例缩放图片，让图片的宽度或者高度刚好填充屏幕
    CGSize imageSize = self.originalImage.size;
    CGSize cropSize = self.cropFrame.size;
    CGFloat oriWidth;
    CGFloat oriHeight ;
    CGFloat oriX;
    CGFloat oriY;
    if (imageSize.width/imageSize.height >= cropSize.width/cropSize.height) {
        oriHeight = cropSize.height;
        oriWidth = self.originalImage.size.width * (oriHeight / self.originalImage.size.height);
        oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
        oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    } else {
        oriWidth = self.cropFrame.size.width;
        oriHeight = self.originalImage.size.height * (oriWidth / self.originalImage.size.width);
        oriX = self.cropFrame.origin.x + (self.cropFrame.size.width - oriWidth) / 2;
        oriY = self.cropFrame.origin.y + (self.cropFrame.size.height - oriHeight) / 2;
    }
    self.oldFrame = CGRectMake(oriX, oriY, oriWidth, oriHeight);
    self.latestFrame = self.oldFrame;
    self.showImgView.frame = self.oldFrame;
    
    self.largeFrame = CGRectMake(0, 0, self.limitRatio * self.oldFrame.size.width, self.limitRatio * self.oldFrame.size.height);
    
    [self addGestureRecognizers];
    [self.view addSubview:self.showImgView];
    /**
     *  半透明遮盖层的
     */
    self.overlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.overlayView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    self.overlayView.userInteractionEnabled = NO;
    self.overlayView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view addSubview:self.overlayView];
    
    //边界线
    self.ratioView = [[UIView alloc] initWithFrame:self.cropFrame];
    self.ratioView.autoresizingMask = UIViewAutoresizingNone;
    [self.view addSubview:self.ratioView];
    
    [self overlayClipping];
}

- (void)initButton {
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    UIButton *cancleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancleButton setTitle:@"取消" forState:UIControlStateNormal];
    [cancleButton sizeToFit];
    cancleButton.frame = CGRectMake(XXBPhotoCropEditorControllerMargin, height - CGRectGetHeight(cancleButton.frame) - XXBPhotoCropEditorControllerMargin , CGRectGetWidth(cancleButton.frame), CGRectGetHeight(cancleButton.frame));
    [self.view addSubview:cancleButton];
    [cancleButton addTarget:self action:@selector(cancelClicked) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *finishButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [finishButton setTitle:@"确定" forState:UIControlStateNormal];
    [finishButton sizeToFit];
    finishButton.frame = CGRectMake(width - CGRectGetWidth(finishButton.frame) - XXBPhotoCropEditorControllerMargin , height - CGRectGetHeight(finishButton.frame) - XXBPhotoCropEditorControllerMargin , CGRectGetWidth(finishButton.frame), CGRectGetHeight(finishButton.frame));
    [self.view addSubview:finishButton];
    [finishButton addTarget:self action:@selector(finishClicked) forControlEvents:UIControlEventTouchUpInside];
}
/**
 *  取消
 */
- (void)cancelClicked{
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropEditorControllerDidCancel:)]) {
        [self.delegate photoCropEditorControllerDidCancel:self];
    }
}
/**
 *  确定
 */
- (void)finishClicked {
    if (self.delegate && [self.delegate respondsToSelector:@selector(photoCropEditorController:didFinished:)]) {
        UIImage *image = [self getSubImage];
        image = [self scalImage:image];
        [self.delegate photoCropEditorController:self didFinished:image];
    }
}

/**
 *  把中间的镂空部分抠出来
 */
- (void)overlayClipping {
    CGFloat lineWidth = 1.0;
    //背景
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:self.overlayView.frame cornerRadius:0];
    
    //镂空
    
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithRect:self.ratioView.frame];
    [path appendPath:circlePath];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.path = path.CGPath;
    maskLayer.fillRule = kCAFillRuleEvenOdd;
    //    半透明
    //    maskLayer.opacity = 0.5;
    self.overlayView.layer.mask = maskLayer;
    
    //画线
    CGRect circleFrame = CGRectMake(lineWidth * 0.5,lineWidth * 0.5, self.ratioView.frame.size.width - lineWidth, self.ratioView.frame.size.height - lineWidth);
    UIBezierPath *circleLinePath = [UIBezierPath bezierPathWithRect:circleFrame];
    CAShapeLayer *circleLayer = [CAShapeLayer layer];
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.frame = self.ratioView.bounds;
    circleLayer.lineCap = kCALineCapRound;
    circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    circleLayer.path = circleLinePath.CGPath;
    circleLayer.lineWidth = lineWidth;
    [self.ratioView.layer addSublayer:circleLayer];
    
}

/**
 *  添加手势
 */
- (void) addGestureRecognizers {
    // add pinch gesture
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchView:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
    
    // add pan gesture
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panView:)];
    [self.view addGestureRecognizer:panGestureRecognizer];
}

// 缩放手势
- (void) pinchView:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    UIView *view = self.showImgView;
    if (pinchGestureRecognizer.state == UIGestureRecognizerStateBegan || pinchGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        view.transform = CGAffineTransformScale(view.transform, pinchGestureRecognizer.scale, pinchGestureRecognizer.scale);
        pinchGestureRecognizer.scale = 1;
    } else {
        if (pinchGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            CGRect newFrame = self.showImgView.frame;
            newFrame = [self handleScaleOverflow:newFrame];
            newFrame = [self handleBorderOverflow:newFrame];
            [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
                self.showImgView.frame = newFrame;
                self.latestFrame = newFrame;
            }];
        }
    }
}
// 拖拽手势
- (void) panView:(UIPanGestureRecognizer *)panGestureRecognizer {
    UIView *view = self.showImgView;
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan || panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat absCenterX = self.cropFrame.origin.x + self.cropFrame.size.width / 2;
        CGFloat absCenterY = self.cropFrame.origin.y + self.cropFrame.size.height / 2;
        CGFloat scaleRatio = self.showImgView.frame.size.width / self.cropFrame.size.width;
        CGFloat acceleratorX = 1 - ABS(absCenterX - view.center.x) / (scaleRatio * absCenterX);
        CGFloat acceleratorY = 1 - ABS(absCenterY - view.center.y) / (scaleRatio * absCenterY);
        CGPoint translation = [panGestureRecognizer translationInView:view.superview];
        [view setCenter:(CGPoint){view.center.x + translation.x * acceleratorX, view.center.y + translation.y * acceleratorY}];
        [panGestureRecognizer setTranslation:CGPointZero inView:view.superview];
    } else {
        if (panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
            // bounce to original frame
            CGRect newFrame = self.showImgView.frame;
            newFrame = [self handleBorderOverflow:newFrame];
            [UIView animateWithDuration:BOUNDCE_DURATION animations:^{
                self.showImgView.frame = newFrame;
                self.latestFrame = newFrame;
            }];
        }
        
    }
}
/**
 *  计算frame
 *
 *  @param newFrame 最新的frame
 *
 *  @return 计算之后的frame
 */
- (CGRect)handleScaleOverflow:(CGRect)newFrame {
    // bounce to original frame
    CGPoint oriCenter = CGPointMake(newFrame.origin.x + newFrame.size.width/2.0, newFrame.origin.y + newFrame.size.height/2.0);
    //小于最开始的时候的状态，就让他等于最开始的时候的状态
    if (newFrame.size.width < self.oldFrame.size.width || newFrame.size.height < self.oldFrame.size.height) {
        newFrame = self.oldFrame;
    }
    //超出最大值，就让他等于最大值
    if (newFrame.size.width > self.largeFrame.size.width || newFrame.size.height > self.largeFrame.size.height) {
        newFrame = self.largeFrame;
    }
    //缩放之后还是再中间
    newFrame.origin.x = oriCenter.x - newFrame.size.width/2;
    newFrame.origin.y = oriCenter.y - newFrame.size.height/2;
    newFrame.origin.x = floorf(newFrame.origin.x);
    newFrame.origin.y = floorf(newFrame.origin.y);
    newFrame.size.width = floorf(newFrame.size.width);
    newFrame.size.height = floorf(newFrame.size.height);
    return newFrame;
}
/**
 *  判断拖拽超出边界
 */
- (CGRect)handleBorderOverflow:(CGRect)newFrame {
    // 判断x方向的
    if (newFrame.origin.x > self.cropFrame.origin.x)
        newFrame.origin.x = self.cropFrame.origin.x;
    if (CGRectGetMaxX(newFrame) < self.cropFrame.origin.x + self.cropFrame.size.width)
        newFrame.origin.x = self.cropFrame.origin.x + self.cropFrame.size.width - newFrame.size.width;
    // 判断y方向
    if (newFrame.origin.y > self.cropFrame.origin.y)
        newFrame.origin.y = self.cropFrame.origin.y;
    if (CGRectGetMaxY(newFrame) < self.cropFrame.origin.y + self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + self.cropFrame.size.height - newFrame.size.height;
    }
    // adapt horizontally rectangle
    if (self.showImgView.frame.size.width > self.showImgView.frame.size.width && newFrame.size.height <= self.cropFrame.size.height) {
        newFrame.origin.y = self.cropFrame.origin.y + (self.cropFrame.size.height - newFrame.size.height) / 2;
    }
    newFrame.origin.x = floorf(newFrame.origin.x);
    newFrame.origin.y = floorf(newFrame.origin.y);
    newFrame.size.width = floorf(newFrame.size.width);
    newFrame.size.height = floorf(newFrame.size.height);
    return newFrame;
}

-(UIImage *)getSubImage {
    CGRect squareFrame = self.cropFrame;
    CGFloat scaleRatio = self.latestFrame.size.width / self.originalImage.size.width;
    CGFloat x = (squareFrame.origin.x - self.latestFrame.origin.x) / scaleRatio;
    CGFloat y = (squareFrame.origin.y - self.latestFrame.origin.y) / scaleRatio;
    CGFloat w = squareFrame.size.width / scaleRatio;
    CGFloat h = squareFrame.size.height / scaleRatio;
    if (self.latestFrame.size.width < self.cropFrame.size.width) {
        CGFloat newW = self.originalImage.size.width;
        CGFloat newH = newW * (self.cropFrame.size.height / self.cropFrame.size.width);
        x = 0; y = y + (h - newH) / 2;
        w = newW; h = newH;
    }
    if (self.latestFrame.size.height < self.cropFrame.size.height) {
        CGFloat newH = self.originalImage.size.height;
        CGFloat newW = newH * (self.cropFrame.size.width / self.cropFrame.size.height);
        x = x + (w - newW) / 2; y = 0;
        w = newW; h = newH;
    }
    CGRect myImageRect = CGRectMake(x * self.originalImage.scale, y * self.originalImage.scale, w * self.originalImage.scale, h * self.originalImage.scale);
    CGImageRef imageRef = self.originalImage.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    return smallImage;
}
//根据方向对图片进行旋转
- (UIImage *)fixOrientation:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp)
        return srcImg;
    CGAffineTransform transform = CGAffineTransformIdentity;
    switch (srcImg.imageOrientation)
    {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, srcImg.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    switch (srcImg.imageOrientation)
    {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, srcImg.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }
    CGContextRef ctx = CGBitmapContextCreate(NULL, srcImg.size.width, srcImg.size.height,
                                             CGImageGetBitsPerComponent(srcImg.CGImage), 0,
                                             CGImageGetColorSpace(srcImg.CGImage),
                                             CGImageGetBitmapInfo(srcImg.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (srcImg.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.height,srcImg.size.width), srcImg.CGImage);
            break;
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,srcImg.size.width,srcImg.size.height), srcImg.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)scalImage:(UIImage *)scalImage {
    CGSize newSize = CGSizeMake(400, 400);
    UIGraphicsBeginImageContext(newSize);
    [scalImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UIView *)coverView {
    if(_coverView == nil) {
        UIView *coverView = [[UIView alloc] initWithFrame:self.view.frame];
        [self.view addSubview:coverView];
        coverView.userInteractionEnabled = YES;
        _coverView = coverView;
    }
    return _coverView;
}
@end
