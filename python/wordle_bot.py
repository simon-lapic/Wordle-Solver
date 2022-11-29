import utils, sys
from random import choice

class WordleBot:
    def __init__(self, solution='crate', scope=[], path='solution_data.csv'):
        '''
        Initiates a new WordleBot object
        
        scope:  the list of words that the bot will use to guess. If the solution is not in this list, 
                then the bot will not be able to guess it
        path:   The file path where bot results should be stored
        '''
        self.__solution = solution
        self.__word_list = scope
        self.__valid_guesses = scope
        self.__output_file = path
        self.__guesses = []
        self.__state = '*****'
        self.__valid_letters = [chr(97+i) for i in range(26)]

    def get_solution(self):
        return self.__solution

    def get_guesses(self):
        return self.__guesses

    def get_valid_guesses(self, valid_letters=[], state='', guess=''):
        '''
        Creates a list of the possible guesses based on the known information. By default, the known information is based on the
        WordleBot's instance variables, but more specific circumstances can be specified
        '''
        if valid_letters == []:
            valid_letters = self.__valid_letters
        if state == '':
            state = self.__state
        if guess == '':
            guess = self.__guesses[-1]
        
        valid_guesses = []
        for word in self.__valid_guesses:
            valid = True
            for k in range(5):
                if word[k] not in valid_letters:
                    valid = False
                elif state[k] != '*' and word[k] != state[k]:
                    valid = False
                
            if valid:
                valid_guesses.append(word)
        return valid_guesses

    def get_new_information(self, valid_letters=[], state='', guess='', solution=''):
        '''
        Creates and returns a tuple describing the new information gained by a new guess. The tuple is in the 
        format (state, letters), where 'state' describes the characters known to be in certain positions and 'letters'
        lists all the letters that could still be in the word

        By default, the new information is generated based on the last guess in the guess list
        '''
        if valid_letters == []:
            valid_letters = self.__valid_letters
        if state == '':
            state = self.__state
        if guess == '':
            guess = self.__guesses[-1]
        if solution == '':
            solution = self.__solution
        
        for i in range(5):
            if guess[i] in valid_letters and not guess[i] in solution:
                valid_letters.remove(guess[i])
            if guess[i] == solution[i]:
                state = state[:i] + guess[i] + state[i+1:]
        
        return state, valid_letters

    def __update_known_info(self, guess=''):
        '''
        Updates all of the instance variables based on the known information. Should be called after making a guess
        '''
        if guess == '':
            guess = self.__guesses[-1]
        
        self.__state, self.__valid_letters = self.get_new_information()
        self.__valid_guesses = self.get_valid_guesses(guess=guess)
    
    def __expected_info(self, word=''):
        '''
        Calculates and returns the amount of information the bot can expect to get by guessing a word. The amount of information is
        derived by finding the average number of guesses that would be eliminated by guessing the word depending on what the
        actual solution is, and getting the percentage of the current valid guesses that would be eliminated from that. A higher 
        expected information value means it is more likely to remove more guesses from the list of possible solutions
        '''
        if len(word) != 5:
            print('Error: Invalid word, or no word specified.')
            return
        num_guesses_eliminated = 0
        for potential_solution in self.__valid_guesses:
            information = self.get_new_information(guess=word, solution=potential_solution)
            num_guesses_eliminated += len(self.get_valid_guesses(information[1], information[0], word))
        return num_guesses_eliminated/max(len(self.__valid_guesses), 1)/max(len(self.__valid_guesses), 1)
        
    def random_guess(self, words=[]):
        '''
        Makes a new guess at random, using only words still available after the previous guesses. A set of words 
        can optionally be specified to select from
        '''
        if words == []:
            words = self.__valid_guesses
        return choice(words)
    
    def informed_guess(self, words=[]):
        '''
        Makes a new guess using expected information values, using only words still available after the previous guesses. A specific
        set of words can optionally be specified to select from
        '''
        if words == []:
            words = self.__valid_guesses
        expected_information_values = []
        for i in utils.progressbar(range(len(self.__valid_guesses)), "Making a guess...", 75):
            expected_information_values.append(self.__expected_info(self.__valid_guesses[i]))
        return self.__valid_guesses[expected_information_values.index(max(expected_information_values))]

    def make_guess(self, method='r', word=''):
        '''
        Makes a guess and updates all the backend for it. By default, the guess is made at random, but the type of guess can be
        specified by the type variable. If method='r', the guess is made at random. If method='i', the guess is made using expected
        information

        Optionally, a specific word can be specified to guess with the 'word' parameter

        The new guess is returned
        '''
        new_guess = word if len(word) == 5 else self.random_guess() if method == 'r' else self.informed_guess() if method == 'i' else '*****'

        if new_guess == '*****':
            print('Error: invalid guess type specified')
            return
        elif new_guess == '':
            print('Error: no guess made')
            return
        self.__guesses.append(new_guess)
        self.__update_known_info()
        return new_guess

if __name__ == '__main__':
    path = sys.argv[1]
    # path = 'data\\test_words.txt' # DEBUGGING
    bot = WordleBot(solution=input('Enter a word for the bot to guess: '), scope=utils.file_to_list(path))

    while len(bot.get_guesses()) < 6:
        print(f'{bot.make_guess(method="i")} (chosen from {len(bot.get_valid_guesses())} possible guesses)')
        if bot.get_guesses()[-1] == bot.get_solution():
            print(f'SOLVED in {len(bot.get_guesses())} guesses!')
            break
    if bot.get_guesses()[-1] != bot.get_solution():
        print("FAILED to guess the correct word")
