//
//  PWSocialAmazingCropperVC.h
//  XXBPhotoCropEditorDemo
//
//  Created by xiaobing on 2017/10/6.
//  Copyright © 2017年 xiaobing. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XXBPhotoCropEditorController;

@protocol XXBPhotoCropEditorControllerDelegate <NSObject>
@optional


/**
 裁剪完成的回掉

 @param cropperViewController 裁剪的controller
 @param editedImage 裁剪完成的照片
 */
- (void)photoCropEditorController:(XXBPhotoCropEditorController *)cropperViewController didFinished:(UIImage *)editedImage;

/**
 取消裁剪

 @param cropperViewController 取消裁剪的controller
 */
- (void)photoCropEditorControllerDidCancel:(XXBPhotoCropEditorController *)cropperViewController;
@end

@interface XXBPhotoCropEditorController : UIViewController

@property (nonatomic, assign) NSInteger tag;

@property (nonatomic, assign) id<XXBPhotoCropEditorControllerDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)originalImage;

- (instancetype)initWithImage:(UIImage *)originalImage limitScaleRatio:(NSInteger)limitRatio;
/**
 *  @param originalImage 要缩放的图片
 *  @param cropFrame     图片的方框的框的位置
 *  @param limitRatio    缩放的比例
 */
- (instancetype)initWithImage:(UIImage *)originalImage cropFrame:(CGRect)cropFrame limitScaleRatio:(NSInteger)limitRatio;
@end
