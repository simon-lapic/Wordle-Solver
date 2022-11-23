import utils, sys, time
from multiprocessing import Process, Queue

NP = 1
WORD_LIST = []
GUESSES_FILE_PATH = '../data/parallel_solver_guess_list.txt'

def get_valid_guesses(solution:str, prev_guesses:list):
    '''
    Gets a list of the valid guesses, which are words that conform to the the previous guesses.

    Returns a list of strings, the valid guesses
    '''
    valid_guesses = []
    global WORD_LIST, GUESSES_FILE_PATH
    
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
    for i in range(len(WORD_LIST)): 
        valid = True
        for k in range(5):
            if WORD_LIST[i][k] not in valid_chars:
                valid = False
            elif known[k] != '0' and WORD_LIST[i][k] != known[k]:
                valid = False
            
        if valid:
            valid_guesses.append(WORD_LIST[i])
    
    return valid_guesses

def average_information(prev_guesses:list, start:int, end:int, queue:Queue):
    '''
    Finds the average amount of information for a subset of the possible answers
    '''
    global WORD_LIST
    local_eliminations = []
    for i in range(start, end):
        local_eliminations.append(len(get_valid_guesses(WORD_LIST[i], prev_guesses)))
    queue.put(sum(local_eliminations)/len(local_eliminations))

def get_information(word:str, prev_guesses:list):
    '''
    Returns the percentage of possible answers a guess will eliminate, on average. Higher values mean that more information is gained, on average, by guessing the word 
    '''
    queue = Queue()
    processes = []

    prev_guesses.append(word)
    for i in range(NP):
        start_index = i * len(WORD_LIST) // NP
        end_index = (i + 1) * len(WORD_LIST) // NP

        process = Process(target=average_information, args=(prev_guesses, start_index, end_index, queue))
        processes.append(process)
    
    for i in range(len(processes)):
        processes[i].start()
    
    for i in range(len(processes)):
        processes[i].join()
    
    sum = 0
    for i in range(NP):
        sum += queue.get()
    
    return sum/NP/len(WORD_LIST)

def informed_guess(solution:str, prev_guesses:list):
    '''
    Makes a new guess bassed on how much information it is expected to generate, using only words still available after the previous guesses. When a guess is made, the words being chosen from are added on a new line to the specified file

    returns a string, the guessed word
    '''
    global WORD_LIST, GUESSES_FILE_PATH
    WORD_LIST = get_valid_guesses(solution, prev_guesses)
    utils.append_list(GUESSES_FILE_PATH, WORD_LIST)
    information_values = [get_information(word, prev_guesses) for word in WORD_LIST]
    return WORD_LIST[information_values.index(utils.list_max(information_values))]

def main():
    global WORD_LIST, NP
    if len(sys.argv) > 2:
        NP = int(sys.argv[2])

    path = sys.argv[1]
    WORD_LIST = utils.file_to_list(path)

    solution = input("Enter a word for the bot to guess: ")
    guesses = []

    print("The bot will make informed guesses:")

    print("\n\n")
    while True:
        start_time = time.time()
        guesses.append(informed_guess(solution, guesses))
        end_time = time.time()
        if len(guesses) == 7:
            print("FAILED. Further guesses below:\n")
        print(f'{guesses[-1]} (chosen from {len(WORD_LIST)} possibilities, guess made in {(start_time-end_time)/60} minutes)\n')
        if guesses[-1] == solution:
            print(f"SOLVED in {len(guesses)} guesses\n")
            break

if __name__ == "__main__":
    main()