# Translating KittiesGtk

## New translation
To create a new translation start by creating a fork of this repository. Now fetch it localy.
First step done localy is generating an up to date template.
You can do this by executing these commands from inside of the project's directory:
```
meson setup build
cd build
meson compile kittiesgtk-pot
```
Now you can go to the `po` directory open the `kittiesgtk.pot` file and save it as `(your-language-code).po`, you can write the translation now.
Once you are done, add `(your-language-code)` to `po/LINGUAS`. MAKE SURE YOU KEEP THE LIST SORTED ALPHABETICALLY!!!

Push the `po/(your-language-code).po` and `po/LINGUAS` to your fork, and create a Pull Request labeled: `chore(i18n): Create (language) translation`.

## Updating translation
Make sure your fork is up to date, fetch the up to date fork.

Once again setup the build directory by running `meson setup build` in the project's directory.
Now you can go to the newly made build directory and run `meson compile kittiesgtk-pot && meson compile kittiesgtk-update-po`
Now edit your translation file, push the changed file to your fork, and create a Pull Request labeled: `chore(i18n): Update (language) translation`.

## Using GNOME Builder instead
In GNOME Builder, open the locally fetched repo. Now from the dropdown menu you can select Configure Project… from there go to Commands
and setup 2 commands, one for setting up the POT file and the other for updating PO files.
