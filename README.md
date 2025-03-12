# pillarbox

A PoC Flutter plugin for pillarbox. Install packages with :

# For iOS

```
fvm install
fvm flutter config --enable-swift-package-manager
fvm flutter pub get
cd example
fvm flutter pub get
fvm flutter build ios
```

# For Android

Same as ios but github credential are required (https://github.com/SRGSSR/pillarbox-android?tab=readme-ov-file#create-a-personal-access-token).

```
~/.gradle/gradle.properties
gpr.user=<your_GitHub_username>
gpr.key=<your_GitHub_personal_access_token>
```
