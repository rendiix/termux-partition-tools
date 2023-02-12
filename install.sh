#!/data/data/com.termux/files/usr/bin/bash

_update(){
apt-get update
apt-get  --assume-yes upgrade
apt-get  --assume-yes install coreutils gnupg wget ncurses*
}

_update > /dev/null 2>&1

function _time_counter() {
	pid=$1
	tput civis
	let start_time="$(($(date +%s%N)/1000000))"
	while kill -0 $pid 2>/dev/null; do
		let current_time="$(($(date +%s%N)/1000000))"
		let milidetik=$current_time-$start_time;
		printf "\r\033[37m[\033[32m%02d:%02d:%003d\033[37m] \033[36m${_message}\033[00m " "$((milidetik/60000%60))" "$((milidetik/1000%60))" "$((milidetik%1000))"
	done
	wait $pid
}

function t() {
	if [ "$1" = 0 ]; then
		shift 1
		_message=$*
	else
		_message=$1
		shift 1
	fi
	(sleep 1; "$@") &
	_time_counter $!
	local _status=$?
	case $_status in
		0)
			echo -e "\033[32m✔ done\033[00m";;
		*)
			echo -e "\033[31m✘ error\033[00m";;
	esac
}


_write_source_list(){
[ ! -d $PREFIX/etc/apt/sources.list.d ] && mkdir $PREFIX/etc/apt/sources.list.d
echo "deb https://rendiix.github.io android-tools termux" > $PREFIX/etc/apt/sources.list.d/rendiix.list
}

_install_key(){
	wget https://rendiix.github.io/rendiix.gpg -q --show-progress
	apt-key add rendiix.gpg
	apt-get update
}

_install_packages(){
	apt-get --assume-yes install android-partition-tools
}

t _write_source_list
t _install_key
t _install_packages

rm rendiix.gpg

