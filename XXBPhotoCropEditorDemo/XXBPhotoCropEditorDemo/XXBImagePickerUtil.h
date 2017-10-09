//
//  XXBImagePickerUtil.h
//  XXBPhotoCropEditorDemo
//
//  Created by xiaobing on 2017/10/6.
//  Copyright © 2017年 xiaobing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class XXBImagePickerUtil;

@protocol XXBImagePickerUtilDelegate <NSObject>
@optional
- (void)imagePickerUtil:(XXBImagePickerUtil *)imagePickerUtil didSelectImage:(UIImage *)selectImage;
@end

@interface XXBImagePickerUtil : NSObject

@property(nonatomic ,weak) id<XXBImagePickerUtilDelegate> delegate;

+ (instancetype)shareImagePickerUtil ;

- (void)showPhotoChooseViewWithController:(UIViewController *)viewController;
@end
