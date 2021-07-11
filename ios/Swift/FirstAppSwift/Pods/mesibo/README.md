## Mesibo Frameworks for iOS
Visit https://mesibo.com for documentation.

## Installation
The Mesibo SDKs for iOS are available as CocoaPods pods OR individual frameworks that can be installed manually. 

[CocoaPods](http://cocoapods.org) is an open source dependency manager for Swift and Objective-C Cocoa projects, which automates the process of using 3rd-party libraries like Mesibo in your projects. For details, see the [CocoaPods Getting Started guide](https://guides.cocoapods.org/using/getting-started.html).

If you prefer to install manually, you can click [here](#install-manually).

> Whatever the method you prefer, ensure that [git lfs](https://git-lfs.github.com/) is installed before you proceed. 

## Install Using CocoaPods
If you already have the CocoaPods tool, skip to Step 2. 

### Step 1: Install CocoaPods

[CocoaPods](http://cocoapods.org) is an open source dependency manager for Swift and Objective-C Cocoa projects, which automates the process of using 3rd-party libraries like Mesibo in your projects. For details, see the [CocoaPods Getting Started guide](https://guides.cocoapods.org/using/getting-started.html).

You can install CocoaPods by running the following commands in Terminal.app:

    $ sudo gem install cocoapods
    $ pod setup

> Depending on your Ruby installation, you may not have to run as `sudo` to install the cocoapods gem.

### Step 2: Create a Podfile

Project dependencies to be managed by CocoaPods are specified in a file name `Podfile`. Create this file in the same directory as your Xcode project (`.xcodeproj`) file and Copy and paste the following lines into it:  
    
    target "YourTargetName" do
        source 'https://github.com/CocoaPods/Specs.git'
        pod 'mesibo'
    end

This will install mesibo core API framework into your project.

### Step 3: Install Mesibo Core API Framework

Now you can install mesibo the dependencies in your project:

    $ pod install

From now on, be sure to always open the generated Xcode workspace (`.xcworkspace`) instead of the project file when building your project:

    $ open <YourProjectName>.xcworkspace

### Step 4: Install Mesibo UI and Calls Framework

Similarly, you can also install mesibo-ui and mesibo-calls framework as following:

    target "YourTargetName" do
        source 'https://github.com/CocoaPods/Specs.git'
        pod 'mesibo-ui'
        pod 'mesibo-calls'
    end


### Step 4: That's All!

At this point, everything's in place for you to start using Mesibo. Just `#import` the headers for the classes you need and start coding!

    #import <Mesibo/Mesibo.h>
    #import <MesiboUI/MesiboUI.h>
    #import <MesiboCall/MesiboCall.h>

## Install Manually
You can add mesibo frameworks manually to your project.

You can download all the Mesibo frameworks for iOS from [GitHub](https://github.com/mesibo/mesiboframeworks) OR by by running the following commands in Terminal.app:

    git clone https://github.com/mesibo/mesiboframeworks.git

If you are using, Mesibo Call framework, you also need to download Mesibo WebRTC framework by downloading from [GitHub](https://github.com/mesibo/mesibowebrtcframework) OR by by running the following commands in Terminal.app:

    git clone https://github.com/mesibo/mesibowebrtcframework.git

### Mesibo Core API Framework
  1. Drag `mesibo.framework` to your xcode project. Xcode will prompt you for various options - make sure to select **Copy items if needed**

  2. Import header in your project

    #import <Mesibo/Mesibo.h>

### Mesibo UI Framework
  1. Drag `messaging.framework` to your xcode project. Xcode will prompt you for various options - make sure to select **Copy items if needed**

  2. Right-click `messaging.framework` in your project, and select "Show In Finder".

  3. Drag the `messagingui.bundle` from the Resources folder into your project. When prompted, ensure that *Copy items into destination* group's folder is **NOT** selected.

  4. Import header in your project

    #import <MesiboUI/MesiboUI.h>

> Mesibo UI SDK uses google map and place API to send location. Hence, in order to use this feature, you must be having Google map and place framework and also your Google API key in the info.plist - refer [how to get your google map api key and install it](https://developers.google.com/places/ios-api/start#step-2-install-the-api).

### Mesibo Voice and Video Call Framework
  1. Drag `mesibocall.framework` to your xcode project. Xcode will prompt you for various options - make sure to select **Copy items if needed**

  2. Right-click `mesibocall.framework` in your project, and select "Show In Finder".

  3. Drag the `MesiboCallBundle.bundle` from the Resources folder into your project. When prompted, ensure that *Copy items into destination* group's folder is **NOT** selected.

  4. Import header in your project

    #import <MesiboCall/MesiboCall.h>
  

You can now begin developing features with mesibo. Be sure you update these frameworks each time mesibo is updated.


