#Makefile _generic_
# --- generic Makefile ---
# --- by Maik Friemel  ---
# ************************
# Licence: GPL V3
# find under https://www.gnu.org/licenses/gpl-3.0-standalone.html
# ************************

# config - edit to make your settings
## Name of the executabel default=basename of the directory
EXE_NAME=
## List of Directories with source files seperated by space
## under the working directory (subdirectories are included)
SRC_DIRS=src

#shared lib if a shared library should be created
#istead of a statc, then comment it out
SHARED= #1

## Directories to include
### -I will be added automatically before (just write the dirs)
INCL_DIRS=

## Libaries for linking
### -l will be automatically added before (just write the lib-name)
#### sets the -llibname option
LF=   #ncurses #=Beispiel
## The options used in linking as well as in any direct use of ld.
### to use for instance for [-Ldir] option
LDF=$(shell wx-config --libs) #wxWidgets

## List of libraries to include seperate by space
## will be added to LDF
LIBS=   # gtkmm-3.0 #Beispiel für gtkmm

## Compiler-Flags
CF=-std=c++20 -Wall -pedantic $(shell wx-config --cxxflags) #wxWidgets

## Debuging
### set to
#### 1 for level minimal :: -g1
#### 2 for regular       :: -g
#### 3 for maximum,      :: -g3
#### or empty -> None
ifeq ($(g),)
	DB= #3
else
	DB= $(g)
endif

#Create a compile_command.json
#comment the value to prevent.
BEAR=bear --append --

## Compiler + Linker to use
COMPILER=g++
LINKER=g++

## Build-Directory where the object- and dependcie-files stored
BUILD=build

#VERBOSE-Option set to @ to shut up the instruction output
VERBOSE = #@

# ^^^ END of config ^^^
# ******************************************************************
# * Don't edit below                                               *
# ******************************************************************

# Variables

# Shell used in this makefile
# bash is used for 'echo -en'
SHELL = /bin/bash

# Timer-Macros
TIME_FILE = $(dir $@).$(notdir $@)_time
START_TIME = date '+%s' > $(TIME_FILE)
END_TIME = read st < $(TIME_FILE) ; \
		$(RM) $(TIME_FILE) ; \
		st=$$((`date '+%s'` - $$st - 86400)) ; \
		echo `date -u -d @$$st '+%H:%M:%S'`

## set the default Name of executeable if it is not set
EMPTY   =
SPACE   = $(EMPTY) $(EMPTY)

ifeq ($(EXE_NAME),)
  CUR_PATH_NAMES = $(subst /,$(SPACE),$(subst $(SPACE),_,$(CURDIR)))
  EXE_NAME = $(word $(words $(CUR_PATH_NAMES)),$(CUR_PATH_NAMES))
  ifeq ($(EXE_NAME),) # fallback to a.out as name if something wend wrong
    EXE_NAME = a.out
  endif
endif

# include all subdirectories
SRC_DIRS := $(sort $(shell find $(SRC_DIRS) -type d))

VPATH = $(SRC_DIRS)

# possible extensions of Source-Files to work with
CEXT=  .c .C .cc .CC
CPPEXT= .cpp .Cpp .CPP .c++ .C++ .cxx .CXX .Cxx .cp .CP .Cp
SRCEXTS = $(CEXT) $(CPPEXT)

# The header file extensions. usualy simply .h or .hpp
HDREXTS = .h .H .hh .HH .Hh .hpp .HPP .Hpp .h++ .H++ .hxx .HXX .Hxx .hp .HP .Hp

