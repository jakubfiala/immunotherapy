#!/usr/bin/env bash
set -o errexit
set -o nounset

if [[ -z `which pip` ]];
then
  echo "No Python installation found; Install Python and pip first."
  exit 1
fi

if [[ -z `which aws` ]];
then
  echo "No AWS CLI found. Installing with pip."
  sudo pip install awscli
  echo "Creating AWS config directory."
  mkdir -p ~/.aws
  echo "Configuring profile 'climato_polly'"
  cat ./config >> ~/.aws/config
  echo "Installing credentials for profile 'climato_polly'."
  cat ./credentials >> ~/.aws/credentials
fi

echo "Polly is ready!"
read -p "What would you like to say? " text
read -p "Great. Which voice would you like to use? (type '?' for a list of available voices) " voice

if [[ $voice == "?" ]];
then
  aws polly describe-voices \
    --profile climato_polly \
    --region eu-west-1 \
    --output text \
    | grep "VOICES"
  read -p "These are the available voices. Which one would you like to use? Just type the person's name. " voice
fi

temp_output="polly_temp_output.mp3"

function cleanup() {
  rm -f $temp_output
}

trap cleanup EXIT

aws polly synthesize-speech \
  --profile climato_polly \
  --region eu-west-1 \
  --output text \
  --text-type ssml \
  --text "<speak>$text</speak>" \
  --output-format mp3 \
  --voice-id "$voice" \
  $temp_output

read -p "Would you like to play the sound immediately? [y=yes, n=no] " play_now

if [[ $play_now == "y" ]];
then
  if [[ -z `which afplay` ]];
  then
    # we're probably on Linux
    if [[ ! -z `which ffplay` ]];
    then
      ffplay $temp_output -nodisp -autoexit
    else
      echo "Linux: Could not find ffplay. Please install ffmpeg first."
    fi
  else
    # we're on Mac
    afplay $temp_output
  fi

  read -p "Would you also like to save this recording? [y=yes, n=no] " save_after_play

  if [[ $save_after_play == "y" ]];
  then
    read -p "What should be the name of the recording file? " output_file
    mv $temp_output $output_file
  fi
else
  read -p "What should be the name of the recording file? " output_file
  mv $temp_output $output_file
fi

