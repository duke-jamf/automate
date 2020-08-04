#!/bin/sh

# Set up variables
ROOTPATH=`dirname "$0"`
SCRIPTS="$ROOTPATH/scripts/src"
DEFINITIONS="$ROOTPATH/definitions/src"

# Require sudo immediately
echo "Gathering permission..."
sudo echo "	PASS!"

# Check for Homebrew
if [ ! "`which brew`" ]; then
    echo "ERROR: Homebrew not found!"
    exit 2
fi

# Check for CLI tools
if [ ! "`which git`" ]; then
    echo "ERROR: Xcode CLI tools not found!"
    exit 3
fi

# Verify or clone Definitions
if [ ! -d "$DEFINITIONS" ]; then
	echo "Cloning Definitions from source..."
	git clone https://github.com/duke-jamf/definitions.git "$ROOTPATH/definitions"
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo "Unable to locate Definitions!"
		exit $RESULT
	fi
fi

# Verify or clone Scripts
if [ ! -d "$SCRIPTS" ]; then
	echo "Cloning Scripts from source..."
	git clone https://github.com/duke-jamf/scripts.git "$ROOTPATH/scripts"
	RESULT=$?
	if [ $RESULT -ne 0 ]; then
		echo "Unable to locate Scripts!"
		exit $RESULT
	fi
fi

# Make sure the working directory is available
DIR=`pwd`/automate
mkdir -p "$DIR"

# Start a new log file
LOG="$DIR/results.log"
date > "$LOG"

# Go through each definition
for DEFINITION in "$DEFINITIONS"/*; do
	# Check if this package needs building/updating
	printf "Checking definition at $DEFINITION... "
	STATUS=`"$SCRIPTS/check-cask" "$DEFINITION"`
	echo "	$STATUS"
	if [ "$STATUS" != "current" ]; then
		# Try building it
		"$SCRIPTS/build" "$DEFINITION"
		RESULT=$?
		if [ $RESULT -ne 0 ]; then
			echo "Build failed for definition: $DEFINITION"

			# Log the failure
			echo "failed: $DEFINITION" >> "$LOG"

		# If build succeeded then try verifying
		else
			PKGNAME=`tail -n 1 "$DEFINITION/.manifest"`

			sudo "$SCRIPTS/verify" "$DEFINITION"
			RESULT=$?
			if [ $RESULT -ne 0 ]; then
				echo "unverified: $PKGNAME" >> "$LOG"
				echo "Verification failed for definition: $DEFINITION"

			# If verification succeeded then harvest the package
			else
				mv "$DEFINITION/$PKGNAME" "$DIR/"
				
				# Log the package name
				echo "$STATUS: $PKGNAME" >> "$LOG"
			fi
		fi		
	fi
done

echo "Automation complete"
exit 0
