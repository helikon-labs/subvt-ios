<p align="center">
	<img width="400" src="https://raw.githubusercontent.com/helikon-labs/subvt/main/assets/design/logo/subvt_logo_blue.png">
</p>

# SubVT iOS

<p align="center">
    <img src="https://raw.githubusercontent.com/helikon-labs/subvt-ios/main/readme_files/subvt_ios_screenshots.jpg">
</p>

<a href="https://testflight.apple.com/join/mx6EkmFh" target="_blank"><img width="100" src="https://raw.githubusercontent.com/helikon-labs/subvt-ios/main/readme_files/app_store_button_large.svg"></a>

SubVT (Substrate Validator Toolkit) is a native mobile application for iOS and Android phones, tablets and wearables that provides node operators with tools that aid them in running their validators on Substrate-based blockchain networks.

Please visit the [top-level repository](https://github.com/helikon-labs/subvt) for detailed project information, and the [backend repository](https://github.com/helikon-labs/subvt-backend) for the backend system that power multiple applications such as SubVT for iOS and Android, SubVT Telegram Bot for [Polkadot](https://t.me/subvt_polkadot_bot) and [Kusama](https://t.me/subvt_kusama_bot) and [Chainviz](https://alpha.chainviz.app).

## Build

1. Clone this repository.
    1. `git clone https://github.com/helikon-labs/subvt-ios.git`
    2. `cd subvt-ios`
2. Rename the data service environment file, and edit the file to set the API & RPC endpoint URLs.
    1. `cd subvt-ios/SubVT/Resources/Config`
    2. `mv data-env-example.json data-env.json`
    3. Edit `data-env.json`.
3. If you'd like to use Crashlytics then copy your `GoogleService-Info.plist` file under `SubVT` folder in the root folder.
4. You should be able to open and run the project with XCode (developed with XCode 14.1).
