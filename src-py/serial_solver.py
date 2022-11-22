import utils, sys
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
    global WORD_LIST, GUESSES_FILE_PATH
    valid_guesses = []
    
    known = '00000'
    valid_chars = [chr(97+i) for i in range(26)]
    
    # Determine known letters and their positions (if applicable)
    for guess in prev_guesses:
        for i in range(5):
            if guess[i] in valid_chars and not guess[i] in solution:
                valid_chars.remove(guess[i])
            if guess[i] == solution[i]:
                known = known[:i] + guess[i] + known[i+1:]
    
    # Find the valid guesses
    for i in range(len(WORD_LIST)):# utils.progressbar(range(len(WORD_LIST)), "Finding Valid Guesses: ", 75): 
        valid = True
        for k in range(5):
            if WORD_LIST[i][k] not in valid_chars:
                valid = False
            elif known[k] != '0' and WORD_LIST[i][k] != known[k]:
                valid = False
            
        if valid:
            valid_guesses.append(WORD_LIST[i])
        
    utils.append_list(GUESSES_FILE_PATH, valid_guesses)
    return valid_guesses
    
def random_guess(solution:str, prev_guesses:list):
    '''
    Makes a new guess at random, using only words still available after the previous guesses. When a guess is made, the words being chosen from are added on a new line to the specified file

    returns a string, the guessed word
    '''
    global WORD_LIST
    WORD_LIST = get_valid_guesses(solution, prev_guesses)
    return choice(WORD_LIST)

def informed_guess(solution:str, prev_guesses:list):
    pass

def main():
    global WORD_LIST
    path = sys.argv[1]
    WORD_LIST = utils.file_to_list(path)

    solution = input("\n\nEnter a word for the bot to guess: ")
    guesses = []

    cmd = input("Would you like the bot to guess randomly (R) or by expected information (I)? ").lower()

    while True:
        if cmd == 'r':
            print("Guessing randomly...\n\n")
            while True:
                guesses.append(random_guess(solution, guesses))
                if len(guesses) == 7:
                    print("FAILED. Further guesses below:")
                print(f'{guesses[-1]} ({len(WORD_LIST)} possibilities)\n')
                if guesses[-1] == solution:
                    print(f"SOLVED in {len(guesses)} guesses\n")
                    break
            break
        elif cmd == 'i':
            print("Guessing randomly...\n\n")
            while True:
                guesses.append(informed_guess(solution, guesses))
                if len(guesses) == 7:
                    print("FAILED. Further guesses below:")
                print(f'{guesses[-1]} ({len(WORD_LIST)} possibilities)\n')
                if guesses[-1] == solution:
                    print(f"SOLVED in {len(guesses)} guesses\n")
                    break
            break
        else:
            cmd = input("Enter 'R' to have the bot guess randomly, or 'I' to have it use expected information: ").lower()
    

if __name__ == "__main__":
    main()