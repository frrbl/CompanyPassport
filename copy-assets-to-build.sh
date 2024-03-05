# This script is called by GitHub Actions to copy the non-plantuml assets in the /assets directory to the /static directory in the build directory.

find ./assets -type f ! -name '*.puml' -exec cp {} ./docs/_site/assets/img/ \;