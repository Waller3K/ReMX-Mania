#include <iostream>
#include <vector>
#include <fstream>
#include <filesystem>
#include <nlohmann/json.hpp>

//Song Metadata
struct Metadata
{
    float           BPM;
    std::string     SongTitle;
    std::string     Artist;
    std::string     Charter;
    float           Difficulty;
    std::string     DifficultyName;
    int             TrackCount;
    std::string     BGMPath;
    std::string     Track1Path;
    std::string     Track2Path;
    std::string     Track3Path;
    std::string     Track4Path;
    std::string     ScratchPath;
    
};

struct NoteObject{
    float Position;
    float End = -1;
    // This is the Note Effect for FX notes would be negative 1 for Scratch Notes
    int Effect = -1;
};

class Chart
{

    Metadata SongMetadata;

    //Note Vectors
    std::vector<NoteObject> TrackFX;
    std::vector<std::vector<NoteObject>> MainTracks;
    std::vector<NoteObject> ScratchTrack;
    std::filesystem::path   MarkerDirectory;

    public:

    Chart(

        float                   BPM,
        std::string             songTitle,
        std::string             artist,
        std::string             charter,
        float                   difficulty,
        std::string             difficultyName,
        int                     trackCount,
        std::string             bgmPath,
        std::string             track1Path,
        std::string             track2Path,
        std::string             track3Path,
        std::string             track4Path,
        std::string             scratchPath,
        std::filesystem::path   markerDirectory

    );

    nlohmann::json Parse(std::filesystem::path TestDir = "", int tempCount = -1);

    std::string GetDifficultyName();


};