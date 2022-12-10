# Parallelized Wordle-Solver
This is a parallelized implementation of an algorithm to solve the Wordle, a daily vocabulary game created by Josh Wardle and now published and run by the New York Times. The algorithm tries to predict which potential guess would give it as much information as possible (i.e. eliminate as many guesses as possible), however it is very computationally intensive to do so for each word. Fortunately, the amount of information we can expect to receive from each word can be calculated entirely independantly, and so it is possible to parallelize this portion of the algorithm using CUDA on a GPU.

In its current form, the program cannot be used to "cheat" with the current Wordle, but has been designed such that there as few dependencies on knowing the actual solution as possible (only the `solve()` and `learn()` functions take it as a parameter, and both only use it to compare to what has been guessed and update the program's knowledge), such that it would not be difficult but perhaps somewhat morally reprehensible to modify the program to do so.

### Compiling and Running the CUDA Implementation
This program requires CMake, a C++11 compiler, and a CUDA compiler, as well as a CUDA-enabled GPU, to compile and run.

If you meet these requirements, you should be able to compile the code in a Linux environment with the following commands
```
mkdir build
cd build/
cmake..
make
```
To run the program normally, use the following command in the `build/` directory:
```
./solver [solution] [word list path] <output file path>
```
Where `[solution]` is a 5-letter word contained in a .txt file at `[word list path]`. The word list in the file should have each word separated by line. Optionally, an `<output file path>` can be specified for a .csv file so that the results are stored on a new line in the file