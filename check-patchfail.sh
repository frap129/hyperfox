set -e

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





echo "Removing '$tmpdir'..."
rm -rf $tmpdir
mkdir $tmpdir
cd $tmpdir
echo "Extracting '$firefox'..."
tar xf ../$firefox
cd firefox-$(cat ../version)

echo ""
echo "Testing patches..."
echo ""
for i in $(cat ../../assets/patches.txt); do
    echo $i:
    patch -p1 -i ../../$i
    patch -R -p1 -i ../../$i
done

cd ../..
echo "Removing '$tmpdir'..."
rm -rf $tmpdir

echo ""
echo "All patches succeeded."
exit 0
