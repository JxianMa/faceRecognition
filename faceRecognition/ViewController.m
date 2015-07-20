//
//  ViewController.m
//  faceRecognition
//
//  Created by MaJixian on 10/28/14.
//  Copyright (c) 2014 MaJixian. All rights reserved.
//

#import "ViewController.h"
#import "faceDetector.h"

#import "ViewController.h"
#import "faceDetector.h"

@interface ViewController () <DetectFaceDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) faceDetector *detectFaceController;

@property (nonatomic, strong) UIImageView *hatImgView;
@property (nonatomic, strong) UIImageView *beardImgView;
@property (nonatomic, strong) UIImageView *mustacheImgView;

@end

@implementation ViewController
{
    UIView *faceRectView;
    UIImage *square;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    square = [UIImage imageNamed:@"squarePNG"];
    self.detectFaceController = [[faceDetector alloc] init];
    self.detectFaceController.delegate = self;
    self.detectFaceController.previewView = self.previewView;
    [self.detectFaceController startDetection];
    faceRectView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillUnload
{
    [self.detectFaceController stopDetection];
    [super viewWillUnload];
}

- (void)viewDidUnload {
    [self setPreviewView:nil];
    [super viewDidUnload];
}


- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation forLayer:(CALayer *)previewLayer forPreivewBox:(CGRect)previewBox
{
    NSLog(@"currentDeviceOrientation:%ld",(long)orientation);
    for ( CIFaceFeature *ff in features ) {
        // find the correct position for the square layer within the previewLayer
        // the feature box originates in the bottom left of the video frame.
        // (Bottom right if mirroring is turned on)
        CGRect faceRect = [ff bounds];
        faceRect = [faceDetector convertFrame:faceRect previewBox:previewBox forVideoBox:clap isMirrored:YES];
        [faceRectView setFrame:faceRect];
        [faceRectView setBackgroundColor:[UIColor redColor]];
        [self.previewView addSubview:faceRectView];
        NSLog(@"faceRectOrigin:X:%f,Y:%f",faceRect.origin.x,faceRect.origin.y);
    }
}

@end
