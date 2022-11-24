import sys
from random import choice

def progressbar(it, prefix="", size=60, out=sys.stdout):
    count = len(it)
    def show(j):
        x = int(size*j/count)
        print(f"{prefix}[{'#'*x}{'.'*(size-x)}] ({100*j//count}%)", end='\r', file=out, flush=True)
    show(0)
    for i, item in enumerate(it):
        yield item
        show(i+1)
    print("\n", flush=True, file=out)

def file_to_list(file_path:str):
    '''Turns a file of comma-separated words into a python list'''
    with open(file_path, 'r') as file:
        l = file.readline().split(',')
    return l

def list_to_file(file_path:str, l:list):
    '''Turns a list into a file'''
    with open(file_path, 'w') as file:
        for i in range(len(l)-1):
            file.write(f'{l[i]},')
        file.write(f'{l[-1]}')

def append_list(file_path:str, l:list):
    '''Appends a list to a file on a new line'''
    with open(file_path, 'a') as file:
        file.write('\n')
        for i in range(len(l)-1):
            file.write(f'{l[i]},')
        file.write(f'{l[-1]}')

def empty_file(file_path:str):
    '''Clears a file of its data'''
    with open(file_path, 'w') as file:
        file.write('')

def sort_words(words:list):
    '''
    Sorts a list of words alphabetically
    '''
    sorted = [words[0]]
    for i in progressbar(range(len(words)), "Sorting Words: ", 75):
        inserted = False
        for k in range(len(sorted)):
            if words[i] < sorted[k]:
                sorted.insert(k, words[i])
                inserted = True
                break
        if not inserted: 
            sorted.append(words[i])

    return sorted

def list_max(items:list):
    '''Returns the maximum value of a list'''
    max = items[0]
    for item in items:
        if item > max:
            max = item
    return max

def random_selection(items:list, n:int):
    '''Returns random subset of the specified list with a size of n'''
    subset = []
    for i in range(n):
        subset.append(choice(items))
        items.remove(subset[i])
    return subset

def main():
    sort_words(file_to_list('../data/wordle_words.txt'))
    # list_to_file('../data/test_words.txt', random_selection(file_to_list('../data/wordle_words.txt'), int(sys.argv[1])))

if __name__ == "__main__":
    main()