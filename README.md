# coords (FX Standalone)

Lightweight, optimized **/coords** tool that shows a precise **vector4(x, y, z, h)** for your current position and heading. Clean UI with proper focus/mouse handling. No frameworks or server code required.

## Features
- **/coords** toggles UI (no auto-open on resource start)
- Shows **vector4** with configurable decimals
- **Copy** button (also posts to client console & optional chat message)
- **ESC / Cancel** cleanly closes the UI and releases mouse focus
- Optional keybind command: `coordstoggle` (bind it with `/bind keyboard F10 coordstoggle`)
- Defensive cleanup on resource stop
- No busy loops or unnecessary threads

## Install
1. Drop the folder **coords/** into your `resources` directory.
2. Add `ensure coords` to your `server.cfg`.
3. Start your server.

## Usage
- `/coords` → open/close the UI
- Click **Copy** to capture the latest vector4 and copy to clipboard.
- Press **ESC** or click **Cancel** to close and release the mouse.
- Optional: bind a key to open/close:
  ```
  /bind keyboard F10 coordstoggle
  ```

## Output Example
```
vector4(-268.123, -956.456, 31.221, 274.15)
```

## Configuration
The client has a tiny embedded `Config` table:
```lua
local Config = {
  Decimals = 3,         -- decimal places for x,y,z
  HeadingDecimals = 2,  -- decimal places for heading
  PrintOnOpen = true,   -- print coords immediately on open
  ChatOnCopy = true,    -- show chat message when copied
  Command = 'coords'    -- command name
}
```

## Notes
- **Standalone**: no ESX/QBCore/vRP required.
- Uses NUI; UI is only active when open.
- Escapes cleanly on `onResourceStop`.

## Changelog
See **UPDATES.log**.
