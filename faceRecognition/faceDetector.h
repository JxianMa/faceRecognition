//
//  faceDetector.h
//  faceRecognition
//
//  Created by MaJixian on 11/3/14.
//  Copyright (c) 2014 MaJixian. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@class faceDetector;
@protocol DetectFaceDelegate <NSObject>

- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation forLayer:(CALayer*)previewLayer forPreivewBox:(CGRect)previewBox;
@end

@interface faceDetector : NSObject
@property (nonatomic, weak) id delegate;

@property (nonatomic, strong) UIView *previewView;

- (void)startDetection;
- (void)stopDetection;

+ (CGRect)convertFrame:(CGRect)originalFrame previewBox:(CGRect)previewBox forVideoBox:(CGRect)videoBox isMirrored:(BOOL)isMirrored;



@end
