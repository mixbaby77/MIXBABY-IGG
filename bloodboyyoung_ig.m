#import <UIKit/UIKit.h>

static NSString * const kBloodboyIGLastTriggerKey = @"felix.ig.bloodboyyoung.mixbaby.last_trigger.1day.epoch";
static NSString * const kBloodboyIGUsername = @"bloodboyyoung.mixbaby";
static NSString * const kBloodboyIGTargetURL = @"https://www.instagram.com/bloodboyyoung.mixbaby?avpt=MXhodHU4OXdrYXptNg%3D%3D&utm_source=qr";
static const NSTimeInterval kBloodboyIGIntervalSeconds = 1.0 * 24.0 * 60.0 * 60.0;

static BOOL bloodboy_should_trigger_1day(NSUserDefaults *defaults, NSTimeInterval nowEpoch) {
    NSNumber *lastTriggerObj = [defaults objectForKey:kBloodboyIGLastTriggerKey];
    if (![lastTriggerObj isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    NSTimeInterval lastEpoch = [lastTriggerObj doubleValue];
    if (nowEpoch < lastEpoch) {
        return YES;
    }
    return (nowEpoch - lastEpoch) >= kBloodboyIGIntervalSeconds;
}

static void bloodboy_open_ig_every_1_day(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSTimeInterval nowEpoch = [[NSDate date] timeIntervalSince1970];

    if (!bloodboy_should_trigger_1day(defaults, nowEpoch)) {
        return;
    }

    [defaults setObject:@(nowEpoch) forKey:kBloodboyIGLastTriggerKey];
    [defaults synchronize];

    NSURL *webURL = [NSURL URLWithString:kBloodboyIGTargetURL];
    NSURL *schemeURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", kBloodboyIGUsername]];
    UIApplication *app = [UIApplication sharedApplication];

    if (webURL) {
        [app openURL:webURL
             options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO}
   completionHandler:^(BOOL opened) {
            if (!opened && schemeURL && [app canOpenURL:schemeURL]) {
                [app openURL:schemeURL options:@{} completionHandler:nil];
            }
        }];
    } else if (schemeURL && [app canOpenURL:schemeURL]) {
        [app openURL:schemeURL options:@{} completionHandler:nil];
    }
}

static void __attribute__((constructor)) bloodboy_ig_1day_entry(void) {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            bloodboy_open_ig_every_1_day();
        });
    }];
}
