![control-hints-thumb-4](https://github.com/user-attachments/assets/47c2066f-d2c9-44c7-89d2-8a9b10aee8fb)

Creating and managing UI for showing game controls has always been one of those tedious tasks that plagued development. Everyone knows they should add it, but there's no easy way of going about it. Look no further, I have the definitive solution for you. **Control Hints** integrates seamlessly with Input Action System (IAS) to generate pretty control hints **complete with industry-standard icons for PC, Xbox, PlayStation, and Mobile.**

### ⭐️ Key Features
- **IAS Compatibility**: Works with the standard IAS setup (Context -> Action -> Binding)
- **Game-Agnostic**: If your game has IAS, you can add Control Hints to it
- **All Platforms**: Keyboard/mouse, Xbox, PlayStation, and mobile devices
- **Customizable**: Choose from premade display styles and icon sets, or make your own
- **Safety First**: All code is written with strict typechecking
- **Optional Features**: Responsive icons, key combinations, and more

### 🕹️ Try Me!
An open-source FPS demo game is available to test the capabilities of Control Hints:
[Control Hints: FPS - Roblox](https://www.roblox.com/games/134115175730196/Control-Hints-FPS)

### ✅ Ready in Four Steps
1. Grab the free model from [Creator Store](https://create.roblox.com/store/asset/87894581499695/Control-Hints) or download the .rbxm file in the repo
2. Ungroup the folders in the model in their correct locations
3. Group all of your InputContexts into a Folder under StarterPlayer -> StarterPlayerScripts
4. Set ```IAS_SETUP``` in the given LocalScript to your new Folder


<details>
<summary>Example IAS Setup</summary>

<img width="184" height="120" alt="Screenshot 2026-02-14 at 6 59 52 AM" src="https://github.com/user-attachments/assets/e48aff72-9df5-4d51-ab86-691ea0a3d853" />

InputBindings whose name begins with...
* "Keyboard" -> shown to PC players
* "Gamepad" -> shown to console players
* "Mobile" -> shown to mobile players

By default, the name of the InputAction is displayed, but this can be overridden by setting the CustomName attribute (string) for the InputAction. You can also set the CustomOrder attribute (number) to override the auto-sort.
</details>

### ⚠️ Known Limitations
- Included icons are only for commonly-used keys. Things like numpad keys or function keys are excluded.
