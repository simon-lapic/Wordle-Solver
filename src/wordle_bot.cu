#include <stdio.h>
#include <time.h>
#include <cstdlib>
#include <string>
#include <sstream>
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
    char state[5];
    short letter_counts[26];
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
    while (getline(file, word) && count > 0) {
        output.push_back(word);
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
 * @brief Updates the given Knowledge struct with new information gained from a new guess. This method assumes that the 
 * solution is known to the user and the bot is running automatically. Otherwise, the Knowledge needs to be updated manually
 * 
 * @param known Knowledge&, the information to update
 * @param guess std::string, the new guess to get more information from
 * @param solution std::string, the solution being used at the moment
 */
void update_knowledge(Knowledge& known, std::string guess, std::string solution) {
    for (int i = 0; i<5; i++) {
        int count = 0;
        bool found = false;
        for (int j = 0; j<5; j++) {
            if (guess.at(i) == solution.at(j)) { // Finding the counts gotten from the guess
                count++;
                found = true;
                if (i == j) { // Update the state where necessary
                    known.state[i] = guess.at(i);
                }
            }
        }

        // Update the letter counts if necessary
        if (known.letter_counts[int(guess.at(i))-97] < count) {
            known.letter_counts[int(guess.at(i))-97] = count;
        }

        if (!found) {
            known.letter_counts[int(guess.at(i))-97] = -1;
        }
    }
}

/**
 * @brief Kernel function to get the expected information of a particular word
 * 
 * @param word_list char**, the list of words 
 */
__global__ void get_expected_information(char** word_list) {

}

/**
 * @brief Makes a guess for the solution based on the amount of information that can be expected to be found by making the guess.
 * The expected information value for each 
 * 
 * @param word_list std::vector<std::string>, the list of words to guess from
 * @return std::string 
 */
std::string make_best_guess(std::vector<std::string> word_list) {
    return "";
}

/**
 * @brief Makes a guess for the solution at random
 * 
 * @param word_list std::vector<std::string>, the list of words to guess from
 * @return std::string, The randomly-made guess
 */
std::string make_random_guess(std::vector<std::string> word_list) {
    return word_list[std::rand() % word_list.size()];
}

/**
 * @brief Prints a guess using the appropriate colors based on what information is known. A letter appears yellow if it appears in
 * the word but not at that position and green if it is at that position, otherwie gray if the letter is not in the word
 * 
 * @param known Knowledge, the knowledge known at the point the guess was made
 * @param guess std::string, the guess to print
 */
void print_guess(Knowledge known, std::string guess) {
    for (int i = 0; i<guess.size(); i++) {
        if (guess.at(i) == known.state[i]) {
            known.letter_counts[int(guess.at(i))-97]--;
        }
    }
    
    for (int i = 0; i<guess.size(); i++) {
        if (guess.at(i) == known.state[i]) {
            std::cout << "\x1B[32m" << guess.at(i) << "\033[0m"; // ANSI Green
        } else if (known.letter_counts[int(guess.at(i))-97] > 0) {
            known.letter_counts[int(guess.at(i))-97]--;
            std::cout << "\x1B[33m" << guess.at(i) << "\033[0m"; // ANSI Yellow
        } else {
            std::cout << guess.at(i);
        }
        std::cout << " ";
    }

    std::cout << std::endl;
}

int main(int argc, char **argv) {
    std::srand(time(0));
    printf("\n");
    // DEBUGGING
    std::vector<std::string> words = get_word_list("../data/wordle_words.txt", 1297200);
    Knowledge test_info = {};
    std::string sol = make_random_guess(words);
    update_knowledge(test_info, "cabal", sol);
    std::cout << sol << ": ";
    print_guess(test_info, "cabal");
    // END DEBUGGING
    printf("\n");
    return 0;
}





