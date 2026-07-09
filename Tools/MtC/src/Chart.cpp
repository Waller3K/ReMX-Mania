#include "Chart.hpp"

Chart::Chart(
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

void to_json(nlohmann::json& j, const NoteObject& note){
    j = nlohmann::json{{"Pos", note.Position}};
    if (note.Position != note.End) {
        j["End"] = note.End;
    }
    if (note.Effect != -1){
        j["Effect"] = note.Effect;
    }
}

nlohmann::json Chart::Parse(std::filesystem::path TestDir, int tempCount) {
    if(TestDir != ""){
        MarkerDirectory = TestDir;
    }

    if(tempCount != -1){
        SongMetadata.TrackCount = tempCount;
    }

    nlohmann::json jsonData;
    
    // Add Song Metadata to json file

    jsonData["Metadata"] = {
        {"BPM",             SongMetadata.BPM},
        {"Title",           SongMetadata.SongTitle},
        {"Artist",          SongMetadata.Artist},
        {"Charter",         SongMetadata.Charter},
        {"Difficulty",      SongMetadata.Difficulty},
        {"DifficultyName",  SongMetadata.DifficultyName},
        {"TrackCount",      SongMetadata.TrackCount},
        {"BGMPath",         SongMetadata.BGMPath},
        {"Track1Path",      SongMetadata.Track1Path},
        {"Track2Path",      SongMetadata.Track2Path},
        {"Track3Path",      SongMetadata.Track3Path},
        {"Track4Path",      SongMetadata.Track4Path},
        {"ScratchPath",     SongMetadata.ScratchPath}
    };

    float   startPos;
    float   endPos;
    int     noteType;


    // vvv FX Track Code! vvv
    std::ifstream TrackFXFile(MarkerDirectory / "TrackFX.txt");

    if (TrackFXFile.fail()){
        std::cout << "Error: Could Not Find FX Markers!" << std::endl;
        return 1;
    }

    //Streams are evaluated as bools!
    while(TrackFXFile >> startPos >> endPos >> noteType){
        NoteObject tempNote;
        tempNote.Position   = startPos;
        tempNote.End        = endPos;
        tempNote.Effect     = noteType;

        TrackFX.push_back(tempNote);
    }

    std::cout << "FX File Loaded" << std::endl;

    TrackFXFile.close();

    // vvv Main Track Code! vvv

    // The TrackCount should ALWAYS be between 2 and 4!

    std::vector<std::ifstream> MainTrackFiles;

    switch(SongMetadata.TrackCount){
        case(2): {

            //Emplace back makes the object in place where as push back needs a premade object
            MainTrackFiles.emplace_back((MarkerDirectory / "Track1.txt"));
            MainTrackFiles.emplace_back((MarkerDirectory / "Track2.txt"));

            break;

        }
        case(3): {
            MainTrackFiles.emplace_back((MarkerDirectory / "Track1.txt"));
            MainTrackFiles.emplace_back((MarkerDirectory / "Track2.txt"));
            MainTrackFiles.emplace_back((MarkerDirectory / "Track3.txt"));

            break;
        }
        case(4): {
            MainTrackFiles.emplace_back((MarkerDirectory / "Track1.txt"));
            MainTrackFiles.emplace_back((MarkerDirectory / "Track2.txt"));
            MainTrackFiles.emplace_back((MarkerDirectory / "Track3.txt"));
            MainTrackFiles.emplace_back((MarkerDirectory / "Track4.txt"));

            break;
        }
        default: {
            std::cerr << "Error: Invalid Number of tracks! '" << SongMetadata.TrackCount << "'!" << std::endl;
            return jsonData;
        }

    }

    for (int i = 0; i < SongMetadata.TrackCount; i++){

        std::vector<NoteObject> tempTrack;

        if(MainTrackFiles[i].fail()){
            std::cerr << "Failed to open Track " << i+1 << " File!" << std::endl;
            continue;
        }

        while(MainTrackFiles[i] >> startPos >> endPos){
            NoteObject tempNote;
            tempNote.Position   = startPos;
            tempNote.End        = endPos;

            tempTrack.push_back(tempNote);
        }

        MainTracks.push_back(tempTrack);

        std::cout << "Track " << i+1 << " File Loaded" << std::endl;

        MainTrackFiles[i].close();

    }

    // vvv Scratch Track Code! vvv
    std::ifstream ScratchTrackFile(MarkerDirectory / "ScratchTrack.txt");

    while(ScratchTrackFile >> startPos >> endPos){
        NoteObject tempNote;
        tempNote.Position   = startPos;
        tempNote.End        = endPos;

        ScratchTrack.push_back(tempNote);

        std::cout << startPos << ", " << endPos << std::endl;
    }

    std::cout << "Scratch File Loaded" << std::endl;

    ScratchTrackFile.close();
 

    //Adds Note Section to Json Data

    jsonData["Notes"] = {};
    
    jsonData["Notes"]["Track FX"] = nlohmann::json::array();

    for(NoteObject note : TrackFX){
        jsonData["Notes"]["Track FX"].push_back(note);
    }


    for(int i = 0; i < MainTracks.size(); i++){
        const std::string TrackName = "Track " + std::to_string(i+1);

        jsonData["Notes"][TrackName] = nlohmann::json::array();

        for(NoteObject note : MainTracks[i]){
            jsonData["Notes"][TrackName].push_back(note);
        }
    }

    jsonData["Notes"]["Scratch Track"] = nlohmann::json::array();

    for(NoteObject note : ScratchTrack){
        jsonData["Notes"]["Scratch Track"].push_back(note);
    }

    std::cout << jsonData.dump(4) << std::endl;


    return jsonData;
}

std::string Chart::GetDifficultyName() {
    return SongMetadata.DifficultyName;
}