#!/usr/bin/env zsh


function wmv {
	UP='\[A'
	DOWN='\[B'
	RIGHT='\[C'
	LEFT='\[D'

	SUCCESS=0
	OTHER=65

	key_input() {
		local key
		for ((i=0; i<3; ++i)); do
			read -s -u 0 -k 1 input 2>/dev/null >&2
			tmp+="$input"
			if [[ ! $input = $'\033' && i -eq 0 ]]; then
				return
			fi
		done
		key=$(echo $tmp | tr -d '\n')

		if [[ $key = $'\C-[[A' ]]; then echo UP; fi;
		if [[ $key = $'\C-[[B' ]]; then echo DOWN; fi;
		if [[ $key = $'\C-[[C' ]]; then echo RIGHT; fi;
		if [[ $key = $'\C-[[D' ]]; then echo LEFT; fi;
	}

	app_name="$1"

	move_up() {
		osascript \
		-e "on run (argv)" \
		-e "tell application (quoted form of item 1 of argv) to set bounds of window 1 to {0, 0, 2560, 720}" \
		-e "end" \
		-- "$app_name"
	}
	move_down() {
		osascript \
		-e "on run (argv)" \
		-e "tell application (quoted form of item 1 of argv) to set bounds of window 1 to {0, 720, 2560, 1440}" \
		-e "end" \
		-- "$app_name"
	}
	move_right() {
		osascript \
		-e "on run (argv)" \
		-e "tell application (quoted form of item 1 of argv) to set bounds of window 1 to {1280, 0, 2560, 1440}" \
		-e "end" \
		-- "$app_name"
	}
	move_left() {
		osascript \
		-e "on run (argv)" \
		-e "tell application (quoted form of item 1 of argv) to set bounds of window 1 to {0, 0, 1280, 1440}" \
		-e "end" \
		-- "$app_name"
	}
# 	move_down() {
# 		osascript -e 'tell application \"$app_name\" to set bounds of window 1 to {0, 720, 2560, 1440}'
# 	}
# 	move_right() {
# 		osascript -e 'tell application \"$app_name\" to set bounds of window 1 to {1280, 0, 2560, 1440}'
# 	}
# 	move_left() {
# 		osascript -e 'tell application \"$app_name\" to set bounds of window 1 to {0, 0, 1280, 1440}'
# 	}

	while true; do
	local selected=$(key_input)
		case $selected in
			UP) move_up;;
			DOWN) move_down;;
			RIGHT) move_right;;
			LEFT) move_left;;
		esac
	done
}

if [[ $# -eq 2 ]]; then
	wmv "$1" "$2"
elif [[ $# -gt 2 ]]; then
	echo 'This program gets only 2 arguments. Please check a program name within "double quotes"'.
	exit 1
else
	echo 'Please write the site name and window size that you want to move.'
	exit 1
fi
