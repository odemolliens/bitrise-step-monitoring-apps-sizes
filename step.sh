#!/bin/bash
set -ex

echo "---- CONFIG ----"
if [ -n "$config_file_path" ]; then
    echo "get config from the config file"
    source $config_file_path
else
    echo "get config from bitrise input"
fi;

if [[ ${check_android} == "yes" && ${android_apk_size} == "" ]]; then
    echo "Error: Config keys are not set preperly"
    echo "Error: You configured to check android part but android_apk_size is not set "
    exit 1
fi

if [[ ${check_ios} == "yes" && ${ios_ipa_size} == ""  ]]; then
    echo "Error: Config keys are not set preperly"
    echo "Error: You configured to check ios part but ios_apk_size is not set "
    exit 1
fi

if [[ ${alert_threshold} == ""  ]]; then
    alert_threshold="5"
fi

if [[ ${check_android} == "yes" ]]; then
    # SIZE CHECK - if the size of the new APk bigger than the size set into config file or on bitrise
    ANDROID_NEW_APP_SIZE=$(wc -c "android.apk" | awk '{print $1}')
    ANDROID_NEW_APP_SIZE_MB=$(echo "$ANDROID_NEW_APP_SIZE / 1024^2" | bc)

    APK_SIZE_WITH_ALERT_THRESHOLD=$(($android_apk_size + $alert_threshold))
    if [ $ANDROID_NEW_APP_SIZE_MB -gt $APK_SIZE_WITH_ALERT_THRESHOLD ]; then
        NEW_APK_SIZE=$ANDROID_NEW_APP_SIZE_MB
        envman add --key NEW_APK_SIZE --value $NEW_APK_SIZE
    fi
fi

if [[ ${check_ios} == "yes" ]]; then
    # SIZE CHECK - if the size of the new IPA bigger than the size set into config file or on bitrise
    IOS_NEW_APP_SIZE=$(wc -c "ios.ipa" | awk '{print $1}')
    IOS_NEW_APP_SIZE_MB=$(echo "$IOS_NEW_APP_SIZE / 1024^2" | bc)

    IPA_SIZE_WITH_ALERT_THRESHOLD=$(($ios_ipa_size + $alert_threshold))
    if [ $IOS_NEW_APP_SIZE_MB -gt $IPA_SIZE_WITH_ALERT_THRESHOLD ]; then
        NEW_IPA_SIZE=$IOS_NEW_APP_SIZE_MB
        envman add --key NEW_IPA_SIZE --value $NEW_IPA_SIZE
    fi
fi

echo "---- REPORT ----"


if [ ! -f "quality_report.txt" ]; then
    printf "QUALITY REPORT\n\n\n" > quality_report.txt
fi

printf ">>>>>>>>>>  CURRENT APP SIZES  <<<<<<<<<<\n" >> quality_report.txt
if [[ ${check_android} == "yes" ]]; then
    printf "Android APK: $android_apk_size MB \n" >> quality_report.txt
fi
if [[ ${check_ios} == "yes" ]]; then
    printf "iOS IPA: $ios_ipa_size MB \n" >> quality_report.txt
fi

printf "\n\n" >> quality_report.txt

if [[ ${check_android} == "yes" ]]; then
    printf "   >>>>>>>  ANDROID  <<<<<<< \n" >> quality_report.txt
    if [[ ${NEW_APK_SIZE} != "" ]]; then
        printf "!!! New Android apk is bigger !!!\n" >> quality_report.txt
        printf "It weighed: $android_apk_size MB \n" >> quality_report.txt
        printf "And now: $NEW_APK_SIZE MB \n" >> quality_report.txt
    else
        printf "0 alert \n" >> quality_report.txt
    fi
    printf "\n" >> quality_report.txt
fi

if [[ ${check_ios} == "yes" ]]; then
    printf "   >>>>>>>  IOS  <<<<<<< \n" >> quality_report.txt
    if [[ ${NEW_IPA_SIZE} != "" ]]; then
        printf "!!! New iOS ipa is bigger !!!\n" >> quality_report.txt
        printf "It weighed: $ios_ipa_size MB \n" >> quality_report.txt
        printf "And now: $NEW_IPA_SIZE MB \n\n" >> quality_report.txt
    else
        printf "0 alert \n" >> quality_report.txt
    fi
    printf "\n" >> quality_report.txt
fi

cp quality_report.txt /Users/vagrant/deploy/quality_report.txt || true

if [[ ${NEW_APK_SIZE} != "" || ${NEW_IPA_SIZE} != ""  ]]; then
    echo "Generate an error due to app size alert"
    exit 1
fi
exit 0