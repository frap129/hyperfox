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

echo "[debug] firefox file = '$firefox'"
echo "[debug] tmpdir = '$tmpdir'"
echo ""







rm -rf $tmpdir
mkdir $tmpdir
cd $tmpdir
tar xf ../$firefox
cd firefox-$(cat ../version)

for i in $(cat assets/patches.txt); do
    echo $i:
    patch -p1 -i ../../$i
    patch -R -p1 -i ../../$i
done

cd ../..
rm -rf $tmpdir

echo ""
echo "check-patchfail.sh: All patches succeeded."
exit 0
