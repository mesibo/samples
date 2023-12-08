# this will move master to temporary brancn, delete master and then rename temp to master
# https://xebia.com/blog/deleting-your-commit-history/

if [[ $# -eq 0 ]] ; then
    echo "usage: git_clean.sh <comment>"
    exit 1
fi

if [ -z "$1" ]; then
    echo "usage: git_clean.sh <comment>"
    exit 1
fi


# Step 1: Check out to a temporary branch
git checkout --orphan temp_branch
#Step 2/2: Add all files
git add -A
git commit -m "v2"
#Step 4: Delete the main branch
git branch -D master
# Step 5: Rename the temporary branch to main
git branch -m master
# Step 6: Force update to our repository
git push --force origin master

# OPTIONAL - doing since later we may need to do for first commit
git push --set-upstream origin master


