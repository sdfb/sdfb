rake assets:precompile
git add .
echo "Please enter a commit message: "
read msg
git commit -m msg
git push
heroku git:remote -a sixdegfrancisbacon
git push heroku master