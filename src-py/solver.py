import sorter

def score_old(word:str, guess:str):
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

def main():
    pass

if __name__ == "__main__":
    main()