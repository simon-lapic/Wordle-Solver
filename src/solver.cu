#include <stdio.h>
#include <chrono>
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
 * @brief Stores data about a particular call of the solve() function
 */
struct GuessResults {
    std::string solution;
    float seconds;
    bool solved;
    int num_guesses;
};

/**
 * @brief Randomizes a list of words
 * 
 * @param list std::vector<std::string>, a list of words
 * @return std::vector<std::string>, the list, randomized
 */
std::vector<std::string> randomize_list(std::vector<std::string> list) {
    std::vector<std::string> randomized = {};

    while (list.size() > 0) {
        int i = std::rand() % list.size();
        randomized.push_back(list[i]);
        list.erase(list.begin() + i);
    }

    return randomized;
}

/**
 * @brief Opens a list of words stored in a file (line-separated) and returns it as an array
 * 
 * @param path std::string, the path to the file to open
 * @param count int, the number of words to extract from the file (256 or the number of items in the file by default)
 * @return std::string*, the list of words extracted from the file
 */
std::vector<std::string> get_word_list(std::string path, int count) {
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

void write_results(std::string path, GuessResults results) {
    std::ofstream file;
    file.open(path, std::ios::app);
    file << results.solution << ","
         << results.solved << ","
         << results.num_guesses << ","
         << results.seconds << "\n";
    file.close();
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
 * @brief Extracts the information from a given word and stores it in a Knowledge struct
 * 
 * @param word std::string
 * @return Knowledge 
 */
Knowledge get_info(std::string word) {
    Knowledge known = {};
    for (int i = 0; i<5; i++) {
        known.state[i] = word.at(i);
        known.letter_counts[int(word.at(i))-97]++;
    }

    return known;
}

/**
 * @brief Updates the given Knowledge struct with new information gained from a new guess. This method assumes that the 
 * solution is known to the user and the bot is running automatically. Otherwise, the Knowledge needs to be updated manually.
 * 
 * @param known Knowledge&, the information to update
 * @param guess std::string, the new guess to get more information from
 * @param solution std::string, the solution being used at the moment
 */
void learn(Knowledge& known, std::string guess, std::string solution) {
    Knowledge s_info = get_info(solution);
    Knowledge g_info = get_info(guess);

    for (int i = 0; i<5; i++)
        if (g_info.state[i] == s_info.state[i])
            known.state[i] = g_info.state[i];

    for (int i = 0; i < 26; i++) {
        if (known.letter_counts[i]<s_info.letter_counts[i] && known.letter_counts[i]<g_info.letter_counts[i])
            known.letter_counts[i] = (g_info.letter_counts[i]<s_info.letter_counts[i])?
                                     (g_info.letter_counts[i]):(s_info.letter_counts[i]);
        if (s_info.letter_counts[i] == 0 && g_info.letter_counts[i] > 0)
            known.letter_counts[i] = -1;
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

        for (int j = 0; j<26; j++) {
            if (known.letter_counts[j] > 0) {
                bool contains_letter = false;
                for (int k = 0; k<5; k++) {
                    if (word_list.at(i).at(k) == char(j+97)) {
                        contains_letter = true;
                    }
                }
                if (!contains_letter) {
                    is_valid = false;
                    break;
                }
            }
        }

        if (!is_valid) {
            word_list.erase(word_list.begin() + i);
        }
    }
}

/**
 * @brief Kernel function to get the letter counts from a given word return it as an array of shorts. 
 * 
 * @param word char[5], the word to get info from
 * @return short[26], the array of letter counts
 */
__device__ void d_get_letter_counts(char* word, short* letter_counts) {
    for (int i = 0; i<5; i++) {
        letter_counts[int(word[i])-97]++;
    }
}

/**
 * @brief Kernel function to get a specific 5-letter word from a flattened list of words
 * 
 * @param word_list char*, the flattened word list
 * @param idx int, the index of the word to grab
 * @return char[5] 
 */
__device__ void d_get_word(char* word_list, int idx, char* word) {
    for (int i = 0; i<5; i++) 
        word[i] = word_list[idx*5+i];
}

/**
 * @brief Kernel function to update the given state and letter counts with information gained from a new guess.
 * 
 * Comparable to the host function learn()
 * 
 * @param guess char[5], the guess
 * @param g_letters short[26], the count of letters in the guess
 * @param solution char[5], the solution
 * @param s_letters short[26], the count of letters in the solution
 * @param learned_state &char[5], the known state, updates with new information
 * @param learned_letters &short[26], the known solution letter counts, updates with new information
 */
__device__ void d_learn(char* guess, short* g_letters, char* solution, short* s_letters, 
                        char* learned_state, short* learned_letters) {
    for (int i = 0; i<5; i++)
        if (guess[i] == solution[i])
            learned_state[i] = guess[i];

    for (int i = 0; i < 26; i++) {
        if (learned_letters[i]<s_letters[i] && learned_letters[i]<g_letters[i])
            learned_letters[i] = (g_letters[i]<s_letters[i])?(g_letters[i]):(s_letters[i]);
        if (s_letters[i] == 0 && g_letters[i] > 0)
            learned_letters[i] = -1;
    }
}

/**
 * @brief Kernel function to determine how many potential solutions are excluded by the known information
 * 
 * @param word_list char*, the flattened solution list
 * @param n int, the size of the word list
 * @param known_state char[5], the known state of the solution
 * @param known_letter_counts short[26], the known letter counts in the solution
 * @return int, the number of valid guesses
 */
__device__ int d_count_exclusions(char *word_list, int n, char* known_state, short* known_letter_counts) {
    int excluded = 0;
    for (int sol_idx = 0; sol_idx<n; sol_idx++) {
        char possible_solution[5]; d_get_word(word_list, sol_idx*5, possible_solution);
        short ps_letter_counts[26]; d_get_letter_counts(possible_solution, ps_letter_counts);
        bool is_valid = true;

        // Check the state
        for (int i = 0; i<5; i++) {
            if (known_state[i] != 0 && possible_solution[i] != known_state[i]) {
                is_valid = false;
                break;
            }
        }

        // Check the letter counts if the potential solution is still valid
        if (is_valid) {
            for (int i = 0; i<26; i++) {
                // There is a letter present in the potential solution that we know is not in the actual solution
                if(known_letter_counts[i] < 0 && ps_letter_counts[i] > 0) {
                    is_valid = false;
                    break;
                } 
                // There are letters we known are in the actual solution that are not in the potential solution
                else if (ps_letter_counts[i] < known_letter_counts[i]) {
                    is_valid = false;
                    break;
                }
            }
        }

        if (!is_valid)
            excluded++;
    }

    return excluded;
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
__global__ void get_expected_information(char *word_list, char *solution_list, int *n, int *k, float *expected_info) {
    int idx = blockIdx.x * blockDim.x + threadIdx.x;
    if (idx < *n) {
        char guess[5]; d_get_word(word_list, idx, guess); //printf("Thread %d got the guess\n", idx);
        short g_letter_counts[26]; d_get_letter_counts(guess, g_letter_counts); //printf("Thread %d got the letter counts\n", idx);
        
        int sum_exclusions = 0;
        // Loops through each potential solution to see how many guesses from word_list would be removed
        // if it were the actual solution
        for (int sol_idx = 0; sol_idx<*k; sol_idx++) {
            char potential_solution[5]; d_get_word(solution_list, sol_idx, potential_solution);
            short ps_letter_counts[26]; d_get_letter_counts(potential_solution, ps_letter_counts);

            char state[5] = {};
            short letter_counts[26] = {};
            d_learn(guess, g_letter_counts, potential_solution, ps_letter_counts, state, letter_counts); //printf("Thread %d learned\n", idx);

            sum_exclusions += d_count_exclusions(solution_list, *n, state, letter_counts); //printf("Thread %d counted exclusions\n", idx);
        }

        expected_info[idx] = float(sum_exclusions) / float(*k);
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
    int size = word_list.size();
    int *n = &size;

    // Allocate and initialize host memory
    float *info = (float*)malloc(size*sizeof(float));
    char *words = (char*)malloc(size*5*sizeof(char));
    for (int i = 0; i<size*5; i++) {
        words[i] = word_list[int(i/5)].at(i%5);
    }

    // Allocate device memory
    float *d_info;
    char *d_words, *d_sols;
    int *d_n, *d_k;
    cudaMalloc(&d_info, size*sizeof(float));
    cudaMalloc(&d_words, size*5*sizeof(char));
    cudaMalloc(&d_sols, size*5*sizeof(char));
    cudaMalloc(&d_n, sizeof(int));
    cudaMalloc(&d_k, sizeof(int));

    // Copy from host to device
    cudaMemcpy(d_words, words, size*5*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_sols, words, size*5*sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_n, n, sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_k, n, sizeof(int), cudaMemcpyHostToDevice);

    // Kernel call
    get_expected_information<<<32, 512>>>(d_words, d_sols, d_n, d_k, d_info);
    cudaDeviceSynchronize();

    // Copy data back to host
    cudaMemcpy(info, d_info, size*sizeof(float), cudaMemcpyDeviceToHost);

    // Interpret data
    int max_idx = 0;
    for (int i = 0; i<size; i++) 
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
 * @return int, the number of guesses it took to solve, or -1 if it failed
 */
void solve(std::string word, std::string path, int n, GuessResults &results) {
    float total_time = 0.0;
    bool solved = false;
    short attempts = 0;
    Knowledge known = {};
    std::vector<std::string> words = randomize_list(get_word_list(path, n));

    std::cout << "Guessing '" << word << "' with expected information..." << std::endl;
    while (attempts < 6 && !solved) {
        int num_remaining = words.size();

        auto start = std::chrono::high_resolution_clock::now();
        std::string guess = make_informed_guess(words);
        auto stop = std::chrono::high_resolution_clock::now();
        auto dur = std::chrono::duration_cast<std::chrono::milliseconds>(stop-start);
        total_time += float(dur.count())/float(1000);

        learn(known, guess, word);
        int guess_idx = 0;
        for (int i = 0; i<words.size(); i++)
            if (words[i] == guess) {
                guess_idx = i;
                break;
            }
        words.erase(words.begin() + guess_idx);
        cull_word_list(words, known);

        std::cout << "     "; 
        print_guess(known, guess); 
        std::cout << "   (out of " << num_remaining << " in " << float(dur.count())/float(1000) << " seconds)\n";

        attempts++;
        if (guess == word)
            solved = true;
    }
        
    std::string message = (solved)?("Solved!"):("Failed!");
    std::cout << message << std::endl;

    results.num_guesses = attempts;
    results.solved = solved;
    results.seconds = total_time;

}

int main(int argc, char **argv) {
    if (argc != 4 && argc != 5) {
        std::cout << "Incorrect Usage: ./solver [solution] [word list path] [size] <output file path>";
        printf("\n");
        return 0;
    } 
    std::string solution = argv[1];
    std::string path = argv[2];
    int num = atoi(argv[3]);
    std::string output = ""; if (argc>3) output = argv[4];
    
    std::srand(time(0));
    printf("\n");

    GuessResults results = {}; results.solution = solution;
    solve(solution, path, num, results);
    if (output != "") 
        write_results(output, results);

    printf("\n");

    return 0;
}