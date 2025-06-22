# 🎯 Professional SA-MP Bingo Server

A complete **individual bingo system** for SA-MP servers with unique 5x7 bingo fields for each player.

## 🎮 Features

### ✨ Individual Bingo System
- **5x7 bingo field** (35 cells) for each player
- **Unique random cell selection** per player  
- **12 total prizes** (5 rows + 7 columns)
- **Anti-duplicate prize system**
- **Multiple prize detection** (win several at once)

### 🎁 Prize System
- **Row Prizes (Horizontal):**
  - Row 0: Game Currency 300000
  - Row 1: Jaguar XKR-S  
  - Row 2: Neon Sword #1
  - Row 3: Skin (2415)
  - Row 4: Nissan GTR

- **Column Prizes (Vertical):**
  - Column 0: Samurai Gas Mask
  - Column 1: Game Currency 150000
  - Column 2: Skin (2363)
  - Column 3: Ferrari 365 GTB/4
  - Column 4: Green Dragon
  - Column 5: 10 EXP
  - Column 6: BMW Alpina B7 Widebody

### 🔄 Fresh Start System
- **No data persistence** - each connection starts fresh
- **Anti-cheat protection** - prevents reconnection exploits
- **Fair gameplay** for all players

## 🎲 Commands

| Command | Description |
|---------|-------------|
| `/bingo` | Open a random bingo cell |
| `/bingofield` | View your current bingo field |
| `/bingoprizes` | Show all prizes you've won |
| `/help` | Display command help |

## 🛠️ Installation

### Requirements
- SA-MP Server 0.3.7-R2 or later
- Windows/Linux compatible

### Setup
1. **Clone the repository:**
   ```bash
   git clone <your-repo-url>
   cd test_task
   ```

2. **Configure server:**
   - Edit `server.cfg` if needed
   - Default port: `7780`
   - Default gamemode: `bingo`

3. **Compile gamemode:**
   ```bash
   pawncc.exe -ipawno/include gamemodes/bingo.pwn
   ```

4. **Start server:**
   ```bash
   samp-server.exe
   ```

## 🎯 How to Play

1. **Connect** to server: `127.0.0.1:7780`
2. **Use `/bingo`** to open random cells
3. **Complete lines** (rows or columns) to win prizes
4. **Check progress** with `/bingofield`
5. **View prizes** with `/bingoprizes`

### 🏆 Winning Conditions
- **Horizontal Bingo:** Complete any full row (7 cells)
- **Vertical Bingo:** Complete any full column (5 cells)  
- **Multiple wins:** Can win several prizes simultaneously

## 📊 Technical Details

### System Architecture
- **Individual fields:** Each player gets unique bingo experience
- **Slot-based system:** Uses SA-MP player slots (not username tracking)
- **Memory efficient:** No file I/O or persistence
- **Duplicate prevention:** Tracks won prizes to avoid repeats

### Code Structure
```
gamemodes/
  └── bingo.pwn          # Main gamemode file
pawno/include/           # SA-MP includes
server.cfg              # Server configuration
```

### Key Variables
```pawn
new bool:playerBingoField[MAX_PLAYERS][BINGO_TOTAL_CELLS];  // Individual fields
new bool:playerWonPrizes[MAX_PLAYERS][12];                  // Prize tracking
new playerTotalPrizes[MAX_PLAYERS];                         // Prize counts
```

## 🚀 Server Configuration

### Default Settings
- **Hostname:** Professional Bingo Server
- **Port:** 7780  
- **Max Players:** 50
- **Password:** None (open access)
- **RCON Password:** alpha1211

### Connection Info
- **IP:** `127.0.0.1:7780`
- **No password required** for players
- **Individual bingo fields** for each player

## 🐛 Bug Fixes Applied

### ✅ Fixed Issues
- **Duplicate prize announcements** - Now tracks won prizes
- **String parsing errors** - Fixed command matching
- **Multiple prize detection** - Can win several prizes at once
- **Encoding issues** - Replaced emojis with ASCII symbols

## 🔧 Development

### Building
```bash
# Compile gamemode
pawncc.exe -ipawno/include gamemodes/bingo.pwn

# Start server
samp-server.exe
```

### Testing
- Connect with SA-MP client
- Use commands to test functionality
- Check server logs for debugging

## 📜 License

This project is open source. Feel free to modify and distribute.

## 👨‍💻 Author

Created for SA-MP server development and testing.

---

**🎯 Enjoy your Professional Bingo Server experience!** 