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
    LogMethod;
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

- (void)stopPlayers
{
    for (AudioPlayer *p in self.audioPlayers) {
        p.delegate = nil;
        p.completeBlock = nil;
        [p stop];
    }
    [self.audioPlayers removeAllObjects];
}

- (void)removePlayer:(AVAudioPlayer *)player
{
    [self.audioPlayers removeObject:player];
}

- (AVAudioPlayer *)playerWithURL:(NSURL *)url
                         success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
                         failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure;
{
    NSError *error = nil;
    AudioPlayer *player = [[AudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    
    if (error && failure) {
        failure(player, error);
        return player;
    }
    
    [player prepareToPlay];
    ((AudioPlayer *)player).completeBlock = success;
    [self.audioPlayers addObject:player];
    
    return player;
}

- (AVAudioPlayer *)playerWithPath:(NSString *)path
                          success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
                          failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure
{
    return [self playerWithURL:[NSURL fileURLWithPath:path] success:success failure:failure];
}

- (void)playerWithURL:(NSURL *)url
              prepare:(void(^)(AVAudioPlayer *audioPlayer))prepare
              success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
              failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure
{
    NSError *error = nil;
    AudioPlayer *player = [[AudioPlayer alloc] initWithContentsOfURL:url error:&error];
    player.delegate = self;
    
    if (error && failure) {
        failure(player, error);
        return ;
    }
    
    [player prepareToPlay];
    ((AudioPlayer *)player).completeBlock = success;
    [self.audioPlayers addObject:player];
    
    if (prepare) {
        prepare(player);
    }
}

- (void)playerWithPath:(NSString *)path
               prepare:(void(^)(AVAudioPlayer *audioPlayer))prepare
               success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
               failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure
{
    [self playerWithURL:[NSURL fileURLWithPath:path] prepare:prepare success:success failure:failure];
}


- (void)playerContinuousWithPath:(NSArray *)paths
                         prepare:(void(^)(AVAudioPlayer *audioPlayer))prepare
                         process:(void(^)(AVAudioPlayer *audioPlayer, NSString *path, BOOL *stop))process
                         success:(void(^)(AVAudioPlayer *audioPlayer, BOOL isSuccessfully))success
                         failure:(void(^)(AVAudioPlayer *audioPlayer, NSError *error))failure
{
    __block NSInteger index = 0;
    __weak AudioManager *wk_self = self;
    void(^__block continuousPlayback)(NSInteger i) = ^(NSInteger i) {
        [wk_self playerWithPath:[paths objectAtIndex:i]
                        prepare:^(AVAudioPlayer *audioPlayer) {
                            if (prepare) prepare(audioPlayer);
                        }
                        success:^(AVAudioPlayer *audioPlayer, BOOL isSuccessfully) {
                            index++;
                            if (index < paths.count) {
                                BOOL stop = false;
                                if (process) process(audioPlayer, [paths objectAtIndex:i], &stop);
                                if (!stop) continuousPlayback(index);
                               
                            } else {
                                if (success) success(audioPlayer, isSuccessfully);
                            }
                        }
                        failure:^(AVAudioPlayer *audioPlayer, NSError *error) {
                            if (failure) {
                                failure(audioPlayer, error);
                            }
                        }];
    };
    continuousPlayback(index);
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
