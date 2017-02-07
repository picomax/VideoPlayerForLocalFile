//
//  ViewController.m
//  TestMPMPlayer
//
//  Created by picomax on 2016. 6. 15..
//  Copyright © 2016년 picomax. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>
#import "ViewController.h"

#define degreeToRadian(x) (M_PI * x / 180.0)
#define radianToDegree(x) (180.0 * x / M_PI)

@interface ViewController ()
@property (strong, nonatomic) MPMoviePlayerController *player;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self setVideoPlayer:CGRectMake(0, 0, 320, 480)];
}

- (void)setVideoPlayer:(CGRect)rect {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sample" ofType:@"mp4"];
    NSURL *videoUrl = [NSURL fileURLWithPath:path];
    videoUrl = [NSURL URLWithString:@"http://picomax.net/xe/files/attach/images/203/646/070/c659a34f00719bdc0d533884a1a0257a.mp4"];
    
    _player = [[MPMoviePlayerController alloc] initWithContentURL:videoUrl];
    //[_player prepareToPlay];
    [_player.view setFrame:rect];
    [_player setControlStyle:MPMovieControlStyleNone];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(movieLoadStateDidChange:)
     name:MPMoviePlayerLoadStateDidChangeNotification
     object:_player];
    
    [_player play];
}

-(void)movieLoadStateDidChange: (NSNotification*)notification
{
    if (_player.loadState)
    {
        [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:MPMoviePlayerLoadStateDidChangeNotification
         object:_player] ;
        
        // 이 지점에서 사이즈를 읽어서..
        NSLog(@"%f, %f", _player.naturalSize.width, _player.naturalSize.height);
        
        // 여기서 회전시키면 됨..
        _player.view.transform = CGAffineTransformMakeRotation(degreeToRadian(-45));
        
        [self.view addSubview:_player.view];
    }
}


@end
