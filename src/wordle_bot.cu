#include <stdio.h>
#include <time.h>
#include <cstdlib>
#include <string>
#include <iostream>
#include <fstream>
#include <vector>

/**
 * @brief Used to make it easier to pass the known data between functions.
 * 
 *  Knowledge.positions is a list of 5 characters, which are only initialized once the character at that 
 * position of the solution is known
 * 
 * Knowledge.letter_counts is a list of 26 shorts which represent the coutns of each letter of the alphabet that are
 * known. The count for a letter is set to -1 if it is known that that letter is not in the solution
 */
struct Knowledge {
    char positions[5];
    short letter_counts[26] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
};

/**
 * @brief Opens a list of words stored in a file (line-separated) and returns it as an array
 * 
 * @param path std::string, the path to the file to open
 * @param count int, the number of words to extract from the file (256 or the number of items in the file by default)
 * @return std::string*, the list of words extracted from the file
 */
std::vector<std::string> get_word_list(std::string path, int count=256) {
    std::vector<std::string> output;
    output.reserve(count);

    std::ifstream file(path);
    std::string word;
    int n = count;
    while (getline(file, word) && count > 0) {
        output[n-count] = word;
        count--;
    }

    return output;
}

/**
 * @brief Determines whether or not a string is a valid word for the wordle. A word is considered valid if it has five
 * characters, and each character is a letter.
 * 
 * @param word std::string, the word to validate
 * @return true if word is valid, otherwise false
 */
bool validate(std::string word) {
    bool valid = word.size() == 5;
    for (char c : word)
        if (!(int(c) >= 97 && int(c) <= 122)) //Confirms that the character is one of the ascii lowercase letters
            valid = false;
    return valid;
}

/**
 * @brief Updates the given Knowledge struct with new information including a new guess. The information will only be updated if
 * a valid guess is passed. If an invalid guess has passed, it throws an exception
 * 
 * @param info Knowledge&, the information to update
 * @param guess std::string, the new guess to get more information from
 */
void update_information(Knowledge& info, std::string guess) {
    if (!validate(guess))
        throw(guess);
    
}

/**
 * @brief Makes a guess for the solution at random
 * 
 * @return std::string, The randomly-made guess
 */
std::string make_random_guess() {

}

/**
 * @brief Makes a guess for the solution based on the amount of information that can be expected to be found by making the guess.
 * The expected information value for each 
 * 
 * @return std::string 
 */
std::string make_best_guess() {

}

int main(int argc, char **argv) {
    int test[5] = {0, 0, 0, 0, 0};
    printf("%d\n", test[2]);
    return 0;
}





