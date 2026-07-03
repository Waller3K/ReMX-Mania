#include <iostream>
#include <vector>
#include <fstream>
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
    int8_t          TrackCount;
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
    std::vector<NoteObject> Track1;
    std::vector<NoteObject> Track2;
    std::vector<NoteObject> Track3;
    std::vector<NoteObject> Track4;
    std::vector<NoteObject> ScratchTrack;
    std::string             MarkerDirectory;

    public:

    Chart(

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

    );

    nlohmann::json Convert();

    std::string GetDifficultyName();


};