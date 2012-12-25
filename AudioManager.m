//
//  AudioManager.h
//
//  Created by Yamamoto Gota on 12/12/20.
//

#import "AudioManager.h"

typedef void(^AVAudioPlayerCompleteBlock)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully);

@interface AudioPlayer : AVAudioPlayer
@property (nonatomic, copy) AVAudioPlayerCompleteBlock completeBlock;
@end
@implementation AudioPlayer

- (void)dealloc
{
    self.completeBlock = nil;
#if !__has_feature(objc_arc)
    [super dealloc];
#endif
}

@end

@interface AudioManager()<AVAudioPlayerDelegate>
@property (nonatomic, strong) NSMutableArray *audioPlayers;
@end

@implementation AudioManager

+ (AudioManager *)sharedManager
{
    static AudioManager *_sharedAudioManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedAudioManager = [[AudioManager alloc] init];
    });
    
    return _sharedAudioManager;
}

- (id)init
{
    if((self=[super init])) {
        self.audioPlayers = [NSMutableArray array];
    }
    return self;
}

- (AVAudioPlayer *)playerWithURL:(NSURL *)url
                        complete:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))complete
                         failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;
{
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    
    if (error && failure) {
        failure(player, error);
        return player;
    }
    
    [player prepareToPlay];
    ((AudioPlayer *)player).completeBlock = complete;
    [self.audioPlayers addObject:player];
    
    return player;
}

- (AVAudioPlayer *)playerWithPath:(NSString *)path
                         complete:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))complete
                          failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure
{
    return [self playerWithURL:[NSURL fileURLWithPath:path] complete:complete failure:failure];
}

- (void)playerWithURL:(NSURL *)url
              success:(void(^)(AVAudioPlayer *audioPlayer))success
             complete:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))complete
              failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure
{
    NSError *error = nil;
    AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    
    if (error && failure) {
        failure(player, error);
        return ;
    }
    
    [player prepareToPlay];
    ((AudioPlayer *)player).completeBlock = complete;
    [self.audioPlayers addObject:player];
    
    if (success) {
        success(player);
    }
}

- (void)playerWithPath:(NSString *)path
               success:(void(^)(AVAudioPlayer *audioPlayer))success
              complete:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))complete
               failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure
{
    [self playerWithURL:[NSURL fileURLWithPath:path] success:success complete:complete failure:failure];
}

#pragma mark - audio player
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (((AudioPlayer *)player).completeBlock) {
        ((AudioPlayer *)player).completeBlock(player, flag);
    }
    [self.audioPlayers removeObject:player];
#if !__has_feature(objc_arc)
    [player release];
#endif
}

@end
