// This file contains some helper scripts for formatting data


// For multiplayer games, show the player count as '1-N'
function formatPlayers(playerCount) {
    if (playerCount === 1)
        return playerCount

    return "1-" + playerCount;
}


// Show dates in Y-M-D format
function formatDate(date) {
    return Qt.formatDate(date, "yyyy-MM-dd");
}


// Show last played time as text. Based on the code of the default Pegasus theme.
// Note to self: I should probably move this into the API.
function formatLastPlayed(lastPlayed) {
    if (isNaN(lastPlayed))
        return "never";

    var now = new Date();

    var elapsedHours = (now.getTime() - lastPlayed.getTime()) / 1000 / 60 / 60;
    if (elapsedHours < 24 && now.getDate() === lastPlayed.getDate())
        return "today";

    var elapsedDays = Math.round(elapsedHours / 24);
    if (elapsedDays <= 1)
        return "yesterday";

    return elapsedDays + " days ago"
}


// Display the play time (provided in seconds) with text.
// Based on the code of the default Pegasus theme.
// Note to self: I should probably move this into the API.
function formatPlayTime(playTime) {
    var minutes = Math.ceil(playTime / 60)
    if (minutes <= 90)
        return Math.round(minutes) + " minutes";

    return parseFloat((minutes / 60).toFixed(1)) + " hours"
}

// Process the platform name to make it friendly for the logo
// Unfortunately necessary for LaunchBox
function getPlatformName(platform) {
  switch (platform) {
    case "panasonic 3do":
      return "3do";
    case "3do interactive multiplayer":
      return "3do";
    case "amstrad cpc":
      return "amstradcpc";
    case "apple ii":
      return "apple2";
    case "atari 800":
      return "atari800";
    case "atari 2600":
      return "atari2600";
    case "atari 5200":
      return "atari5200";
    case "atari 7800":
      return "atari7800";
    case "atari jaguar":
      return "atarijaguar";
    case "atari jaguar cd":
      return "atarijaguarcd";
    case "atari lynx":
      return "atarilynx";
    case "atari st":
      return "atarist";
    case "commodore 64":
      return "c64";
    case "tandy trs-80":
      return "coco";
    case "commodore amiga":
      return "amiga";
    case "sega dreamcast":
      return "dreamcast";
    case "final burn alpha":
      return "fba";
    case "sega game gear":
      return "gamegear";
    case "nintendo game boy":
      return "gb";
    case "nintendo game boy advance":
      return "gba";
    case "nintendo game boy color":
      return "gbc";
    case "nintendo gamecube":
      return "gc";
    case "sega genesis":
      return "genesis";
    case "mattel intellivision":
      return "intellivision";
    case "sega master system":
      return "mastersystem";
    case "sega mega drive":
      return "megadrive";
    case "sega genesis":
      return "genesis";
    case "microsoft msx":
      return "msx";
    case "nintendo 64":
      return "n64";
    case "nintendo ds":
      return "nds";
    case "snk neo geo aes":
      return "neogeo";
    case "snk neo geo mvs":
      return "neogeo";
    case "snk neo geo cd":
      return "neogeocd";
    case "nintendo 64":
      return "segacd";
    case "nintendo entertainment system":
      return "nes";
    case "snk neo geo pocket":
      return "ngp";
    case "snk neo geo pocket color":
      return "ngpc";
    case "sega cd":
      return "segacd";
    case "nec turbografx-16":
      return "turbografx16";
    case "sony psp":
      return "psp";
    case "sony playstation":
      return "psx";
    case "sony playstation 2":
      return "ps2";
    case "sony playstation 3":
      return "ps3";
    case "sony playstation vita":
      return "vita";
    case "sega saturn":
      return "saturn";
    case "sega 32x":
      return "sega32x";
    case "super nintendo entertainment system":
      return "snes";
    case "sega cd":
      return "segacd";
    case "nintendo wii":
      return "wii";
    case "nintendo wii u":
      return "wii u";
    case "nintendo 3ds":
      return "3ds";
    case "microsoft xbox":
      return "xbox";
    case "microsoft xbox 360":
      return "xbox360";
    case "nintendo switch":
      return "switch";
    default:
      return platform;
  }
}

/*function processButtonArt(buttonModel) {
  return buttonModel;
}*/
