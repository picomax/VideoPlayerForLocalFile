//
//  ViewController.m
//  TestAVPlayer
//
//  Created by picomax on 2016. 6. 15..
//  Copyright © 2016년 picomax. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ViewController.h"

#define degreeToRadian(x) (M_PI * x / 180.0)
#define radianToDegree(x) (180.0 * x / M_PI)

@interface ViewController ()
@property (nonatomic, strong) AVPlayer *avPlayer;
@property (nonatomic, strong) UIView * videoView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setVideoPlayer:CGRectMake(0, 0, 320, 480)];
}


- (void) setVideoPlayer:(CGRect)rect {
    _videoView = [[UIView alloc] initWithFrame:rect];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"];
    NSURL *videoUrl = [NSURL fileURLWithPath:path];
    videoUrl = [NSURL URLWithString:@"http://picomax.net/xe/files/attach/images/203/646/070/c659a34f00719bdc0d533884a1a0257a.mp4"];

    _avPlayer = [AVPlayer playerWithURL:videoUrl];
    _avPlayer.volume = 0.0f;
    
    AVPlayerLayer* playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.avPlayer];
    playerLayer.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    playerLayer.needsDisplayOnBoundsChange = YES;
    
    [_videoView.layer addSublayer:playerLayer];
    _videoView.layer.needsDisplayOnBoundsChange = YES;
    
    //how to know real size of video.
    AVAssetTrack *track = [_avPlayer.currentItem.asset tracksWithMediaType:AVMediaTypeVideo][0];
    CGSize theNaturalSize = [track naturalSize];
    theNaturalSize = CGSizeApplyAffineTransform(theNaturalSize, track.preferredTransform);
    theNaturalSize.width = fabs(theNaturalSize.width);
    theNaturalSize.height = fabs(theNaturalSize.height);
    NSLog(@"hahahahahah : %f, %f", theNaturalSize.width, theNaturalSize.height);
    //how to know real size of video.
    
    self.avPlayer = [self rotateVideoPlayer:_avPlayer withDegree:-45.0];
    [_avPlayer play];
    
    [self.view addSubview:_videoView];
}


