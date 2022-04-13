tmpdir="tmpdir92"

if [ ! -f version ]; then
    echo "error: 'version' does not exist. Are you in the right folder?"
    exit 1
fi
firefox=firefox-$(cat version).source.tar.xz
if [ ! -f "$firefox" ]; then
    echo "error: '$firefox' does not exist."
    exit 1
fi



failed_patches=

echo "Removing '$tmpdir'..."
rm -rf $tmpdir
mkdir $tmpdir
cd $tmpdir
echo "Extracting '$firefox'..."
tar xf ../$firefox
cd firefox-$(cat ../version)

echo ""
echo "Testing patches..."

for i in $(cat ../../assets/patches.txt); do
    echo ""
    echo "==> $i:"
    echo ""
    patch $* -p1 -i ../../$i > ../patch.tmp
    cat ../patch.tmp

    s=""
    for j in $(grep -n rej$ ../patch.tmp | awk '{ print $(NF); }'); do
	s="$s $j"
    done
    s=$s
    if [ ! -z "$s" ]; then
	s=$(echo $i)
	failed_patches="$failed_patches [$s]"
	echo ""
	for k in $s; do
	    echo "--> $s:"
	    cat $s
	done
    fi
    
    rm -f ../patch.tmp
    #patch -R -p1 -i ../../$i
done

cd ../..
echo ""
echo "Removing '$tmpdir'..."
rm -rf $tmpdir
echo ""

if [ ! -z "$failed_patches" ]; then
    echo $failed_patches
    echo ""
    echo "error: Some patches failed!"
    exit 1
else
    echo "success: All patches where applied successfully."
    exit 0
fi
