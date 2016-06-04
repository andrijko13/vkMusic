//
//  FirstViewController.m
//  vkMusic
//
//  Created by Andriy Suden on 2/21/16.
//  Copyright © 2016 DropGeeks. All rights reserved.
//

#import "FirstViewController.h"

static NSString *const TOKEN_KEY = @"my_application_access_token";
static NSString *const NEXT_CONTROLLER_SEGUE_ID = @"START_WORK";
// Change APP_ID to your personal APP_ID, as specified in your VK app
static NSString *const APP_ID = @"";
static NSArray  *SCOPE = nil;

@interface FirstViewController () <UIAlertViewDelegate, VKSdkUIDelegate>

@end

@implementation FirstViewController
@synthesize _vkButton;
@synthesize _loginButton;
@synthesize _delegate;

-(IBAction)vkClicked:(id)sender{
    [_delegate setFriend:0];
    [self performSegueWithIdentifier:@"DoingView" sender:self];
}

- (IBAction)_musButton:(id)sender {
    [self performSegueWithIdentifier:@"showMusic" sender:self];
}

- (IBAction)_searchButton:(id)sender {
    [self performSegueWithIdentifier:@"searchMusic" sender:self];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)viewDidLoad {
    
    self._delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    SCOPE = @[VK_PER_FRIENDS, VK_PER_WALL, VK_PER_AUDIO, VK_PER_PHOTOS, VK_PER_EMAIL, VK_PER_MESSAGES];
    
    [self setupMusicFolder];
    
    [super viewDidLoad];
    [[VKSdk initializeWithAppId:APP_ID] registerDelegate:self];
    [[VKSdk instance] setUiDelegate:self];
    [VKSdk wakeUpSession:SCOPE completeBlock:^(VKAuthorizationState state, NSError *error) {
        if (state == VKAuthorizationAuthorized) {
            [_loginButton setTitle:@"Logged In" forState:UIControlStateNormal];
            [_loginButton setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:210.0f/255.0f blue:118.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [self startWorking];
        } else if (error) {
            [[[UIAlertView alloc] initWithTitle:nil message:@"Your connection appears to be offline. Network services disabled." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
            [_loginButton setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:183.0f/255.0f blue:82.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            //[_loginButton setTitle:@"Log in to get started" forState:UIControlStateNormal];
        }
        else {
            [_loginButton setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:183.0f/255.0f blue:82.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
            [_loginButton setTitle:@"Log in to get started" forState:UIControlStateNormal];
        }
    }];
}

- (void)setupMusicFolder{
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Documents
    NSString *dataPath = [documentsDirectory stringByAppendingPathComponent:@"/music"]; // Make new folder path
    
    // if the folder doesn't exist, make it
    if (![[NSFileManager defaultManager] fileExistsAtPath:dataPath])
        [[NSFileManager defaultManager] createDirectoryAtPath:dataPath withIntermediateDirectories:NO attributes:nil error:&error];
    
}

- (void)startWorking {
    //[self performSegueWithIdentifier:@"DoingView" sender:self];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)authorize:(id)sender {
    [VKSdk authorize:SCOPE];
}

/*- (IBAction)openShareDialog:(id)sender {
    VKShareDialogController *shareDialog = [VKShareDialogController new];
    shareDialog.text = @"This post created created created created and made and post and delivered using #vksdk #ios";
    shareDialog.uploadImages = @[ [VKUploadImage uploadImageWithImage:[UIImage imageNamed:@"apple"] andParams:[VKImageParameters jpegImageWithQuality:1.0] ] ];
    [shareDialog setCompletionHandler:^(VKShareDialogController *dialog, VKShareDialogControllerResult result) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
    [self presentViewController:shareDialog animated:YES completion:nil];
}*/


- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
    [vc presentIn:self.navigationController.topViewController];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [self authorize:nil];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    if (result.token) {
        [self startWorking];
        [_loginButton setTitle:@"Logged In" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor colorWithRed:0.0f/255.0f green:210.0f/255.0f blue:118.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
    } else if (result.error) {
//        result.error = result.error;
        [_loginButton setTitle:@"Log in to get started" forState:UIControlStateNormal];
        [_loginButton setTitleColor:[UIColor colorWithRed:255.0f/255.0f green:183.0f/255.0f blue:82.0f/255.0f alpha:1.0f] forState:UIControlStateNormal];
        [[[UIAlertView alloc] initWithTitle:nil message:[NSString stringWithFormat:@"Authorization Failed"] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    }
}

- (void)vkSdkUserAuthorizationFailed {
    [[[UIAlertView alloc] initWithTitle:nil message:@"Access Denied" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil] show];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}


@end
