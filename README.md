# Cell Quest

![Cell Quest Logo](cellquestlogo.png)

An educational game where you play as a drug molecule navigating inside the brain, fighting abnormal cells and tumors. Built with Overworld's Waypoint world model for real-time visual generation.

## Features

- Real-time world generation using Waypoint AI model
- Health bar system with player and enemy stats
- Context bank for visual consistency
- Video frame extraction for reference images
- Auto-reinforce system to maintain scene coherence

## How to Play

1. Enter the passphrase to connect to a GPU server
2. Upload a reference image or video frame
3. Click "USE AS LOOPING CONTEXT" for visual consistency
4. Click canvas to lock mouse
5. WASD to move, mouse to look around
6. Left click to fire at abnormal cells
7. Destroy all abnormal cells before your health runs out

## Controls

| Key | Action |
|-----|--------|
| W/A/S/D | Move |
| Mouse | Look around |
| Left Click | Fire |
| Right Click | Aim |
| Shift | Sprint |
| Space | Jump |
| P / Esc | Pause |
| U | Reset to seed |

## Running Locally

```bash
npm run dev
```

Then open http://localhost:3000

## Requirements

- Overworld hackathon passphrase for GPU access
- Modern browser with WebSocket support

## Tech Stack

- Vanilla HTML/CSS/JavaScript
- WebSocket for real-time communication
- Overworld Waypoint world model API

## API Protocol

The game connects to Overworld's GPU servers via:
1. HTTP claim request with passphrase
2. WebSocket connection for frame streaming
3. Control messages (keyboard/mouse input)
4. Seed image and prompt for scene conditioning

## License

MIT
