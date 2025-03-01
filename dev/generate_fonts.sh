raw_fonts_dir="raw"
proc_fonts_dir="prod"
all_fonts=1
temp_dir=`mktemp --directory`
parent_path=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )

## Hard-code the date to 0 to ensure that the output is deterministic.
## If this is not set, the output will be different each time the script is run even if nothing changes,
## which will massively inflate the size of the Git repository.
## See: https://reproducible-builds.org/docs/source-date-epoch/
## https://github.com/fontforge/fontforge/pull/2943
export SOURCE_DATE_EPOCH=0

LATINBASE=$(cat "$parent_path/charSetLatinBase.txt")
LATINEXT=$(cat "$parent_path/charSetLatinExt.txt")
CYRILLIC=$(cat "$parent_path/charSetCyrillic.txt")
GREEK=$(cat "$parent_path/charSetGreek.txt")

mkdir -p "$proc_fonts_dir/latin"
mkdir -p "$proc_fonts_dir/all"

while IFS= read -r file || [[ -n "$file" ]];
do
    if [[ -f $file ]]; then
        filename=$(basename "$file")
        filename_without_extension="${filename%.*}"
        filename_proc=$filename_without_extension.woff
        file_proc_latin=$proc_fonts_dir/latin/$filename_proc
        file_proc_all=$proc_fonts_dir/all/$filename_proc
        file_temp1=$temp_dir/$filename_without_extension.1.otf
        file_temp2_latin=$temp_dir/$filename_without_extension.latin.otf
        file_temp2_all=$temp_dir/$filename_without_extension.all.otf

        ## If `all_fonts` option is 0, only fonts not already in the output directory are processed.
        # if [[ ! -e "$processed_fonts_dir/$filename" || "$all_fonts" = 1]]; then
        if [[ ! -e "$file_proc_latin" || "$all_fonts" = 1 ]]; then
            ## Convert to .otf
            fontforge -quiet -lang=ff -c 'Open($1); Generate($2)' $file $file_temp1

            ## Subset font to contain only desired characters
            ## The --no-layout-closure option prevents ligatures from being automatically included when all the individual characters are
            hb-subset --no-layout-closure --output-file="$file_temp2_latin" --text="$LATINBASE$LATINEXT" "$file_temp1"
            hb-subset --no-layout-closure --output-file="$file_temp2_all" --text="$LATINBASE$LATINEXT$CYRILLIC$GREEK" "$file_temp1"

            ## For now, ligatures need to be included. 
            ## Ligatures are not removed when rendering to canvas, so if the font does not have them the metrics will not be correct.
            # hb-subset --output-file="$file_temp2" --text-file=dev/charSet.txt "$file_temp1"
            python dev/processFont.py "$file_temp2_latin" "$file_proc_latin"
            python dev/processFont.py "$file_temp2_all" "$file_proc_all"

        fi
    else
        echo "File not found: $file"
    fi
done < "dev/fontList.txt"

## Standardize font names to match [family]-[style].woff, as expected in the application.
mv prod/all/P052-Roman.woff prod/all/Palatino-Regular.woff
mv prod/all/P052-Italic.woff prod/all/Palatino-Italic.woff
mv prod/all/P052-Bold.woff prod/all/Palatino-Bold.woff
mv prod/all/P052-BoldItalic.woff prod/all/Palatino-BoldItalic.woff
mv prod/latin/P052-Roman.woff prod/latin/Palatino-Regular.woff
mv prod/latin/P052-Italic.woff prod/latin/Palatino-Italic.woff
mv prod/latin/P052-Bold.woff prod/latin/Palatino-Bold.woff
mv prod/latin/P052-BoldItalic.woff prod/latin/Palatino-BoldItalic.woff

mv prod/all/EBGaramond-Regular.woff prod/all/Garamond-Regular.woff
mv prod/all/EBGaramond-Italic.woff prod/all/Garamond-Italic.woff
mv prod/all/EBGaramond-Bold.woff prod/all/Garamond-Bold.woff
mv prod/all/EBGaramond-BoldItalic.woff prod/all/Garamond-BoldItalic.woff
mv prod/latin/EBGaramond-Regular.woff prod/latin/Garamond-Regular.woff
mv prod/latin/EBGaramond-Italic.woff prod/latin/Garamond-Italic.woff
mv prod/latin/EBGaramond-Bold.woff prod/latin/Garamond-Bold.woff
mv prod/latin/EBGaramond-BoldItalic.woff prod/latin/Garamond-BoldItalic.woff

mv prod/all/C059-Roman.woff prod/all/Century-Regular.woff
mv prod/all/C059-Italic.woff prod/all/Century-Italic.woff
mv prod/all/C059-Bold.woff prod/all/Century-Bold.woff
mv prod/all/C059-BdIta.woff prod/all/Century-BoldItalic.woff
mv prod/latin/C059-Roman.woff prod/latin/Century-Regular.woff
mv prod/latin/C059-Italic.woff prod/latin/Century-Italic.woff
mv prod/latin/C059-Bold.woff prod/latin/Century-Bold.woff
mv prod/latin/C059-BdIta.woff prod/latin/Century-BoldItalic.woff

mv prod/all/NimbusMonoPS-Regular.woff prod/all/NimbusMono-Regular.woff
mv prod/all/NimbusMonoPS-Italic.woff prod/all/NimbusMono-Italic.woff
mv prod/all/NimbusMonoPS-Bold.woff prod/all/NimbusMono-Bold.woff
mv prod/all/NimbusMonoPS-BoldItalic.woff prod/all/NimbusMono-BoldItalic.woff
mv prod/latin/NimbusMonoPS-Regular.woff prod/latin/NimbusMono-Regular.woff
mv prod/latin/NimbusMonoPS-Italic.woff prod/latin/NimbusMono-Italic.woff
mv prod/latin/NimbusMonoPS-Bold.woff prod/latin/NimbusMono-Bold.woff
mv prod/latin/NimbusMonoPS-BoldItalic.woff prod/latin/NimbusMono-BoldItalic.woff

rm -rf "$temp_dir"
