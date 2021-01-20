<img align="right" src="assets/icon.svg" width="150" height="150" >

# Bitrise step - Mobile apps sizes monitoring

Check mobile applications sizes and compare with configured values to be warned when sizes increased

You have to launch this step after [apps-decompiler](https://github.com/imranMnts/bitrise-step-apps-decompiler) to have informations from your APK/IPA

We are looking into the APK/IPA to be sure to have the **REAL** information because during the development of a mobile application, many libraries can be used and these can add some permissions or useless heavy resources without the consent of the developer. Like that, we can follow up them and be aware when we have any unwanted changes

<br/>

## Usage

Add this step using standard Workflow Editor and provide required input environment variables.

<br/>

To give to our step the informations about the expected values, you have:
- create a config file (which should be added to your project repository) and set `config_file_path`  to find them. You can find a config example file [here](#config-file-example)
- **OR** set these keys with expected values directly on Bitrise side
  - android_apk_size
  - ios_ipa_size
  - alert_threshold

<br/>

## Inputs

The asterisks (*) mean mandatory keys

|Key             |Value type                     |Description    |Default value        
|----------------|-------------|--------------|--------------|
|check_android* |yes/no |Setup - Set yes if you want check Android part|yes|
|check_ios* |yes/no |Setup - Set yes if you want check iOS part|yes|
|config_file_path |String |Config file path - You can create a config file (see bellow example) where you can set different needed data to follow up values via your git client - eg. `folder/config.sh` ||
|android_apk_size | String |Config - APK's expected size (value in MB) - *not need to set if already set into your config file*||
|ios_ipa_size | String |Config - IPA's expected size (value in MB) - *not need to set if already set into your config file*||
|alert_threshold | String |Config - To generate an error when Android and/or iOS app's size exceeds this threshold - *not need to set if already set into your config file*|5 (MB)|

<br />

## Outputs

|Key             |Value type    |Description
|----------------|-------------|--------------|
|NEW_IPA_SIZE |String |New generated iOS app's size|
|NEW_APK_SIZE |String |New generated Android app's size|

<br />

### Config file example

config.sh
```bash
android_apk_size=35
ios_ipa_size=28
alert_threshold=3
```
