//
//  ViewController.m
//  XXBPhotoCropEditorDemo
//
//  Created by xiaobing on 2017/10/6.
//  Copyright © 2017年 xiaobing. All rights reserved.
//

#import "ViewController.h"
#import "XXBImagePickerUtil.h"

@interface ViewController ()<XXBImagePickerUtilDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self initNavi];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)initNavi {
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(choosePhotos)];
}

- (void) choosePhotos {
    [[XXBImagePickerUtil shareImagePickerUtil] setDelegate:self];
    [[XXBImagePickerUtil shareImagePickerUtil] showPhotoChooseViewWithController:self];
}

- (void)imagePickerUtil:(XXBImagePickerUtil *)imagePickerUtil didSelectImage:(UIImage *)selectImage {
    self.imageView.image = selectImage;
}
@end
