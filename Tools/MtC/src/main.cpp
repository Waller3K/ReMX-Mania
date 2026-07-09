#include <memory>
#include "Chart.hpp"


float                   BPM;
std::string             Title;
std::string             Artist;
std::string             Charter;
float                   Difficulty;
std::string             DifficultyName;
int                     TrackCount;

std::filesystem::path   ChartPaths[8];
//The labels for each of the Chart Paths
std::string             ChartPathNames[8] = {
                            "BGMPath",
                            "Track 1 Path",
                            "Track 2 Path",
                            "Track 3 Path",
                            "Track 4 Path",
                            "Scratch Track Path",
                            "Audacity Marker File Directory",
                            "Final Export Path"
                        };


int main(int _argc, char * argv[])
{
    std::cout << "Welcome to the Audacity Marker to ReMX Mania Chart Converter!" << std::endl << "Please enter chart Metadata Information Below:" << std::endl;

    std::cout << "Song BPM:" << std::endl;
    while(!(std::cin >> BPM)){
        std::cout << "Invalid Input! Please enter a number: ";
        std::cin.clear();
        std::cin.ignore(10000, '\n');
    }

    // Clears trailing newline left from cin.
    std::cin.ignore();

    std::cout << "Song Title:" << std::endl;
    std::getline(std::cin, Title);

    std::cout << "Artist:" << std::endl;
    std::getline(std::cin, Artist);

    std::cout << "Charter:" << std::endl;
    std::getline(std::cin, Charter);

    std::cout << "Difficulty Level:" << std::endl;
    std::cin >> Difficulty;

    std::cin.ignore();
    
    std::cout << "Difficulty Name:" << std::endl;
    std::getline(std::cin, DifficultyName);

    std::cout << "Main Track Count (Minimum of 2 max of 4):" << std::endl;
    std::cin >> TrackCount;

    std::cin.ignore();

    //File Paths

    std::string inputBuffer;


    int i = 0;
    for(std::filesystem::path& path : ChartPaths){
        
        std::cout << "Enter "<< ChartPathNames[i] << ": " << std::endl;

        std::getline(std::cin, inputBuffer);

        path = inputBuffer;

        if(std::filesystem::exists(path)){
            std::cout << "Valid Path!" << std::endl;
        }else{
            std::cerr << "Invalid Path!" << std::endl;
            return 1;
        }

        i++;
    }

    std::cout << "Creating Chart..." << std::endl;

    auto chart = std::make_shared<Chart>(
        BPM,
        Title, 
        Artist, 
        Charter,
        Difficulty,
        DifficultyName,
        TrackCount,
        ChartPaths[0].string(),
        ChartPaths[1].string(),
        ChartPaths[2].string(),
        ChartPaths[3].string(),
        ChartPaths[4].string(),
        ChartPaths[5].string(),
        ChartPaths[6]
    );

    std::ofstream output(chart->GetDifficultyName() + ".json");

    output << chart->Parse().dump(4) << std::endl;

    output.close();

    return 0;
}