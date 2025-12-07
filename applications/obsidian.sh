if [ ! -d $HOME/Applications ]; then
	echo "Creating a directory for appimages"
	mkdir $HOME/Applications
fi

if [ -f $HOME/Applications/obsidian.appimage ]; then
	echo "Obsidian is already installed. Do you want to update?"
	exit 0;
fi

echo "Installing Obsidian"
curl -fssL https://github.com/obsidianmd/obsidian-releases/releases/download/v1.7.7/Obsidian-1.7.7.AppImage -o $HOME/Applications/obsidian.appimage
chmod +x $HOME/Applications/obsidian.appimage

echo "Adding desktop entry"
