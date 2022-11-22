import sorter, sys
from random import choice

WORD_LIST = []
GUESSES_FILE_PATH = '../data/serial_solver_guess_list.txt'

def set_words(word_list:list):
    '''
    Sets the WORD_LIST variable when serial_guesser is not the main file
    '''
    WORD_LIST = word_list

def set_guesses_path(path:list):
    '''
    Sets the WORD_LIST variable when serial_guesser is not the main file
    '''
    GUESSES_FILE_PATH = path

def OLD_score(word:str, guess:str):
    '''
    Scores a guess based on the system for labeling a data, and returns that score as a float
    '''
    S = 0.0

    counts = {}
    guessed = {}
    correct = {}

    for i in range(5):
        counts[word[i]] = 1 if not word[i] in counts.keys() else counts[word[i]]+1
        correct[word[i]] = (1 if not word[i] in correct.keys() else correct[word[i]]+1) if word[i] == guess[i] else 0
        guessed[guess[i]] = 1 if not word[i] in guessed.keys() else guessed[word[i]]+1

    for letter in guessed.keys():
        if letter in word:
            S += float(correct[letter]) + (float(1/4-sum(correct.values())) if correct[letter] < counts[letter] else 0.0)
            
    return S

def get_valid_guesses(solution:str, prev_guesses:list):
    '''
    Gets a list of the valid guesses, which are words that conform to the the previous guesses.

    Returns a list of strings, the valid guesses
    '''
    valid_guesses = []
    
    known = '00000'
    valid_chars = [ord(97+i) for i in range(26)]
    
    # Determine known letters and their positions (if applicable)
    for guess in prev_guesses:
        for i in range(5):
            if guess[i] in valid_chars and not guess[i] in solution:
                valid_chars.remove(guess[i])
            elif guess[i] == solution[i]:
                known[i] = guess[i]
    
    # Find the valid guesses
    for i in sorter.progressbar(range(len(WORD_LIST)), "Sorting Words: ", 75): 
        valid = True
        for k in range(5):
            if WORD_LIST[i][k] not in valid_chars:
                valid = False
                break
            elif known[k] != 0 and WORD_LIST[i][k] != known[i]:
                valid = False
                break
        if valid:
            valid_guesses.append(WORD_LIST[i])
        
    WORD_LIST = valid_guesses
    with open(GUESSES_FILE_PATH, 'a') as file:
        file.write(valid_guesses)
    
    

def random_guess(solution:str, prev_guesses:list):
    '''
    Makes a new guess at random, using only words still available after the previous guesses. When a guess is made, the words being chosen from are added on a new line to the specified file

    returns a string, the guessed word
    '''
    available = get_valid_guesses(solution, prev_guesses)
    return choice(available)

def main():
    sorter.sort_words(sorter.file_to_list(sys.argv[1]), GUESSES_FILE_PATH)

    solution = input("\n\nEnter a word for the bot to guess: ")
    guesses = []

    print("\n\n")
    while True:
        guesses.append(random_guess(solution, guesses))
        if len(guesses) == 7:
            print("FAILED. Further guesses below:\n")
        print(f'guesses[-1]\n')

if __name__ == "__main__":
    main()