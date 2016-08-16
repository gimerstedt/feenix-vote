#!/bin/bash
wd="/home/ake1/vote"
source $wd/config.sh

function login_wow_one {
	curl \
		--silent \
		--request POST \
		--cookie-jar $wd/cookie \
		--data "username=$username" \
		--data "password=$password" \
		--data "submit=Login" \
		https://www.wow-one.com/account/login \
		&> /dev/null
}

function get_vote_status {
	curl \
		--silent \
		--cookie $wd/cookie \
		https://www.wow-one.com/vote \
		| grep \
		--before-context=1 \
		"Your IP has voted." \
		> $wd/votepage
	export has_voted_1=$(grep "xtremetop100" $wd/votepage)
	export has_voted_2=$(grep "topg" $wd/votepage)
	export has_voted_5=$(grep "arena100" $wd/votepage)
}

function vote {
	vote_no=$*
	sleep 10
	curl \
		--silent \
		--location \
		--cookie $wd/cookie \
		https://www.wow-one.com/vote/process/$vote_no \
		&> /dev/null
	echo "$(date +'%F %R:%S') - Voting: $vote_no" >> $wd/log
}

function log_attempt {
	echo "$(date +'%F %R:%S') - Not voting: $*" >> $wd/log
}

function clean_up {
	rm $wd/cookie $wd/votepage
}

function main {
	login_wow_one
	get_vote_status

	if [ -z "$has_voted_1" ]; then
		vote 1
	else
		log_attempt 1
	fi
	if [ -z "$has_voted_2" ]; then
		vote 2
	else
		log_attempt 2
	fi
	if [ -z "$has_voted_5" ]; then
		vote 5
	else
		log_attempt 5
	fi

	clean_up
}

main