-(AVPlayer*)rotateVideoPlayer:(AVPlayer*)player withDegree:(float)degree {
    NSURL* url = [(AVURLAsset *)player.currentItem.asset URL];
    
    AVMutableComposition *composition;
    AVMutableVideoComposition *videoComposition;
    AVMutableVideoCompositionInstruction * instruction;
    
    AVURLAsset* asset = [[AVURLAsset alloc] initWithURL:url options:nil];
    AVMutableVideoCompositionLayerInstruction *layerInstruction = nil;
    CGAffineTransform t1;
    CGAffineTransform t2;
    AVAssetTrack *assetVideoTrack = nil;
    AVAssetTrack *assetAudioTrack = nil;
    // Check if the asset contains video and audio tracks
    if ([[asset tracksWithMediaType:AVMediaTypeVideo] count] != 0) {
        assetVideoTrack = [[asset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0];
    }
    if ([[asset tracksWithMediaType:AVMediaTypeAudio] count] != 0) {
        assetAudioTrack = [[asset tracksWithMediaType:AVMediaTypeAudio] objectAtIndex:0];
    }
    CMTime insertionPoint = kCMTimeInvalid;
    NSError *error = nil;
    
    // Step 1
    // Create a new composition
    composition = [AVMutableComposition composition];
    // Insert the video and audio tracks from AVAsset
    if (assetVideoTrack != nil) {
        AVMutableCompositionTrack *compositionVideoTrack = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionVideoTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetVideoTrack atTime:insertionPoint error:&error];
    }
    if (assetAudioTrack != nil) {
        AVMutableCompositionTrack *compositionAudioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
        [compositionAudioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, [asset duration]) ofTrack:assetAudioTrack atTime:insertionPoint error:&error];
    }
    
    
    // Step 2
    // Calculate position and size of render video after rotating
    float width=assetVideoTrack.naturalSize.width;
    float height=assetVideoTrack.naturalSize.height;
    float toDiagonal=sqrt(width*width+height*height);
    float toDiagonalAngle=radianToDegree(acosf(width/toDiagonal));
    float toDiagonalAngle2=90-radianToDegree(acosf(width/toDiagonal));
    
    float toDiagonalAngleComple;
    float toDiagonalAngleComple2;
    float finalHeight;
    float finalWidth;
    
    if(degree >= 0 && degree <= 90) {
        
        toDiagonalAngleComple=toDiagonalAngle+degree;
        toDiagonalAngleComple2=toDiagonalAngle2+degree;
        
        finalHeight=ABS(toDiagonal*sinf(degreeToRadian(toDiagonalAngleComple)));
        finalWidth=ABS(toDiagonal*sinf(degreeToRadian(toDiagonalAngleComple2)));
        
        t1 = CGAffineTransformMakeTranslation(height*sinf(degreeToRadian(degree)), 0.0);
    }
    else if(degree > 90 && degree <= 180) {
        
        
        float degree2 = degree - 90;
        
        toDiagonalAngleComple=toDiagonalAngle+degree2;
        toDiagonalAngleComple2=toDiagonalAngle2+degree2;
        
        finalHeight=ABS(toDiagonal*sinf(degreeToRadian(toDiagonalAngleComple2)));
        finalWidth=ABS(toDiagonal*sinf(degreeToRadian(toDiagonalAngleComple)));
        
        t1 = CGAffineTransformMakeTranslation(width*sinf(degreeToRadian(degree2))+height*cosf(degreeToRadian(degree2)), height*sinf(degreeToRadian(degree2)));
    }
    else if(degree>=-90&&degree<0){
        
        float degree2 = degree-90;
        float absDegree = ABS(degree);
        
        toDiagonalAngleComple=toDiagonalAngle+degree2;
        toDiagonalAngleComple2=toDiagonalAngle2+degree2;
        
        finalHeight=ABS(toDiagonal*sinf(degreeToRadian(toDiagonalAngleComple2)));
        finalWidth=ABS(toDiagonal*sinf(degreeToRadian(toDiagonalAngleComple)));
        
        t1 = CGAffineTransformMakeTranslation(0, width*sinf(degreeToRadian(absDegree)));
        
    }
    else if(degree>=-180&&degree<-90){
        
        float absDegree = ABS(degree);
        float plusDegree = absDegree-90;
        
        toDiagonalAngleComple=toDiagonalAngle+degree;
        toDiagonalAngleComple2=toDiagonalAngle2+degree;
        
        finalHeight=ABS(toDiagonal*sinf(degreeToRadian(toDiagonalAngleComple)));
        finalWidth=ABS(toDiagonal*sinf(degreeToRadian(toDiagonalAngleComple2)));
        
        t1 = CGAffineTransformMakeTranslation(width*sinf(degreeToRadian(plusDegree)), height*sinf(degreeToRadian(plusDegree))+width*cosf(degreeToRadian(plusDegree)));
        
    }
    
    
    // Rotate transformation
    t2 = CGAffineTransformRotate(t1, degreeToRadian(degree));
    
    
    // Step 3
    // Set the appropriate render sizes and rotational transforms
    
    
    // Create a new video composition
    videoComposition = [AVMutableVideoComposition videoComposition];
    videoComposition.renderSize = CGSizeMake(finalWidth,finalHeight);
    videoComposition.frameDuration = CMTimeMake(1, 30);
    
    // The rotate transform is set on a layer instruction
    instruction = [AVMutableVideoCompositionInstruction videoCompositionInstruction];
    
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, [composition duration]);
    
    layerInstruction = [AVMutableVideoCompositionLayerInstruction videoCompositionLayerInstructionWithAssetTrack:[composition.tracks objectAtIndex:0]];
    [layerInstruction setTransform:t2 atTime:kCMTimeZero];
    
    
    // Step  4
    // Add the transform instructions to the video composition
    instruction.layerInstructions = [NSArray arrayWithObject:layerInstruction];
    videoComposition.instructions = [NSArray arrayWithObject:instruction];
    
    AVPlayerItem *playerItem_ = [[AVPlayerItem alloc] initWithAsset:composition];
    playerItem_.videoComposition = videoComposition;
    
    CMTime time;
    
    time=kCMTimeZero;
    [player replaceCurrentItemWithPlayerItem:playerItem_];
    
    [player seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    
    //Export rotated video to the file
    AVAssetExportSession *exportSession = [[AVAssetExportSession alloc] initWithAsset:composition presetName:AVAssetExportPresetMediumQuality] ;
    exportSession.outputURL = [NSURL URLWithString:[NSString stringWithFormat:@"%@_rotated",url]];
    exportSession.outputFileType = AVFileTypeQuickTimeMovie;
    exportSession.videoComposition = videoComposition;
    exportSession.shouldOptimizeForNetworkUse = YES;
    exportSession.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration);
    
    [exportSession exportAsynchronouslyWithCompletionHandler:^{
        NSLog(@"Video exported");
    }];
    
    
    return  player;
    
}

@end
