# Fabric Mod Updater (by weed6)

In simpler terms, this program basically edits the gradle.properties, build.gradle, and fabric.mod.json in the selected project folder to make it easier for Fabric mod developers to seamlessly switch compatible Minecraft versions without too much effort.

Supported versions: 1.21.1, 1.21.2, 1.21.3, 1.21.4, 1.21.8, 1.21.11

Compatibility: This tool does not work with every mod enivorment. It is designed for Standard Fabric API client mods (HUDs, utilities, overlays). It does not support Mixin-heavy, Multi-Loader, or Kotlin-based projects.

How to use: Select your project folder (the one containing gradle.properties, build.gradle, etc.) in the program, select your preferred Minecraft version, then click 'Done'. Then click the path of the project folder and enter `cmd`. Run `gradlew clean build` in the command prompt and you should be able to find your compiled mod in *\[Project Folder]\build\libs* once it is done.

Caution: The program was made using ps2exe so it is likely that Windows Defender will block it. Because the ps2exe tool converts PowerShell scripts into .exe files, malware creators use that exact same tool to hide viruses. Because of this, Windows Defender and other antiviruses treat all .exe files made with ps2exe as highly suspicious. Turn off Real-Time Protection in **Virus & Threat Protection** in your Windows Defender settings.
