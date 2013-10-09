rm -rf lib
coffee -cbo lib/ src/

component build -s throws -o . -n throws

coffee -cb src/ test/
browserify test/*.js > test/browser/tests.js
rm src/*.js test/*.js
