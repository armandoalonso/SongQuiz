import os
import json
import subprocess
import uuid

# Read the playlist URLs from the JSON file
with open('playlist_data.json', 'r') as f:
    playlist_data = json.load(f)

    # Create folder with playlist name with no spaces, using os libaray, to lower case
    for item in playlist_data["data"]:
        os.mkdir(item['name'].replace(' ', '_').lower())

    # Loop over the playlist URLs and download each playlist
    for item in playlist_data["data"]:
        # Run the yt-dlp command to download the playlist to the correct playlist folder
        subprocess.run(["yt-dlp", "-x", "--audio-format", "mp3", "--output", f"{item['name'].replace(' ', '_')}/%(title)s.%(ext)s", "https://www.youtube.com/playlist?list="+item["id"]])

    with open(f"{item['name'].replace(' ', '_').lower()}.json", 'w') as w:
        song_data ={}
        # Loop over files in the playlist folder and add them to the JSON file
        for file in os.listdir(item['name'].replace(' ', '_').lower()):
            # generate random uuid for each song
            song_id = str(uuid.uuid4())
            # add song id as key and song name as value
            song_data[song_id] = "res://resources/playlists/" + item['name'].replace(' ', '_').lower() + "/" + file
        
        # write song data to json file
        json.dump(song_data, w, indent=4)