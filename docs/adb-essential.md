# ADB
**Android Debug Bridge**

Android Debug Bridge or adb, is a command line tool that lets you communicate with a device (an emulator or a connected Android device). This tool is included in the Android SDK package and consists of both client and server-side programs that communicate with one another. This is not a guide on how to setup Android Debug Bridge rather a useful resource for the essential commands and functions that power users should know. The client-server program includes three main components:

+ Client, which runs on your local machine and sends commands to the daemon. You can envoke a client on a machine by using the **adb** command. The client checks if an adb server process is already running, if not it binds to local TCP port `5037` and listens for commands from the adb client. All adb clients use port `5037` to communicate with the adb server.
+ Daemon (**adbd**), runs as a background process on each device and issues commands sent to that device from a client application.
+ Server, runs as a background process on your local machine listening on port `5555` to `5585`, which is the range used by the first 16 emulators. Once the server finds an **adb** daemon `adbd`, it will then setup connections on that port.

Emulator uses a pair of sequential ports — an even-numbered port for console connections and an odd-numbered port for adb connections.

```
Emulator 1, console: 5554
Emulator 1, adb: 5555
Emulator 2, console: 5556
Emulator 2, adb: 5557
...
```

## Device Commands

| Command       | Description   |
| ------------- |:-------------:|
| adb devices | List connected devices |
| adb devices -l | List devcies and model |
| adb start-server | Starts the adbd server |
| adb kill-server | Kills the adb server |
| adb remount| Remounts filesystem r/w access |
| adb reboot | Reboots the device |
| adb shell | Gain user level shell access |
| adb root | Restarts adbd with root permissions |
| adb reboot bootloader| Reboots device into fastboot |
| adb connect **device_ip** | Connect over TCP to device  |


<br>`wait-for-device` can be used after `adb` to ensure the command will run once the device is connected.

`-s` flag can be used to send commands to a specific device when multiple are connected.

`disable-verity` is related to device-mapper-verity (dm-verity) kernel feature, which provides transparent integrity checks of block devices. This helps prevent persistent rootkits that can hold root priviledge. If trying to *mount* the system folder but receiving the error `dm_verity is enabled on the system and vendor partitions` you can issue the `adb shell su mount -o remount /system` or just reboot the bootloader with verity disabled `adb disable-verity`

```
Example

$ adb wait-for-device reboot bootloader
$ adb -s foodevice root
```

## File Management

| Command       | Description   |
| ------------- |:-------------:|
| adb push *local_file* **remote**  | Copy file to device |
| adb pull *remote_file* **local** | Pull file from device |

<br>

**Note**: If you need a file from a system application you can use
`adb shell su` (if su binary is present) and `cp` file to you sdcard
to later pull from the device.

```
$ adb shell su
$ cp /system/somefile /sdcard/somefile
$ exit
$ adb pull /sdcard/somefile file-from-device
$ adb push file-from-device /sdcard/somefile
```

## Logcat
**Every sysadmins favorite passtime**

| Command       | Description   |
| ------------- |:-------------:|
| adb logcat --help | Display logcat help dialog |
| adb logcat | Start printing log message to stdout |
| adb logcat -e `expr`| Prints logs that match regular expressions |
| adb logcat -g | Display current log buffer sizes |
| adb logcat -G *size* | Sets the buffer size (K or M) |
| adb logcat --pid=`pid`| Print logs from given PID |
| adb logcat -c | Clears the log buffers |
| adb logcat `*:V*` | Enables all log messages verbose |
| adb logcat -f *foofile* | Dumps specified file |

<br>

## Remote Shell Commands

The flags you choose to pass with adb must come before the command.

`adb -flag device command`

`$ adb -s android123 shell . . .`

| Command       | Description   |
| ------------- |:-------------:|
| adb -d | Direct command to the only running connected device |
| adb -e | Direct command to the only running emultor |
| adb -s | Direct command to specific serial number of device |
| adb shell `command` | Most Unix commands work here |
| adb shell monkey -p `app.package.name` | Starts the specific package |
| adb shell pm list packages | Lists all installed packages |
| adb shell pm list packages -3 | List 3rd-party packages|
| adb install app.package.name | Install package |
| adb install -r app.package.name | Re-install app and keep its data on device |
| adb uninstall app.package.name | Uninstall package and user data |
| adb uninstall -k app.package.name | Uninstall package but leave data |
| adb shell pm uninstall app.package.name | Uninstall package but leaves data |
| adb shell pm clear app.package.name | Deletes all data associated with package |

<br>
Example: Uninstall app from all connected devices:

```
adb devices | tail -n +2 | cut -sf 1 | xargs -IX adb -s X uninstall app.package.name
```

**Extras**

| Command       | Description   |
| ------------- |:-------------:|
| adb shell input text `"foo!,\ text \to \screen" `| Input text to device if field is selected |
| adb shell screencap -p /sdcard/foo.png | Screenshot device |
| adb shell screenrecord /sdcard/foocreep.mp4 | Record screen of device |
| adb shell am start -a android.intent.action.VIEW -d $URL | Open URL in default browser |

<br>