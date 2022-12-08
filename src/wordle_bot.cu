#include <stdio.h>
#include <time.h>
#include <cstdlib>
#include <string>
#include <sstream>
#include <iostream>
#include <fstream>
#include <vector>
#include <cstring>

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

/**
 * @brief Prints a distribution graph for how well the bot did solving the game
 * 
 * @param dist 
 */
void print_dist(std::vector<int> dist) {
    std::cout << "1: ";
    for (int i = 0; i<dist.size(); i++)
        if (dist[i] == 1)
            std::cout << "#";
    std::cout << "\n2: ";
    for (int i = 0; i<dist.size(); i++)
        if (dist[i] == 2)
            std::cout << "#";
    std::cout << "\n3: ";
    for (int i = 0; i<dist.size(); i++)
        if (dist[i] == 3)
            std::cout << "#";
    std::cout << "\n4: ";
    for (int i = 0; i<dist.size(); i++)
        if (dist[i] == 4)
            std::cout << "#";
    std::cout << "\n5: ";
    for (int i = 0; i<dist.size(); i++)
        if (dist[i] == 5)
            std::cout << "#";
    std::cout << "\n6: ";
    for (int i = 0; i<dist.size(); i++)
        if (dist[i] == 6)
            std::cout << "#";
    std::cout << "\nF: ";
    for (int i = 0; i<dist.size(); i++)
        if (dist[i] == -1)
            std::cout << "#";
    std::cout << std::endl; 
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
 * @brief Culls the word list to only contain words that are still possible solutions, based on the known information
 * 
 * @param word_list std::vector<std::string>, the list to cull
 * @param known Knowledge, the known information
 */
void cull_word_list(std::vector<std::string>& word_list, Knowledge known) {
    for (int i = word_list.size()-1; i>=0; i--) {
        bool is_valid = true;
        for (int j = 0; j<5; j++) {
            if (known.letter_counts[int(word_list.at(i).at(j))-97] < 0) {
                is_valid = false;
                break;
            } else if (known.state[j] != 0 && word_list.at(i).at(j) != known.state[j]) {
                is_valid = false;
                break;
            }
        }

        if (!is_valid) {
            word_list.erase(word_list.begin() + i);
        }
    }
}

/**
 * @brief Kernel function to get the expected information for each word in the word_list
 * 
 * @param word_list char**, the list of words to get expected information for
 * @param solution_list char**, the list of potential solutions to check each element of word_list against
 * @param n int, the number of words in the word list
 * @param k int, the number of words in the solution list
 * @param info float*, the list of expected information values (generated by this function)
 */
__global__ void get_expected_information(char *word_list, char *solution_list, int *n, int *k, float *info) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < *n) {
        char potential_guess[5] = {word_list[idx*5], word_list[idx*5+1], word_list[idx*5+2], 
                                    word_list[idx*5+3], word_list[idx*5+4]};
        int *exclusions;

        for (int i = 0; i<*k*5; i++) {
            char potential_solution[5] = {solution_list[i*5], solution_list[i*5+1], solution_list[i*5+2], 
                                        solution_list[i*5+3], solution_list[i*5+4]};

            // Find the information
            char state[5];
            char letter_counts[26] = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
            for (int g = 0; g<5; g++) {
                int count = 0;
                bool found = false;
                for (int s = 0; s<5; s++) {
                    if (potential_guess[g] == potential_solution[s]) { // Finding the counts gotten from the guess
                        count++;
                        found = true;
                        if (g == s) { // Update the state where necessary
                            state[g] = potential_guess[g];
                        }
                    }
                }

                // Update the letter counts if necessary
                if (letter_counts[int(potential_guess[g])-97] < count) {
                    letter_counts[int(potential_guess[g])-97] = count;
                }

                if (!found) {
                    letter_counts[int(potential_guess[g])-97] = -1;
                }
            }

            // Count excluded possible guesses
            int num_excluded = 0;
            for (int j = *n; j>=0; j--) {
                bool is_valid = true;
                for (int l = 0; l<5; l++) {
                    if (letter_counts[int(potential_guess[l]-97)] < 0) {
                        is_valid = false;
                        break;
                    } else if (state[l] != 0 && potential_guess[l] != state[l]) {
                        is_valid = false;
                        break;
                    }
                }

                if (!is_valid) {
                    num_excluded++;
                }
            }
            exclusions[i] = num_excluded;
        }

        // Average the information values and store it in the output
        float expected = 0.0;
        for (int i = 0; i<*k; i++) {
            expected += exclusions[i];
        }

        info[idx] = expected / *k;
    }
}

/**
 * @brief Makes a guess for the solution based on the amount of information that can be expected to be found by making the guess.
 * The expected information value for each 
 * 
 * @param word_list std::vector<std::string>, the list of words to guess from
 * @return std::string 
 */
