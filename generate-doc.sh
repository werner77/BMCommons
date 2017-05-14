OUTPUT_DIR="./build"

mkdir -p "$OUTPUT_DIR"
mkdir -p "/tmp/doc-templates"

SOURCE_PATHS=""
MODULES="BMCore BMUICore BMUIExtensions BMMedia BMGoogle BMYouTube BMXML BMLocation BMCoreData BMRestKit"

for MODULE_NAME in $MODULES
do

Bin/ClassOverviewGenerator -h "__${MODULE_NAME} Classes__\n" -i ./BMCommons/Modules/${MODULE_NAME}/Sources/Classes "/tmp/doc-templates/${MODULE_NAME}ClassesOverview-template.md"
SOURCE_PATHS="$SOURCE_PATHS ./BMCommons/Modules/${MODULE_NAME}/Sources/Classes"

done

appledoc \
--project-name BMCommons \
--project-company "BehindMedia" \
--company-id com.behindmedia \
--keep-undocumented-objects \
--keep-undocumented-members \
--logformat xcode \
--exit-threshold 2 \
--no-repeat-first-par \
--ignore *_Private.h \
--ignore .m \
--include "/tmp/doc-templates" \
--include ./Documentation/Templates \
--index-desc ./Documentation/index.md \
--output "$OUTPUT_DIR" \
--keep-intermediate-files \
--no-warn-undocumented-object \
--no-warn-undocumented-member \
--no-warn-missing-arg \
--no-warn-empty-description \
--clean-output \
--create-html \
$SOURCE_PATHS

rm -rf "/tmp/doc-templates"

