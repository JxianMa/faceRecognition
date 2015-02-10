//
//  ViewController.m
//  faceRecognition
//
//  Created by MaJixian on 10/28/14.
//  Copyright (c) 2014 MaJixian. All rights reserved.
//

#import "ViewController.h"
#import "faceDetector.h"

//NSTimeInterval x;
@interface ViewController () <faceDetectorDelegate>

@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (strong, nonatomic) faceDetector *detectFaceController;
@property (nonatomic, strong) UIImageView *smileImgView;
@property (nonatomic, strong) UIImageView *rightStayImgView;
@property (nonatomic, strong) UIImageView *leftStayImgView;
@property (nonatomic, strong) UIImageView *stayImageView;
@property (nonatomic, strong) UIImageView *animationImageView;
@property (nonatomic, strong) UIImageView *slideshowA;
@property (nonatomic, strong) UIImageView *slideshowB;
@property (nonatomic, strong) UIImageView *slideshowC;
@property (nonatomic, strong) CATransition *transition;
@property (nonatomic, strong) UILabel *smileDetectLabel;
@property (nonatomic, strong) NSArray *priorConstraints;
@property (nonatomic, strong) NSArray *images;
@end
int imageIndex;

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.detectFaceController = [[faceDetector alloc] init];
    self.detectFaceController.delegate = self;
    self.detectFaceController.previewView = self.previewView;
    [self.detectFaceController startDetection];
    imageIndex = 0;

    self.previewView.backgroundColor = [UIColor blackColor];
    self.slideshowA = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, [[UIScreen mainScreen] applicationFrame].size.width, 350)];
    self.slideshowA.image = [UIImage imageNamed:@"1.jpg"];
    self.slideshowB = [[UIImageView alloc] initWithFrame:CGRectMake(0, 30, [[UIScreen mainScreen] applicationFrame].size.width, 350)];
    self.slideshowB.image = [UIImage imageNamed:@"2.jpg"];
    [self.previewView addSubview:self.slideshowB];
    self.smileDetectLabel = [[UILabel alloc]initWithFrame:CGRectMake(130, 450, [[UIScreen mainScreen] applicationFrame].size.width, 40)];
    self.smileDetectLabel.textColor = [UIColor whiteColor];
    self.smileDetectLabel.backgroundColor = [UIColor blackColor];
    [self.previewView addSubview:self.smileDetectLabel];


   
 }




- (void)didReceiveMemoryWarning {
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



- (void)detectedFaceController:(faceDetector *)controller features:(NSArray *)featuresArray forVideoBox:(CGRect)clap withPreviewBox:(CGRect)previewBox
{
    for (CIFaceFeature *ff in featuresArray) {
        NSLog(@"Left eye %f %f", ff.leftEyePosition.x, ff.leftEyePosition.y);
        NSLog(@"Right eye %f %f", ff.rightEyePosition.x, ff.rightEyePosition.y);
        NSLog(@"smile:%d", ff.hasSmile);
        NSLog(@"lefteyeclose: %d", ff.leftEyeClosed);
        NSLog(@"righteyeclose: %d", ff.rightEyeClosed);


        if (ff.hasSmile) {
            UIView *fromView, *toView;
            if ([self.slideshowB superview] != nil)
            {
                fromView = self.slideshowB;
                toView = self.slideshowA;
                self.smileDetectLabel.text = [NSString stringWithFormat:@"image 1"];
            }
            else
            {
                fromView = self.slideshowA;
                toView = self.slideshowB;
                self.smileDetectLabel.text = [NSString stringWithFormat:@"image 2"];
            }
            NSArray *priorConstraints = self.priorConstraints;
            [UIView transitionFromView:fromView
                                toView:toView
                              duration:1.0
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            completion:^(BOOL finished)  {
                                if (priorConstraints != nil)
                                {
                                    [self.view removeConstraints:priorConstraints];
                                }
                            }];
        
        }

        


            
            }
}
@end