std::string make_informed_guess(std::vector<std::string> word_list) {
    int temp = word_list.size();
    int *n = &temp;

    // Allocate and initialize host memory
    float *info = (float*)malloc(temp*sizeof(float));
    char *words = (char*)malloc(temp*5*sizeof(char));
    for (int i = 0; i<temp*5; i++) {
        words[i] = word_list[int(i/5)].at(i%5);
    }

    // Allocate device memory
    float *d_info;
    char *d_words, *d_sols;
    int *d_n, *d_k;
    cudaMalloc(&d_info, temp*sizeof(float));
    cudaMalloc(&d_words, temp*5*sizeof(char));
    cudaMalloc(&d_sols, temp*5*sizeof(char));
    cudaMalloc(&d_n, sizeof(int));
    cudaMalloc(&d_k, sizeof(int));

    // Copy from host to device
    cudaMemcpy(d_words, words, temp*5*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_sols, words, temp*5*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_n, n, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_k, n, sizeof(int), cudaMemcpyHostToDevice);

    // Kernel call
    get_expected_information<<<32, 512>>>(d_words, d_sols, d_n, d_k, d_info); // 32, 512
    cudaDeviceSynchronize();

    // Copy data back to host
    cudaMemcpy(info, d_info, temp*sizeof(float), cudaMemcpyDeviceToHost);

    // Interpret data
    int max_idx = 0;
    for (int i = 0; i<temp; i++) 
        if (info[i] > info[max_idx]) 
            max_idx = i;

    // Free memory
    free(info); 
    free(words); 
    cudaFree(d_info); 
    cudaFree(d_words); 
    cudaFree(d_n); 
    cudaFree(d_k); 
    
    return word_list[max_idx];
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
 * @brief Solves a wordle puzzle for a given solution
 * 
 * @param word std::string, the solution to solve for
 * @param path std::string, the file path for a list of words to use as the possible guesses
 * @param t char, the method to solve it with. Should be 'r' for random or 'i' to use expected information
 * @return int, the number of guesses it took to solve, or -1 if it failed
 */
int solve(std::string word, std::string path, char t, bool print) {
    bool solved = false;
    short attempts = 0;
    Knowledge known = {};
    std::vector<std::string> words = get_word_list(path, 12972); // 12972

    if (t == 'r') {
        if (print) std::cout << "Guessing '" << word << "' with random guesses..." << std::endl;
        while (attempts < 6 && !solved) {
            std::string guess = make_random_guess(words);
            update_knowledge(known, guess, word);
            int guess_idx = 0;
            for (int i = 0; i<words.size(); i++)
                if (words[i] == guess) {
                    guess_idx = i;
                    break;
                }
            words.erase(words.begin() + guess_idx);
            cull_word_list(words, known);
            if (print) {std::cout << "     "; print_guess(known, guess);}
            attempts++;
            if (guess == word)
                solved = true;
        }

        if (print) {
            std::string message = (solved)?("Solved!"):("Failed!");
            std::cout << message << std::endl;
        }
    } else if (t == 'i') {
        if (print) std::cout << "Guessing '" << word << "' with expected information..." << std::endl;
        while (attempts < 6 && !solved) {
            std::string guess = make_informed_guess(words);
            update_knowledge(known, guess, word);
            int guess_idx = 0;
            for (int i = 0; i<words.size(); i++)
                if (words[i] == guess) {
                    guess_idx = i;
                    break;
                }
            words.erase(words.begin() + guess_idx);
            cull_word_list(words, known);
            int num_remaining = words.size();
            if (print) {std::cout << "     "; print_guess(known, guess);}
            attempts++;
            if (guess == word)
                solved = true;
        }
        if (print) {
            std::string message = (solved)?("Solved!"):("Failed!");
            std::cout << message << std::endl;
        }
    } else {
        std::cout << "Invalid method type. Use 'r' for random or 'i' to use expected information." << std::endl;
    }

    return (solved)?(attempts):(-1);
}

int main(int argc, char **argv) {
    std::srand(time(0));
    printf("\n");

    // DEBUGGING
    Knowledge test_known = {};
    std::string sol = "ounce";
    std::vector<std::string> words = {"crate", "tepid", "itchy", "ounce", "store"};
    while (true) {
        std::string guess; std::cin >> guess;
        update_knowledge(test_known, guess, sol);
        cull_word_list(words, test_known);
        print_guess(test_known, guess);
        for (std::string word : words) std::cout << word << ", ";
        std::cout << std::endl;
    }
    // END DEBUGGING

    // std::vector<std::string> sols = get_word_list(argv[1], atoi(argv[2]));
    // std::vector<int> dist;
    // for (std::string sol : sols) {
    //     dist.push_back(solve(sol, argv[1], argv[3][0], (argc > 4)));
    //     if (argc > 4) std::cout << std::endl;
    // }
    // print_dist(dist);
    
    printf("\n");
    return 0;
}