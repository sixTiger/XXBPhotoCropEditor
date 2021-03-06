//
//  XXBImagePickerUtil.m
//  XXBPhotoCropEditorDemo
//
//  Created by xiaobing on 2017/10/6.
//  Copyright © 2017年 xiaobing. All rights reserved.
//

#import "XXBImagePickerUtil.h"
#import "XXBPhotoCropEditorController.h"
#import <RSKImageCropper/RSKImageCropper.h>

@interface XXBImagePickerUtil ()<UINavigationControllerDelegate, UIImagePickerControllerDelegate,XXBPhotoCropEditorControllerDelegate,RSKImageCropViewControllerDelegate>
@property(nonatomic ,strong) UIImagePickerController *imagePicker;
@end

@implementation XXBImagePickerUtil
static id _instance = nil;
+ (instancetype)shareImagePickerUtil {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            _instance = [super allocWithZone:zone];
        });
    }
    return _instance;
}

- (id)copyWithZone:(NSZone *)zone {
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [self setupData];
        });
    }
    return self;
}

- (void)setupData {
    
}

- (void)showPhotoChooseViewWithController:(UIViewController *)viewController {
    UIAlertController *alertController = [[UIAlertController alloc] init];
    __weak typeof(self)weakSelf = self;
    UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showCameraPickerWithController:viewController];
    }];
    UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showPhotoPickerWithController:viewController];
    }];
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [alertController addAction:cameraAction];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [alertController addAction:photoAction];
    }
    [alertController addAction:cancleAction];
    [viewController presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)showPhotoPickerWithController:(UIViewController *)controller {
    [self showImagePickerWithController:controller andSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void)showCameraPickerWithController:(UIViewController *)controller {
    [self showImagePickerWithController:controller andSourceType:UIImagePickerControllerSourceTypeCamera];
}

- (void)showImagePickerWithController:(UIViewController *)controller andSourceType:(UIImagePickerControllerSourceType)sourceType {
    self.imagePicker = [[UIImagePickerController alloc] init];
    self.imagePicker.sourceType = sourceType;
    self.imagePicker.delegate = self;
    [controller presentViewController:self.imagePicker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    if(image != nil) {
        [self showCropAlertWithImage:image andViewController:picker controller:picker];
    }
}

- (void)showCropAlertWithImage:(UIImage *)image andViewController:(UINavigationController *)navi controller:(UIViewController *)controller {
    
    UIAlertController *alertController = [[UIAlertController alloc] init];
    __weak typeof(self)weakSelf = self;
    UIAlertAction *photoCropEditorController = [UIAlertAction actionWithTitle:@"XXBPhotoCropEditorController" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showPhotoCropEditorControllerWithImage:image navigation:navi];
    }];
    
    UIAlertAction *rskImageCropper = [UIAlertAction actionWithTitle:@"RSKImageCropper" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf showRSKImageCropperWithImage:image navigation:navi];
    }];
    
    UIAlertAction *cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertController addAction:photoCropEditorController];
    [alertController addAction:rskImageCropper];
    [alertController addAction:cancleAction];
    [controller presentViewController:alertController animated:YES completion:^{
        
    }];
}

- (void)showPhotoCropEditorControllerWithImage:(UIImage *)image navigation:(UINavigationController *)navigation {
    XXBPhotoCropEditorController *amazingCropperVC = [[XXBPhotoCropEditorController alloc] initWithImage:image];
    amazingCropperVC.delegate = self;
    [navigation pushViewController:amazingCropperVC animated:YES];
    
}

- (void)showRSKImageCropperWithImage:(UIImage *)image navigation:(UINavigationController *)navigation {
    
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image cropMode:RSKImageCropModeSquare];
    imageCropVC.portraitSquareMaskRectInnerEdgeInset = 0;
    imageCropVC.avoidEmptySpaceAroundImage = YES;
    imageCropVC.maskLayerStrokeColor = [UIColor redColor];
    imageCropVC.delegate = self;
    [navigation pushViewController:imageCropVC animated:YES];
}

- (UIImage*)image:(UIImage *)image scaledToSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - delegate
- (void)photoCropEditorControllerDidCancel:(XXBPhotoCropEditorController *)cropperViewController {
    if (self.imagePicker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        [self.imagePicker dismissViewControllerAnimated:YES completion:^{
            [UIApplication sharedApplication].statusBarHidden = NO;
        }];
    } else {
        [self.imagePicker popViewControllerAnimated:YES];
    }
}

- (void)photoCropEditorController:(XXBPhotoCropEditorController *)cropperViewController didFinished:(UIImage *)editedImage {
    
    UIImage *image = [[UIImage alloc]initWithData:UIImageJPEGRepresentation(editedImage, 0.5)];
    if ([self.delegate respondsToSelector:@selector(imagePickerUtil:didSelectImage:)]) {
        [self.delegate imagePickerUtil:self didSelectImage:image];
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarHidden = NO;
    }];
}

#pragma mark - RSKImageCropViewControllerDelegate
/**
 Tells the delegate that crop image has been canceled.
 */
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {
    
}

/**
 Tells the delegate that the original image will be cropped.
 */
- (void)imageCropViewController:(RSKImageCropViewController *)controller willCropImage:(UIImage *)originalImage {
    
}

/**
 Tells the delegate that the original image has been cropped. Additionally provides a crop rect used to produce image.
 */
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect {
    UIImage *image = [[UIImage alloc]initWithData:UIImageJPEGRepresentation(croppedImage, 0.5)];
    if ([self.delegate respondsToSelector:@selector(imagePickerUtil:didSelectImage:)]) {
        [self.delegate imagePickerUtil:self didSelectImage:image];
    }
    [self.imagePicker dismissViewControllerAnimated:YES completion:^{
        [UIApplication sharedApplication].statusBarHidden = NO;
    }];
}

///**
// Tells the delegate that the original image has been cropped. Additionally provides a crop rect and a rotation angle used to produce image.
// */
//- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle {
//    
//}

@end
