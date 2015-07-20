//
//  faceDetector.m
//  faceRecognition
//
//  Created by MaJixian on 11/3/14.
//  Copyright (c) 2014 MaJixian. All rights reserved.
//

#import "faceDetector.h"
#import <CoreImage/CoreImage.h>
#import <ImageIO/ImageIO.h>
#import <AVFoundation/AVFoundation.h>


@interface faceDetector () <AVCaptureVideoDataOutputSampleBufferDelegate>

@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic, strong) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic, strong) CIDetector *faceDetector;

@end

@implementation faceDetector
{
    UIDeviceOrientation currentDeviceOrientation;
    BOOL isUsingFrontFacingCamera;
}

- (void)setupAVCapture
{
    AVCaptureSession *session = [AVCaptureSession new];
    [session setSessionPreset:AVCaptureSessionPreset640x480];
    
    // Select a video device, make an input
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    //in real app you would use camera that user chose
    if([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]) {
        isUsingFrontFacingCamera = YES;
        for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
            if ([d position] == AVCaptureDevicePositionFront)
            device = d;
        }
    }
    else
    exit(0);
    
    NSError *error = nil;
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if(error != nil)
    {
        exit(0);
    }
    
    if ([session canAddInput:deviceInput])
    [session addInput:deviceInput];
    
    // Make a video data output
    self.videoDataOutput = [AVCaptureVideoDataOutput new];
    
    // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA'
    NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCMPixelFormat_32BGRA)};
    [self.videoDataOutput setVideoSettings:rgbOutputSettings];
    [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked (as we process the still image)
    
    self.videoDataOutputQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
    [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
    
    if ( [session canAddOutput:self.videoDataOutput] )
    [session addOutput:self.videoDataOutput];
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:NO];
    
    self.previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:session];
    [self.previewLayer setBackgroundColor:[[UIColor blackColor] CGColor]];
    [self.previewLayer setVideoGravity:AVLayerVideoGravityResizeAspect];
    CALayer *rootLayer = [self.previewView layer];
    [rootLayer setMasksToBounds:YES];
    [self.previewLayer setFrame:[rootLayer bounds]];
    [rootLayer addSublayer:self.previewLayer];
    [session startRunning];
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    // got an image
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
    CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(__bridge NSDictionary *)attachments];
    if (attachments)
    CFRelease(attachments);
    
    
    
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
    
    //int exifOrientation = 6; //   6  =  0th row is on the right, and 0th column is the top.
    int exifOrientation;
    
    enum {
        PHOTOS_EXIF_0ROW_TOP_0COL_LEFT          = 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
        PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT         = 2, //   2  =  0th row is at the top, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
        PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
        PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
        PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
        PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
    };
    
    switch (currentDeviceOrientation) {
        case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
        exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
        break;
        case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
        if (isUsingFrontFacingCamera)
        exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
        else
        exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
        break;
        case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
        if (isUsingFrontFacingCamera)
        exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
        else
        exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
        break;
        case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
        default:
        exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
        break;
    }
    
    NSDictionary *imageOptions = @{CIDetectorImageOrientation : @(exifOrientation)};
    
    NSArray *features = [self.faceDetector featuresInImage:ciImage options:imageOptions];
    
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
    CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
    CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false
                                                           /*originIsTopLeft == false*/);
    
    // called asynchronously as the capture output is capturing sample buffers, this method asks the face detector
    // to detect features
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        CGSize parentFrameSize = [self.previewView frame].size;
        NSString *gravity = [self.previewLayer videoGravity];
        //BOOL isMirrored = [self.previewLayer isMirrored];
        CGRect previewBox = [faceDetector videoPreviewBoxForGravity:gravity
                                                        frameSize:parentFrameSize
                                                     apertureSize:clap.size];
        
        if ([self.delegate respondsToSelector:@selector(drawFaceBoxesForFeatures:forVideoBox:orientation:forLayer:forPreivewBox:)]) {
            currentDeviceOrientation = [[UIDevice currentDevice] orientation];
            [self.delegate drawFaceBoxesForFeatures:features forVideoBox:clap orientation:currentDeviceOrientation forLayer:self.previewLayer forPreivewBox:previewBox];
        }
    });
}

- (void)startDetection
{
    [self setupAVCapture];
    [[self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo] setEnabled:YES];
    NSDictionary *detectorOptions = @{CIDetectorAccuracy : CIDetectorAccuracyLow};
    self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions];
}

- (void)stopDetection
{
    [self teardownAVCapture];
}

// clean up capture setup
- (void)teardownAVCapture
{
    if (self.videoDataOutputQueue)
    self.videoDataOutputQueue = nil;
}

// find where the video box is positioned within the preview layer based on the video size and gravity
+ (CGRect)videoPreviewBoxForGravity:(NSString *)gravity frameSize:(CGSize)frameSize apertureSize:(CGSize)apertureSize
{
    CGFloat apertureRatio = apertureSize.height / apertureSize.width;
    CGFloat viewRatio = frameSize.width / frameSize.height;
    
    CGSize size = CGSizeZero;
    if ([gravity isEqualToString:AVLayerVideoGravityResizeAspectFill]) {
        if (viewRatio > apertureRatio) {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        } else {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        if (viewRatio > apertureRatio) {
            size.width = apertureSize.height * (frameSize.height / apertureSize.width);
            size.height = frameSize.height;
        } else {
            size.width = frameSize.width;
            size.height = apertureSize.width * (frameSize.width / apertureSize.height);
        }
    } else if ([gravity isEqualToString:AVLayerVideoGravityResizeAspect]) {
        size.width = frameSize.width;
        size.height = frameSize.height;
    }
    
    CGRect videoBox;
    videoBox.size = size;
    if (size.width < frameSize.width)
    videoBox.origin.x = (frameSize.width - size.width) / 2;
    else
    videoBox.origin.x = (size.width - frameSize.width) / 2;
    
    if ( size.height < frameSize.height )
    videoBox.origin.y = (frameSize.height - size.height) / 2;
    else
    videoBox.origin.y = (size.height - frameSize.height) / 2;
    
    return videoBox;
}

+ (CGRect)convertFrame:(CGRect)originalFrame previewBox:(CGRect)previewBox forVideoBox:(CGRect)videoBox isMirrored:(BOOL)isMirrored
{
    // flip preview width and height
    CGFloat temp = originalFrame.size.width;
    originalFrame.size.width = originalFrame.size.height;
    originalFrame.size.height = temp;
    temp = originalFrame.origin.x;
    originalFrame.origin.x = originalFrame.origin.y;
    originalFrame.origin.y = temp;
    // scale coordinates so they fit in the preview box, which may be scaled
    CGFloat widthScaleBy = previewBox.size.width / videoBox.size.height;
    CGFloat heightScaleBy = previewBox.size.height / videoBox.size.width;
    originalFrame.size.width *= widthScaleBy;
    originalFrame.size.height *= heightScaleBy;
    originalFrame.origin.x *= widthScaleBy;
    originalFrame.origin.y *= heightScaleBy;
    
    if(isMirrored)
    {
        originalFrame = CGRectOffset(originalFrame, previewBox.origin.x + previewBox.size.width - originalFrame.size.width - (originalFrame.origin.x * 2), previewBox.origin.y);
    }
    else
    {
        originalFrame = CGRectOffset(originalFrame, previewBox.origin.x, previewBox.origin.y);
    }
    
    return originalFrame;
}




@end