# Set the Source-files by searching of all files in the SRC_DIRS with the SRCEXTS
SOURCES = $(foreach d,$(SRC_DIRS),$(wildcard $(addprefix $(d)/*,$(SRCEXTS))))
# Set the Header-files by searching of all files in the SRC_DIRS with the HDREXTS
HEADERS = $(foreach d,$(SRC_DIRS),$(wildcard $(addprefix $(d)/*,$(HDREXTS))))

# Set objet-files out of the source-files by using their basename with .o
OBJS    = $(addprefix $(BUILD)/, $(notdir $(addsuffix .o, $(basename $(SOURCES)))))

# Set a dependeny file for each object-file by settig .d for .o
DEPS    = $(OBJS:.o=.d)

# adding -g to the compilerflags if Debuging is turned on
ifneq ($(DB),)
  ifeq ($(DB),1)
       DB= -g1
  else
       ifeq ($(DB),3)
	 DB= -g3
       else
	 DB= -g
       endif
  endif
  CF += $(DB)
endif

ifeq ($(SHARED),1)
  CF +=  -fPIC
  LDF += -shared
  LIB_ENDING=.so
else
  LIB_ENDING=.a
endif

# adding the include directories with -I before to the Compilerflags
CF += $(foreach incl,$(INCL_DIRS), $(addprefix -I ,$(incl)))

# setting the library-name with -l before as Linkerflags
## this can be extended by LIBS
## with pkg-config --libs $(LIBS) in the next section
LF:= $(foreach l,$(LF), $(addprefix -l,$(l)))
LDF += $(LF)
# Append pkg-config specific libraries if need be
#Symbol’s value as variable is void: pkg-config # Beispiel für gtkmm
ifneq ($(LIBS),)
	CF += `pkg-config --cflags $(LIBS)`
	LDF += `pkg-config --libs $(LIBS)`
endif

# Set the option to create the dependencie-files
DEP_OPT = -MM -MP 

# instruction to create the dependencie-files
MK_DEP = $(COMPILER)  $(DEP_OPT)

# compile-instruction to generate the object-file
COMPILE = $(COMPILER) -c $(CF)

# ^^^ END Variable-Definition ^^^
# ****************************************************
# Rules for make                                     *
# ****************************************************

.PHONY: all clean 

# Delete the default suffixes
.SUFFIXES:

all: $(EXE_NAME)

# Rules for creating dependency files (.d)
define mk-dependencies

$(BUILD)/%.d:%$(1)
	@echo "create $$@ for $$<"
	@[ -d $$(BUILD) ] || mkdir -p $$(BUILD)
	$$(VERBOSE)$$(COMPILER) $(CF) -MM $$< | sed 's/^/$$(BUILD)\//' >$$@

endef

$(foreach EXT, $(SRCEXTS),$(eval $(call mk-dependencies,$(EXT))) )

ifndef NODEP
ifneq ($(DEPS),)
  sinclude $(DEPS)
endif
endif

# Rules for generating object files (.o) / objs
define mk-compile

$(BUILD)/%.o:%$(1) #$(BUILD)
	@echo "Compiling: $$< -> $$@"
	@$$(START_TIME)
	$$(VERBOSE) $$(BEAR) $$(COMPILE) $$< -o $$@
	@echo -en "\t Compile time: "
	@$$(END_TIME)

endef

$(foreach EXT, $(SRCEXTS),$(eval $(call mk-compile,$(EXT))) )

# Rule for generating the executable
$(EXE_NAME):$(OBJS)
	@echo "Create executable: $@"
	@$(START_TIME)
	$(VERBOSE)$(LINKER) $(OBJS) $(LDF) -o $@
	@echo -en "\t time to create executable: "
	@$(END_TIME)
	@echo Type ./$@ to execute the program.

#generating a  lib
lib: $(OBJS)
	@echo "Create static lib: lib/$@$(EXE_NAME).a"
	@$(START_TIME)
	@mkdir -p lib
	$(VERBOSE)ar rcs lib/lib$(EXE_NAME)$(LIB_ENDING) $^

clean:
	$(RM) $(OBJS)

clean_build:
	$(RM) -rf $(BUILD)

# Function used to check variables. Use on the command line:
# make print-VARNAME
# Useful for debugging and adding features
print-%: ; @echo "$*=>$($*)<"

help:
	@echo "generic Makfile by Maik Friemel"
	@echo "Licence GPL V3 or higher"
	@echo "Diese Makefile automatisiert das Kompilieren und Linken"
	@echo "Usage:"
	@echo "make :: wenn es am Kopf des Makfiles nicht"
	@echo "anders konfiguriert ist sucht make"
	@echo "vom Ordner des Makefiles ausgehend"
	@echo "alle source und header Dateien"
	@echo "compiliert und verlinkt diese,"
	@echo "wobei der Name der ausführbaren Datei,"
	@echo " dem des Ordners entspricht."
	@echo 
	@echo "Konfiguration:"
	@echo "EXE_NAME :: Der Name des Programs oder der"
	@echo "Bibliothek, die erstellt wird.  Sofern nicht angegeben,"
	@echo "wird der Name des Ordners genutzt."
	@echo "SHARED :: auskommentiert oder 1; 1, wenn"
	@echo "make lib statt eine statischen Bibliothek"
	@echo "eine dynamische erzeugen soll."
	@echo "SRC_DIRS :: Der Name des oder der Ordner in denen "
	@echo "rekursiv nach source/header-Dateien gesucht wird,"
	@echo "die dann zu Objektdateien verabeitet werden."
	@echo "INCL_DIRS :: Der Pfad oder die Pfade zu den "
	@echo "Includeverzeichnissen (header-Dateien) von"
	@echo "einzubindenden Bibliotheken, wo bei hier nur"
	@echo "der Pfad eingegeben wird.  Die Option -I beim"
	@echo "späteren Kompilieren, wird automatisch ergänzt."
	@echo "LF :: Hier werden die Namen von einzubindenden "
	@echo "Bibliotheken angegeben.  Es muss auschließlich"
	@echo "der Name, also ohne die Linker-Option -l"
	@echo "angegeben werden, da diese beim linken automatisch"
	@echo "für diesen Eintrag ergänzt wird.  Außerdem ist der"
	@echo "Name der Bibliothek ohne ein vorangestelltes lib"
	@echo "und nachgesteltes .a oder .so anzugeben!"
	@echo "LDF :: hier werden alle Linkeroptionen angegeben."
	@echo "Beim Einbinden von Bibliotheken wird hier der Pfad"
	@echo "zur Bibliothek mit vorangestellter Option -L"
	@echo "angegeben. Was hier eingegeben wird,"
	@echo "wird eins zu eins genau so an den Linker"
	@echo "als Option beim Linken übergeben."
	@echo "LIBS :: was hier angegeben wird wird an die "
	@echo "Funktionen:"
	@echo "pkg-config --cflags $(LIBS), die CF erweitert "
	@echo "und "
	@echo "pkg-config --libs $(LIBS), die LDF erweitert"
	@echo "übergeben."
	@echo "CF :: hier werden die gewünschten Flags für"
	@echo "den Compiler angegeben, die genau wie eingeben"
	@echo "beim kompilieren als Option genutzt werden."
	@echo "DB :: hier kann das gewünschte Level"
	@echo "für die Debuginginformationen angegeben werden."
	@echo "es wird zwischen folgenden möglichen"
	@echo "Leveln unterschieden, die wie folgt anzugeben sind:"
	@echo "# :: auskommentiert => Debuging aus"
	@echo "1 :: Debuging niedrigstes Level := -g1"
	@echo "2 :: Standard-Debuging enspricht := -g"
	@echo "3 :: Maximales Debuging-Level := -g3"
	@echo "COMPILER :: hier kann ein anderer Compiler"
	@echo "angegeben werden, als g++, wie z.Bsp clang"
	@echo "LINKER :: falls man einen anderen Linker"
	@echo "als den g++ verwenden möchte, hier angeben."
	@echo "BUILD :: Hier kann ein Ordner angegeben werden,"
	@echo "in den alle .o und .d-Dateien gespeichert werden."
	@echo "VERBOSE :: auskommentiert oder @,"
	@echo "wobei @ die ausgaben des Makefiles"
	@echo "zum Großteil unterdrückt."
	@echo "Das sind derzeit alle Optionen."
	@echo "Unterhalb dieser Stelle sollten"
	@echo "keine Änderungen vorgenommen werden."
	@echo "Alternative Ziele:"
	@echo "Zusätzlich zu der Möglichkeit mit make"
	@echo "oder gleichbedeutend make all"
	@echo "wie oben beschrieben ein ausführbares"
	@echo "Programm zu erstellen,"
	@echo "gibt es noch folgende Möglichkeiten:"
	@echo "make clean :: löscht die Objektdteien."
	@echo "make clean_build :: löscht den build-Ordner"
	@echo "mit allen .d- und .o- Dateien."
	@echo "make lib :: erstellt eine libNAME[.a|.so]-Datei."
	@echo "im Ordner lib. Die Endung Endung hängt von der"
	@echo "der Konfiguration der Variable SHARED im oberen"
	@echo "Teil des Makefiles ab, wobei .a gewählt wird,"
	@echo "wenn SHARED nicht 1 ist, also eine statische"
	@echo "Bibliothek erstellt wird, und .so gewählt wird,"
	@echo "wenn SHARED = 1 ist, also eine dynamische "
	@echo "Bibliothek erstellt wird."
	@echo "make print-VARIABLENNAME :: Gibt den Wert der"
	@echo "Variable im Makefile zu Debugingzwecken des"
	@echo "Makfiles aus."
	@echo "make help :: ruft diese Hilfe auf."
	@echo "wobei versucht wurde die Konfiguration"
	@echo "bereits weitgehend selbsterklärend zu gestalten."
	@echo "Damit sollte das Kompiliern und Linken"
	@echo "weitgehend automatisch vonstatten gehen,"
	@echo "so dass die Konzentration mehr auf"
	@echo "der Programmierung liegen kann."
	@echo "Viel Spaß beim Programmieren :-)"
