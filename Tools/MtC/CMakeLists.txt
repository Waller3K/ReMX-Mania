cmake_minimum_required(VERSION 3.28)
project(Markers-To-Chart LANGUAGES CXX)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

include(FetchContent)

FetchContent_Declare(Nlohmann_Json
					GIT_REPOSITORY https://github.com/nlohmann/json.git
					GIT_TAG v3.12.0
					GIT_SHALLOW ON
					EXCLUDE_FROM_ALL
					SYSTEM)
FetchContent_MakeAvailable(Nlohmann_Json)

add_subdirectory(src)

target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)
target_link_libraries(${PROJECT_NAME} PUBLIC nlohmann_json::nlohmann_json)


