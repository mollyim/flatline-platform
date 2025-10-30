# Flatline Prototype Evaluation

This document briefly describes the steps required or suggested to build and evaluate Molly clients with the Flatline prototype. This documentation focuses on the default case, in which Molly clients run under the Android Emulator in the same host where Flatline is installed. However, this documentation will offer some brief indications for evaluation in environments where Flatline is deployed on a different host or Molly is installed in physical devices.

## Install Flatline

Install Flatline following the [installation](installation.md) instructions.

## Build Molly for Flatline

### Requirements

- Install the Android SDK. Ensure that your environment has `ANDROID_HOME` pointing to its path.
- Install the tools and dependencies to build `libsignal`. For example, on Debian/Ubuntu:

```bash
# This value should match the contents of the "rust-toolchain" file in the repository.
LIBSIGNAL_RUST_TOOLCHAIN=nightly-2025-02-25
apt update
apt install rustup clang protobuf-compiler cmake make crossbuild-essential-arm64
rustup toolchain install $LIBSIGNAL_RUST_TOOLCHAIN \
  --profile minimal \
  --target aarch64-linux-android \
  --target armv7-linux-androideabi \
  --target x86_64-linux-android \
  --target aarch64-unknown-linux-gnu
```

### Build

1. Check out the "flatline-dev-build" branch of the Molly source.

```bash
git clone -b flatline-dev-build https://github.com/mollyim/mollyim-android
```

2. Check out the "flatline-dev-build" branch of Molly's `libsignal` fork in the same parent directory.

```bash
git clone -b flatline-dev-build https://github.com/mollyim/libsignal
```

3. Apply the following patch to the Molly source:

```diff
diff --git a/gradle.properties b/gradle.properties
index 696c269af1..682cb8d725 100644
--- a/gradle.properties
+++ b/gradle.properties
@@ -11,5 +11,5 @@ org.gradle.configuration-cache=false
 org.gradle.java.installations.auto-download=false
 
 # Uncomment these to build libsignal from source.
-# libsignalClientPath=../libsignal
-# org.gradle.dependency.verification=lenient
+libsignalClientPath=../libsignal
+org.gradle.dependency.verification=lenient
```

4. Open the Molly source in Android Studio.

5. Navigate to `Tools > SDK Manager > SDK` Tools and install `NDK 28.0.13004108`.

6. Select `devFossWebsiteDebug` as build variant.

7. Build the application and deploy it to your evaluation devices.

## Internal Domain Resolution

Ensure that the client devices are able to resolve the "flatline.internal" hostname, which is configured by default in the Helm chart. To do so when using the Android Emulator, simply add the following entries to the `/etc/hosts` file in the host running both Flatline and the Android Emulator:

```
10.0.2.2 flatline.internal
10.0.2.2 whisper.flatline.internal
10.0.2.2 storage.flatline.internal
10.0.2.2 cdn0.flatline.internal
10.0.2.2 cdn3.flatline.internal
10.0.2.2 sfu.flatline.internal
10.0.2.2 turn.flatline.internal
```

The `10.0.2.2` address allows the emulated devices to [reach the host](https://developer.android.com/studio/run/emulator-networking), where Flatline is installed.

If Flatline is installed in a different host or physical devices are being used for this evaluation, ensure that client devices are able to resolve those hostnames to an IP address where they can reach Flatline. Ensure that the `global.advertisedAddress` Helm value is [changed](installation.md#customizing-the-installation) to that same IP address so that multimedia calls can work.

If the hostname used for Flatline has been [changed](#changing-hostname) to a publicly registered domain, this step should not be necessary, as long as the DNS servers used by the Android Emulator host or client devices can resolve the name to an IP address that will be reachable by the clients.

## Creating Accounts

The previous steps should leave you with an emulated or physical device that has the Molly application installed and that is able to reach Flatline over the network. To test this, attempt to create an account:

1. Open the Molly application. Grant the required permissions as prompted.

2. When asked for a phone number, enter any valid one. Remember the last six digits.

3. When asked for the verification code, enter the last six digits of the phone number.

4. When asked for a PIN, enter any accepted number. The PIN will [fail to be stored](architecture.md#secure-value-recovery).

5. Navigate to `Settings` and tap on your avatar picture.

6. Configure a username.

To test any communication features, follow the above procedure with two or more devices.

If you find any unexpected errors or other issues, review the application logs using Logcat in Android Studio and the logs from the Whisper component using `kubectl` to ensure that requests are reaching Flatline and are being successfully handled.

## Testing Communication

The following steps should allow two devices to communicate with each other:

1. Tap on the bottom-right pencil icon.

2. You may see an error when [attempting to retrieve contacts](architecture.md#contact-discovery-service).

3. Tap on `Find by username`.

4. Write the username registered for the other device.

5. The chat window will open, allowing you to message the other device.

Once both users are in contact, you will be able to test messaging, attachments, multimedia calls...

If you find any unexpected errors or other issues, review the logs as described [above](#creating-accounts). If the logs seem correct but messages are not reaching some of the clients, re-install the Molly application in both devices through Android Studio (`Shift+F10`) to force reconnection to Whisper.

## Extra Operations

This section describes operations that may be useful during the evaluation of Flatline.

### Changing Hostname

The default hostname defined for Flatline in the Helm chart is "flatline.internal". Defaulting to a hostname on a reserved TLD ensures that users can test Flatline without having to register a domain name or having to generate any certificates themselves.

To host Flatline on a different hostname, [change](installation.md#customizing-the-installation) the `global.hostname` value in the Helm chart. You will need to update the certificate used in Traefik, which is also pinned by the Molly application and its CA is pinned by `libsignal`.

The following are steps to re-generate and re-distribute all the necessary cryptographic material when changing the hostname used by Flatline. These steps rely on the [certificate generation script](../charts/flatline/files/traefik/gen-certs.sh).

1. Decide on the hostname to use for Flatline.

2. Update the `*.cnf` files under `charts/flatline/files/traefik` to use that hostname. Ensure that the wildcard names are updated but kept, so that the certificate is valid for all Flatline component hostnames.

3. Download a [Bouncy Castle provider JAR](https://www.bouncycastle.org/download/bouncy-castle-java/).

4. Run the certificate generation script:

```bash
# Optional: Add "-ca" to also re-generate the certificate authority.
./gen-certs.sh -cert -bc <PATH_TO_BOUNCY_CASTLE_PROVIDER_JAR>
```

5. Copy the newly generated `whisper.store` file to the Molly repository as `app/src/main/res/raw/whisper.store`.

6. Optional. Copy the newly generated `ca.cer` file to the `libsignal` repository as `rust/net/res/internal.cer`.

7. Upgrade the existing Helm chart installation or install it from scratch.

8. Update the URL references found under the `dev` environment in the `app/build.gradle.kts`.

9. Synchronize and re-build the Molly project in Android Studio and re-install the application.