import utils, sys
from random import choice

WORD_LIST = []
GUESSES_FILE_PATH = '../data/serial_solver_guess_list.txt'

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
        
    return valid_guesses
    
def random_guess(solution:str, prev_guesses:list):
    '''
    Makes a new guess at random, using only words still available after the previous guesses. When a guess is made, the words being chosen from are added on a new line to the specified file

    returns a string, the guessed word
    '''
    global WORD_LIST, GUESSES_FILE_PATH
    WORD_LIST = get_valid_guesses(solution, prev_guesses)
    utils.append_list(GUESSES_FILE_PATH, WORD_LIST)
    return choice(WORD_LIST)

def get_information(word:str):
    '''
    Determines how many possible guesses would be eliminated, on average, from the wordlist by a given guess. The result is returned as a float
    '''
    eliminations = []
    for potential_solution in WORD_LIST:
        eliminations.append(len(get_valid_guesses(potential_solution, WORD_LIST)))
    return sum(eliminations)/len(eliminations)/len(eliminations)

def informed_guess(solution:str, prev_guesses:list):
    '''
    Makes a new guess bassed on how much information it is expected to generate, using only words still available after the previous guesses. When a guess is made, the words being chosen from are added on a new line to the specified file

    returns a string, the guessed word
    '''
    global WORD_LIST, GUESSES_FILE_PATH
    WORD_LIST = get_valid_guesses(solution, prev_guesses)
    utils.append_list(GUESSES_FILE_PATH, WORD_LIST)
    information_values = [get_information(word) for word in WORD_LIST]
    return WORD_LIST[information_values.index(utils.list_max(information_values))]

def main():
    global WORD_LIST, GUESSES_FILE_PATH
    WORD_LIST = utils.file_to_list(sys.argv[1])
    utils.empty_file(GUESSES_FILE_PATH)

    cmd = input("Would you like the bot to guess randomly (R) or by expected information (I)? ").lower()
    solution = input("Enter a word for the bot to guess: ")
    guesses = []

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
            print("Guessing informedly...\n\n")
            while True:
                guesses.append(informed_guess(solution, guesses))
                if len(guesses) == 7:
                    print("FAILED. Further guesses below:")
                print(f'{guesses[-1]} ({len(WORD_LIST)} possibilities)\n')
                if guesses[-1] == solution:
                    print(f"SOLVED in {len(guesses)} guesses\n")
                    break
            break
        elif cmd == 'exit':
            break
        else:
            cmd = input("Enter 'R' to have the bot guess randomly, or 'I' to have it use expected information: ").lower()

if __name__ == "__main__":
    main()