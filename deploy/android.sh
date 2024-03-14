#!/bin/sh
flutter build appbundle --flavor master --build-number $TRAVIS_BUILD_NUMBER
cd android
bundle exec fastlane deploy