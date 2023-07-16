set -o xtrace

rm -r venv

python3 -m venv venv

source venv/bin/activate

curl https://pythonify.util.repl.co/linkify.py -o linkify.py

# Install Pip
git clone https://github.com/replit/pip.git /tmp/pip
rm -r venv/lib/python3.10/site-packages/pip
cp -r /tmp/pip/src/pip venv/lib/python3.10/site-packages/pip
python3 linkify.py
python3 -m compileall -f -r 999 venv/lib/python3.10/site-packages/pip
rm -fr /tmp/pip
rm venv/bin/pip
curl https://pythonify.util.repl.co/pipbin -o venv/bin/pip
chmod u+x venv/bin/pip

# Install Poetry
pip install poetry==1.1.11
git clone https://github.com/replit/poetry.git /tmp/poetry
cd /tmp/poetry
POETRY_FILES=$(git diff 1.1.11 --name-only -- poetry)
for file in $POETRY_FILES
do
    DEST_FILE="$HOME/$REPL_SLUG/venv/lib/python3.10/site-packages/${file#"src/"}"
    unlink $DEST_FILE
    cp /tmp/poetry/${file} $DEST_FILE
done
cd - 
python3 -m compileall -f -r 999 venv/lib/python3.10/site-packages/poetry
rm -fr /tmp/poetry

# Clean up
rm linkify.py

# Install custom python3 script which will have the LD_LIBRARY_PATH set
# for important C libraries as defined in replit.nix
unlink venv/bin/python3
curl https://pythonify.util.repl.co/python3script -o venv/bin/python3
chmod u+x venv/bin/python3
ln -s $HOME/$REPL_SLUG/venv/bin/python3 venv/bin/python3.10

#poetry install

