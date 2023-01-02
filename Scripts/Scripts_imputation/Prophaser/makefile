## Phaser: Compilation with GDB for debugging
CC = g++
CFLAGS = -std=c++14 -static -Ofast -g3 -Wall -c -fopenmp -msse2 -mavx -DNDEBUG
LFLAGS = -static -static-libgcc -static-libstdc++ -fopenmp -g -o

#CFLAGS = -std=c++14  -Ofast -g3 -Wall -c -fopenmp -msse2 -mavx
#LFLAGS = -fopenmp -g -o


#CFLAGS = -std=c++14  -O3 -g3 -Wall -c -fopenmp
#LFLAGS =  -fopenmp -g -o


SOURCES=$(wildcard *.cpp)
OBJECTS=$(SOURCES:.cpp=.o)
TARGET=phase
LIBSTATGEN=../libStatGen
EIGEN=../eigen3

all: $(TARGET)


$(TARGET): $(OBJECTS)
	$(CC) $(LFLAGS) $@ $^  -L$(LIBSTATGEN) -lStatGen -lz
#	$(CC) $(LFLAGS) $@ $^  -L$(LIBSTATGEN) -lStatGen_debug -lz
%.o: %.cpp %.h
	$(CC) $(CFLAGS) -g $< -I $(LIBSTATGEN)/include/ -I $(EIGEN)


%.o: %.cpp
	 $(CC) $(CFLAGS) $< -I $(LIBSTATGEN)/include/  -I $(EIGEN)


clean:
	rm -f *.o
