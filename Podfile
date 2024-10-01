platform :ios, '13.0'
use_frameworks!
inhibit_all_warnings!

system("

mkdir -p ./SDK

if [ -d ./SDK/Marketplace ]; then
   echo 'Marketplace directory exists, install pods and quit'
   cd ./SDK/Marketplace; git fetch origin; git pull; pod install;
   cd ../../
else
   echo 'Will clone Marketplace'
   git clone https://git.lgn.me/prime/prime-2/marketplace-ios.git ./SDK/Marketplace
   cd ./SDK/Marketplace; git checkout main; pod install;
   cd ../../
fi
       ")

workspace 'PrimePark.xcworkspace'
project 'PrimePark.xcodeproj'
project './SDK/Marketplace/MarketPlace.xcodeproj'

def shared_pods
  pod 'SwiftLint', '0.40.0'
  pod 'SnapKit', '5.0.0'
  pod 'SkeletonView'
  pod 'FloatingPanel', :git => 'https://github.com/scenee/FloatingPanel', :branch => 'v1'
  pod 'Alamofire', '4.7.3'
  pod 'PromiseKit', '6.13.0'
  pod 'Nuke', '9.1.2'
  pod 'libPhoneNumber-iOS', '~> 0.8'
  pod 'ChatSDK', :git => 'https://git.lgn.me/technolab/pr1me/chat_ios.git', :branch => 'PRIME_PARK'
  pod 'AnyCodable-FlightSchool', '~> 0.3.0'
  pod 'FSCalendar'
  pod 'DynamicBlurView'
  pod 'FBSDKCoreKit', '~> 8.0.0'
#  pod 'Firebase', '8.9.1'
#  pod 'Firebase/Crashlytics'
  #pod 'Firebase'
  #pod 'YandexMobileMetrica', '3.14.0'
  pod 'PhoneNumberKit', '~> 3.3'
end

def marketplace_pods
   pod 'SnapKit', '5.0.0'
end
   
target 'PrimePark' do
  project 'PrimePark.xcodeproj'
  shared_pods
end
    
target 'MarketPlace' do
   project './SDK/Marketplace/MarketPlace.xcodeproj'
   marketplace_pods
end

target 'PrimeParkSimulator' do
 project 'PrimePark.xcodeproj'
  shared_pods
end

target 'OneSignalNotificationServiceExtension' do
project 'PrimePark.xcodeproj'
  #only copy below line
  pod 'OneSignal', '>= 3.0.0', '< 4.0'
end

post_install do |installer|
         installer.pods_project.targets.each do |target|
           target.build_configurations.each do |config|
             config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
       end
    end
end
