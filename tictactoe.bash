#!/bin/bash
# tui tictactoe

while [[ -z $playerToken ]] || [[ $playerToken = [[:space:]] ]]; do
  IFS="" read -r -n 1 -p "Choose your character: " playerToken
done

if [[ $playerToken = "O" ]]; then
  compToken="X"
else
  compToken="O"
fi

if [[ $playerToken = "-" ]]; then
  openToken="~"
else
  openToken="-"
fi

# 3x3 board will be represented by a 9 element array
for square in {1..9}; do
  squares+=("$openToken")
done

# checkBoard token array
# example: checkBoard "X" "${squares[@]}"
# - use in an `if` statement
# - make a copy of squares to lookahead for wins
checkBoard() {
    local i
    token="$1"
    shift
    i=0
    row_i=3
    dia_i=4
    adi_i=5 #anti diagonal
    counter=(0 0 0 0 0 0) #col0 col1 col2 row_i dia_i adi_i
    for square do
        row=$((i / 3))
        col=$((i % 3))
        if [[ $square == "$token" ]]; then
            ((counter[row_i]++)) # looking for three in a row
            ((counter[col]++)) # looking for three in a column
            if ((counter[row_i] == 3)) || ((counter[col] == 3)); then
                return 0
            fi
            if ((row == col)); then
                ((counter[dia_i]++)) # looking for three on the diagonal
                if ((counter[dia_i] == 3)); then
                    return 0
                fi
            fi
            if ((row + col == 2)); then
                ((counter[adi_i]++)) # looking for three on the antidiagonal
                if ((counter[adi_i] == 3)); then
                    return 0
                fi
            fi
        else
            counter[$row_i]=0 # ends streak for this row
        fi
        ((i++)) 
        if ((i / 3 != row)); then
            counter[$row_i]=0 # new row, new streak
        fi
    done
    return 1 # no win found
}

# get user input
getChoice() {
    local choice
    while ((choice < 1)) || ((choice > 9)); do
        read -rp "Select a square [1-9]: " choice
    done
    ((--choice))
    echo "$choice"
}

# something to visualize the board with
# takes an array as argument
printBoard() {
    local squares
    squares=("$@")
    printf "\n"
    for ((i = 0; i < 9; ++i)); do
        printf "%c" "${squares[$i]}"
        if ((i == 2)) || ((i == 5)) || ((i == 8)); then
            printf "\n"
        else
            printf "|"
        fi
    done
}

# getCompCoice array
# pass the board in as an argument
getCompChoice() {
    local i choice openSquare squaresCopy
    squaresCopy=("$@")
    for ((i = 0; i < 9; i++)); do
        if [[ ${squaresCopy[$i]} == "$openToken" ]]; then
            squaresCopy[$i]="$playerToken"
            if checkBoard "$playerToken" "${squaresCopy[@]}"; then
                echo "$i"
                return
            fi
            squaresCopy[$i]="$compToken"
            if checkBoard "$compToken" "${squaresCopy[@]}"; then
                echo "$i"
                return
            fi
            squaresCopy[$i]="$openToken" # put it back the way it was
            openSquare=$i # last open square we find will be the default move
        fi
    done
    echo $openSquare
}

moveCount=0 # determines tie games
choice=9 # initialize to invalid choice
# main loop, use ctrl + c to exit early
while true; do
    printBoard "${squares[@]}"
    until [[ ${squares[$choice]} == "$openToken" ]]; do
        choice=$(getChoice)
    done
    squares[$choice]="$playerToken"
    if checkBoard "$playerToken" "${squares[@]}"; then
        printBoard "${squares[@]}"
        echo "You win"
        exit 0
    fi
    ((moveCount++))
    if ((moveCount == 5)); then
        printBoard "${squares[@]}"
        echo "It's a tie! Let's play again."
        unset squares
        for square in {1..9}; do
          squares+=("$openToken")
        done
        choice=9
        continue
    fi
    choice=$(getCompChoice "${squares[@]}")
    squares[$choice]="$compToken"
    if checkBoard "$compToken" "${squares[@]}"; then
        printBoard "${squares[@]}"
        echo "You lose"
        exit 0
    fi
done
