# vkMusic
[![vkMusicBuild](https://img.shields.io/badge/build-passing-brightgreen.svg)]()
[![vkMusicStage](https://img.shields.io/badge/stage-beta-orange.svg)]()
[![vkMusicVersion](https://img.shields.io/badge/release-v1.1.1-blue.svg)]()
[![vkMusicVersion](https://img.shields.io/badge/license-BSD 3--clause revised-blue.svg)]()

# IMPORTANT UPDATE #
<b> Public access to the VK Api was disabled, and as of 2017, it is no longer possible to get music data from VK, and thus much of vkMusic's functionality is broken. The code for VK will NOT be deleted, as the original intent of this project was to provide example usage of VK API </b>

vkMusic is a piece of software that is intended to show one of the possible uses of the VK iOS API by downloading music onto the phone to be later replayed
while the user is offline. The user can listen to friend's music, suggestions based on previous playback, as well as sync with their VK media library.

## Fair Use
This software is intended to be used for educational purposes. Feel free to copy, modify, and redistribute the
software as long as credit is given to the various contributors. Since this software is intended to demonstrate an example of the VK
iOS API usage, no contributors may be liable for any damages or any copyright infringements that might occur due to downloads of 
copyrighted content. In jurisdictions where it's legal to download music for personal use, this project may be built as a comlete piece
of software and used under legal conditions.

## Necessary Setup for XCODE 7
After cloning the repository, a few things need to be edited:
  1. As specified in the iOS SDK documentation, you need to register your application with VK to authenticate the user. You can follow
  the instructions at https://vk.com/dev/ios_sdk, or simply do the following. Go to https://vk.com/dev/, hit 'create application' (you will
  need a VK account for this). Follow the instructions until your application is created. You will then see a settings tab on the left-hand
  side of the screen. Click on it and copy your Application ID.
  2. There are two files that need to be modified to include the Application ID. First, go to your project settings, hit the info tab under
  targets, and expand the URL Types subsection. Click on the + icon, and you should an "Identifier" and "URL Schemes" text field. Into each,
  enter the value "vk"+APP_ID. Therefore, if your APP ID is 123456, then you should enter "vk123456" into both fields.
  3. Once the URL Scheme is set up, you need to specify the APP ID in the FirstViewController.m file. In the first few lines, where a static
  NSString is declared with name APP_ID, change @"" to be @"*app_id_here*". If your APP ID is 123456, then, the line should read:
    
    static NSString *const APP_ID = @"123456";
    
  4. Build and run the project!
