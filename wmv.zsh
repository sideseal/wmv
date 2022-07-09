#!/usr/bin/env zsh


function wmv {
	UP='\[A'
	DOWN='\[B'
	RIGHT='\[C'
	LEFT='\[D'

	echo "프로그램을 종료하시려면 ESC를 세 번 눌러주세요."

	key_input() {
		local key
		IFS=''
		ESC=$( printf "\033" )

		for ((i=0; i<3; ++i)); do
			read -s -k 1 input 2>/dev/null >&2
			tmp+="$input"
			if [ $input -eq 0 ]; then echo ENTER; return;
			elif [[ ! $input = $ESC && i -eq 0 ]]; then return; fi;
		done

		key=$(echo $tmp)

		if [[ $key = $'\C-[[A' ]]; then echo UP; fi;
		if [[ $key = $'\C-[[B' ]]; then echo DOWN; fi;
		if [[ $key = $'\C-[[C' ]]; then echo RIGHT; fi;
		if [[ $key = $'\C-[[D' ]]; then echo LEFT; fi;
		if [[ $key =~ $ESC$ ]] then echo ESC; fi;
	} 2>/dev/null

	app_name="$1"
	app_size="$2"

	move_up() {
 		local horizontal=`echo "1440*$app_size" | bc`
		osascript <<-EOF
			set argv to {"$app_name", "$horizontal"}
			set horizontal to (item 2 of argv) as number

			tell application (quoted form of item 1 of argv)
				set bounds of window 1 to {0, 0, 2560, horizontal}
			end tell
		EOF
	}
	move_down() {
 		local horizontal=`echo "1440-1440*$app_size" | bc`
		osascript <<-EOF
			set argv to {"$app_name", "$horizontal"}
			set horizontal to (item 2 of argv) as number

			tell application (quoted form of item 1 of argv)
				set bounds of window 1 to {0, horizontal, 2560, 1440}
			end tell
		EOF
	}
	move_right() {
 		local vertical=`echo "2560-2560*$app_size" | bc`
		osascript <<-EOF
			set argv to {"$app_name", "$vertical"}
			set vertical to (item 2 of argv) as number

			tell application (quoted form of item 1 of argv)
				set bounds of window 1 to {vertical, 0, 2560, 1440}
			end tell
		EOF
	}
	move_left() {
 		local vertical=`echo "2560*$app_size" | bc`
		osascript <<-EOF
			set argv to {"$app_name", "$vertical"}
			set vertical to (item 2 of argv) as number

			tell application (quoted form of item 1 of argv)
				set bounds of window 1 to {0, 0, vertical, 1440}
			end tell
		EOF
	}
	full_screen() {
		osascript \
		-e "on run (argv)" \
		-e "tell application (quoted form of item 1 of argv) to set bounds of window 1 to {0, 0, 2560, 1440}" \
		-e "end" \
		-- "$app_name"
	}

	while true; do
	local selected=$(key_input)
		case $selected in
			UP) move_up;;
			DOWN) move_down;;
			RIGHT) move_right;;
			LEFT) move_left;;
			ENTER) full_screen;;
			ESC) echo "프로그램 종료."; exit 0
		esac
	done
}

function validate_size {
	local size=`echo "$1" | bc`

	if [[ $size -gt 0 ]]; then
		echo "1보다 작은 분수를 입력해주세요. 의도하지 않은 결과가 나올 수 있습니다."
		return 1 # false
	fi
	return 0 # true
}

if [[ $# -eq 2 ]]; then
	if [[ "$2" =~ ^[1-9][0-9]*\/[1-9][0-9]*$ ]]; then
		if validate_size "$2"; then wmv "$1" "$2"; else exit 1; fi
	else
		echo '올바른 분수를 입력해주세요.'
	fi
	exit 0
elif [[ $# -gt 2 ]]; then
	echo '이 스크립트는 두 개의 인자를 갖습니다. 프로그램의 이름을 따옴표로 감쌌는지 확인해보세요.'.
	exit 1
else
	echo '창 크기를 바꾸고자 하는 프로그램의 이름과 비율(분수)를 입력해주세요.'
	exit 1
fi
