import sorter, sys
from multiprocessing import Process, Queue
from random import choice

NP = 1
WORD_LIST = []
GUESSES_FILE_PATH = '../data/parallel_solver_guess_list.txt'

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

def get_valid_guesses(start:int, end:int, prev_guesses:list, queue:Queue):
    pass

def random_guess(prev_guesses:list):
    '''
    Makes a new guess at random, using only words still available after the previous guesses.

    The available guesses are determined in parallel
    '''
    
    available = Queue()
    processes = []

    for i in range(NP):
        start_idx = i * (len(WORD_LIST) // NP)
        end_idx = (i+1) * (len(WORD_LIST) // NP)

        process = Process(target=get_valid_guesses, args=(start_idx, end_idx, prev_guesses, available))
        processes.append(process)
    
    for i in range(len(processes)):
        processes[i].start()
    
    for i in range(len(processes)):
        processes[i].join()

    return choice(available)



def main():
    if sys.argv[2]:
        NP = sys.argv[2]
    
    sorter.sort_words(sorter.file_to_list(sys.argv[1]), '../data/solver_word_list.txt')

    

if __name__ == "__main__":
    main()