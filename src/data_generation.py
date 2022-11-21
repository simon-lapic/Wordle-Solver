import io
import sys

from multiprocessing import Process, Queue

def progressbar(it, prefix="", size=60, out=sys.stdout):
    count = len(it)
    def show(j):
        x = int(size*j/count)
        print("{}[{}{}] {}/{}".format(prefix, "#"*x, "."*(size-x), j, count), end='\r', file=out, flush=True)
    show(0)
    for i, item in enumerate(it):
        yield item
        show(i+1)
    print("\n", flush=True, file=out)

def file_to_list(file_path):
    '''Turns a file of comma-separated words into a python list'''
    file = open(file_path, 'r')
    l = file.readline().split(',')
    file.close()

    return l

def list_to_file(file_path, l:list):
    '''Turns a string into a file'''
    file = open(file_path, 'w')
    for i in range(len(l)-1):
        file.write(f'{l[i]},')
    file.write(f'{l[len(l)-1]}')
    file.close()

def sort_word_list(words:list, file_path:str):
    '''
    Sorts a list of words alphabetically, and returns a list of indecies that act as jump points to different letters of the alphabet. 
    
    For example, indecies[3] should be an index in words corresponding to the first words beginning with the character 'c'
    '''
    sorted = [words[0]]
    for i in progressbar(range(len(words)), "Sorting: ", 50):
        inserted = False
        for k in range(len(sorted)):
            if words[i] < sorted[k]:
                sorted.insert(k, words[i])
                inserted = True
                break
        if not inserted: 
            sorted.append(words[i])

    sorted[0] = sorted[0][4:]
    list_to_file(file_path, sorted)

    # Generate the indices list
    indecies = [0]
    l = 'b'
    for i in range(len(sorted)):
        if sorted[i].startswith(l):
            indecies.append(i)
            l = chr(ord(l)+1)

    return indecies

def first_guesses(words:list, num_processes:int):
    '''
    Generates training data for making the first guess of for a wordle word
    words: the list of words that can be guessed
    
    The data is represented by a string in the format "y:x1,x2,..." where "y" is the word being guessed and each "x" is a guess already made before

    The label is a score represented by a float, where each letter in the correct place increases the score by 1, each letter in the word but not in the correct place increases the score by 1/n (where n is the number of possible locations the letter could be [repeated letters are only scored once]), and each incorrect letter does not affect the score

    The training data is returned as a tuple of lists in the format (data, labels)
    '''
    data = []
    labels = []

    for i in progressbar(range(len(words)**2), "Opening Threads: ", 50):
        w1, w2 = words[i//len(words)], words[i%len(words)]
        data.append(f'{w1}:{w2},00000,00000,00000,00000,00000')
        labels.append(score(w1, w2))

    return (data, labels)

def score(word:str, guess:str):
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

def get_training_data(words:list):
    temp = first_guesses(words, 8)
    data = temp[0]
    labels = temp[1]

    training_str = ""
    for i in range(len(data)):
        training_str += f'{labels[i]} : {data[i]}\n'
    
    file = open(r".\data\training_data.txt", 'w')
    file.write(training_str)
    file.close()

def main():
    words = file_to_list(r".\data\wordle_words.txt")
    idxs = sort_word_list(words, r".\data\sorted_words.txt")
    sorted = file_to_list(r".\data\sorted_words.txt")

    broken_idx = 2
    print(f'{sorted[broken_idx//len(words)]}, {sorted[broken_idx%len(words)]}')

    get_training_data(sorted)

    list_to_file(r".\data\sorted_words.txt", sorted)
    
if __name__ == "__main__":
    main()