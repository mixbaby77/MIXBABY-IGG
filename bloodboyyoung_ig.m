#import <UIKit/UIKit.h>

static NSString * const kBloodboyIGDoneKey = @"felix.ig.bloodboyyoung.mixbaby.firstlaunch.done";
static NSString * const kBloodboyIGUsername = @"bloodboyyoung.mixbaby";
static NSString * const kBloodboyIGTargetURL = @"https://www.instagram.com/bloodboyyoung.mixbaby?avpt=MXhodHU4OXdrYXptNg%3D%3D&utm_source=qr";

static void bloodboy_open_ig_once(void) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:kBloodboyIGDoneKey]) {
        return;
    }

    [defaults setBool:YES forKey:kBloodboyIGDoneKey];
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

static void __attribute__((constructor)) bloodboy_ig_entry(void) {
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidBecomeActiveNotification
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification * _Nonnull note) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            bloodboy_open_ig_once();
        });
    }];
}
