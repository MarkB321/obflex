
export REPO="/Users/markbranion/Desktop/Sandbox/fresenius-iphone/"
find $REPO -name '*.m' -exec cat {} \; > BIG.m
uncrustify -c config.txt BIG.m 
mv BIG.m.uncrustify objc.flexible/BIG.m
cd objc.flexible/
export REPO="/Users/markbranion/Desktop/Sandbox/flexible/objc.flexible"
./run.objc  > X.html 

