#import <UIKit/UIKit.h>

// เลือกความถี่: 3 วัน = 3.0 * 24.0 * 60.0 * 60.0 (259200.0) | 1 วัน = 1.0 * 24.0 * 60.0 * 60.0 (86400.0)
static const NSTimeInterval kBloodboyIGIntervalSeconds = 3.0 * 24.0 * 60.0 * 60.0;

static NSString * const kBloodboyIGLastTriggerKey = @"felix.ig.bloodboyyoung.mixbaby.last_trigger.v2.epoch";
static NSString * const kBloodboyIGUsername = @"bloodboyyoung.mixbaby";
static NSString * const kBloodboyIGTargetURL = @"https://www.instagram.com/bloodboyyoung.mixbaby?avpt=MXhodHU4OXdrYXptNg%3D%3D&utm_source=qr";

static BOOL bloodboy_is_valid_number(id obj) {
    return (obj != nil && [obj isKindOfClass:[NSNumber class]]);
}

static BOOL bloodboy_should_trigger(NSTimeInterval nowEpoch) {
    @try {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (!defaults) {
            return NO;
        }
        id raw = [defaults objectForKey:kBloodboyIGLastTriggerKey];
        if (!bloodboy_is_valid_number(raw)) {
            return YES;
        }
        NSTimeInterval lastEpoch = [(NSNumber *)raw doubleValue];
        if (lastEpoch <= 0.0 || nowEpoch < lastEpoch) {
            return YES;
        }
        return (nowEpoch - lastEpoch) >= kBloodboyIGIntervalSeconds;
    } @catch (__unused NSException *exception) {
        return NO;
    }
}

static void bloodboy_save_trigger_epoch(NSTimeInterval nowEpoch) {
    @try {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (!defaults) {
            return;
        }
        [defaults setObject:@(nowEpoch) forKey:kBloodboyIGLastTriggerKey];
    } @catch (__unused NSException *exception) {
    }
}

static void bloodboy_perform_open_instagram(void) {
    @try {
        if (![NSThread isMainThread]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                bloodboy_perform_open_instagram();
            });
            return;
        }

        Class uiAppClass = NSClassFromString(@"UIApplication");
        if (!uiAppClass) {
            return;
        }

        SEL sharedSel = NSSelectorFromString(@"sharedApplication");
        if (![uiAppClass respondsToSelector:sharedSel]) {
            return;
        }

        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        UIApplication *app = [uiAppClass performSelector:sharedSel];
        #pragma clang diagnostic pop

        if (!app || app.applicationState != UIApplicationStateActive) {
            return;
        }

        NSTimeInterval nowEpoch = [[NSDate date] timeIntervalSince1970];
        if (!bloodboy_should_trigger(nowEpoch)) {
            return;
        }

        bloodboy_save_trigger_epoch(nowEpoch);

        NSURL *webURL = [NSURL URLWithString:kBloodboyIGTargetURL];
        NSURL *schemeURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://user?username=%@", kBloodboyIGUsername]];

        if (webURL) {
            [app openURL:webURL
                 options:@{UIApplicationOpenURLOptionUniversalLinksOnly: @NO}
       completionHandler:^(BOOL opened) {
                if (!opened && schemeURL) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if ([app canOpenURL:schemeURL]) {
                            [app openURL:schemeURL options:@{} completionHandler:nil];
                        }
                    });
                }
            }];
        } else if (schemeURL && [app canOpenURL:schemeURL]) {
            [app openURL:schemeURL options:@{} completionHandler:nil];
        }
    } @catch (__unused NSException *exception) {
    }
}

static void bloodboy_schedule_check(void) {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        bloodboy_perform_open_instagram();
    });
}

static void __attribute__((constructor)) bloodboy_ig_safe_entry(void) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(__unused NSNotification *note) {
            bloodboy_schedule_check();
        }];
    });
}
