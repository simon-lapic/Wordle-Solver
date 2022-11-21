import sys

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

def file_to_list(file_path:str):
    '''Turns a file of comma-separated words into a python list'''
    file = open(file_path, 'r')
    l = file.readline().split(',')
    file.close()

    return l

def list_to_file(file_path:str, l:list):
    '''Turns a string into a file'''
    file = open(file_path, 'w')
    for i in range(len(l)-1):
        file.write(f'{l[i]},')
    file.write(f'{l[len(l)-1]}')
    file.close()

def sort_words(words:list, file_path:str):
    '''
    Sorts a list of words alphabetically and stores them in the specified file, then returns a list of indecies that act as jump points to different letters of the alphabet. 
    
    For example, indecies[3] should be an index in words corresponding to the first words beginning with the character 'c'
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

    sorted[0] = sorted[0]
    list_to_file(file_path, sorted)

    # Generate the indices list
    indecies = [0]
    l = 'b'
    for i in range(len(sorted)):
        if sorted[i].startswith(l):
            indecies.append(i)
            l = chr(ord(l)+1)

    return indecies

def main():
    sort_words(file_to_list(sys.argv[1]), sys.argv[2])

if __name__ == "__main__":
    main()