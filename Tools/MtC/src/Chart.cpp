#include "Chart.hpp"

Chart::Chart(
    float BPM,
    std::string     songTitle,
    std::string     artist,
    std::string     charter,
    float           difficulty,
    std::string     difficultyName,
    int8_t          trackCount,
    std::string     bgmPath,
    std::string     track1Path,
    std::string     track2Path,
    std::string     track3Path,
    std::string     track4Path,
    std::string     scratchPath,
    std::string     markerDirectory
) {
    SongMetadata.BPM = BPM;
    SongMetadata.SongTitle = songTitle;
    SongMetadata.Artist = artist;
    SongMetadata.Charter = charter;
    SongMetadata.Difficulty = difficulty;
    SongMetadata.DifficultyName = difficultyName;
    SongMetadata.TrackCount = trackCount;
    SongMetadata.BGMPath = bgmPath;
    SongMetadata.Track1Path = track1Path;
    SongMetadata.Track2Path = track2Path;
    SongMetadata.Track3Path = track3Path;
    SongMetadata.Track4Path = track4Path;
    SongMetadata.ScratchPath = scratchPath;
    MarkerDirectory = markerDirectory;
}

nlohmann::json Chart::Convert() {
    nlohmann::json jsonData;

    return jsonData;
}

std::string Chart::GetDifficultyName() {
    return SongMetadata.DifficultyName;
}