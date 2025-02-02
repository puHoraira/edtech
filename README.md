# edtech

Project about Online Education App (LearnSphere) [Previously EdTech]


Apk file : https://drive.google.com/drive/folders/10mQJtZjhcYVyHDqe6WLUhivX_pow-DzS?usp=sharing

Date: 29/12/2024


Project for second semester second year android lab course


Instructor: Fahim Arefn Sir, Lecturer, Computer Science and Engineering, University of Dhaka


## Getting Started

# commands
flutter pub add go_router

flutter pub add cloud_firestore

flutter pub add firebase_auth (normal users no need to perform that)

flutter pub add uuid

flutter pub add url_launcher

flutter pub add shared_preferences

flutterfire configure

flutter pub add firebase_storage



android sdk version problem solution:

│ The plugin firebase_auth requires a higher Android SDK version.                                 │
│ Fix this issue by adding the following to the file D:\.....\edtech\android\app\build.gradle: │
│ android {                                                                                       │
│   defaultConfig {                                                                               │
│     minSdkVersion 23                                                                            │
│   }                                                                                             │
│ }

androidManifest.xml modificaitons:


<uses-permission android:name="android.permission.QUERY_ALL_PACKAGES" />  // after <manifest>
<intent>
<action android:name="android.intent.action.VIEW" />
<category android:name="android.intent.category.BROWSABLE" />
<data android:scheme="https" />
</intent>

