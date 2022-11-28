import sys, time
from random import choice

def progressbar(it, prefix="", size=60, out=sys.stdout):
    '''
    Creates a progress bar to show that a function is progressing. To use, replace the 'range()' in a for-loop with a 
    declaration of this function
    '''
    count = max(len(it), 1)
    def show(j):
        x = int(size*j/count)
        print(f"{prefix}[{'#'*x}{'.'*(size-x)}] ({round(100*j/count, 4)}%)", end='\r', file=out, flush=True)
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

def write_csv(file_path:str, *columns):
    '''Creates a csv file from any number of lists. The lists should all be of the same size'''
    with open(file_path, 'w') as file:
        for i in range(len(columns[0])):
            line = ''
            for c in columns:
                line += f'{c[i]},'
            file.write(line + '\n')

def sort(items:list):
    '''Sorts a list from least to greatest'''
    sorted = [items[0]]
    for i in progressbar(range(len(items)), "Sorting: ", 75):
        inserted = False
        for k in range(len(sorted)):
            if items[i] < sorted[k]:
                sorted.insert(k, items[i])
                inserted = True
                break
        if not inserted: 
            sorted.append(items[i])

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

def timer(func):
    '''A function wrapper which causes the function to return the amount of time it took to execture'''
    def timed_func(*args, **kwargs):
        start = time.time()
        func(*args, **kwargs)
        end = time.time()
        return end-start
    return timed_func

def main():
    print('Selecting a test sample...')
    list_to_file('../data/test_words.txt', random_selection(file_to_list('../data/wordle_words.txt'), int(sys.argv[1])))
    print('Test File generated.')

if __name__ == "__main__":
    main()