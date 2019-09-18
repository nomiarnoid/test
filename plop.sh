#!/bin/sh

## first test : develop is ahead master, hotfix applied to master, then rebase develop on master
# First lets make develop ahead master
git checkout develop
echo "develop world" > test2
git add .
git commit -m 'This commit makes develop ahead master' --no-edit
git push origin develop

# Now create hotfix
git checkout master
git checkout -b hotfix/my-hotfix
echo "bye world" > test
git add .
git commit -m 'This is the commit from my hotfix' --no-edit
git push origin hotfix/my-hotfix

# Merge hotfix in master and delete hotfix
git checkout master
git merge hotfix/my-hotfix --no-edit
git branch -D hotfix/my-hotfix

# Retrieve hotfix on develop by rebasing
git checkout develop
git rebase master # No problem here. Conflict will happen if and only if the same lines are modified, just like for any other rebase
git push origin develop --force-with-lease

## Now another thing : lets merge hotfix in master AND develop
git checkout master
git checkout -b hotfix/my-hotfix
echo "hallo munde" > test
git add .
git commit -m 'This is the commit from my hotfix' --no-edit
git checkout master
git merge hotfix/my-hotfix --no-edit # hotfix is now on master
git checkout develop
git merge hotfix/my-hotfix --no-edit # hotfix is also now on develop
git checkout master
git branch -D hotfix/my-hotfix
git merge develop --no-edit # No conflict here, commit is the same

## One last thing : cherry-pick
git checkout master
echo "hola que tal" > test
git add .
git commit -m 'Master is above develop, this commit will be cherry picked' --no-edit
commit="$(git rev-parse HEAD)"
git checkout develop
git cherry-pick $commit
git checkout master
git merge develop --no-edit # No conflict here again, commit is the same

exit

# clean
cd ..
rm -Rf test
